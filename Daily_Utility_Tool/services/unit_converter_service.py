from models.unit_converter_models import UnitCategory


class UnitConverterValidationError(ValueError):
    def __init__(self, message: str, field: str = "value") -> None:
        super().__init__(message)
        self.field = field


class UnitConverterService:
    CONVERSION_FACTORS = {
        UnitCategory.LENGTH: {
            "m": 1.0,
            "km": 1000.0,
            "cm": 0.01,
            "mm": 0.001,
            "dm": 0.1,
            "nm": 1e-9,
            "um": 1e-6,
            "mile": 1609.34,
            "yard": 0.9144,
            "foot": 0.3048,
            "inch": 0.0254,
            "nautical_mile": 1852.0
        },
        UnitCategory.WEIGHT: {
            "kg": 1000.0,
            "g": 1.0,
            "mg": 0.001,
            "ton": 1000000.0,
            "pound": 453.592,
            "ounce": 28.3495,
            "stone": 6350.29,
            "dram": 1.77185
        },
        UnitCategory.VOLUME: {
            "liter": 1.0,
            "ml": 0.001,
            "gallon": 3.78541,
            "cup": 0.24,
            "pint": 0.473176,
            "quart": 0.946353
        },
        UnitCategory.AREA: {
            "sq_m": 1.0,
            "sq_km": 1000000.0,
            "sq_ft": 0.092903,
            "acre": 4046.86,
            "hectare": 10000.0
        },
        UnitCategory.SPEED: {
            "m/s": 1.0,
            "km/h": 0.277778,
            "mph": 0.44704,
            "knot": 0.514444
        },
        UnitCategory.TIME: {
            "second": 1.0,
            "minute": 60.0,
            "hour": 3600.0,
            "day": 86400.0,
            "week": 604800.0
        },
        UnitCategory.DIGITAL_STORAGE: {
            "bit": 0.125,
            "byte": 1.0,
            "KB": 1024.0,
            "MB": 1048576.0,
            "GB": 1073741824.0,
            "TB": 1099511627776.0,
            "PB": 1125899906842624.0
        },
        UnitCategory.PRESSURE: {
            "pascal": 1.0,
            "bar": 100000.0,
            "psi": 6894.76,
            "atm": 101325.0
        },
        UnitCategory.ENERGY: {
            "joule": 1.0,
            "kj": 1000.0,
            "calorie": 4.184,
            "kcal": 4184.0,
            "wh": 3600.0,
            "kwh": 3600000.0
        },
        UnitCategory.POWER: {
            "watt": 1.0,
            "kw": 1000.0,
            "hp": 745.7
        },
        UnitCategory.ANGLE: {
            "degree": 1.0,
            "radian": 57.2958,
            "gradian": 0.9
        }
    }

    SUPPORTED_UNITS = {
        cat: set(factors.keys()) for cat, factors in CONVERSION_FACTORS.items()
    }
    SUPPORTED_UNITS[UnitCategory.TEMPERATURE] = {"Celsius", "Fahrenheit", "Kelvin"}

    @classmethod
    def convert(cls, category: UnitCategory, value: float, from_unit: str, to_unit: str) -> float:
        """
        Convert a value between units within a category.
        """
        if category not in cls.SUPPORTED_UNITS:
            raise UnitConverterValidationError(f"Category '{category}' is not supported.", field="category")

        # Validate non-negative values for specific categories
        if category in {
            UnitCategory.LENGTH, UnitCategory.WEIGHT, UnitCategory.VOLUME,
            UnitCategory.AREA, UnitCategory.SPEED, UnitCategory.TIME,
            UnitCategory.DIGITAL_STORAGE, UnitCategory.ENERGY, UnitCategory.POWER
        } and value < 0:
            raise UnitConverterValidationError(f"Value for category '{category.value}' cannot be negative.", field="value")

        supported_units_for_category = cls.SUPPORTED_UNITS[category]

        if from_unit not in supported_units_for_category:
            raise UnitConverterValidationError(
                f"Unit '{from_unit}' is not supported for category '{category}'. Supported: {', '.join(sorted(supported_units_for_category))}",
                field="from_unit"
            )

        if to_unit not in supported_units_for_category:
            raise UnitConverterValidationError(
                f"Unit '{to_unit}' is not supported for category '{category}'. Supported: {', '.join(sorted(supported_units_for_category))}",
                field="to_unit"
            )

        if from_unit == to_unit:
            return value

        if category == UnitCategory.TEMPERATURE:
            converted = cls._convert_temperature(value, from_unit, to_unit)
        else:
            converted = cls._convert_multiplicative(category, value, from_unit, to_unit)

        return round(converted, 4)

    @classmethod
    def get_categories(cls) -> list[dict[str, str]]:
        """
        Return all supported unit categories.
        """
        return [{"id": cat.value, "name": cat.name.replace("_", " ").title()} for cat in UnitCategory]

    @classmethod
    def get_units(cls, category: UnitCategory) -> list[str]:
        """
        Return supported units for a given category.
        """
        if category not in cls.SUPPORTED_UNITS:
            raise UnitConverterValidationError(f"Category '{category}' is not supported.", field="category")
        return sorted(list(cls.SUPPORTED_UNITS[category]))

    @classmethod
    def _convert_multiplicative(cls, category: UnitCategory, value: float, from_unit: str, to_unit: str) -> float:
        factors = cls.CONVERSION_FACTORS[category]
        value_in_base = value * factors[from_unit]
        converted_value = value_in_base / factors[to_unit]
        return converted_value

    @classmethod
    def _convert_temperature(cls, value: float, from_unit: str, to_unit: str) -> float:
        if from_unit == to_unit:
            return value

        # Convert to Celsius first
        if from_unit == "Celsius":
            celsius = value
        elif from_unit == "Fahrenheit":
            celsius = (value - 32.0) * 5.0 / 9.0
        elif from_unit == "Kelvin":
            celsius = value - 273.15
        else:
            raise UnitConverterValidationError("Invalid from_unit for temperature", field="from_unit")

        # Convert Celsius to to_unit
        if to_unit == "Celsius":
            return celsius
        elif to_unit == "Fahrenheit":
            return (celsius * 9.0 / 5.0) + 32.0
        elif to_unit == "Kelvin":
            return celsius + 273.15
        else:
            raise UnitConverterValidationError("Invalid to_unit for temperature", field="to_unit")
