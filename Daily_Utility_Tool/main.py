from __future__ import annotations

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv

load_dotenv()

from models.barcode_models import ErrorItem, ErrorResponse

from routes.barcode_routes import router as barcode_router
from routes.qr_routes import router as qr_router
from routes.unit_converter_routes import router as converter_router
from routes.age_route import router as age_router
from routes.emi_routes import router as emi_router


app = FastAPI(
    title="Daily Utility Tools Backend",
    version="1.0.0",
    description="API for daily utility features such as barcode generation.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(barcode_router)
app.include_router(qr_router)
app.include_router(converter_router)
app.include_router(emi_router)
app.include_router(age_router)


@app.get("/health", tags=["Health"])
def health_check() -> dict[str, str]:
    return {"status": "ok", "service": "utility_tools_backend"}


@app.exception_handler(HTTPException)
async def http_exception_handler(_: Request, exc: HTTPException) -> JSONResponse:
    if isinstance(exc.detail, dict):
        payload = ErrorResponse(
            message=str(exc.detail.get("message", "Request failed.")),
            errors=[ErrorItem(**item) for item in exc.detail.get("errors", [])],
            details=exc.detail.get("details"),
        )
    else:
        payload = ErrorResponse(message=str(exc.detail))

    return JSONResponse(status_code=exc.status_code, content=payload.model_dump())


@app.exception_handler(RequestValidationError)
async def request_validation_exception_handler(
    _: Request,
    exc: RequestValidationError,
) -> JSONResponse:
    errors = [
        ErrorItem(field=".".join(map(str, e.get("loc", [])[1:])), message=e.get("msg", "Invalid value"))
        for e in exc.errors()
    ]
    payload = ErrorResponse(message="Request validation failed.", errors=errors)
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=payload.model_dump(),
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(_: Request, __: Exception) -> JSONResponse:
    payload = ErrorResponse(message="Internal server error.")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=payload.model_dump(),
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
