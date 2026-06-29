import base64
import re
from dataclasses import dataclass
from io import BytesIO
from typing import Optional

from PIL import Image, ImageDraw
import qrcode
import qrcode.image.svg as svg
from qrcode.constants import (
    ERROR_CORRECT_L,
    ERROR_CORRECT_M,
    ERROR_CORRECT_Q,
    ERROR_CORRECT_H,
)

class QRType:
    TEXT = "text"
    URL = "url"
    EMAIL = "email"
    PHONE = "phone"
    WIFI = "wifi"
    EVENT = "event"
    VCARD = "vcard"
    LOCATION = "location"
    WHATSAPP = "whatsapp"
    FILE = "file"
    SOCIAL = "social"
  
@dataclass
class NormalizedQRInput:
    original_data: str
    normalized_data: str
    qr_type: str

class QRValidationError(ValueError):
    pass


class QRService:
    _EMAIL_PATTERN = re.compile(r"^[^@]+@[^@]+\.[^@]+$")
    _PHONE_PATTERN = re.compile(r"^\+?\d{7,15}$")
    _SOCIAL_PATTERN = re.compile(r"(instagram|facebook|linkedin|twitter|x\.com)", re.IGNORECASE)

    
    @classmethod
    def generate_qr_image(
        cls,
        data: str,
        qr_type: Optional[str] = None,
        size: int = 300,
        fill_color: str = "#000000",
        back_color: str = "#ffffff",
        error_correction: str = "M",
        logo: Optional[bytes] = None,
        output_format: str = "png",
        shape: str = "square",
        frame: bool = False,
    ) -> dict:

        normalized = cls._normalize_and_validate(data, qr_type)

        qr = qrcode.QRCode(
            version=1,
            error_correction=cls._get_error_correction(error_correction),
            box_size=10,
            border=4,
        )

        qr.add_data(normalized.normalized_data)
        qr.make(fit=True)

  
        if output_format.lower() == "svg":
            factory = svg.SvgImage
            img = qrcode.make(normalized.normalized_data, image_factory=factory)

            buffer = BytesIO()
            img.save(buffer)
            image_bytes = buffer.getvalue()

            encoded = base64.b64encode(image_bytes).decode()

            return {
                "qr_type": normalized.qr_type,
                "image_base64": encoded,
                "data_uri": f"data:image/svg+xml;base64,{encoded}",
            }

        
        img = qr.make_image(fill_color=fill_color, back_color=back_color).convert("RGB")
        img = img.resize((size, size))

        img = cls._apply_shape_mask(img, shape)

        if logo:
            img = cls._add_logo(img, logo)

        if frame:
            img = cls._add_frame(img)

        buffer = BytesIO()
        img.save(buffer, format="PNG")
        image_bytes = buffer.getvalue()

        encoded = base64.b64encode(image_bytes).decode()

        return {
            "qr_type": normalized.qr_type,
            "image_base64": encoded,
            "data_uri": f"data:image/png;base64,{encoded}",
        }

    
    @classmethod
    def _normalize_and_validate(cls, data: str, qr_type: Optional[str]) -> NormalizedQRInput:
        raw = data.strip()

        if not raw:
            raise QRValidationError("Input cannot be empty")

        detected_type = qr_type or cls._auto_detect_type(raw)

        if detected_type == QRType.URL:
            if not raw.startswith("http"):
                raw = "https://" + raw
            return NormalizedQRInput(data, raw, QRType.URL)

        if detected_type == QRType.EMAIL:
            return NormalizedQRInput(data, f"mailto:{raw}", QRType.EMAIL)

        if detected_type == QRType.PHONE:
            return NormalizedQRInput(data, f"tel:{raw}", QRType.PHONE)

        if detected_type == QRType.WHATSAPP:
            return NormalizedQRInput(data, f"https://wa.me/{raw}", QRType.WHATSAPP)

        if detected_type == QRType.WIFI:
            parts = raw.split(";")
            if len(parts) != 2:
                raise QRValidationError("WiFi format: SSID;PASSWORD")

            ssid, password = parts
            return NormalizedQRInput(
                data,
                f"WIFI:T:WPA;S:{ssid};P:{password};;",
                QRType.WIFI,
            )

        
        if detected_type == QRType.LOCATION:
            # If it's already a maps link → keep it
            if "maps.google.com" in raw or "goo.gl/maps" in raw:
                return NormalizedQRInput(data, raw, QRType.LOCATION)

            # Otherwise treat as place name → force Google Maps app
            return NormalizedQRInput(
                data,
                f"geo:0,0?q={raw}",
                QRType.LOCATION,
            )

        if detected_type == QRType.EVENT:
            return NormalizedQRInput(
                data,
                f"BEGIN:VEVENT\nSUMMARY:{raw}\nEND:VEVENT",
                QRType.EVENT,
            )

        if detected_type == QRType.VCARD:
            return NormalizedQRInput(
                data,
                f"BEGIN:VCARD\nFN:{raw}\nEND:VCARD",
                QRType.VCARD,
            )

        if detected_type == QRType.SOCIAL:
            return NormalizedQRInput(data, raw, QRType.SOCIAL)

        return NormalizedQRInput(data, raw, QRType.TEXT)

    
    @classmethod
    def _auto_detect_type(cls, value: str) -> str:
        value = value.strip().lower()

        if "maps.google.com" in value or "goo.gl/maps" in value:
            return QRType.LOCATION

        if cls._SOCIAL_PATTERN.search(value):
            return QRType.SOCIAL

        if cls._EMAIL_PATTERN.match(value):
            return QRType.EMAIL

        if cls._PHONE_PATTERN.match(value):
            return QRType.PHONE

        if value.startswith("http"):
            return QRType.URL

        if "." in value and " " not in value:
            return QRType.URL

        if " " in value or value.isalpha():
            return QRType.LOCATION

        return QRType.TEXT

    @staticmethod
    def _get_error_correction(level: str):
        levels = {
            "L": ERROR_CORRECT_L,
            "M": ERROR_CORRECT_M,
            "Q": ERROR_CORRECT_Q,
            "H": ERROR_CORRECT_H,
        }
        return levels.get(level.upper(), ERROR_CORRECT_M)

    @staticmethod
    def _apply_shape_mask(image: Image.Image, shape: str) -> Image.Image:
        if shape == "circle":
            mask = Image.new("L", image.size, 0)
            draw = ImageDraw.Draw(mask)
            draw.ellipse((0, 0, image.size[0], image.size[1]), fill=255)

            result = Image.new("RGB", image.size)
            result.paste(image, mask=mask)
            return result

        return image

    @staticmethod
    def _add_frame(image: Image.Image, border_size: int = 20) -> Image.Image:
        new_size = (
            image.size[0] + 2 * border_size,
            image.size[1] + 2 * border_size,
        )

        framed = Image.new("RGB", new_size, "black")
        framed.paste(image, (border_size, border_size))
        return framed

    @staticmethod
    def _add_logo(qr_img: Image.Image, logo_bytes: bytes) -> Image.Image:
        logo = Image.open(BytesIO(logo_bytes))

        qr_width = qr_img.size[0]
        logo_size = qr_width // 4

        logo = logo.resize((logo_size, logo_size))

        pos = ((qr_width - logo_size) // 2, (qr_width - logo_size) // 2)
        qr_img.paste(logo, pos, mask=logo if logo.mode == "RGBA" else None)

        return qr_img
