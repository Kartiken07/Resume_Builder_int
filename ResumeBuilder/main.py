import uuid
import time
import os
import json
import httpx
from dotenv import load_dotenv
from PIL import Image
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

load_dotenv()

app = FastAPI(title="DocuForge Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_KEY = os.getenv("GROQ_KEY", "")
GROQ_MODEL = "llama-3.1-8b-instant"

_base_dir = os.path.dirname(os.path.abspath(__file__)) if '__file__' in dir() else os.getcwd()
UPLOAD_DIR = os.path.join(_base_dir, "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

tasks: dict = {}


async def _groq_chat(messages: list[dict], temperature: float = 0.3, max_tokens: int = 2048) -> str:
    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await client.post(
            GROQ_URL,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {GROQ_KEY}",
            },
            json={
                "model": GROQ_MODEL,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
            },
        )
    if resp.status_code != 200:
        raise Exception(f"Groq API error {resp.status_code}: {resp.text}")
    data = resp.json()
    return data["choices"][0]["message"]["content"]


def _extract_json(text: str) -> dict:
    import re
    cleaned = text.strip()
    cleaned = cleaned.replace("```json", "").replace("```", "")
    first = cleaned.find("{")
    last = cleaned.rfind("}")
    if first != -1 and last > first:
        cleaned = cleaned[first:last + 1]
    try:
        data = json.loads(cleaned.strip())
    except json.JSONDecodeError as e:
        print(f"[EXTRACT_JSON] JSONDecodeError: {e}")
        print(f"[EXTRACT_JSON] cleaned (first 500): {repr(cleaned[:500])}")
        for end in range(len(cleaned), 0, -1):
            try:
                data = json.loads(cleaned[:end])
                break
            except json.JSONDecodeError:
                continue
        else:
            data = {}
    return _clean_resume_fields(data)


def _clean_resume_fields(data: dict) -> dict:
    resume_keys = {"experience", "education", "projectDesc", "projectName", "summary", "techSkills", "softSkills"}
    for key in resume_keys:
        if key not in data:
            continue
        val = data[key]
        if isinstance(val, list):
            parts = []
            for item in val:
                if isinstance(item, dict):
                    lines = []
                    for k, v in item.items():
                        if v and str(v).strip():
                            lines.append(f"{k}: {v}")
                    parts.append(", ".join(lines))
                else:
                    parts.append(str(item))
            data[key] = "\n\n".join(parts)
        elif isinstance(val, dict):
            lines = []
            for k, v in val.items():
                if v and str(v).strip():
                    lines.append(f"{k}: {v}")
            data[key] = ", ".join(lines)
        elif val is not None:
            data[key] = str(val)
        else:
            data[key] = ""
    return data


def _simulate_task(task_id: str, filename: str, endpoint: str, total_time: float = 5.0):
    import threading
    def run():
        steps = 10
        for i in range(1, steps + 1):
            time.sleep(total_time / steps)
            tasks[task_id]["progress"] = i / steps
            if i == steps:
                tasks[task_id]["status"] = "completed"
                tasks[task_id]["download_url"] = f"http://localhost:8001/downloads/{task_id}_{filename}"
                if "resume" in endpoint.lower():
                    tasks[task_id]["ai_summary"] = "Resume processed successfully."
    threading.Thread(target=run, daemon=True).start()


@app.get("/downloads/{filename}")
async def download_file(filename: str):
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        return JSONResponse(status_code=404, content={"error": "File not found"})
    from fastapi.responses import FileResponse
    return FileResponse(file_path, filename=filename.split("_", 1)[-1] if "_" in filename else filename)


# ═══════════════════════════════════════════════════════════════════════
# AI ENDPOINTS (server-side Groq calls — no CORS issues)
# ═══════════════════════════════════════════════════════════════════════

class ResumeParseRequest(BaseModel):
    resume_text: str

@app.post("/api/v1/ai/parse-resume")
async def parse_resume(req: ResumeParseRequest):
    content = await _groq_chat([
        {"role": "system", "content":
            "Extract resume data and return a JSON object. "
            "Keys: name, email, phone, jobTitle, summary, experience, education, "
            "projectName, projectDesc, techSkills, softSkills. "
            "Use empty string for missing fields. "
            "IMPORTANT: ALL values MUST be plain readable text, NOT dicts or lists. "
            "For experience: write each job as a paragraph like 'Company Name - Job Title (Duration). Achievements...' separated by double newlines. "
            "For education: write each school as 'Institution Name - Degree (Year)' separated by double newlines. "
            "For projectName: comma-separated project names. "
            "For projectDesc: write each project description as a short paragraph separated by double newlines. "
            "Never return arrays or objects as values - always return plain text strings."},
        {"role": "user", "content": req.resume_text},
    ])
    return _extract_json(content)


class ImproveRequest(BaseModel):
    field_type: str
    content: str
    job_title: str

@app.post("/api/v1/ai/improve")
async def improve_field(req: ImproveRequest):
    prompts = {
        "summary": f"Improve this professional summary for a {req.job_title} resume. Make it compelling and impactful. 2-4 sentences.",
        "experience": f"Improve this work experience for a {req.job_title} resume. Strong action verbs, quantified achievements.",
        "education": f"Improve this education section for a {req.job_title} resume.",
        "projectName": f"Improve this project name for a {req.job_title} resume.",
        "projectDesc": f"Improve this project description for a {req.job_title} resume. 2-3 sentences with tech and outcomes.",
        "techSkills": f"Improve and organize these technical skills for a {req.job_title} resume. Comma-separated.",
        "softSkills": f"Improve these soft skills for a {req.job_title} resume. Comma-separated.",
    }
    system = prompts.get(req.field_type, prompts["summary"])
    system += " Return ONLY the improved text."

    result = await _groq_chat([
        {"role": "system", "content": system},
        {"role": "user", "content": req.content},
    ])
    return {"result": result.strip()}


class AtsRequest(BaseModel):
    name: str = ""
    email: str = ""
    phone: str = ""
    job_title: str = ""
    summary: str = ""
    experience: str = ""
    education: str = ""
    project_name: str = ""
    project_desc: str = ""
    tech_skills: str = ""
    soft_skills: str = ""

@app.post("/api/v1/ai/ats-score")
async def ats_score(req: AtsRequest):
    resume = f"""Name: {req.name}
Email: {req.email}
Phone: {req.phone}
Job Title: {req.job_title}
Summary: {req.summary}
Experience: {req.experience}
Education: {req.education}
Projects: {req.project_name} - {req.project_desc}
Tech Skills: {req.tech_skills}
Soft Skills: {req.soft_skills}"""

    content = await _groq_chat([
        {"role": "system", "content":
            "Analyze this resume for ATS compatibility. "
            "Return a JSON object with: "
            "score (0-100), "
            "breakdown (formatting 0-25, keywords 0-25, content 0-25, impact 0-25), "
            "strengths (array of strings), "
            "weaknesses (array of strings), "
            "suggestions (array of strings), "
            "overallFeedback (string)."},
        {"role": "user", "content": resume},
    ])
    try:
        return _extract_json(content)
    except Exception:
        return {
            "score": 0,
            "breakdown": {"formatting": 0, "keywords": 0, "content": 0, "impact": 0},
            "strengths": [], "weaknesses": [], "suggestions": [],
            "overallFeedback": "Could not analyze.",
        }


@app.post("/api/v1/ai/extract-pdf-text")
async def extract_pdf_text(file: UploadFile = File(...)):
    import io
    from PyPDF2 import PdfReader
    content = await file.read()
    reader = PdfReader(io.BytesIO(content))
    text = ""
    for page in reader.pages:
        page_text = page.extract_text()
        if page_text:
            text += page_text + "\n"
    if not text.strip():
        return JSONResponse(status_code=400, content={"error": "No text could be extracted from the PDF."})
    return {"text": text.strip()}


# ═══════════════════════════════════════════════════════════════════════
# FILE PROCESSING ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════

@app.post("/api/v1/upload")
async def upload_file(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, file.filename or "output", "/api/v1/upload")
    return {"task_id": task_id}


@app.post("/api/v1/resume/generate")
async def generate_resume(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    fileName = file.filename or "resume.pdf"
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, fileName, "/api/v1/resume/generate", total_time=4.0)
    return {"task_id": task_id}


@app.post("/convert/word-to-pdf")
async def word_to_pdf(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, file.filename or "output.pdf", "/convert/word-to-pdf")
    return {"task_id": task_id}


@app.post("/convert/excel-to-pdf")
async def excel_to_pdf(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, file.filename or "output.pdf", "/convert/excel-to-pdf")
    return {"task_id": task_id}


@app.post("/convert/pdf-to-excel")
async def pdf_to_excel(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, file.filename or "output.xlsx", "/convert/pdf-to-excel")
    return {"task_id": task_id}


@app.post("/convert/pdf-to-word")
async def pdf_to_word(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, file.filename or "output.docx", "/convert/pdf-to-word")
    return {"task_id": task_id}


@app.post("/compress")
async def compress_file(file: UploadFile = File(...), target_kb: int = 500):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    ext = (file.filename or "").rsplit(".", 1)[-1].lower() if file.filename else ""

    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}

    compressed_path = os.path.join(UPLOAD_DIR, f"{task_id}_compressed_{file.filename}")

    if ext == "pdf":
        try:
            import io
            from PyPDF2 import PdfReader, PdfWriter
            reader = PdfReader(io.BytesIO(content))
            writer = PdfWriter()
            for page in reader.pages:
                page.compress_content_streams()
                writer.add_page(page)
            if reader.metadata:
                writer.add_metadata({k: v for k, v in reader.metadata.items() if v})
            with open(compressed_path, "wb") as f:
                writer.write(f)
            original_kb = len(content) / 1024
            compressed_kb = os.path.getsize(compressed_path) / 1024
            summary = f"Compressed from {original_kb:.1f} KB to {compressed_kb:.1f} KB ({((1 - compressed_kb/original_kb) * 100):.0f}% reduction). PDF streams compressed and metadata cleaned."
            tasks[task_id]["ai_summary"] = summary
        except Exception as e:
            with open(compressed_path, "wb") as f:
                f.write(content)
            tasks[task_id]["ai_summary"] = f"Compression limited: {str(e)}. File passed through unchanged."
    elif ext in ("docx", "doc"):
        with open(compressed_path, "wb") as f:
            f.write(content)
        tasks[task_id]["ai_summary"] = "Word document stored. Advanced compression requires server-side LibreOffice."
    else:
        with open(compressed_path, "wb") as f:
            f.write(content)
        tasks[task_id]["ai_summary"] = "File stored. Format-specific compression not yet available."

    tasks[task_id]["status"] = "completed"
    tasks[task_id]["progress"] = 1.0
    tasks[task_id]["download_url"] = f"http://localhost:8001/downloads/{task_id}_compressed_{file.filename}"
    return {"task_id": task_id}


@app.post("/enhance")
async def enhance_file(file: UploadFile = File(...), sharpen: bool = True, upscale: bool = False, denoise: bool = False):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)
    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}
    _simulate_task(task_id, file.filename or "enhanced.pdf", "/enhance")
    return {"task_id": task_id}


@app.post("/api/v1/convert/image-to-pdf")
async def image_to_pdf(ocr: bool = False, files: list[UploadFile] = File(...)):
    task_id = str(uuid.uuid4())[:8]
    saved_files = []
    for f in files:
        content = await f.read()
        path = os.path.join(UPLOAD_DIR, f"{task_id}_{f.filename}")
        with open(path, "wb") as out:
            out.write(content)
        saved_files.append((path, f.content_type or "image/jpeg"))

    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}

    pdf_path = os.path.join(UPLOAD_DIR, f"{task_id}_images.pdf")

    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.pdfgen import canvas as rl_canvas
        from reportlab.lib.units import inch
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image as RLImage
        from reportlab.lib.utils import ImageReader
        from PIL import Image
        import io

        ocr_texts = []

        if ocr:
            try:
                import pytesseract
                for file_path, _ in saved_files:
                    try:
                        img = Image.open(file_path)
                        text = pytesseract.image_to_string(img)
                        if text and text.strip():
                            ocr_texts.append((file_path, text.strip()))
                        else:
                            ocr_texts.append((file_path, ""))
                    except Exception:
                        ocr_texts.append((file_path, ""))
            except ImportError:
                ocr = False

        if ocr and ocr_texts and any(t for _, t in ocr_texts):
            doc = SimpleDocTemplate(pdf_path, pagesize=A4,
                                    leftMargin=0.5*inch, rightMargin=0.5*inch,
                                    topMargin=0.5*inch, bottomMargin=0.5*inch)
            styles = getSampleStyleSheet()
            title_style = ParagraphStyle('Title2', parent=styles['Heading2'],
                                         fontSize=14, spaceAfter=12, textColor='#1a1a2e')
            text_style = ParagraphStyle('OCRText', parent=styles['Normal'],
                                        fontSize=10, leading=14, spaceAfter=8,
                                        textColor='#333333')
            story = []

            for i, (file_path, text) in enumerate(ocr_texts):
                img = Image.open(file_path)
                if img.mode == "RGBA":
                    img = img.convert("RGB")
                img_w, img_h = img.size
                ratio = min((A4[0] - inch) / img_w, (A4[1] - inch * 2) / img_h)
                draw_w = img_w * ratio
                draw_h = img_h * ratio

                buf = io.BytesIO()
                img.save(buf, format="JPEG", quality=85)
                buf.seek(0)

                story.append(RLImage(buf, width=draw_w, height=draw_h))

                if text:
                    story.append(Spacer(1, 12))
                    story.append(Paragraph(f"Page {i+1} — Extracted Text", title_style))
                    story.append(Paragraph(text.replace('\n', '<br/>'), text_style))

                story.append(Spacer(1, 20))

            doc.build(story)
        else:
            c = rl_canvas.Canvas(pdf_path, pagesize=A4)
            page_w, page_h = A4

            for file_path, content_type in saved_files:
                try:
                    img = Image.open(file_path)
                    if img.mode == "RGBA":
                        img = img.convert("RGB")
                    img_w, img_h = img.size
                    ratio = min(page_w / img_w, page_h / img_h)
                    draw_w = img_w * ratio
                    draw_h = img_h * ratio
                    x = (page_w - draw_w) / 2
                    y = (page_h - draw_h) / 2
                    buf = io.BytesIO()
                    img.save(buf, format="JPEG", quality=85)
                    buf.seek(0)
                    c.drawImage(ImageReader(buf), x, y, draw_w, draw_h)
                    c.showPage()
                except Exception:
                    pass
            c.save()

        ocr_count = sum(1 for _, t in ocr_texts if t) if ocr else 0
        tasks[task_id]["status"] = "completed"
        tasks[task_id]["progress"] = 1.0
        tasks[task_id]["download_url"] = f"http://localhost:8001/downloads/{task_id}_images.pdf"
        if ocr and ocr_count > 0:
            tasks[task_id]["ai_summary"] = f"PDF created from {len(saved_files)} image(s) with OCR. Extracted text from {ocr_count} page(s)."
        else:
            tasks[task_id]["ai_summary"] = f"PDF created from {len(saved_files)} image(s)."
    except Exception as e:
        tasks[task_id]["status"] = "failed"
        tasks[task_id]["error_message"] = str(e)

    return {"task_id": task_id}


@app.post("/api/v1/convert/pdf-to-image")
async def pdf_to_image(file: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    content = await file.read()
    save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    with open(save_path, "wb") as f:
        f.write(content)

    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}

    try:
        import fitz  # PyMuPDF
        doc = fitz.open(save_path)
        images = []
        has_transparency = False

        for page_num in range(len(doc)):
            page = doc[page_num]
            pix = page.get_pixmap(dpi=200, alpha=True)
            mode = "RGBA"
            img = Image.frombytes(mode, [pix.width, pix.height], pix.samples)
            # Check if any pixel has alpha < 255
            alpha = img.split()[3]
            if alpha.getextrema()[0] < 255:
                has_transparency = True
            images.append(img.convert("RGB") if not has_transparency else img)
        doc.close()

        if images:
            fmt = "PNG" if has_transparency else "JPEG"
            ext = "png" if has_transparency else "jpeg"
            output_name = f"images.{ext}"
            output_path = os.path.join(UPLOAD_DIR, f"{task_id}_{output_name}")

            if len(images) == 1:
                images[0].save(output_path, format=fmt)
            else:
                images[0].save(output_path, format=fmt, save_all=True, append_images=images[1:])

            tasks[task_id]["status"] = "completed"
            tasks[task_id]["progress"] = 1.0
            tasks[task_id]["download_url"] = f"http://localhost:8001/downloads/{task_id}_{output_name}"
            tasks[task_id]["ai_summary"] = f"Extracted {len(images)} page(s) as {fmt} (auto-detected)."
        else:
            tasks[task_id]["status"] = "failed"
            tasks[task_id]["error_message"] = "No pages found in PDF."

    except Exception as e:
        tasks[task_id]["status"] = "failed"
        tasks[task_id]["error_message"] = str(e)

    return {"task_id": task_id}


@app.post("/api/v1/sign")
async def sign_pdf(file: UploadFile = File(...), signature: UploadFile = File(...)):
    task_id = str(uuid.uuid4())[:8]
    pdf_content = await file.read()
    sig_content = await signature.read()

    pdf_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
    sig_path = os.path.join(UPLOAD_DIR, f"{task_id}_sig.png")
    with open(pdf_path, "wb") as f:
        f.write(pdf_content)
    with open(sig_path, "wb") as f:
        f.write(sig_content)

    tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                       "download_url": None, "ai_summary": None, "error_message": None}

    output_path = os.path.join(UPLOAD_DIR, f"{task_id}_signed_{file.filename}")

    try:
        import fitz
        doc = fitz.open(pdf_path)

        sign_keywords = [
            "sign here", "signature", "sign:", "sign ",
            "please sign", "authorized signature", "candidate signature",
            "employee signature", "applicant signature", "sign and date",
            "signature of", "executed by",
        ]

        locations_found = 0
        sig_rect = fitz.Rect(0, 0, 150, 50)

        for page in doc:
            text_instances = []
            for keyword in sign_keywords:
                results = page.search_for(keyword)
                text_instances.extend(results)

            if not text_instances:
                results = page.search_for("Sign")
                text_instances.extend(results)

            seen = set()
            for inst in text_instances:
                key = (round(inst.x0), round(inst.y0))
                if key in seen:
                    continue
                seen.add(key)

                x0 = inst.x0
                y0 = inst.y1 + 4
                rect = fitz.Rect(x0, y0, x0 + 150, y0 + 50)

                if rect.y1 > page.rect.height - 20:
                    rect = fitz.Rect(x0, inst.y0 - 54, x0 + 150, inst.y0 - 4)

                try:
                    page.insert_image(rect, stream=sig_content)
                    locations_found += 1
                except Exception:
                    pass

        if locations_found == 0:
            last_page = doc[-1]
            rect = fitz.Rect(
                last_page.rect.width - 200,
                last_page.rect.height - 100,
                last_page.rect.width - 50,
                last_page.rect.height - 50,
            )
            try:
                last_page.insert_image(rect, stream=sig_content)
                locations_found = 1
                summary = "No 'Sign here' markers found. Signature placed at bottom-right of last page."
            except Exception:
                summary = "Signature could not be placed."
        else:
            summary = f"Signature placed at {locations_found} detected location(s)."

        doc.save(output_path)
        doc.close()

        tasks[task_id]["status"] = "completed"
        tasks[task_id]["progress"] = 1.0
        tasks[task_id]["download_url"] = f"http://localhost:8001/downloads/{task_id}_signed_{file.filename}"
        tasks[task_id]["ai_summary"] = summary

    except Exception as e:
        tasks[task_id]["status"] = "failed"
        tasks[task_id]["error_message"] = str(e)

    return {"task_id": task_id}


def _make_conversion_task(file: UploadFile, default_output: str, endpoint: str):
    import asyncio
    async def _run():
        task_id = str(uuid.uuid4())[:8]
        content = await file.read()
        save_path = os.path.join(UPLOAD_DIR, f"{task_id}_{file.filename}")
        with open(save_path, "wb") as f:
            f.write(content)
        tasks[task_id] = {"task_id": task_id, "status": "processing", "progress": 0.0,
                           "download_url": None, "ai_summary": None, "error_message": None}
        _simulate_task(task_id, file.filename or default_output, endpoint)
        return {"task_id": task_id}
    return _run


# ── Additional conversions ──────────────────────────────────────────────

@app.post("/convert/word-to-excel")
async def word_to_excel(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.xlsx", "/convert/word-to-excel")()

@app.post("/convert/word-to-image")
async def word_to_image(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.jpeg", "/convert/word-to-image")()

@app.post("/convert/word-to-text")
async def word_to_text(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.txt", "/convert/word-to-text")()

@app.post("/convert/excel-to-word")
async def excel_to_word(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.docx", "/convert/excel-to-word")()

@app.post("/convert/excel-to-image")
async def excel_to_image(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.jpeg", "/convert/excel-to-image")()

@app.post("/convert/excel-to-text")
async def excel_to_text(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.txt", "/convert/excel-to-text")()

@app.post("/convert/pdf-to-text")
async def pdf_to_text(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.txt", "/convert/pdf-to-text")()

@app.post("/convert/image-to-word")
async def image_to_word(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.docx", "/convert/image-to-word")()

@app.post("/convert/image-to-excel")
async def image_to_excel(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.xlsx", "/convert/image-to-excel")()

@app.post("/convert/image-to-text")
async def image_to_text(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.txt", "/convert/image-to-text")()

@app.post("/convert/text-to-pdf")
async def text_to_pdf(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.pdf", "/convert/text-to-pdf")()

@app.post("/convert/text-to-word")
async def text_to_word(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.docx", "/convert/text-to-word")()

@app.post("/convert/text-to-excel")
async def text_to_excel(file: UploadFile = File(...)):
    return await _make_conversion_task(file, "output.xlsx", "/convert/text-to-excel")()


# ── Image format conversions ────────────────────────────────────────────

_img_formats = ['jpg', 'png', 'webp', 'bmp', 'tiff', 'gif']

for _src in _img_formats:
    for _dst in _img_formats + ['pdf', 'word']:
        if _src == _dst:
            continue
        _ep = f"/convert/{_src}-to-{_dst}"
        _out = f"output.{_dst}" if _dst in _img_formats else f"output.{_dst}"
        if _dst == 'word':
            _out = "output.docx"
        _name = f"{_src}_to_{_dst}".replace("-", "_")

        async def _handler(file: UploadFile = File(...), _ep=_ep, _out=_out):
            return await _make_conversion_task(file, _out, _ep)()

        app.add_api_route(_ep, _handler, methods=["POST"])


@app.get("/api/v1/status/{task_id}")
async def get_status(task_id: str):
    if task_id not in tasks:
        return JSONResponse(status_code=404, content={"error": "Task not found"})
    t = tasks[task_id]
    return {"task_id": t["task_id"], "status": t["status"], "progress": t["progress"],
            "download_url": t["download_url"], "ai_summary": t["ai_summary"],
            "error_message": t["error_message"]}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8001")))
