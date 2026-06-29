from pydantic import BaseModel, Field
from typing import Optional


class QRRequest(BaseModel):
    data: str = Field(..., min_length=1)

    qr_type: Optional[str] = None

    size: int = Field(default=300, ge=100, le=1000)

    fill_color: str = "#000000"
    back_color: str = "#ffffff"

    error_correction: str = "M"

    shape: str = "square"   # square / circle
    frame: bool = False

    output_format: str = "png"   # png / svg


class QRResponse(BaseModel):
    message: str
    qr_type: str
    image: str
