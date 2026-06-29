# System Architecture Documentation

## Overview

This document explains the complete architecture of the integrated application stack, including how backends start up, connect to each other, and communicate through Nginx as a reverse proxy.

---

## Table of Contents

1. [Architecture Diagram](#architecture-diagram)
2. [Components Overview](#components-overview)
3. [Network Architecture](#network-architecture)
4. [Startup Sequence](#startup-sequence)
5. [Request Flow](#request-flow)
6. [Database Architecture](#database-architecture)
7. [Configuration Files](#configuration-files)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser/App)                     │
│                         Port: 80 (HTTP)                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP Requests
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Nginx Reverse Proxy                           │
│                    Container: nginx                              │
│                    Network: url-shortener-network                │
│                                                                   │
│  Routes:                                                          │
│  • /api/*       → Daily Utility Tool (host.docker.internal:8000)│
│  • /*           → Minima Backend (backend:8000)                  │
└─────────────┬───────────────────────────────────┬───────────────┘
              │                                   │
              │                                   │
              ↓                                   ↓
┌─────────────────────────────┐   ┌─────────────────────────────────┐
│  Daily Utility Tool Backend │   │     Minima Backend API          │
│  Type: Python Process       │   │     Container: backend          │
│  Port: 8000                 │   │     Port: 8000 (internal)       │
│  Framework: FastAPI/Uvicorn │   │     Framework: FastAPI          │
│  Location: Host Machine     │   │     Network: url-shortener-net  │
│                             │   │                                 │
│  Features:                  │   │     Features:                   │
│  • QR Code Generator        │   │     • URL Shortener             │
│  • Barcode Generator        │   │     • Link Analytics            │
│  • Unit Converter           │   │     • QR Generation             │
│  • Age Calculator           │   │     • Custom Aliases            │
│  • EMI Calculator           │   │                                 │
└─────────────────────────────┘   └────────────┬────────────────────┘
                                               │
                                               │ Connects to
                                               ↓
                    ┌──────────────────────────────────────────────┐
                    │         Database Layer                        │
                    │                                               │
                    │  ┌────────────────┐    ┌──────────────────┐ │
                    │  │  PostgreSQL    │    │      Redis       │ │
                    │  │  Container:    │    │  Container:      │ │
                    │  │  postgres      │    │  redis           │ │
                    │  │  Port: 5650    │    │  Port: 6379      │ │
                    │  │                │    │                  │ │
                    │  │  Stores:       │    │  Caches:         │ │
                    │  │  • Short URLs  │    │  • URL mappings  │
                    │  │  • Link stats  │    │  • Click stats   │
                    │  │  • Analytics   │    │  • Temp data     │ │
                    │  └────────────────┘    └──────────────────┘ │
                    └──────────────────────────────────────────────┘

                    ┌──────────────────────────────────────────────┐
                    │       Background Workers                      │
                    │                                               │
                    │  ┌────────────────────────────────────────┐  │
                    │  │     Celery Worker                      │  │
                    │  │     Container: worker                  │  │
                    │  │                                        │  │
                    │  │     Tasks:                             │  │
                    │  │     • Metadata scraping                │  │
                    │  │     • Click logging                    │  │
                    │  │     • Analytics processing             │  │
                    │  └────────────────────────────────────────┘  │
                    └──────────────────────────────────────────────┘
```

---

## Components Overview

### 1. **Nginx (Reverse Proxy)**
- **Purpose**: Acts as a single entry point for all client requests
- **Container**: `nginx`
- **Port**: 80 (HTTP)
- **Network**: `url-shortener-network`
- **Configuration**: `/Nginx/nginx.conf`

**Key Responsibilities:**
- Route API requests to appropriate backends
- Handle CORS headers
- Rate limiting (10 requests/second)
- SSL termination (future)
- Load balancing (future)

### 2. **Daily Utility Tool Backend**
- **Type**: Native Python process (not containerized)
- **Port**: 8000
- **Framework**: FastAPI + Uvicorn
- **Location**: Host machine (`c:\Users\NITRO\Desktop\Integrate\Daily_Utility_Tool`)
- **Process Management**: PowerShell background process

**Features:**
- QR Code Generation
- Barcode Generation (Code128, EAN13, etc.)
- Unit Conversion (length, weight, temperature, etc.)
- Age Calculator
- EMI Calculator

**Why not containerized?**
- Easier development and debugging
- Direct access to host resources
- Faster iteration cycles

### 3. **Minima Backend API**
- **Type**: Docker container
- **Container**: `backend`
- **Port**: 8000 (internal)
- **Framework**: FastAPI
- **Network**: `url-shortener-network`
- **Location**: `/Minima/url_shortener_backend`

**Features:**
- URL shortening with custom aliases
- Link analytics and statistics
- QR code generation for short URLs
- Click tracking
- Expiry management

### 4. **PostgreSQL Database**
- **Container**: `postgres`
- **Port**: 5650 (external), 5432 (internal)
- **Version**: PostgreSQL 15
- **Network**: `url-shortener-network`
- **Data Persistence**: Docker volume

**Schema:**
- `links` table: Stores short URLs, original URLs, metadata
- `clicks` table: Records click events with device info
- `users` table (future): User management

### 5. **Redis Cache**
- **Container**: `redis`
- **Port**: 6379
- **Version**: Redis 7
- **Network**: `url-shortener-network`
- **Purpose**: High-speed caching layer

**Cached Data:**
- Short URL → Original URL mappings
- Link statistics (60s TTL)
- Session data (future)
- Rate limiting counters

### 6. **Celery Worker**
- **Container**: `worker`
- **Network**: `url-shortener-network`
- **Message Broker**: Redis
- **Purpose**: Asynchronous task processing

**Background Tasks:**
- Metadata scraping (fetch page title, description, favicon)
- Click logging (record analytics data)
- Report generation (future)
- Email notifications (future)

---

## Network Architecture

### Docker Network: `url-shortener-network`

All Docker containers communicate through a dedicated Docker bridge network.

**Network Configuration:**
```
Network Name: url-shortener-network
Type: Bridge
Subnet: 172.19.0.0/16
Gateway: 172.19.0.1
```

**Container IP Addresses (Dynamic):**
```
nginx:    172.19.0.x
backend:  172.19.0.x
worker:   172.19.0.x
postgres: 172.19.0.x
redis:    172.19.0.x
```

**DNS Resolution:**
- Containers communicate using **hostnames**, not IPs
- Docker's internal DNS resolves container names to IPs
- Example: `backend` resolves to `172.19.0.6` (dynamic)

**Host Access:**
- Daily Utility Tool runs on host machine
- Nginx accesses it via `host.docker.internal:8000`
- `host.docker.internal` is Docker's special DNS name for the host

### Port Mappings

| Service | Container Port | Host Port | Purpose |
|---------|---------------|-----------|---------|
| Nginx | 80 | 80 | HTTP traffic |
| Daily Utility | 8000 | 8000 | Backend API |
| PostgreSQL | 5432 | 5650 | Database access |
| Redis | 6379 | 6379 | Cache access |
| Minima Backend | 8000 | - | Internal only |
| Worker | - | - | Internal only |

---

## Startup Sequence

### Execution Flow of `start-all.ps1`

```
START
  │
  ├─ Step 1: Create Docker Network
  │    └─ docker network create url-shortener-network
  │
  ├─ Step 2: Start Database Services
  │    ├─ Check if postgres & redis are running
  │    ├─ If not: docker compose up -d (in Database folder)
  │    └─ Wait 5 seconds for databases to be ready
  │
  ├─ Step 3: Start Daily Utility Tool Backend
  │    ├─ Check if port 8000 is in use
  │    ├─ If not:
  │    │    ├─ Start Python process (hidden, background)
  │    │    ├─ Command: python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
  │    │    └─ Save PID to .daily_util_pid file
  │    └─ Wait 3 seconds for startup
  │
  ├─ Step 4: Start Minima Backend + Worker
  │    ├─ docker compose -f docker-compose.api.yml up -d
  │    ├─ Starts: backend, worker containers
  │    └─ Wait 5 seconds for backend to connect to database
  │
  ├─ Step 5: Start Nginx
  │    ├─ docker compose up -d (in Nginx folder)
  │    └─ Nginx starts and loads configuration
  │
  ├─ Step 6: Refresh Nginx DNS
  │    ├─ docker restart nginx
  │    ├─ Forces Nginx to re-resolve backend hostnames
  │    └─ Ensures correct IP addresses are used
  │
  └─ COMPLETE: All services running
```

### Why Each Step Matters

**Step 1 - Network Creation:**
- Must exist before any container starts
- Allows containers to discover each other by name
- Creates isolated network segment

**Step 2 - Database First:**
- Minima backend needs PostgreSQL immediately on startup
- If database isn't ready, backend crashes
- Redis needed for caching and Celery message queue

**Step 3 - Daily Utility Tool:**
- Independent of Minima
- Can start in parallel with databases
- Runs on host, not Docker

**Step 4 - Minima Backend:**
- Depends on PostgreSQL being ready
- Creates database tables on first startup
- Worker depends on Redis for task queue

**Step 5 - Nginx Last:**
- Needs backends to be running
- Performs DNS resolution on startup
- Routes traffic to backends

**Step 6 - DNS Refresh (Critical!):**
- Docker assigns IPs dynamically
- Nginx caches DNS resolutions
- If containers restart, IPs may change
- Restart forces fresh DNS lookup
- **Without this step: 502 Bad Gateway errors occur**

---

## Request Flow

### Example: URL Shortening Request

```
1. CLIENT REQUEST
   │
   │  POST http://192.168.1.6/shorten
   │  Body: { "original_url": "https://google.com" }
   │
   ↓
2. NGINX RECEIVES REQUEST
   │
   │  • Matches route: /*
   │  • Applies CORS headers
   │  • Rate limiting check
   │  • Proxies to: http://backend:8000/shorten
   │
   ↓
3. MINIMA BACKEND PROCESSES
   │
   │  • Validates URL
   │  • Generates short code (e.g., "abc123")
   │  • Checks for custom alias conflicts
   │
   ↓
4. DATABASE TRANSACTION
   │
   │  • INSERT into links table
   │  • Stores: original_url, short_code, created_at
   │  • PostgreSQL commits transaction
   │
   ↓
5. ASYNC TASK DISPATCH
   │
   │  • Backend sends task to Celery
   │  • Task: scrape_metadata_task.delay("abc123", url)
   │  • Worker picks up task from Redis queue
   │
   ↓
6. RESPONSE TO CLIENT
   │
   │  • Backend returns JSON:
   │    {
   │      "short_code": "abc123",
   │      "short_url": "http://192.168.1.6/abc123",
   │      "qr_url": "http://192.168.1.6/qr/abc123"
   │    }
   │
   ↓
7. NGINX FORWARDS RESPONSE
   │
   │  • Adds CORS headers
   │  • Returns to client
   │
   ↓
8. BACKGROUND WORKER
   │
   │  • Scrapes page metadata (async)
   │  • Fetches: title, description, favicon
   │  • Updates link record in database
```

### Example: URL Redirection Request

```
1. CLIENT REQUEST
   │
   │  GET http://192.168.1.6/abc123
   │
   ↓
2. NGINX ROUTES TO BACKEND
   │
   │  • Matches: /{short_code}
   │  • Proxies to: http://backend:8000/abc123
   │
   ↓
3. MINIMA CHECKS REDIS CACHE
   │
   │  • Looks up: GET abc123
   │  • If found: Use cached URL (skip database)
   │  • If not found: Query PostgreSQL
   │
   ↓
4. DATABASE QUERY (if cache miss)
   │
   │  • SELECT original_url FROM links WHERE short_code='abc123'
   │  • Check expiry_time
   │  • If expired: Return 410 Gone
   │
   ↓
5. CACHE UPDATE
   │
   │  • Store in Redis: SET abc123 "https://google.com"
   │  • Set TTL based on expiry (if applicable)
   │
   ↓
6. ASYNC CLICK LOGGING
   │
   │  • Dispatch Celery task: log_click.delay()
   │  • Records: IP, user-agent, referrer, timestamp
   │
   ↓
7. REDIRECT RESPONSE
   │
   │  • Backend returns: HTTP 302 Redirect
   │  • Location: https://google.com
   │
   ↓
8. CLIENT REDIRECTED
   │
   │  • Browser follows redirect
   │  • User lands on original URL
```

### Example: Daily Utility Tool Request

```
1. CLIENT REQUEST
   │
   │  POST http://192.168.1.6/api/v1/qr/generate
   │  Body: { "data": "rajrishabh401@gmail.com", "size": 300 }
   │
   ↓
2. NGINX ROUTES TO DAILY UTILITY
   │
   │  • Matches route: /api/*
   │  • Proxies to: http://host.docker.internal:8000/api/v1/qr/generate
   │
   ↓
3. DAILY UTILITY TOOL PROCESSES
   │
   │  • Detects data type: email
   │  • Generates QR code image
   │  • Converts to base64
   │
   ↓
4. RESPONSE
   │
   │  • Returns JSON:
   │    {
   │      "qr_type": "email",
   │      "image": "base64_encoded_image...",
   │      "data_uri": "data:image/png;base64,..."
   │    }
   │
   ↓
5. CLIENT RENDERS QR CODE
   │
   │  • Displays QR code image
   │  • User can download or share
```

---

## Database Architecture

### PostgreSQL Schema (Minima)

#### `links` Table
```sql
CREATE TABLE links (
    id SERIAL PRIMARY KEY,
    original_url TEXT NOT NULL,
    short_code VARCHAR(32) UNIQUE NOT NULL,
    custom_alias VARCHAR(32) UNIQUE,
    
    title TEXT,
    description TEXT,
    favicon_url TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    expiry_time TIMESTAMP,
    
    INDEX idx_short_code (short_code),
    INDEX idx_custom_alias (custom_alias)
);
```

#### `clicks` Table
```sql
CREATE TABLE clicks (
    id SERIAL PRIMARY KEY,
    link_id INTEGER REFERENCES links(id) ON DELETE CASCADE,
    
    ip_address VARCHAR(45),
    user_agent TEXT,
    referrer TEXT,
    device VARCHAR(20),  -- 'mobile', 'pc', 'tablet'
    
    clicked_at TIMESTAMP DEFAULT NOW(),
    
    INDEX idx_link_id (link_id),
    INDEX idx_clicked_at (clicked_at)
);
```

### Redis Cache Structure

**Key Patterns:**
```
# URL mapping cache
abc123 → "https://google.com"
TTL: Based on expiry_time or infinite

# Stats cache
stats:abc123 → JSON({"total_clicks": 42, "device_distribution": [...]})
TTL: 60 seconds

# Rate limiting
ratelimit:192.168.1.6 → counter
TTL: 1 second
```

---

## Configuration Files

### 1. Nginx Configuration (`Nginx/nginx.conf`)

```nginx
upstream minima_backend {
    server backend:8000;  # Docker DNS resolution
}

upstream daily_utility_backend {
    server host.docker.internal:8000;  # Host machine
}

server {
    listen 80;
    
    # Daily Utility Tool
    location /api {
        proxy_pass http://daily_utility_backend;
        # CORS headers, timeouts, etc.
    }
    
    # Minima Backend
    location / {
        proxy_pass http://minima_backend;
        # CORS headers, timeouts, etc.
    }
}
```

**Key Settings:**
- `proxy_pass`: Routes requests to backends
- `proxy_set_header`: Forwards client info
- `add_header`: CORS and security headers
- `limit_req`: Rate limiting
- `proxy_*_timeout`: Connection timeouts

### 2. Database Docker Compose (`Database/docker-compose.yml`)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: postgres
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    ports:
      - "5650:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - url-shortener-network

  redis:
    image: redis:7
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - url-shortener-network

networks:
  url-shortener-network:
    external: true

volumes:
  postgres_data:
```

### 3. Minima Backend Compose (`Minima/docker-compose.api.yml`)

```yaml
version: '3.8'

services:
  backend:
    build: ./url_shortener_backend
    container_name: backend
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/db
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - postgres
      - redis
    networks:
      - url-shortener-network

  worker:
    build: ./url_shortener_backend
    container_name: worker
    command: poetry run celery -A tasks worker --loglevel=info
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/db
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - redis
    networks:
      - url-shortener-network

networks:
  url-shortener-network:
    external: true
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. **502 Bad Gateway from Nginx**

**Symptoms:**
- Nginx returns 502 error
- Backend is running but unreachable

**Causes:**
- Nginx has cached old IP address of backend
- Backend container restarted with new IP
- DNS resolution failed

**Solution:**
```powershell
docker restart nginx
```

**Prevention:**
- `start-all.ps1` automatically restarts Nginx (Step 6)

---

#### 2. **Minima Backend Won't Start**

**Symptoms:**
- Container exits immediately
- Logs show database connection error

**Causes:**
- PostgreSQL not running
- Database not ready when backend starts
- Wrong connection string

**Solution:**
```powershell
# Check if database is running
docker ps | findstr postgres

# Start database
cd Database
docker compose up -d

# Wait for database to be ready
Start-Sleep -Seconds 5

# Restart backend
cd ..\Minima
docker compose -f docker-compose.api.yml up -d
```

---

#### 3. **Daily Utility Tool Not Accessible**

**Symptoms:**
- 502 error on `/api/*` endpoints
- Port 8000 not listening

**Causes:**
- Python process not running
- Port already in use
- Process crashed

**Solution:**
```powershell
# Check if running
netstat -ano | findstr ":8000"

# Kill existing process
Stop-Process -Id <PID> -Force

# Restart
cd Daily_Utility_Tool
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

#### 4. **Database Connection Refused**

**Symptoms:**
- Backend logs: "Connection refused"
- Can't connect to PostgreSQL

**Causes:**
- PostgreSQL container stopped
- Network connectivity issue
- Wrong port or credentials

**Solution:**
```powershell
# Check database status
docker ps -a | findstr postgres

# Restart database
docker start postgres

# Check logs
docker logs postgres

# Test connection
docker exec -it postgres psql -U <username> -d <database>
```

---

#### 5. **Redis Connection Failed**

**Symptoms:**
- Backend warns about Redis failure
- Caching not working
- Celery tasks not processing

**Causes:**
- Redis container stopped
- Network issue
- Redis out of memory

**Solution:**
```powershell
# Check Redis status
docker ps | findstr redis

# Restart Redis
docker restart redis

# Test connection
docker exec -it redis redis-cli PING
# Should return: PONG
```

---

#### 6. **Port Already in Use**

**Symptoms:**
- `start-all.ps1` reports port conflict
- Cannot start service

**Solution:**
```powershell
# Find process using port 8000
netstat -ano | findstr ":8000"

# Kill process
Stop-Process -Id <PID> -Force

# Or find and kill by name
Get-Process -Name python | Stop-Process -Force
```

---

### Diagnostic Commands

**Check all running containers:**
```powershell
docker ps
```

**Check all containers (including stopped):**
```powershell
docker ps -a
```

**View container logs:**
```powershell
docker logs <container_name>
docker logs backend --tail 50
```

**Check network connectivity:**
```powershell
# From host to container
curl http://localhost:8000

# Between containers
docker exec nginx ping backend
docker exec backend ping postgres
```

**Inspect network:**
```powershell
docker network inspect url-shortener-network
```

**Check database connection:**
```powershell
docker exec -it postgres psql -U postgres
```

**Check Redis:**
```powershell
docker exec -it redis redis-cli
> PING
> KEYS *
> GET abc123
```

**Monitor real-time logs:**
```powershell
# Single container
docker logs -f backend

# Multiple containers
docker compose -f docker-compose.api.yml logs -f
```

---

## Best Practices

### Development Workflow

1. **Always use `start-all.ps1` and `stop-all.ps1`**
   - Ensures correct startup order
   - Handles DNS refresh automatically
   - Manages PID files properly

2. **Check logs when things go wrong**
   ```powershell
   docker logs backend
   docker logs nginx
   docker logs worker
   ```

3. **Restart Nginx after backend changes**
   ```powershell
   docker restart nginx
   ```

4. **Keep databases running between sessions**
   - Faster startup
   - Preserves data
   - Only stop when needed

5. **Use environment variables for configuration**
   - Never hardcode credentials
   - Use `.env` files
   - Different configs for dev/prod

### Production Considerations

1. **Use production WSGI server**
   - Replace `--reload` with production settings
   - Use Gunicorn instead of Uvicorn directly
   - Configure worker processes

2. **Enable SSL/TLS**
   - Add SSL certificates to Nginx
   - Redirect HTTP to HTTPS
   - Use Let's Encrypt for free certs

3. **Configure proper CORS**
   - Restrict allowed origins
   - Remove wildcard `*`
   - Add specific domains

4. **Set up monitoring**
   - Health check endpoints
   - Log aggregation
   - Metrics collection
   - Alerting

5. **Database backups**
   - Regular automated backups
   - Test restore procedures
   - Monitor disk space

6. **Rate limiting**
   - Per-IP limits
   - Per-API-key limits
   - DDoS protection

---

## Summary

This architecture provides:

✅ **Scalability**: Easy to add more backends
✅ **Flexibility**: Mix of containerized and native services
✅ **Reliability**: Database persistence, caching, background tasks
✅ **Maintainability**: Clear separation of concerns
✅ **Performance**: Redis caching, async processing
✅ **Developer Experience**: Automated startup/shutdown, hot reload

The key to this architecture is the **careful orchestration of startup sequence** and **Nginx's role as a central routing hub**, combined with Docker networking for container communication.

---

**Last Updated**: June 28, 2026
**Version**: 1.0.0
