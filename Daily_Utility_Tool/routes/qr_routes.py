from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from io import BytesIO
import base64

from models.qr_model import QRRequest
from services.qr_service import QRService

router = APIRouter(prefix="/api/v1/qr", tags=["QR Code"])

@router.get("/")
def health():
    return {"status": "QR API is running 🚀"}

@router.post("/generate")
def generate_qr(payload: QRRequest):
    try:
        result = QRService.generate_qr_image(**payload.dict())

        base64_str = result["image_base64"]
        print("\n===== QR DEBUG =====")
        print("TYPE:", result["qr_type"])
        print("BASE64 LENGTH:", len(base64_str))
        print("====================\n")

        return {
            "message": "QR Code generated successfully",
            "qr_type": result["qr_type"],
            "image": base64_str,
            "data_uri": result["data_uri"],
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/generate-simple")
def generate_qr_get(data: str, qr_type: str = None):
    try:
        result = QRService.generate_qr_image(
            data=data,
            qr_type=qr_type
        )

        return {
            "message": "QR generated successfully",
            "qr_type": result["qr_type"],
            "image": result["image_base64"],
            "data_uri": result["data_uri"],
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/download")
def download_qr(payload: QRRequest):
    try:
        result = QRService.generate_qr_image(**payload.dict())

        image_bytes = base64.b64decode(result["image_base64"])

        return StreamingResponse(
            BytesIO(image_bytes),
            media_type="image/png",
            headers={"Content-Disposition": "attachment; filename=qr.png"},
        )

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
