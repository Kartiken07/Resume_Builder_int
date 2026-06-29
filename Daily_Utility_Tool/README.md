# Daily Utility Tools — Backend

A **FastAPI** backend providing REST APIs for everyday utility features: barcode generation, QR code generation, age calculation, EMI/loan calculations, and unit conversion.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Request Lifecycle](#request-lifecycle)
- [Project Structure](#project-structure)
- [Module Map](#module-map)
- [API Reference](#api-reference)
  - [Barcode Generator](#barcode-generator)
  - [QR Code Generator](#qr-code-generator)
  - [Age Calculator](#age-calculator)
  - [EMI Calculator](#emi-calculator)
  - [Unit Converter](#unit-converter)
- [Error Handling](#error-handling)
- [Getting Started](#getting-started)

---

## Architecture Overview

How the project is layered — every request moves through these four tiers in order.

```mermaid
graph TD
    Client(["🌐 Client"])

    subgraph FastAPI["FastAPI Application (main.py)"]
        MW["CORS Middleware"]
        EH["Global Error Handlers\nHTTP · Validation · 500"]
    end

    subgraph Routers["Routers  /api/v1/..."]
        R1["/barcodes"]
        R2["/generate  /download"]
        R3["/age"]
        R4["/emi"]
        R5["/converter"]
    end

    subgraph Services["Services  (business logic)"]
        S1["BarcodeService"]
        S2["QRService"]
        S3["AgeService"]
        S4["EMIService"]
        S5["UnitConverterService"]
    end

    subgraph Models["Pydantic Models  (validation + schema)"]
        M1["BarcodeModels"]
        M2["QRModels"]
        M3["AgeModels"]
        M4["EMIModels"]
        M5["UnitConverterModels"]
    end

    Client --> MW --> EH
    EH --> R1 & R2 & R3 & R4 & R5
    R1 --> S1 --> M1
    R2 --> S2 --> M2
    R3 --> S3 --> M3
    R4 --> S4 --> M4
    R5 --> S5 --> M5
```

---

## Request Lifecycle

What happens from the moment a request arrives to the moment a response leaves.

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant MW as CORS Middleware
    participant R as Router
    participant P as Pydantic Model
    participant S as Service
    participant EH as Error Handler

    C->>MW: HTTP Request
    MW->>R: Forwarded request
    R->>P: Deserialise + validate body
    alt Validation fails
        P-->>EH: RequestValidationError
        EH-->>C: 422 + error details
    end
    P->>S: Validated data object
    alt Business logic error
        S-->>EH: ValidationError / ValueError
        EH-->>C: 400 / 422 + field + message
    end
    alt Unhandled exception
        S-->>EH: Exception
        EH-->>C: 500 Internal server error
    end
    S-->>R: Result dict / object
    R-->>C: 200 JSON response
```

---

## Project Structure

```
Daily_Utility_Tools_Backend_/
├── main.py                       ← App entry, middleware, error handlers
├── requirements.txt
├── .env                          ← Secrets (not committed)
├── alembic.ini
├── alembic/
│   └── env.py                    ← DB migration config
├── models/
│   ├── age_model.py
│   ├── barcode_models.py         ← Also holds ErrorItem + ErrorResponse
│   ├── emi_models.py
│   ├── qr_model.py
│   └── unit_converter_models.py
├── routes/
│   ├── age_route.py              ← GET + POST /api/v1/age/calculate
│   ├── barcode_routes.py         ← POST /api/v1/barcodes/generate|download
│   ├── emi_routes.py             ← 8 endpoints under /api/v1/emi
│   ├── qr_routes.py              ← GET + POST /generate|download
│   └── unit_converter_routes.py  ← GET /categories · GET /units · GET+POST /convert
└── services/
    ├── age_service.py
    ├── barcode_service.py
    ├── emi_service.py
    ├── qr_service.py
    └── unit_converter_service.py
```

---

## Module Map

All five modules, their endpoints, inputs, and outputs at a glance.

### 🔲 Barcode Generator — `/api/v1/barcodes`

| Method | Endpoint | Input | Output |
|---|---|---|---|
| POST | `/generate` | `data`, `barcode_type` | JSON with `image_base64` + `data_uri` |
| POST | `/download` | `data`, `barcode_type` | PNG file download |

**Types:** `code128` · `code39` · `code93` · `ean8` · `ean13` · `upc` · `isbn10` · `isbn13` · `issn` · `gs1_128` · `ean`

---

### 📱 QR Code Generator — `/`

| Method | Endpoint | Input | Output |
|---|---|---|---|
| POST | `/generate` | `data`, `qr_type`, `size`, `fill_color`, `back_color`, `error_correction`, `shape`, `frame`, `output_format` | JSON with `image` + `data_uri` |
| GET | `/generate` | `data`, `qr_type` (query params) | JSON with `image` + `data_uri` |
| POST | `/download` | same as generate | PNG file download |

**Auto-detected types:** `url` · `email` · `phone` · `wifi` · `location` · `vcard` · `whatsapp` · `social` · `text`

---

### 🎂 Age Calculator — `/api/v1/age`

| Method | Endpoint | Input | Output |
|---|---|---|---|
| POST | `/calculate` | `dob`, `target_date`, `timezone` | Full age breakdown (see below) |
| GET | `/calculate` | same as query params | Full age breakdown |

**Output fields:** `years` · `months` · `days` · `total_days` · `total_weeks` · `total_hours` · `next_birthday_days` · `day_of_birth` · `zodiac_sign` · `working_days` · `weekends` · `life_progress` · `planetary_age` · `famous_birthdays` · `historical_event`

---

### 💰 EMI Calculator — `/api/v1/emi`

| Method | Endpoint | Input | Output |
|---|---|---|---|
| POST | `/calculate` | `principal`, `rate`, `time`, `unit`, `payment_frequency` | `emi`, `total_interest`, `total_payment` |
| POST | `/amortization-schedule` | same + `summary_by_year` | Period-by-period payment breakdown |
| POST | `/prepayment-analysis` | same + `prepayments[]` | Interest saved, tenure saved per prepayment |
| POST | `/eligibility` | `monthly_income`, `existing_emi`, `foir_limit`, `rate`, `time` | `max_affordable_emi`, `eligible_loan_amount` |
| POST | `/compare` | `loans[]` (2–10 items) | Ranked by total cost with cost difference |
| POST | `/reverse/loan-amount` | `target_emi`, `rate`, `time` | Max principal for that EMI |
| POST | `/reverse/required-rate` | `principal`, `target_emi`, `time` | Interest rate needed |
| POST | `/reverse/tenure` | `principal`, `rate`, `target_emi` | Tenure needed |

**Payment frequencies:** `monthly` · `quarterly` · `semi_annual` · `annual`

---

### 🔁 Unit Converter — `/api/v1/converter`

| Method | Endpoint | Input | Output |
|---|---|---|---|
| GET | `/categories` | — | List of all 12 categories |
| GET | `/units` | `category` (query param) | List of supported units for that category |
| POST | `/convert` | `category`, `value`, `from_unit`, `to_unit` | `result` (rounded to 4 decimal places) |
| GET | `/convert` | same as query params (`fromUnit`, `toUnit`) | `result` |

**Supported categories:** `length` · `weight` · `volume` · `area` · `speed` · `time` · `temperature` · `digital_storage` · `pressure` · `energy` · `power` · `angle`

---

## API Reference

### Barcode Generator

```mermaid
flowchart LR
    IN["Input\ndata · barcode_type"]
    V{"Validate"}
    N["Normalise\nstrip · checksum"]
    G["Generate PNG\npython-barcode"]
    B64["Base64 encode"]
    OUT["Response\nimage_base64 · data_uri"]
    ERR["422\nfield + message"]

    IN --> V
    V -- invalid --> ERR
    V -- valid --> N --> G --> B64 --> OUT
```

**Supported types:** `code128` · `code39` · `code93` · `ean8` · `ean13` · `upc` · `isbn10` · `isbn13` · `issn` · `gs1_128` · `ean`

| Endpoint | Method | Returns |
|---|---|---|
| `/api/v1/barcodes/generate` | POST | JSON with `image_base64` + `data_uri` |
| `/api/v1/barcodes/download` | POST | PNG file (`barcode.png`) |

**Request body**
```json
{ "data": "5901234123457", "barcode_type": "ean13" }
```

---

### QR Code Generator

```mermaid
flowchart LR
    IN["Input\ndata · options"]
    DT{"Auto-detect\nQR type"}
    NRM["Normalise\nURL prefix · tel: · mailto:"]
    FMT{"Format?"}
    SVG["SVG output"]
    PNG["PNG output\n+ shape mask\n+ optional logo/frame"]
    B64["Base64 encode"]
    OUT["Response\nqr_type · image · data_uri"]

    IN --> DT --> NRM --> FMT
    FMT -- svg --> SVG --> B64 --> OUT
    FMT -- png --> PNG --> B64 --> OUT
```

**Type auto-detection logic**

```mermaid
flowchart TD
    D["raw input"]
    D --> U1{"maps.google.com\nor goo.gl/maps?"}
    U1 -- yes --> LOC["location"]
    U1 -- no --> U2{"social pattern?\ninstagram/fb/linkedin..."}
    U2 -- yes --> SOC["social"]
    U2 -- no --> U3{"email pattern?"}
    U3 -- yes --> EML["email  →  mailto:"]
    U3 -- no --> U4{"phone pattern?\n7–15 digits"}
    U4 -- yes --> PHN["phone  →  tel:"]
    U4 -- no --> U5{"starts with http?"}
    U5 -- yes --> URL["url"]
    U5 -- no --> U6{"has dot, no space?"}
    U6 -- yes --> URL2["url  →  https://prefix"]
    U6 -- no --> TXT["text"]
```

| Endpoint | Method | Returns |
|---|---|---|
| `/generate` | POST / GET | JSON with `image` + `data_uri` |
| `/download` | POST | PNG file (`qr.png`) |

---

### Age Calculator

```mermaid
flowchart LR
    IN["Input\ndob · target_date · timezone"]
    PD["Parse date\n3 formats accepted"]
    TZ["Resolve timezone\ndefault UTC"]
    CALC["Calculate\nyears · months · days\ntotal days/weeks/hours"]
    ENR["Enrich\nzodiac · day of week\nworkdays · weekends\nplanetary age\nfamous birthdays\nhistorical event"]
    OUT["Response JSON"]

    IN --> PD --> TZ --> CALC --> ENR --> OUT
```

**Accepted date formats:** `YYYY-MM-DD` · `DD-MM-YYYY` · `DD/MM/YYYY`

| Endpoint | Method |
|---|---|
| `/api/v1/age/calculate` | POST + GET |

---

### EMI Calculator

Eight endpoints covering the full loan analysis lifecycle.

```mermaid
flowchart TD
    IN["Loan inputs\nprincipal · rate · time · unit\npayment_frequency"]

    subgraph Core
        C["POST /calculate\nEMI · total interest · total payment"]
        A["POST /amortization-schedule\nPeriod-by-period breakdown"]
    end

    subgraph Analysis
        PR["POST /prepayment-analysis\nInterest saved · tenure saved"]
        EL["POST /eligibility\nMax EMI · eligible loan amount\n(based on FOIR)"]
        CM["POST /compare\nRank 2–10 loans by total cost"]
    end

    subgraph Reverse
        RL["POST /reverse/loan-amount\nTarget EMI → max principal"]
        RR["POST /reverse/required-rate\nTarget EMI → required interest rate"]
        RT["POST /reverse/tenure\nTarget EMI → required tenure"]
    end

    IN --> Core & Analysis & Reverse
```

**Payment frequencies:** `monthly` · `quarterly` · `semi_annual` · `annual`

---

## Error Handling

All endpoints share one consistent error shape.

```mermaid
flowchart LR
    ERR["Exception raised"]

    ERR --> T1{"HTTPException?"}
    T1 -- yes --> FMT1["ErrorResponse\nmessage + errors list"]

    ERR --> T2{"RequestValidationError?"}
    T2 -- yes --> FMT2["422\nper-field error list"]

    ERR --> T3{"Unhandled?"}
    T3 -- yes --> FMT3["500\nInternal server error"]

    FMT1 & FMT2 & FMT3 --> SHAPE["{ success: false\n  message: string\n  errors: [{field, message}]\n  details: object | null }"]
```

---

## Getting Started

### Prerequisites
- Python 3.12+

### Installation

```bash
git clone https://github.com/naiyo-24/Daily_Utility_Tools_Backend_.git
cd Daily_Utility_Tools_Backend_

python -m venv venv
source venv/bin/activate       # Windows: venv\Scripts\activate

pip install -r requirements.txt
cp .env.example .env           # edit as needed
```

### Run

```bash
uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

- Swagger UI → `http://127.0.0.1:8000/docs`
- ReDoc → `http://127.0.0.1:8000/redoc`
- Health check → `GET /health`

### Database migrations

```bash
alembic upgrade head                              # apply migrations
alembic revision --autogenerate -m "description" # new migration
alembic downgrade -1                              # rollback one
```

---

### Unit Converter

```mermaid
flowchart LR
    IN["Input\ncategory · value\nfrom_unit · to_unit"]
    VC{"Validate\ncategory + units"}
    TC{"Temperature?"}
    TEMP["Special formula\nCelsius ↔ Fahrenheit ↔ Kelvin"]
    MULT["Multiplicative\nvalue × factor_from ÷ factor_to"]
    RND["Round to 4 decimal places"]
    OUT["result"]
    ERR["422\nfield + message"]

    IN --> VC
    VC -- invalid --> ERR
    VC -- valid --> TC
    TC -- yes --> TEMP --> RND --> OUT
    TC -- no --> MULT --> RND --> OUT
```

**Supported categories and units**

| Category | Units |
|---|---|
| Length | `m` `km` `cm` `mm` `dm` `nm` `um` `mile` `yard` `foot` `inch` `nautical_mile` |
| Weight | `kg` `g` `mg` `ton` `pound` `ounce` `stone` `dram` |
| Volume | `liter` `ml` `gallon` `cup` `pint` `quart` |
| Area | `sq_m` `sq_km` `sq_ft` `acre` `hectare` |
| Speed | `m/s` `km/h` `mph` `knot` |
| Time | `second` `minute` `hour` `day` `week` |
| Temperature | `Celsius` `Fahrenheit` `Kelvin` |
| Digital Storage | `bit` `byte` `KB` `MB` `GB` `TB` `PB` |
| Pressure | `pascal` `bar` `psi` `atm` |
| Energy | `joule` `kj` `calorie` `kcal` `wh` `kwh` |
| Power | `watt` `kw` `hp` |
| Angle | `degree` `radian` `gradian` |

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/converter/categories` | GET | List all supported categories |
| `/api/v1/converter/units?category=length` | GET | List units for a category |
| `/api/v1/converter/convert` | POST + GET | Perform conversion |

**Request body**
```json
{ "category": "length", "value": 100, "from_unit": "m", "to_unit": "foot" }
```

**Response**
```json
{ "result": 328.084 }
```