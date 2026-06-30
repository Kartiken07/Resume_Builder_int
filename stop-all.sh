#!/usr/bin/env bash
# Master Stop Script for ToolHub
# Stops Backend APIs, Daily Utility Tool, and Nginx, but PRESERVES Database

echo "========================================="
echo "  ToolHub - Stopping Services (Mac/Linux)"
echo "========================================="
echo ""

echo "Stopping Nginx..."
(cd Nginx && docker compose down)
echo "  [OK] Nginx stopped"
echo ""

echo "Stopping Daily Utility Tool backend..."
STOPPED=0
PID_FILE="Daily_Utility_Tool/.daily_util_pid"

if [ -f "$PID_FILE" ]; then
    STORED_PID=$(cat "$PID_FILE")
    if ps -p $STORED_PID > /dev/null; then
        kill $STORED_PID 2>/dev/null
        sleep 1
        if ! ps -p $STORED_PID > /dev/null; then
            echo "  [OK] Daily Utility backend stopped (PID: $STORED_PID)"
            STOPPED=1
        fi
    fi
    rm -f "$PID_FILE"
fi

if [ $STOPPED -eq 0 ]; then
    # Fallback: kill any process using port 8000
    PIDS=$(lsof -ti:8000)
    if [ -n "$PIDS" ]; then
        for PID in $PIDS; do
            kill $PID 2>/dev/null
            echo "  [OK] Stopped process on port 8000 (PID: $PID)"
            STOPPED=1
        done
    fi
fi

if [ $STOPPED -eq 0 ]; then
    echo "  [INFO] No Daily Utility Tool backend process found"
fi
echo ""

echo "Stopping Minima Backend API..."
(cd Minima && docker compose -f docker-compose.api.yml down)
echo "  [OK] Minima Backend API stopped"
echo ""

echo "Stopping File Sharing Backend API..."
(cd FileSharing && docker compose -f docker-compose.api.yml down)
echo "  [OK] File Sharing Backend API stopped"
echo ""

echo "========================================="
echo "  Services Stopped Successfully!"
echo "========================================="
echo ""
echo "Status:"
echo "  [X] Nginx                   : Stopped"
echo "  [X] Daily Utility Tool      : Stopped"
echo "  [X] Minima Backend API      : Stopped"
echo "  [X] File Sharing Backend    : Stopped"
echo "  [OK] PostgreSQL             : Still running (data preserved)"
echo "  [OK] Redis                  : Still running (cache preserved)"
echo ""
echo "Database is kept running to preserve your data."
echo ""
echo "To restart services:"
echo "  ./start-all.sh"
echo ""
echo "To stop database (WARNING: May lose data in memory):"
echo "  (cd Database && docker compose -f docker-compose.database.yml down)"
echo ""
