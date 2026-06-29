# Nginx Reverse Proxy

Independent Nginx reverse proxy for URL Shortener application.

## Overview

This Nginx instance acts as a **reverse proxy** in front of the FastAPI backend, providing:
- Single entry point on port 80
- Rate limiting
- CORS handling
- Request logging
- Security layer

## Architecture

```
Client Request (Port 80)
    ↓
Nginx Reverse Proxy (This Service)
    ↓
FastAPI Backend (Port 8000 - Internal)
```

## Quick Start

### Prerequisites
- Docker Desktop running
- Backend API must be running
- Shared network: `url-shortener-network`

### Start Nginx
```powershell
.\start-nginx.ps1
```

### Stop Nginx
```powershell
.\stop-nginx.ps1
```

## Configuration

### nginx.conf Features

**Rate Limiting:**
- 10 requests per second per IP
- Burst of 20 requests allowed
- Prevents API abuse

**CORS Headers:**
- Allows all origins (*)
- Supports all common HTTP methods
- Handles preflight requests

**Proxy Settings:**
- Preserves client IP
- Forwards headers
- 60-second timeouts

**Security:**
- 10MB upload limit
- Client buffer protection
- Request/error logging

## Management

### View Logs
```powershell
docker compose logs -f
```

### Restart
```powershell
docker compose restart
```

### Reload Configuration
```powershell
# After editing nginx.conf
docker compose restart
```

## Endpoints

### Health Check
```http
GET /health
```
Returns: `Nginx is running`

### API Documentation
```http
GET /docs
```
Proxied to backend FastAPI Swagger UI

### All API Endpoints
```http
GET/POST/PUT/DELETE /*
```
All requests are proxied to backend

## Access URLs

**Local Machine:**
- http://localhost/health
- http://localhost/docs
- http://localhost/shorten

**Network Access:**
- http://192.168.1.6/health
- http://192.168.1.6/docs
- http://192.168.1.6/shorten

## Customization

Edit `nginx.conf` to modify:
- Rate limiting: `limit_req_zone` and `limit_req`
- Upload size: `client_max_body_size`
- Timeouts: `proxy_*_timeout`
- CORS origins: `Access-Control-Allow-Origin`

After changes:
```powershell
docker compose restart
```

## Troubleshooting

### Nginx Won't Start
```powershell
# Check if port 80 is available
netstat -ano | findstr :80

# Check if backend is running
docker ps | findstr backend
```

### 502 Bad Gateway
Backend is not running or not reachable:
```powershell
# Start backend
cd ..\Minima
.\start-api.ps1
```

### Configuration Errors
```powershell
# Test configuration
docker compose exec nginx nginx -t

# View error logs
docker compose logs nginx
```

## Dependencies

Nginx depends on:
- **Backend API** - Must be running on the same network
- **Shared Network** - `url-shortener-network`

Does NOT depend on:
- Database (connects through backend)
- Frontend (served separately)

## Tech Stack

- **Image:** nginx:alpine
- **Port:** 80 (HTTP)
- **Network:** url-shortener-network (shared)

## Related Services

- **Backend API:** `c:\Users\NITRO\Desktop\Integrate\Minima\`
- **Database:** `c:\Users\NITRO\Desktop\Integrate\Database\`
- **Frontend:** `c:\Users\NITRO\Desktop\Integrate\Frontend\`

## Current Status

✅ Nginx decoupled and running independently
✅ Reverse proxy to backend API
✅ Rate limiting enabled
✅ CORS configured

---

**Location:** `c:\Users\NITRO\Desktop\Integrate\Nginx\`
