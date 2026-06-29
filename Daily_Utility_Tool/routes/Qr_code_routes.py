from fastapi import APIRouter


router = APIRouter(prefix="/api/v1/qr-code", tags=["QR Code"])


@router.get("/health")
def qr_health() -> dict[str, str]:
	return {"status": "ok", "module": "qr-code"}

