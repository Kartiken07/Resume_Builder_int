# Getting Started Guide

## Quick Start Documentation for Integrated Application Stack

This guide will help you set up and run the complete integrated application stack consisting of the Daily Utility Tool and Minima URL Shortener.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [Configuration](#configuration)
4. [Starting the Application](#starting-the-application)
5. [Accessing the Application](#accessing-the-application)
6. [Stopping the Application](#stopping-the-application)
7. [Troubleshooting](#troubleshooting)
8. [Next Steps](#next-steps)

---

## Prerequisites

### Required Software

| Software | Version | Purpose | Download Link |
|----------|---------|---------|---------------|
| **Docker Desktop** | Latest | Container management | [Download](https://www.docker.com/products/docker-desktop) |
| **Python** | 3.11+ | Backend runtime | [Download](https://www.python.org/downloads/) |
| **Flutter** | 3.10+ | Frontend framework | [Download](https://flutter.dev/docs/get-started/install) |
| **Git** | Latest | Version control | [Download](https://git-scm.com/downloads) |
| **PowerShell** | 5.1+ | Script execution | Pre-installed on Windows |

### System Requirements

- **Operating System**: Windows 10/11 (64-bit)
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: At least 10GB free space
- **Network**: Active internet connection for initial setup
- **CPU**: Multi-core processor recommended

### Optional Tools

- **VS Code**: Recommended IDE ([Download](https://code.visualstudio.com/))
- **Postman**: API testing ([Download](https://www.postman.com/downloads/))
- **pgAdmin**: PostgreSQL GUI (optional)

---

## Installation Steps

### Step 1: Install Docker Desktop

1. Download Docker Desktop from the official website
2. Run the installer
3. Follow the installation wizard
4. **Important**: Enable WSL 2 backend when prompted
5. Restart your computer
6. Verify installation:

```powershell
docker --version
docker compose version
```

Expected output:
```
Docker version 24.x.x
Docker Compose version v2.x.x
```

### Step 2: Install Python

1. Download Python 3.11+ from python.org
2. **Important**: Check "Add Python to PATH" during installation
3. Verify installation:

```powershell
python --version
pip --version
```

Expected output:
```
Python 3.11.x
pip 24.x.x
```

### Step 3: Install Flutter

1. Download Flutter SDK
2. Extract to `C:\src\flutter` (or your preferred location)
3. Add Flutter to PATH:
   - Open System Environment Variables
   - Add `C:\src\flutter\bin` to PATH
4. Run Flutter doctor:

```powershell
flutter doctor
```

5. Install any missing dependencies shown by Flutter doctor

### Step 4: Get the Project Files

**Option A: From Git Repository**

```powershell
# Clone to your desired location
cd C:\Users\<YourUsername>\Desktop
git clone <repository-url> Integrate
cd Integrate
```

**Option B: From Zip File**

1. Extract the project folder to your desired location
2. Example: `C:\Users\<YourUsername>\Desktop\Integrate`
3. Open PowerShell in that folder:

```powershell
cd C:\Users\<YourUsername>\Desktop\Integrate
```

⚠️ **Important**: Replace `<YourUsername>` with your actual Windows username!

---

## Configuration

### Backend Configuration

#### 1. Daily Utility Tool Backend

Navigate to the backend folder and install dependencies:

```powershell
cd Daily_Utility_Tool
pip install -r requirements.txt
```

**Create `.env` file** (if it doesn't exist):

```env
# Daily Utility Tool Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=True
```

#### 2. Minima Backend

The Minima backend uses Docker, so no local Python setup is needed.

**Check `.env` file** in the `Minima` folder:

```env
# Database Configuration
DB_USER=postgres
DB_PASSWORD=your_secure_password_here
DB_NAME=url_shortener
DB_HOST=postgres
DB_PORT=5432

# Redis Configuration
REDIS_URL=redis://redis:6379/0

# Application Configuration
ALLOWED_ORIGINS=*
SECRET_KEY=your_secret_key_here
```

⚠️ **Security Note**: Change default passwords in production!

### Frontend Configuration

Navigate to the frontend folder:

```powershell
cd Daily_Utility_Tool_Frontend
flutter pub get
```

**Update API Base URL** in `lib/api_services/api_routes.dart`:

```dart
const String apiBaseUrl = 'http://YOUR_IP_HERE';  // Replace with your IP
```

**To find YOUR IP address:**

```powershell
ipconfig | findstr IPv4
```

Look for your network adapter's IPv4 address. Examples:
- Wired connection (Ethernet): `192.168.1.100`
- WiFi connection (Wi-Fi): `192.168.1.50`
- May start with `10.x.x.x` or `172.x.x.x`

**Replace `YOUR_IP_HERE` with the IP you found!**

Example:
```dart
// Before
const String apiBaseUrl = 'http://YOUR_IP_HERE';

// After (using your actual IP)
const String apiBaseUrl = 'http://192.168.1.50';
```

### Database Configuration

The databases are configured via Docker Compose. Check `Database/.env`:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=url_shortener
```

⚠️ **Important for your friend**: 
- If the `.env` file doesn't exist, create it using the example above
- Change `your_password` to something secure
- This is needed for the database to start properly

---

## Starting the Application

### Method 1: Automated Startup (Recommended)

From the `Integrate` folder, run:

```powershell
.\start-all.ps1
```

This script will:
1. ✅ Create Docker network
2. ✅ Start PostgreSQL and Redis
3. ✅ Start Daily Utility Tool backend
4. ✅ Start Minima backend and worker
5. ✅ Start Nginx reverse proxy
6. ✅ Configure DNS resolution

**Expected Output:**

```
=========================================
  URL Shortener - Master Startup
=========================================

Detected IP: 192.168.x.x  (This will be YOUR computer's IP)

Step 1/4: Creating shared Docker network...
  Network ready

Step 2/5: Checking database services...
  Database already running

Step 3/6: Starting Daily Utility Tool backend...
  Starting backend as background process...
  Backend started (PID: 12345)

Step 4/6: Starting Minima backend API...
  Backend API started
  Waiting for backend to be ready...

Step 5/6: Starting Nginx reverse proxy...
  Nginx started

Step 6/6: Ensuring Nginx can connect to backends...
  Restarting Nginx to refresh DNS resolution...
  Nginx DNS refreshed

=========================================
  All Services Started Successfully!
=========================================

Services Running:
  ✅ PostgreSQL          : Database
  ✅ Redis               : Cache
  ✅ Daily Utility Tool  : Port 8000
  ✅ Backend API         : Containerized
  ✅ Nginx               : Reverse Proxy

Access Your Application:
  API Documentation : http://YOUR_IP/docs
  Health Check      : http://YOUR_IP/health
  Base URL          : http://YOUR_IP
```

📝 **Note**: The IP address shown will be YOUR computer's IP, not the example `192.168.1.6`

### Method 2: Manual Startup (Advanced)

If you prefer to start services individually:

#### 1. Start Databases

```powershell
cd Database
docker compose up -d
cd ..
```

#### 2. Start Daily Utility Tool

```powershell
cd Daily_Utility_Tool
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
# Keep this terminal open
```

#### 3. Start Minima Backend (New Terminal)

```powershell
cd Minima
docker compose -f docker-compose.api.yml up -d
cd ..
```

#### 4. Start Nginx (New Terminal)

```powershell
cd Nginx
docker compose up -d
docker restart nginx  # Important for DNS resolution
cd ..
```

### Starting the Frontend

Open a new terminal:

```powershell
cd Daily_Utility_Tool_Frontend
flutter run -d chrome
```

Or for production build:

```powershell
flutter build web --release
# Serve the build folder with a web server
```

---

## Accessing the Application

### Backend APIs

| Service | URL | Purpose |
|---------|-----|---------|
| **Main Entry Point** | http://192.168.1.6 | Nginx reverse proxy |
| **Health Check** | http://192.168.1.6/health | Service status |
| **API Docs** | http://192.168.1.6/docs | Interactive API documentation |
| **QR Generator** | http://192.168.1.6/api/v1/qr/ | QR code API |
| **URL Shortener** | http://192.168.1.6/shorten | Link shortening |

### Frontend

| Platform | URL | Notes |
|----------|-----|-------|
| **Web Development** | http://localhost:PORT | Flutter hot reload enabled |
| **Production Web** | Your deployment URL | After `flutter build web` |
| **Mobile** | http://192.168.1.6:PORT | Same Wi-Fi network required |

### Database Access

| Database | Connection String | GUI Access |
|----------|------------------|------------|
| **PostgreSQL** | `postgresql://postgres:password@localhost:5650/url_shortener` | pgAdmin on port 5650 |
| **Redis** | `redis://localhost:6379/0` | Redis CLI: `docker exec -it redis redis-cli` |

---

## Stopping the Application

### Method 1: Automated Shutdown (Recommended)

```powershell
.\stop-all.ps1
```

This will:
- ✅ Stop Nginx
- ✅ Stop Daily Utility Tool backend
- ✅ Stop Minima backend and worker
- ✅ **Keep databases running** (data preserved)

**Expected Output:**

```
=========================================
  URL Shortener - Stopping Services
=========================================

Stopping Nginx...
  [OK] Nginx stopped

Stopping Daily Utility Tool backend...
  [OK] Daily Utility backend stopped (PID: 12345)

Stopping Backend API...
  [OK] Backend API stopped

=========================================
  Services Stopped Successfully!
=========================================

Status:
  [X] Nginx               : Stopped
  [X] Daily Utility Tool  : Stopped
  [X] Backend API         : Stopped
  [X] Celery Worker       : Stopped
  [OK] PostgreSQL         : Still running (data preserved)
  [OK] Redis              : Still running (cache preserved)
```

### Stopping Databases (Optional)

⚠️ **Warning**: This will stop the databases. Data in memory will be lost.

```powershell
cd Database
docker compose down
cd ..
```

### Method 2: Manual Shutdown

```powershell
# Stop Nginx
cd Nginx
docker compose down

# Stop Minima Backend
cd ..\Minima
docker compose -f docker-compose.api.yml down

# Stop Daily Utility Tool (find PID first)
netstat -ano | findstr ":8000"
Stop-Process -Id <PID> -Force

# Stop Databases (optional)
cd ..\Database
docker compose down
```

---

## Troubleshooting

### Common Issues

#### Issue 1: Docker Desktop Not Running

**Symptoms:**
```
error during connect: This error may indicate that the docker daemon is not running
```

**Solution:**
1. Open Docker Desktop application
2. Wait for it to fully start (whale icon in system tray)
3. Try again

---

#### Issue 2: Port Already in Use

**Symptoms:**
```
Error: Port 8000 is already allocated
```

**Solution:**

```powershell
# Find process using port
netstat -ano | findstr ":8000"

# Kill the process
Stop-Process -Id <PID> -Force

# Or kill all Python processes
Get-Process -Name python | Stop-Process -Force
```

---

#### Issue 3: Database Connection Failed

**Symptoms:**
```
sqlalchemy.exc.OperationalError: could not connect to server
```

**Solution:**

```powershell
# Check if PostgreSQL is running
docker ps | findstr postgres

# Start database
cd Database
docker compose up -d

# Wait 5 seconds for database to be ready
Start-Sleep -Seconds 5

# Restart backend
cd ..\Minima
docker compose -f docker-compose.api.yml restart backend
```

---

#### Issue 4: 502 Bad Gateway from Nginx

**Symptoms:**
- Nginx returns 502 error
- Backend is running but unreachable

**Solution:**

```powershell
# Restart Nginx to refresh DNS
docker restart nginx

# Wait a few seconds
Start-Sleep -Seconds 3

# Test again
curl http://localhost/health
```

---

#### Issue 5: Flutter Build Fails

**Symptoms:**
```
Error: Could not resolve dependencies
```

**Solution:**

```powershell
cd Daily_Utility_Tool_Frontend

# Clean and get dependencies
flutter clean
flutter pub get

# Run again
flutter run -d chrome
```

---

#### Issue 6: Python Module Not Found

**Symptoms:**
```
ModuleNotFoundError: No module named 'fastapi'
```

**Solution:**

```powershell
cd Daily_Utility_Tool

# Reinstall dependencies
pip install -r requirements.txt

# Or install specific package
pip install fastapi uvicorn
```

---

### Verification Commands

Check if services are running:

```powershell
# Check Docker containers
docker ps

# Check port 8000
netstat -ano | findstr ":8000"

# Test health endpoint
curl http://localhost/health

# Check Nginx logs
docker logs nginx --tail 20

# Check Minima backend logs
docker logs backend --tail 20
```

---

## Next Steps

### After Successful Setup

1. **Explore the APIs**
   - Visit http://192.168.1.6/docs for interactive API documentation
   - Try generating a QR code via the API
   - Create a short URL

2. **Test the Frontend**
   - Open the Flutter web app
   - Navigate through different tools
   - Generate QR codes and barcodes
   - Create short URLs

3. **Learn the Architecture**
   - Read `ARCHITECTURE.md` for backend details
   - Read `FRONTEND_ARCHITECTURE.md` for frontend details
   - Understand the startup sequence

4. **Customize Configuration**
   - Update API base URLs for your network
   - Configure custom domains
   - Set up SSL certificates (production)

5. **Develop New Features**
   - Follow the modular structure
   - Add new API endpoints
   - Create new Flutter screens
   - Integrate with external services

### Development Workflow

```powershell
# Start services
.\start-all.ps1

# Start frontend in dev mode (new terminal)
cd Daily_Utility_Tool_Frontend
flutter run -d chrome

# Make changes to code (hot reload enabled)

# When done
.\stop-all.ps1
```

### Production Deployment

For production deployment, refer to:
- `ARCHITECTURE.md` - Section on "Production Considerations"
- Configure SSL/TLS in Nginx
- Use production database credentials
- Set up monitoring and logging
- Configure automated backups

---

## Quick Reference

### Essential Commands

```powershell
# Start everything
.\start-all.ps1

# Stop everything
.\stop-all.ps1

# Check service status
docker ps

# View logs
docker logs backend
docker logs nginx
docker logs worker

# Restart a service
docker restart backend
docker restart nginx

# Clean restart (databases too)
cd Database
docker compose down
cd ..
.\start-all.ps1
```

### Important Paths

| Path | Purpose |
|------|---------|
| `Daily_Utility_Tool/` | Python backend code |
| `Minima/` | URL shortener backend |
| `Daily_Utility_Tool_Frontend/` | Flutter web app |
| `Database/` | Database Docker configs |
| `Nginx/` | Reverse proxy config |
| `.daily_util_pid` | Process ID file |

### Default Ports

| Service | Port | Protocol |
|---------|------|----------|
| Nginx | 80 | HTTP |
| Daily Utility Tool | 8000 | HTTP |
| PostgreSQL | 5650 | TCP |
| Redis | 6379 | TCP |
| Frontend (dev) | Variable | HTTP |

---

## Getting Help

### Documentation

- **Backend Architecture**: `ARCHITECTURE.md`
- **Frontend Architecture**: `FRONTEND_ARCHITECTURE.md`
- **This Guide**: `GETTING_STARTED.md`

### Logs Location

```powershell
# Docker container logs
docker logs <container_name>

# Nginx logs
docker exec nginx cat /var/log/nginx/access.log
docker exec nginx cat /var/log/nginx/error.log

# Daily Utility Tool logs
# Check terminal output or console
```

### Common Commands Cheatsheet

```powershell
# Docker
docker ps                          # List running containers
docker ps -a                       # List all containers
docker logs <container>            # View logs
docker exec -it <container> bash   # Enter container
docker restart <container>         # Restart container

# Database
docker exec -it postgres psql -U postgres
docker exec -it redis redis-cli

# Network
ipconfig                          # Get your IP
netstat -ano | findstr ":8000"    # Check port usage

# Process Management
Get-Process -Name python          # List Python processes
Stop-Process -Id <PID> -Force     # Kill process
```

---

## Support

If you encounter issues not covered in this guide:

1. Check the logs for error messages
2. Review the architecture documentation
3. Verify all prerequisites are installed
4. Ensure Docker Desktop is running
5. Check firewall settings
6. Verify network connectivity

---

**Version**: 1.0.0  
**Last Updated**: June 28, 2026  
**Maintained by**: Architecture Team

---

## Congratulations! 🎉

You're now ready to use the integrated application stack. Happy coding!
