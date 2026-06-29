from fastapi import APIRouter, HTTPException, status
from fastapi.responses import StreamingResponse
from io import BytesIO
import base64
from models.barcode_models import (
    BarcodeGenerationRequest,
    BarcodeGenerationResponse,
    ErrorResponse,
    ErrorItem,
)
from services.barcode_service import BarcodeService, BarcodeValidationError


router = APIRouter(prefix="/api/v1/barcodes", tags=["Barcode Generator"])


@router.post(
    "/generate",
    response_model=BarcodeGenerationResponse,
    status_code=status.HTTP_200_OK,
    responses={
        status.HTTP_422_UNPROCESSABLE_ENTITY: {
            "model": ErrorResponse,
            "description": "Validation failed for barcode input.",
        },
        status.HTTP_500_INTERNAL_SERVER_ERROR: {
            "model": ErrorResponse,
            "description": "Unexpected server error.",
        },
    },
)
def generate_barcode(request: BarcodeGenerationRequest):
    try:
        payload = BarcodeService.generate_barcode_image(
            data=request.data,
            barcode_type=request.barcode_type,
        )

        return BarcodeGenerationResponse(
            message="Barcode generated successfully.",
            data=payload,
        )
    except BarcodeValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "message": "Barcode validation failed.",
                "errors": [ErrorItem(field=exc.field, message=str(exc)).model_dump()],
            },
        ) from exc
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e),
        ) from e


@router.post(
    "/download",
    status_code=status.HTTP_200_OK,
    responses={
        status.HTTP_422_UNPROCESSABLE_ENTITY: {
            "model": ErrorResponse,
            "description": "Validation failed for barcode input.",
        },
        status.HTTP_500_INTERNAL_SERVER_ERROR: {
            "model": ErrorResponse,
            "description": "Unexpected server error.",
        },
    },
)
def download_barcode(request: BarcodeGenerationRequest):
    try:
        payload = BarcodeService.generate_barcode_image(
            data=request.data,
            barcode_type=request.barcode_type,
        )

        image_bytes = base64.b64decode(payload.get("image_base64", ""))
        buffer = BytesIO(image_bytes)

        return StreamingResponse(
            buffer,
            media_type="image/png",
            headers={"Content-Disposition": "attachment; filename=barcode.png"},
        )
    except BarcodeValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "message": "Barcode validation failed.",
                "errors": [ErrorItem(field=exc.field, message=str(exc)).model_dump()],
            },
        ) from exc
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e),
        ) from e
