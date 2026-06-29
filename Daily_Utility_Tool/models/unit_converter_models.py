from enum import Enum
from pydantic import BaseModel, Field, ConfigDict


class UnitCategory(str, Enum):
    LENGTH = "length"
    WEIGHT = "weight"
    TEMPERATURE = "temperature"
    VOLUME = "volume"
    AREA = "area"
    SPEED = "speed"
    TIME = "time"
    DIGITAL_STORAGE = "digital_storage"
    PRESSURE = "pressure"
    ENERGY = "energy"
    POWER = "power"
    ANGLE = "angle"


class UnitConversionRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    category: UnitCategory = Field(..., description="Category of the conversion")
    value: float = Field(..., description="Value to convert")
    from_unit: str = Field(..., alias="fromUnit", description="Unit to convert from (e.g., 'm', 'kg', 'Celsius')")
    to_unit: str = Field(..., alias="toUnit", description="Unit to convert to (e.g., 'km', 'g', 'Fahrenheit')")


class UnitConversionResponse(BaseModel):
    result: float


class CategoryListResponse(BaseModel):
    categories: list[dict[str, str]]


class UnitListResponse(BaseModel):
    category: UnitCategory
    units: list[str]
