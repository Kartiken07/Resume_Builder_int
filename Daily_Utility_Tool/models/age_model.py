from pydantic import BaseModel
from typing import Optional


class AgeRequest(BaseModel):
    dob: str                      # auto-detect format
    target_date: Optional[str] = None
    timezone: Optional[str] = "UTC"


class AgeResponse(BaseModel):
    years: int
    months: int
    days: int
    next_birthday_days: int

    total_days: int
    total_weeks: int
    total_hours: int

    day_of_birth: str
    zodiac_sign: str

    working_days: int
    weekends: int

    life_progress: float

    historical_event: str
    famous_birthdays: list
