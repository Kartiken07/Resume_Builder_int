from fastapi import APIRouter, HTTPException, status, Query

from models.unit_converter_models import (
    UnitConversionRequest,
    UnitConversionResponse,
    UnitCategory,
    CategoryListResponse,
    UnitListResponse,
)
from models.barcode_models import ErrorResponse, ErrorItem
from services.unit_converter_service import UnitConverterService, UnitConverterValidationError


router = APIRouter(prefix="/api/v1/converter", tags=["Unit Converter"])


@router.get(
    "/categories",
    response_model=CategoryListResponse,
    status_code=status.HTTP_200_OK,
)
def get_categories() -> CategoryListResponse:
    """
    Get all supported unit categories.
    """
    return CategoryListResponse(categories=UnitConverterService.get_categories())


@router.get(
    "/units",
    response_model=UnitListResponse,
    status_code=status.HTTP_200_OK,
)
def get_units(category: UnitCategory) -> UnitListResponse:
    """
    Get all supported units for a given category.
    """
    return UnitListResponse(
        category=category,
        units=UnitConverterService.get_units(category)
    )


@router.post(
    "/convert",
    response_model=UnitConversionResponse,
    status_code=status.HTTP_200_OK,
    responses={
        status.HTTP_422_UNPROCESSABLE_ENTITY: {
            "model": ErrorResponse,
            "description": "Validation failed for unit conversion input.",
        },
        status.HTTP_500_INTERNAL_SERVER_ERROR: {
            "model": ErrorResponse,
            "description": "Unexpected server error.",
        },
    },
)
def convert_unit(request: UnitConversionRequest) -> UnitConversionResponse:
    try:
        result = UnitConverterService.convert(
            category=request.category,
            value=request.value,
            from_unit=request.from_unit,
            to_unit=request.to_unit,
        )
        return UnitConversionResponse(result=result)
    except UnitConverterValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "message": "Unit conversion validation failed.",
                "errors": [ErrorItem(field=exc.field, message=str(exc)).model_dump()],
            },
        ) from exc


@router.get(
    "/convert",
    response_model=UnitConversionResponse,
    status_code=status.HTTP_200_OK,
    responses={
        status.HTTP_422_UNPROCESSABLE_ENTITY: {
            "model": ErrorResponse,
            "description": "Validation failed for unit conversion input.",
        },
        status.HTTP_500_INTERNAL_SERVER_ERROR: {
            "model": ErrorResponse,
            "description": "Unexpected server error.",
        },
    },
)
def convert_unit_get(
    category: UnitCategory,
    value: float,
    from_unit: str = Query(..., alias="fromUnit"),
    to_unit: str = Query(..., alias="toUnit"),
) -> UnitConversionResponse:
    try:
        result = UnitConverterService.convert(
            category=category,
            value=value,
            from_unit=from_unit,
            to_unit=to_unit,
        )
        return UnitConversionResponse(result=result)
    except UnitConverterValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "message": "Unit conversion validation failed.",
                "errors": [ErrorItem(field=exc.field, message=str(exc)).model_dump()],
            },
        ) from exc