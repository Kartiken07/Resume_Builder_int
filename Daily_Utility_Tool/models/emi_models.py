from pydantic import BaseModel, Field, validator
from enum import Enum
from typing import List, Optional


class TimeUnit(str, Enum):
    MONTHS = "months"
    YEARS = "years"


class PaymentFrequency(str, Enum):
    MONTHLY = "monthly"
    QUARTERLY = "quarterly"
    SEMI_ANNUAL = "semi_annual"
    ANNUAL = "annual"


# ============= Request Models =============

class EMIRequest(BaseModel):
    principal: float = Field(..., gt=0, description="Loan amount")
    rate: float = Field(..., gt=0, description="Annual interest rate (percentage)")
    time: int = Field(..., gt=0, description="Duration in specified unit")
    unit: TimeUnit = Field(default=TimeUnit.MONTHS)
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY, description="Payment frequency")


class AmortizationScheduleRequest(BaseModel):
    principal: float = Field(..., gt=0)
    rate: float = Field(..., gt=0)
    time: int = Field(..., gt=0)
    unit: TimeUnit = Field(default=TimeUnit.MONTHS)
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY)
    summary_by_year: bool = Field(default=False, description="Return yearly summaries for long tenures")


class PrepaymentScenario(BaseModel):
    amount: float = Field(..., gt=0, description="Prepayment amount")
    month: int = Field(..., gt=0, description="Month when prepayment is made (1-indexed)")


class PrepaymentAnalysisRequest(BaseModel):
    principal: float = Field(..., gt=0)
    rate: float = Field(..., gt=0)
    time: int = Field(..., gt=0)
    unit: TimeUnit = Field(default=TimeUnit.MONTHS)
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY)
    prepayments: List[PrepaymentScenario] = Field(default_factory=list, description="List of prepayment scenarios")

    @validator("prepayments")
    def validate_prepayment_months_within_tenure(cls, v, values):
        time = values.get("time")
        unit = values.get("unit", TimeUnit.MONTHS)

        if time is None:
            return v

        tenure_months = time * 12 if unit == TimeUnit.YEARS else time
        invalid_months = [p.month for p in v if p.month > tenure_months]

        if invalid_months:
            raise ValueError(
                f"Prepayment month(s) {invalid_months} exceed loan tenure of {tenure_months} months"
            )

        return v


class ReverseCalculationLoanAmountRequest(BaseModel):
    target_emi: float = Field(..., gt=0, description="Desired EMI amount")
    rate: float = Field(..., gt=0, description="Annual interest rate (percentage)")
    time: int = Field(..., gt=0, description="Loan tenure")
    unit: TimeUnit = Field(default=TimeUnit.MONTHS)
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY)


class ReverseCalculationRateRequest(BaseModel):
    principal: float = Field(..., gt=0)
    target_emi: float = Field(..., gt=0, description="Desired EMI amount")
    time: int = Field(..., gt=0, description="Loan tenure")
    unit: TimeUnit = Field(default=TimeUnit.MONTHS)
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY)


class ReverseCalculationTenureRequest(BaseModel):
    principal: float = Field(..., gt=0)
    rate: float = Field(..., gt=0)
    target_emi: float = Field(..., gt=0, description="Desired EMI amount")
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY)


class EligibilityRequest(BaseModel):
    monthly_income: float = Field(..., gt=0, description="Monthly income of the applicant")
    existing_emi: float = Field(..., ge=0, description="Total ongoing EMI obligations")
    foir_limit: float = Field(..., gt=0, description="Fixed Obligation to Income Ratio percentage")
    rate: float = Field(..., gt=0, description="Annual interest rate (percentage)")
    time: int = Field(..., gt=0, description="Loan tenure")
    unit: TimeUnit = Field(default=TimeUnit.YEARS)
    payment_frequency: PaymentFrequency = Field(default=PaymentFrequency.MONTHLY)


class EligibilityResponseData(BaseModel):
    monthly_income: float
    existing_emi: float
    foir_limit: float
    max_affordable_emi: float
    eligible_loan_amount: float
    rate: float
    tenure: int
    unit: TimeUnit
    payment_frequency: PaymentFrequency


class EligibilityResponse(BaseModel):
    success: bool = True
    message: str
    data: EligibilityResponseData


class LoanComparisonItem(BaseModel):
    principal: float = Field(..., gt=0)
    rate: float = Field(..., gt=0)
    tenure_months: int = Field(..., gt=0)
    payment_frequency: PaymentFrequency


class LoanComparisonRequest(BaseModel):
    loans: List[LoanComparisonItem] = Field(..., min_items=2, max_items=10)


# ============= Response Models =============

class EMIResponseData(BaseModel):
    emi: float
    total_interest: float
    total_payment: float
    payment_frequency: PaymentFrequency = PaymentFrequency.MONTHLY


class EMIResponse(BaseModel):
    success: bool = True
    message: str
    data: EMIResponseData


class AmortizationScheduleRow(BaseModel):
    period: int = Field(description="Payment period (1-indexed)")
    payment: float
    principal_portion: float
    interest_portion: float
    remaining_balance: float


class AmortizationScheduleSummary(BaseModel):
    total_emi_paid: float
    total_principal_paid: float
    total_interest_paid: float
    final_balance: float


class AmortizationScheduleResponse(BaseModel):
    success: bool = True
    message: str
    schedule: List[AmortizationScheduleRow]
    summary: AmortizationScheduleSummary


class PrepaymentImpact(BaseModel):
    prepayment_amount: float
    prepayment_month: int
    original_tenure_months: int
    new_tenure_months: int
    months_saved: int
    original_total_interest: float
    new_total_interest: float
    interest_saved: float
    new_emi: Optional[float] = None


class PrepaymentAnalysisResponse(BaseModel):
    success: bool = True
    message: str
    original_emi: float
    original_total_interest: float
    impacts: List[PrepaymentImpact]


class ReverseCalculationResponse(BaseModel):
    success: bool = True
    message: str
    calculated_value: float
    unit: str = Field(description="Unit of the calculated value (amount, rate %, or months)")
    validation_warnings: List[str] = Field(default_factory=list)


class LoanComparisonResult(BaseModel):
    rank: int
    principal: float
    rate: float
    tenure_months: int
    payment_frequency: PaymentFrequency
    emi: float
    total_interest: float
    total_payment: float
    cost_difference_from_cheapest: float = 0.0


class LoanComparisonResponse(BaseModel):
    success: bool = True
    message: str
    loans: List[LoanComparisonResult]