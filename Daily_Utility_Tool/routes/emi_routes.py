from fastapi import APIRouter, HTTPException, status
from models.emi_models import (
    EMIRequest, EMIResponse, EMIResponseData,
    AmortizationScheduleRequest, AmortizationScheduleResponse, AmortizationScheduleRow, AmortizationScheduleSummary,
    PrepaymentAnalysisRequest, PrepaymentAnalysisResponse,
    ReverseCalculationLoanAmountRequest, ReverseCalculationRateRequest, ReverseCalculationTenureRequest,
    EligibilityRequest, EligibilityResponse, EligibilityResponseData,
    ReverseCalculationResponse,
    LoanComparisonRequest, LoanComparisonResponse, LoanComparisonResult,
    PaymentFrequency,
)
from services.emi_service import EMIService, EMIValidationError

router = APIRouter(prefix="/api/v1/emi", tags=["EMI Calculator"])


def handle_emi_error(e: Exception) -> HTTPException:
    """Common error handler for EMI calculations"""
    if isinstance(e, EMIValidationError):
        return HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": e.field, "message": e.message}
        )
    return HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail=str(e)
    )


@router.post("/calculate", response_model=EMIResponse)
def calculate_emi(request: EMIRequest):
    try:
        result = EMIService.calculate_emi(
            principal=request.principal,
            rate=request.rate,
            time=request.time,
            unit=request.unit,
            payment_frequency=request.payment_frequency,
        )

        return EMIResponse(
            message="EMI calculated successfully",
            data=EMIResponseData(
                emi=result["emi"],
                total_interest=result["total_interest"],
                total_payment=result["total_payment"],
                payment_frequency=request.payment_frequency,
            )
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/amortization-schedule", response_model=AmortizationScheduleResponse)
def get_amortization_schedule(request: AmortizationScheduleRequest):
    try:
        tenure_months = EMIService._convert_tenure_to_months(request.time, request.unit)

        result = EMIService.generate_amortization_schedule(
            principal=request.principal,
            rate=request.rate,
            tenure_months=tenure_months,
            payment_frequency=request.payment_frequency,
            summary_by_year=request.summary_by_year,
        )

        schedule_rows = [
            AmortizationScheduleRow(**row) for row in result["schedule"]
        ]

        summary = AmortizationScheduleSummary(**result["summary"])

        return AmortizationScheduleResponse(
            message="Amortization schedule generated successfully",
            schedule=schedule_rows,
            summary=summary,
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/prepayment-analysis", response_model=PrepaymentAnalysisResponse)
def analyze_prepayments(request: PrepaymentAnalysisRequest):
    try:
        tenure_months = EMIService._convert_tenure_to_months(request.time, request.unit)

        prepayments_list = [
            {"amount": p.amount, "month": p.month}
            for p in request.prepayments
        ]

        result = EMIService.calculate_prepayment_impact(
            principal=request.principal,
            rate=request.rate,
            tenure_months=tenure_months,
            payment_frequency=request.payment_frequency,
            prepayments=prepayments_list,
        )

        return PrepaymentAnalysisResponse(
            message="Prepayment analysis completed successfully",
            original_emi=result["original_emi"],
            original_total_interest=result["original_total_interest"],
            impacts=result["impacts"],
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/reverse/loan-amount", response_model=ReverseCalculationResponse)
def calculate_loan_amount(request: ReverseCalculationLoanAmountRequest):
    try:
        tenure_months = EMIService._convert_tenure_to_months(request.time, request.unit)

        result = EMIService.calculate_reverse_loan_amount(
            target_emi=request.target_emi,
            rate=request.rate,
            tenure_months=tenure_months,
            payment_frequency=request.payment_frequency,
        )

        return ReverseCalculationResponse(
            message="Loan amount calculated successfully",
            calculated_value=result["calculated_value"],
            unit="Loan Amount (₹)",
            validation_warnings=result["validation_warnings"],
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/eligibility", response_model=EligibilityResponse)
def calculate_loan_eligibility(request: EligibilityRequest):
    try:
        result = EMIService.calculate_loan_eligibility(
            monthly_income=request.monthly_income,
            existing_emi=request.existing_emi,
            foir_limit=request.foir_limit,
            rate=request.rate,
            time=request.time,
            unit=request.unit,
            payment_frequency=request.payment_frequency,
        )

        return EligibilityResponse(
            message="Loan eligibility calculated successfully",
            data=EligibilityResponseData(**result),
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/reverse/required-rate", response_model=ReverseCalculationResponse)
def calculate_required_rate(request: ReverseCalculationRateRequest):
    try:
        tenure_months = EMIService._convert_tenure_to_months(request.time, request.unit)

        result = EMIService.calculate_reverse_required_rate(
            principal=request.principal,
            target_emi=request.target_emi,
            tenure_months=tenure_months,
            payment_frequency=request.payment_frequency,
        )

        return ReverseCalculationResponse(
            message="Required interest rate calculated successfully",
            calculated_value=result["calculated_value"],
            unit="Annual Interest Rate (%)",
            validation_warnings=result["validation_warnings"],
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/reverse/tenure", response_model=ReverseCalculationResponse)
def calculate_tenure(request: ReverseCalculationTenureRequest):
    try:
        result = EMIService.calculate_reverse_tenure(
            principal=request.principal,
            rate=request.rate,
            target_emi=request.target_emi,
            payment_frequency=request.payment_frequency,
        )

        return ReverseCalculationResponse(
            message="Required tenure calculated successfully",
            calculated_value=result["calculated_value"],
            unit=result["unit"],
            validation_warnings=result["validation_warnings"],
        )

    except Exception as e:
        raise handle_emi_error(e)


@router.post("/compare", response_model=LoanComparisonResponse)
def compare_loans(request: LoanComparisonRequest):
    try:
        loans_data = [
            {
                "principal": loan.principal,
                "rate": loan.rate,
                "tenure_months": loan.tenure_months,
                "payment_frequency": loan.payment_frequency,
            }
            for loan in request.loans
        ]

        result = EMIService.compare_loans(loans_data)

        comparison_results = [
            LoanComparisonResult(**loan) for loan in result["loans"]
        ]

        return LoanComparisonResponse(
            message="Loan comparison completed successfully",
            loans=comparison_results,
        )

    except Exception as e:
        raise handle_emi_error(e)