# URL Shortener - Backend API

Backend API service for the URL Shortener application.

## Overview

This is the **API layer only** - a decoupled FastAPI backend with Celery worker for background tasks.

**Dependencies:**
- Database services must be running (PostgreSQL + Redis)
- See: `c:\Users\NITRO\Desktop\Integrate\Database\`

## Quick Start

### Prerequisites
1. Docker Desktop installed and running
2. Database services running

### Start API

```powershell
.\start-api.ps1
```

The script will:
- Auto-detect your network IP
- Check if database is running
- Start FastAPI backend (Port 8000)
- Start Celery worker

## Services

| Service | Port | Purpose |
|---------|------|---------|
| FastAPI Backend | 8000 | REST API endpoints |
| Celery Worker | - | Background tasks (metadata scraping, analytics) |

## API Access

- **Documentation:** http://192.168.1.6:8000/docs
- **Base URL:** http://192.168.1.6:8000

## API Endpoints

### Create Short URL
```http
POST /shorten
Content-Type: application/json

{
  "original_url": "https://example.com/very/long/url",
  "custom_alias": "my-link",  // optional
  "expiry_time": "2026-12-31T23:59:59Z"  // optional
}
```

### Redirect to Original URL
```http
GET /{short_code}
```

### Get Analytics
```http
GET /{short_code}/stats
```

### Generate QR Code
```http
GET /qr/{short_code}
```

## Management

### Start
```powershell
.\start-api.ps1
```

### Stop
```powershell
docker compose -f docker-compose.api.yml down
```

### Restart
```powershell
docker compose -f docker-compose.api.yml restart
```

### View Logs
```powershell
# All services
docker compose -f docker-compose.api.yml logs -f

# Backend only
docker compose -f docker-compose.api.yml logs -f backend

# Worker only
docker compose -f docker-compose.api.yml logs -f worker
```

### Rebuild
```powershell
docker compose -f docker-compose.api.yml up --build -d
```

## Configuration

Edit `.env` file:

```env
API_BASE_URL=http://192.168.1.6:8000
DATABASE_URL=postgresql://user:password@postgres/url_db
REDIS_URL=redis://redis:6379/0
ALLOWED_ORIGINS=*
PYTHONPATH=./url_shortener_backend
```

## Project Structure

```
Minima/
├── docker-compose.api.yml          # API services configuration
├── start-api.ps1                   # Startup script
├── .env                            # Environment variables
├── SERVICES_GUIDE.md               # Detailed service guide
└── url_shortener_backend/          # Python source code
    ├── main.py                     # FastAPI application
    ├── api.py                      # API routes
    ├── models.py                   # Database models
    ├── schemas.py                  # Pydantic schemas
    ├── database.py                 # Database connection
    ├── redis_client.py             # Redis connection
    ├── tasks.py                    # Celery background tasks
    └── utils.py                    # Utility functions
```

## Development

### Backend Code Changes
```powershell
# Edit code in url_shortener_backend/

# Restart to apply changes
docker compose -f docker-compose.api.yml restart backend
```

### Add New Dependencies
```powershell
# Edit url_shortener_backend/pyproject.toml

# Rebuild containers
docker compose -f docker-compose.api.yml up --build -d
```

### Database Migrations
```powershell
# Access backend container
docker exec -it backend bash

# Run migrations (if using alembic)
poetry run alembic upgrade head
```

## Troubleshooting

### API Won't Start
```powershell
# Check if database is running
docker ps | findstr postgres
docker ps | findstr redis

# If not, start database first
cd ..\Database
.\start-database.ps1
```

### Connection Errors
```powershell
# Test database connection
docker exec postgres pg_isready -U user

# Test Redis connection
docker exec redis redis-cli ping

# Check network
docker network inspect url-shortener-network
```

### View Detailed Logs
```powershell
# Backend logs
docker logs backend --tail 50

# Worker logs
docker logs worker --tail 50
```

### Clean Restart
```powershell
docker compose -f docker-compose.api.yml down
docker compose -f docker-compose.api.yml up --build -d
```

## Architecture

This service connects to:
- **Database (PostgreSQL)** - Persistent storage
- **Redis** - Caching and message broker
- **Frontend** - Serves API requests

```
Database Services (External)
├── PostgreSQL (Port 5650)
└── Redis (Port 6379)
     ↓ (shared network)
Backend API (This Service)
├── FastAPI Backend (Port 8000)
└── Celery Worker
     ↓ (REST API)
Frontend (External)
└── Flutter Web App
```

## Related Services

- **Database:** `c:\Users\NITRO\Desktop\Integrate\Database\`
- **Frontend:** `c:\Users\NITRO\Desktop\Integrate\Frontend\flutter_app\`
- **Main Documentation:** `c:\Users\NITRO\Desktop\Integrate\README.md`

## Tech Stack

- **Framework:** FastAPI (Python 3.12)
- **Database:** PostgreSQL 15 + SQLAlchemy ORM
- **Cache:** Redis 7
- **Background Tasks:** Celery
- **Async Processing:** asyncio
- **Web Scraping:** BeautifulSoup4
- **Validation:** Pydantic
- **Server:** Uvicorn

## Current Status

✅ API service decoupled and running independently
✅ Connects to external database services
✅ Ready for development and deployment

---

**For detailed service management, see:** `SERVICES_GUIDE.md`
