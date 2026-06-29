from enum import Enum
from typing import Any
from pydantic import BaseModel, Field


class BarcodeType(str, Enum):
    CODE128 = "code128"
    CODE39 = "code39"
    CODE93 = "code93"
    EAN8 = "ean8"
    EAN13 = "ean13"
    UPC = "upc"
    ISBN10 = "isbn10"
    ISBN13 = "isbn13"
    ISSN = "issn"
    GS1_128 = "gs1_128"
    EAN = "ean"


class BarcodeGenerationRequest(BaseModel):
    data: str = Field(
        ...,
        min_length=1,
        description="Raw input data for barcode generation",
        examples=["5901234123457", "12345678901", "HELLO-123"],
    )
    barcode_type: BarcodeType = Field(..., description="Type of barcode to generate")


class BarcodePayload(BaseModel):
    barcode_type: BarcodeType
    original_data: str
    normalized_data: str
    mime_type: str
    image_base64: str
    data_uri: str


class BarcodeGenerationResponse(BaseModel):
    success: bool = True
    message: str
    data: BarcodePayload


class ErrorItem(BaseModel):
    field: str | None = None
    message: str


class ErrorResponse(BaseModel):
    success: bool = False
    message: str
    errors: list[ErrorItem] = Field(default_factory=list)
    details: dict[str, Any] | None = None
