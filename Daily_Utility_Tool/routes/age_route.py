from fastapi import APIRouter, HTTPException, Query
from models.age_model import AgeRequest
from services.age_service import AgeService

router = APIRouter(prefix="/api/v1/age", tags=["Age"])


@router.post("/calculate")
def calculate_age(payload: AgeRequest):
    try:
        result = AgeService.calculate_age(
            dob_str=payload.dob,
            target_str=payload.target_date,
            timezone=payload.timezone,
        )

        return {
            "message": "Age calculated successfully",
            "data": result
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/calculate")
def calculate_age_get(
    dob: str = Query(..., description="Date of Birth (YYYY-MM-DD)"),
    target_date: str = Query(None, description="Target Date (YYYY-MM-DD)"),
    timezone: str = Query("UTC", description="Timezone (default UTC)")
):
    try:
        result = AgeService.calculate_age(
            dob_str=dob,
            target_str=target_date,
            timezone=timezone,
        )

        return {
            "message": "Age calculated successfully (GET)",
            "data": result
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
