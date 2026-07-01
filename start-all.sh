#!/usr/bin/env bash

echo "========================================="
echo "  ToolHub - Master Startup (Mac/Linux)"
echo "========================================="
echo ""

# Detect IP on macOS
IP=$(ipconfig getifaddr en0)
if [ -z "$IP" ]; then
    IP="127.0.0.1"
fi

echo "Detected IP: $IP"
echo ""

echo "Step 1/8: Creating shared Docker network..."
docker network create url-shortener-network 2>/dev/null || true
echo "  Network ready"
echo ""

echo "Step 2/8: Checking database services..."
POSTGRES_RUNNING=$(docker ps --filter name=^postgres$ --filter status=running -q)
REDIS_RUNNING=$(docker ps --filter name=^redis$ --filter status=running -q)

POSTGRES_STOPPED=$(docker ps -a --filter name=^postgres$ --filter status=exited -q)
REDIS_STOPPED=$(docker ps -a --filter name=^redis$ --filter status=exited -q)

if [ -n "$POSTGRES_STOPPED" ] || [ -n "$REDIS_STOPPED" ]; then
    echo "  Database containers exist but stopped. Starting them..."
    if [ -n "$POSTGRES_STOPPED" ]; then
        docker start postgres >/dev/null
        echo "  PostgreSQL started"
    fi
    if [ -n "$REDIS_STOPPED" ]; then
        docker start redis >/dev/null
        echo "  Redis started"
    fi
    echo "  Waiting for databases to be ready..."
    sleep 5
elif [ -z "$POSTGRES_RUNNING" ] || [ -z "$REDIS_RUNNING" ]; then
    echo "  Creating and starting database services..."
    (cd Database && docker compose -f docker-compose.database.yml up -d)
    echo "  Database started"
    echo "  Waiting for databases to be ready..."
    sleep 5
else
    echo "  Database already running"
fi
echo ""

echo "Step 3/8: Starting Daily Utility Tool backend..."
cd Daily_Utility_Tool || exit

# Check if dependencies are installed
if [ ! -f .daily_util_deps_installed ]; then
    echo "  First time setup detected..."
    echo "  Installing Python dependencies..."
    if pip install -r requirements.txt -q; then
        echo "  Dependencies installed successfully"
        touch .daily_util_deps_installed
    else
        echo "  [WARNING] Failed to install dependencies. Please run manually:"
        echo "  cd Daily_Utility_Tool && pip install -r requirements.txt"
    fi
fi

# Check if already running on port 8000
if ! lsof -i :8000 >/dev/null 2>&1; then
    echo "  Starting backend as background process..."
    nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload > uvicorn.log 2>&1 &
    PID=$!
    echo $PID > .daily_util_pid
    sleep 3
    echo "  Backend started (PID: $PID)"
else
    echo "  Backend already running on port 8000"
fi
cd ..
echo ""

echo "Step 4/8: Starting Minima backend API..."
(cd Minima && docker compose -f docker-compose.api.yml up -d)
echo "  Minima Backend API started"
echo "  Waiting for backend to be ready..."
sleep 5
echo ""

echo "Step 5/8: Starting File Sharing backend API..."
(cd FileSharing && docker compose -f docker-compose.api.yml up -d)
echo "  File Sharing Backend API started"
echo "  Waiting for backend to be ready..."
sleep 5
echo ""

echo "Step 6/8: Starting ResumeBuilder backend..."
cd ResumeBuilder || exit

# Check if dependencies are installed
if [ ! -f .resume_builder_deps_installed ]; then
    echo "  First time setup detected..."
    echo "  Installing Python dependencies..."
    if pip install -r requirements.txt -q; then
        echo "  Dependencies installed successfully"
        touch .resume_builder_deps_installed
    else
        echo "  [WARNING] Failed to install dependencies. Please run manually:"
        echo "  cd ResumeBuilder && pip install -r requirements.txt"
    fi
fi

# Check if already running on port 8001
if ! lsof -i :8001 >/dev/null 2>&1; then
    echo "  Starting backend as background process..."
    nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload > uvicorn.log 2>&1 &
    PID=$!
    echo $PID > .resume_builder_pid
    sleep 3
    echo "  Backend started (PID: $PID)"
else
    echo "  Backend already running on port 8001"
fi
cd ..
echo ""

echo "Step 7/8: Starting Nginx reverse proxy..."
(cd Nginx && docker compose up -d)
echo "  Nginx started"
echo ""

echo "Step 8/8: Ensuring Nginx can connect to backends..."
echo "  Restarting Nginx to refresh DNS resolution..."
docker restart nginx >/dev/null 2>&1
sleep 2
echo "  Nginx DNS refreshed"
echo ""

echo "========================================="
echo "  All Services Started Successfully!"
echo "========================================="
echo ""
echo "Services Running:"
echo "  [OK] PostgreSQL             : Database (shared)"
echo "  [OK] Redis                  : Cache"
echo "  [OK] Daily Utility Tool     : Port 8000"
echo "  [OK] ResumeBuilder          : Port 8001"
echo "  [OK] Minima Backend API     : Containerized"
echo "  [OK] File Sharing Backend   : Containerized"
echo "  [OK] Nginx                  : Reverse Proxy"
echo ""
echo "Access Your Application:"
echo "  API Documentation (DUT)    : http://$IP/api/docs"
echo "  ResumeBuilder API Docs     : http://$IP/resume-api/docs"
echo "  Minima (URL Shortener)     : http://$IP/"
echo "  File Sharing API           : http://$IP/fileshare/docs"
echo "  File Sharing Health        : http://$IP/fileshare/health"
echo "  Nginx Health Check         : http://$IP/health"
echo "  Base URL                   : http://$IP"
echo ""
