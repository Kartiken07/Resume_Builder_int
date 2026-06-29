// ============================================================================
// BASE URL
// ============================================================================

// Backend host URL used by all API requests - Now through Nginx reverse proxy
const String apiBaseUrl = 'http://192.168.1.6';

// ============================================================================
// EMI ENDPOINTS
// ============================================================================

// POST: Calculate EMI based on principal, rate, tenure, unit and frequency.
const String emiCalculateEndpoint = '/api/v1/emi/calculate';

// POST: Generate full amortization schedule and summary.
const String emiAmortizationScheduleEndpoint =
    '/api/v1/emi/amortization-schedule';

// POST: Analyze impact of one or more prepayments.
const String emiPrepaymentAnalysisEndpoint = '/api/v1/emi/prepayment-analysis';

// POST: Reverse calculation for loan amount from target EMI.
const String emiReverseLoanAmountEndpoint = '/api/v1/emi/reverse/loan-amount';

// POST: Reverse calculation for required interest rate from target EMI.
const String emiReverseRequiredRateEndpoint =
    '/api/v1/emi/reverse/required-rate';

// POST: Reverse calculation for tenure from target EMI.
const String emiReverseTenureEndpoint = '/api/v1/emi/reverse/tenure';

// POST: Compare multiple loan options side-by-side.
const String emiCompareEndpoint = '/api/v1/emi/compare';

// POST: Calculate loan eligibility based on FOIR.
const String emiEligibilityEndpoint = '/api/v1/emi/eligibility';

// GET: Retrieve EMI calculation history.
const String emiHistoryEndpoint = '/api/v1/emi/history';

// ============================================================================
// BARCODE ENDPOINTS
// ============================================================================

// POST: Generate barcode image from input data and barcode type.
const String barcodeGenerateEndpoint = '/api/v1/barcodes/generate';

// GET: Retrieve barcode generation history.
const String barcodeHistoryEndpoint = '/api/v1/barcodes/history';

// GET: Download barcode image by history ID.
const String barcodeDownloadEndpoint = '/api/v1/barcodes/download';

// ============================================================================
// UNIT CONVERTER ENDPOINTS
// ============================================================================

// GET: Get all supported unit categories.
const String unitConverterCategoriesEndpoint = '/api/v1/converter/categories';

// GET: Get all supported units for a given category.
const String unitConverterUnitsEndpoint = '/api/v1/converter/units';

// POST: Convert a value between units within a category.
const String unitConverterConvertEndpoint = '/api/v1/converter/convert';

// ============================================================================
// QR CODE ENDPOINTS
// ============================================================================

// POST: Generate QR code with customization options.
const String qrCodeGenerateEndpoint = '/api/v1/qr/generate';

// POST: Download QR image
const String qrDownloadEndpoint = '/api/v1/qr/download';

// ============================================================================
// AGE CALCULATOR ENDPOINT
// ============================================================================

// POST: Calculate age with advanced analytics
const String ageCalculateEndpoint = '/api/v1/age/calculate';
