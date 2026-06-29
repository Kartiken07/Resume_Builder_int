from typing import Dict, List, Tuple
from enum import Enum
import math

class PaymentFrequency(str, Enum):
    MONTHLY = "monthly"; QUARTERLY = "quarterly"; SEMI_ANNUAL = "semi_annual"; ANNUAL = "annual"

class EMIValidationError(Exception):
    def __init__(self, field: str, message: str):
        super().__init__(f"{field}: {message}")
        self.field = field
        self.message = message

class EMIService:
    MIN_RATE = 0.1
    MAX_RATE = 40.0
    MIN_TENURE_MONTHS = 1
    MAX_TENURE_MONTHS = 40 * 12
    FREQUENCY_MAP = {
        PaymentFrequency.MONTHLY.value: 12,
        PaymentFrequency.QUARTERLY.value: 4,
        PaymentFrequency.SEMI_ANNUAL.value: 2,
        PaymentFrequency.ANNUAL.value: 1,
    }

    @staticmethod
    def _validate_inputs(principal: float, rate: float, tenure_months: int) -> None:
        if principal <= 0:
            raise EMIValidationError("principal", "Principal must be greater than 0")
        if not (EMIService.MIN_RATE <= rate <= EMIService.MAX_RATE):
            raise EMIValidationError("rate", f"Interest rate must be between {EMIService.MIN_RATE}% and {EMIService.MAX_RATE}%")
        if not (EMIService.MIN_TENURE_MONTHS <= tenure_months <= EMIService.MAX_TENURE_MONTHS):
            raise EMIValidationError("tenure", f"Tenure must be between {EMIService.MIN_TENURE_MONTHS} month and {EMIService.MAX_TENURE_MONTHS // 12} years")

    @staticmethod
    def _get_payment_frequency_multiplier(payment_frequency: str) -> int:
        return EMIService.FREQUENCY_MAP.get(payment_frequency, 12)

    @staticmethod
    def _convert_tenure_to_months(time: int, unit: str) -> int:
        return time * 12 if unit == "years" else time

    @staticmethod
    def _get_effective_rate_and_periods(annual_rate: float, total_months: int, payment_frequency: str) -> Tuple[float, int]:
        payments_per_year = EMIService._get_payment_frequency_multiplier(payment_frequency)
        return annual_rate / (100 * payments_per_year), (total_months * payments_per_year) // 12

    @staticmethod
    def calculate_emi(principal: float, rate: float, time: int, unit: str, payment_frequency: str = "monthly") -> dict:
        tenure_months = EMIService._convert_tenure_to_months(time, unit)
        EMIService._validate_inputs(principal, rate, tenure_months)
        r, n = EMIService._get_effective_rate_and_periods(rate, tenure_months, payment_frequency)
        emi = principal / n if r == 0 else (principal * r * ((1 + r) ** n)) / (((1 + r) ** n) - 1)
        total_payment = emi * n
        return {"emi": round(emi, 2), "total_interest": round(total_payment - principal, 2), "total_payment": round(total_payment, 2)}

    @staticmethod
    def generate_amortization_schedule(principal: float, rate: float, tenure_months: int, payment_frequency: str = "monthly", summary_by_year: bool = False) -> dict:
        EMIService._validate_inputs(principal, rate, tenure_months)
        r, n = EMIService._get_effective_rate_and_periods(rate, tenure_months, payment_frequency)
        emi = principal / n if r == 0 else (principal * r * ((1 + r) ** n)) / (((1 + r) ** n) - 1)
        schedule = []
        remaining_balance = principal
        total_principal = 0
        total_interest = 0
        for period in range(1, int(n) + 1):
            interest_payment = remaining_balance * r
            principal_payment = emi - interest_payment
            remaining_balance -= principal_payment
            if remaining_balance < 0:
                principal_payment += remaining_balance
                remaining_balance = 0
            total_principal += principal_payment
            total_interest += interest_payment
            schedule.append({
                "period": period,
                "payment": round(emi, 2),
                "principal_portion": round(principal_payment, 2),
                "interest_portion": round(interest_payment, 2),
                "remaining_balance": round(remaining_balance, 2),
            })
        return {"schedule": schedule, "summary": {"total_emi_paid": round(emi * n, 2), "total_principal_paid": round(total_principal, 2), "total_interest_paid": round(total_interest, 2), "final_balance": round(remaining_balance, 2)}}

    @staticmethod
    def calculate_prepayment_impact(principal: float, rate: float, tenure_months: int, payment_frequency: str = "monthly", prepayments: List[Dict] = None) -> dict:
        prepayments = prepayments or []
        EMIService._validate_inputs(principal, rate, tenure_months)
        original = EMIService.calculate_emi(principal, rate, tenure_months, "months", payment_frequency)
        schedule = EMIService.generate_amortization_schedule(principal, rate, tenure_months, payment_frequency)["schedule"]
        impacts = []
        for prepayment in prepayments:
            amount = prepayment["amount"]
            month = prepayment["month"]
            if month > tenure_months:
                continue
            balance = schedule[month - 1]["remaining_balance"]
            if amount > balance:
                amount = balance
            new_principal = balance - amount
            remaining_tenure = tenure_months - month
            if new_principal <= 0:
                impacts.append({"prepayment_amount": prepayment["amount"], "prepayment_month": month, "original_tenure_months": tenure_months, "new_tenure_months": month, "months_saved": tenure_months - month, "original_total_interest": original["total_interest"], "new_total_interest": 0, "interest_saved": original["total_interest"], "new_emi": None})
            else:
                new_calc = EMIService.calculate_emi(new_principal, rate, remaining_tenure, "months", payment_frequency)
                interest_paid_until_prepay = sum(row["interest_portion"] for row in schedule[:month])
                new_total_interest = interest_paid_until_prepay + new_calc["total_interest"]
                impacts.append({"prepayment_amount": prepayment["amount"], "prepayment_month": month, "original_tenure_months": tenure_months, "new_tenure_months": remaining_tenure, "months_saved": tenure_months - (month + remaining_tenure - 1), "original_total_interest": original["total_interest"], "new_total_interest": new_total_interest, "interest_saved": original["total_interest"] - new_total_interest, "new_emi": new_calc["emi"]})
        return {"original_emi": original["emi"], "original_total_interest": original["total_interest"], "impacts": impacts}

    @staticmethod
    def calculate_reverse_loan_amount(target_emi: float, rate: float, tenure_months: int, payment_frequency: str = "monthly") -> dict:
        EMIService._validate_inputs(target_emi, rate, tenure_months)
        r, n = EMIService._get_effective_rate_and_periods(rate, tenure_months, payment_frequency)
        principal = target_emi * n if r == 0 else target_emi * ((((1 + r) ** n) - 1) / (r * ((1 + r) ** n)))
        warnings = ["Calculated principal is very high"] if principal > 10000000 else []
        return {"calculated_value": round(principal, 2), "unit": "amount", "validation_warnings": warnings}

    @staticmethod
    def calculate_reverse_required_rate(principal: float, target_emi: float, tenure_months: int, payment_frequency: str = "monthly") -> dict:
        if principal <= 0:
            raise EMIValidationError("principal", "Principal must be greater than 0")
        if target_emi <= 0:
            raise EMIValidationError("target_emi", "Target EMI must be greater than 0")
        if tenure_months <= 0:
            raise EMIValidationError("tenure", "Tenure must be greater than 0")

        payments_per_year = EMIService._get_payment_frequency_multiplier(payment_frequency)
        n = (tenure_months * payments_per_year) // 12

        if n <= 0:
            raise EMIValidationError("tenure", "Tenure must include at least one payment period")

        min_emi = principal / n
        if target_emi < min_emi:
            raise EMIValidationError(
                "target_emi",
                "Target EMI is too low for the given principal and tenure",
            )

        def emi_for_rate(annual_rate: float) -> float:
            periodic_rate = annual_rate / (100 * payments_per_year)
            return principal / n if periodic_rate == 0 else (principal * periodic_rate * ((1 + periodic_rate) ** n)) / (((1 + periodic_rate) ** n) - 1)

        low, high = 0.0, max(EMIService.MAX_RATE, 100.0)
        for _ in range(80):
            mid = (low + high) / 2
            if emi_for_rate(mid) > target_emi:
                high = mid
            else:
                low = mid

        calculated_rate = round((low + high) / 2, 4)
        warnings = []
        if calculated_rate > EMIService.MAX_RATE:
            warnings.append("Required interest rate exceeds typical upper bounds")

        return {
            "calculated_value": calculated_rate,
            "unit": "Annual Interest Rate (%)",
            "validation_warnings": warnings,
        }

    @staticmethod
    def calculate_reverse_tenure(principal: float, rate: float, target_emi: float, payment_frequency: str = "monthly") -> dict:
        if principal <= 0:
            raise EMIValidationError("principal", "Principal must be greater than 0")
        if rate < 0:
            raise EMIValidationError("rate", "Interest rate must be 0 or greater")
        if target_emi <= 0:
            raise EMIValidationError("target_emi", "Target EMI must be greater than 0")

        payments_per_year = EMIService._get_payment_frequency_multiplier(payment_frequency)
        periodic_rate = rate / (100 * payments_per_year)

        if periodic_rate == 0:
            periods = principal / target_emi
        else:
            interest_per_period = principal * periodic_rate
            if target_emi <= interest_per_period:
                raise EMIValidationError(
                    "target_emi",
                    "Target EMI is too low to cover interest at the specified rate",
                )
            periods = math.log(target_emi / (target_emi - interest_per_period)) / math.log(1 + periodic_rate)

        if periods <= 0:
            raise EMIValidationError("target_emi", "Unable to calculate tenure for the provided values")

        total_months = math.ceil(periods * 12 / payments_per_year)
        if total_months > EMIService.MAX_TENURE_MONTHS:
            raise EMIValidationError(
                "tenure",
                f"Calculated tenure cannot exceed {EMIService.MAX_TENURE_MONTHS} months",
            )

        unit = "years" if total_months % 12 == 0 else "months"
        calculated_value = total_months // 12 if unit == "years" else total_months

        return {
            "calculated_value": calculated_value,
            "unit": unit,
            "validation_warnings": [],
        }

    @staticmethod
    def compare_loans(loans: List[Dict]) -> dict:
        if len(loans) < 2:
            raise EMIValidationError("loans", "At least two loans are required for comparison")

        results = []
        for loan in loans:
            principal = loan["principal"]
            rate = loan["rate"]
            tenure_months = loan["tenure_months"]
            payment_frequency = loan["payment_frequency"]

            EMIService._validate_inputs(principal, rate, tenure_months)
            calculation = EMIService.calculate_emi(principal, rate, tenure_months, "months", payment_frequency)

            results.append({
                "principal": principal,
                "rate": rate,
                "tenure_months": tenure_months,
                "payment_frequency": payment_frequency,
                "emi": calculation["emi"],
                "total_interest": calculation["total_interest"],
                "total_payment": calculation["total_payment"],
            })

        sorted_loans = sorted(results, key=lambda x: x["total_payment"])
        cheapest_payment = sorted_loans[0]["total_payment"] if sorted_loans else 0.0

        comparison = []
        for index, loan in enumerate(sorted_loans, start=1):
            comparison.append({
                "rank": index,
                "principal": loan["principal"],
                "rate": loan["rate"],
                "tenure_months": loan["tenure_months"],
                "payment_frequency": loan["payment_frequency"],
                "emi": loan["emi"],
                "total_interest": loan["total_interest"],
                "total_payment": loan["total_payment"],
                "cost_difference_from_cheapest": round(loan["total_payment"] - cheapest_payment, 2),
            })

        return {"loans": comparison}

    @staticmethod
    def calculate_loan_eligibility(monthly_income: float, existing_emi: float, foir_limit: float, rate: float, time: int, unit: str, payment_frequency: str = "monthly") -> dict:
        if monthly_income <= 0:
            raise EMIValidationError("monthly_income", "Monthly income must be greater than 0")
        if existing_emi < 0:
            raise EMIValidationError("existing_emi", "Existing EMI must be zero or greater")
        if foir_limit <= 0:
            raise EMIValidationError("foir_limit", "FOIR limit must be greater than 0")
        if rate <= 0:
            raise EMIValidationError("rate", "Interest rate must be greater than 0")
        if time <= 0:
            raise EMIValidationError("time", "Loan tenure must be greater than 0")
        tenure_months = EMIService._convert_tenure_to_months(time, unit)
        if not (EMIService.MIN_TENURE_MONTHS <= tenure_months <= EMIService.MAX_TENURE_MONTHS):
            raise EMIValidationError("time", f"Tenure must be between {EMIService.MIN_TENURE_MONTHS} month and {EMIService.MAX_TENURE_MONTHS // 12} years")
        max_affordable_emi = (monthly_income * foir_limit / 100) - existing_emi
        if max_affordable_emi <= 0:
            raise EMIValidationError("foir_limit", "Provided income and existing EMIs do not leave any affordable EMI")
        reverse = EMIService.calculate_reverse_loan_amount(max_affordable_emi, rate, tenure_months, payment_frequency)
        return {"monthly_income": monthly_income, "existing_emi": existing_emi, "foir_limit": foir_limit, "max_affordable_emi": round(max_affordable_emi, 2), "eligible_loan_amount": reverse["calculated_value"], "rate": rate, "tenure": time, "unit": unit, "payment_frequency": payment_frequency}