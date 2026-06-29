
from __future__ import annotations

import sys
import base64
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path
import re
import base64
import re
from dataclasses import dataclass
from io import BytesIO

import barcode
from barcode.errors import BarcodeError, IllegalCharacterError, NumberOfDigitsError
from barcode.writer import ImageWriter

_ROOT_DIR = Path(__file__).resolve().parents[1]
if str(_ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(_ROOT_DIR))

from models.barcode_models import BarcodeType


BARCODE_MAP = {
    BarcodeType.CODE128: "code128",
    BarcodeType.CODE39: "code39",
    BarcodeType.CODE93: "code93",
    BarcodeType.EAN8: "ean8",
    BarcodeType.EAN13: "ean13",
    BarcodeType.UPC: "upc",
    BarcodeType.ISBN10: "isbn10",
    BarcodeType.ISBN13: "isbn13",
    BarcodeType.ISSN: "issn",
    BarcodeType.GS1_128: "gs1_128",
}


from models.barcode_models import BarcodeType

@dataclass
class NormalizedBarcodeInput:
    original_data: str
    normalized_data: str
    barcode_type: BarcodeType
    symbology: str


class BarcodeValidationError(ValueError):
    def __init__(self, message: str, field: str = "data") -> None:
        super().__init__(message)
        self.field = field


class BarcodeService:
    _NUMERIC_PATTERN = re.compile(r"^\d+$")
    _CODE128_PATTERN = re.compile(r"^[\x20-\x7E]+$")

    @classmethod
    def generate_barcode_image(cls, data: str, barcode_type: BarcodeType) -> dict:
        normalized = cls._normalize_and_validate(data=data, barcode_type=barcode_type)

        try:
            barcode_class = barcode.get_barcode_class(normalized.symbology)
            barcode_instance = barcode_class(normalized.normalized_data, writer=ImageWriter())

            buffer = BytesIO()
            barcode_instance.write(
                buffer,
                options={
                    "module_width": 0.2,
                    "module_height": 15.0,
                    "font_size": 10,
                    "text_distance": 5.0,
                    "quiet_zone": 6.5,
                },
            )
            image_bytes = buffer.getvalue()
            encoded_image = base64.b64encode(image_bytes).decode("utf-8")
            mime_type = "image/png"

            return {
                "barcode_type": normalized.barcode_type,
                "original_data": normalized.original_data,
                "normalized_data": normalized.normalized_data,
                "mime_type": mime_type,
                "image_base64": encoded_image,
                "data_uri": f"data:{mime_type};base64,{encoded_image}",
            }
        except (NumberOfDigitsError, IllegalCharacterError, BarcodeError) as exc:
            raise BarcodeValidationError(str(exc)) from exc

    @classmethod
    def _normalize_and_validate(cls, data: str, barcode_type: BarcodeType) -> NormalizedBarcodeInput:
        raw_data = data.strip()
        if not raw_data:
            raise BarcodeValidationError("Input data cannot be empty.")

        if barcode_type == BarcodeType.CODE128:
            cls._validate_code128(raw_data)
            return NormalizedBarcodeInput(
                original_data=data,
                normalized_data=raw_data,
                barcode_type=barcode_type,
                symbology="code128",
            )

        if barcode_type == BarcodeType.EAN:
            normalized_data, symbology = cls._validate_ean(raw_data)
            return NormalizedBarcodeInput(
                original_data=data,
                normalized_data=normalized_data,
                barcode_type=barcode_type,
                symbology=symbology,
            )

        if barcode_type == BarcodeType.UPC:
            normalized_data = cls._validate_upc(raw_data)
            return NormalizedBarcodeInput(
                original_data=data,
                normalized_data=normalized_data,
                barcode_type=barcode_type,
                symbology="upc",
            )

        raise BarcodeValidationError("Unsupported barcode format.", field="barcode_type")

    @classmethod
    def _validate_code128(cls, value: str) -> None:
        if len(value) > 80:
            raise BarcodeValidationError("Code128 supports up to 80 characters for this API.")
        if not cls._CODE128_PATTERN.fullmatch(value):
            raise BarcodeValidationError(
                "Code128 supports printable ASCII characters only (space to ~)."
            )

    @classmethod
    def _validate_ean(cls, value: str) -> tuple[str, str]:
        if not cls._NUMERIC_PATTERN.fullmatch(value):
            raise BarcodeValidationError("EAN supports numeric digits only.")

        if len(value) in (7, 8):
            if len(value) == 8:
                cls._validate_checksum(value, "EAN")
                value = value[:-1]
            return value, "ean8"

        if len(value) in (12, 13):
            if len(value) == 13:
                cls._validate_checksum(value, "EAN")
                value = value[:-1]
            return value, "ean13"

        raise BarcodeValidationError(
            "EAN data must be 7/8 digits (EAN-8) or 12/13 digits (EAN-13)."
        )

    @classmethod
    def _validate_upc(cls, value: str) -> str:
        if not cls._NUMERIC_PATTERN.fullmatch(value):
            raise BarcodeValidationError("UPC supports numeric digits only.")

        if len(value) == 12:
            cls._validate_checksum(value, "UPC")
            return value[:-1]

        if len(value) == 11:
            return value

        raise BarcodeValidationError("UPC data must be 11 or 12 digits.")

    @classmethod
    def _validate_checksum(cls, value: str, barcode_name: str) -> None:
        expected = cls._calculate_mod10_checksum(value[:-1])
        actual = int(value[-1])
        if expected != actual:
            raise BarcodeValidationError(
                f"Invalid checksum for {barcode_name}. Expected last digit {expected}."
            )

    @staticmethod
    def _calculate_mod10_checksum(value: str) -> int:
        total = 0
        reversed_digits = list(map(int, reversed(value)))

        for index, digit in enumerate(reversed_digits):
            if index % 2 == 0:
                total += digit * 3
            else:
                total += digit

        return (10 - (total % 10)) % 10
