# Adding New Projects Guide

## Complete Guide for Adding New Backends and Frontends

This comprehensive guide will walk you through adding new backend services and frontend projects to the integrated application stack.

---

## Table of Contents

1. [Overview](#overview)
2. [Adding a New Backend](#adding-a-new-backend)
3. [Adding a New Frontend Project](#adding-a-new-frontend-project)
4. [Integrating Backend with Nginx](#integrating-backend-with-nginx)
5. [Updating Automation Scripts](#updating-automation-scripts)
6. [Testing Your New Project](#testing-your-new-project)
7. [Best Practices](#best-practices)
8. [Examples](#examples)

---

## Overview

The integrated application stack is designed for easy extensibility. You can add:

- **New Backend Services**: Python/FastAPI, Node.js, Go, or any HTTP service
- **New Frontend Projects**: Additional Flutter projects, React apps, or static sites
- **New Features**: Within existing projects

### Current Structure

```
Integrate/
├── Daily_Utility_Tool/          # Backend #1 (Python/FastAPI)
├── Minima/                      # Backend #2 (Python/FastAPI in Docker)
├── Daily_Utility_Tool_Frontend/ # Frontend (Flutter)
├── Nginx/                       # Reverse proxy
├── Database/                    # Shared databases
└── Scripts (start-all.ps1, etc.)
```

---

## Adding a New Backend

### Step 1: Choose Your Backend Type

**Option A: Native Process (like Daily_Utility_Tool)**
- Runs directly on host machine
- Good for: Development, simple services
- Examples: Python, Node.js scripts

**Option B: Dockerized (like Minima)**
- Runs in Docker container
- Good for: Production, complex services
- Examples: Any containerized app

### Step 2: Create Backend Structure

#### Option A: Python/FastAPI Backend (Native)

```powershell
# Create new backend folder
cd C:\Users\NITRO\Desktop\Integrate
mkdir NewBackend
cd NewBackend
```

**Create project structure:**

```
NewBackend/
├── main.py                 # FastAPI application
├── requirements.txt        # Python dependencies
├── models/                 # Data models
├── routes/                 # API routes
├── services/               # Business logic
├── .env                    # Environment variables
└── README.md              # Documentation
```

**Create `main.py`:**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(
    title="New Backend API",
    version="1.0.0",
    description="Description of your new backend"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "New Backend API is running"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "new_backend"}

# Add your routes here
@app.post("/api/v1/new-feature")
def new_feature_endpoint(data: dict):
    # Your logic here
    return {"result": "success", "data": data}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8001))  # Use different port
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
```

**Create `requirements.txt`:**

```txt
fastapi==0.116.1
uvicorn[standard]==0.35.0
python-dotenv==1.0.0
pydantic==2.12.5
# Add other dependencies
```

**Create `.env`:**

```env
PORT=8001
HOST=0.0.0.0
DEBUG=True
# Add your environment variables
```

**Install dependencies:**

```powershell
pip install -r requirements.txt
```

**Test your backend:**

```powershell
python main.py
```

Visit: http://localhost:8001/docs

---

#### Option B: Dockerized Backend

**Create `NewBackend/` folder with:**

```
NewBackend/
├── src/
│   ├── main.py
│   └── ...
├── Dockerfile
├── docker-compose.yml
├── requirements.txt  (or package.json for Node.js)
└── .env
```

**Create `Dockerfile`:**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY src/ .

# Expose port
EXPOSE 8001

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
```

**Create `docker-compose.yml`:**

```yaml
version: '3.8'

services:
  new-backend:
    build: .
    container_name: new-backend
    ports:
      - "8001:8001"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    networks:
      - url-shortener-network
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

networks:
  url-shortener-network:
    external: true
```

**Start your backend:**

```powershell
docker compose up -d
```

---

### Step 3: Choose a Unique Port

**Port Allocation:**

| Service | Port | Status |
|---------|------|--------|
| Daily Utility Tool | 8000 | ✅ Used |
| New Backend | 8001 | 🆕 Available |
| Another Backend | 8002 | 🆕 Available |
| Custom Service | 8003+ | 🆕 Available |

⚠️ **Important**: Each backend needs a unique port!

---

### Step 4: Add to Nginx Configuration

Edit `Nginx/nginx.conf`:

```nginx
# Add new upstream
upstream new_backend {
    server host.docker.internal:8001;  # For native process
    # OR
    # server new-backend:8001;         # For Docker container
}

server {
    listen 80;
    
    # Existing routes...
    
    # New backend route
    location /api/v2 {
        proxy_pass http://new_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

**Reload Nginx:**

```powershell
docker restart nginx
```

---

### Step 5: Update Start/Stop Scripts

#### Update `start-all.ps1`

Add your backend to the startup sequence:

```powershell
# Add after Daily Utility Tool startup (around line 50)

Write-Output "Step 4/7: Starting New Backend..."
Push-Location NewBackend

# For native process:
$newBackendRunning = netstat -ano | findstr ":8001" | findstr "LISTENING"
if (-not $newBackendRunning) {
    Write-Output "  Starting New Backend as background process..."
    $process = Start-Process "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--reload" -WindowStyle Hidden -PassThru
    $process.Id | Out-File -FilePath "$PSScriptRoot\.new_backend_pid" -Force
    Start-Sleep -Seconds 3
    Write-Output "  New Backend started (PID: $($process.Id))"
} else {
    Write-Output "  New Backend already running"
}
Pop-Location
Write-Output ""

# OR for Docker:
# Write-Output "  Starting New Backend (Docker)..."
# docker compose -f NewBackend/docker-compose.yml up -d
```

#### Update `stop-all.ps1`

Add shutdown logic:

```powershell
# Add after Daily Utility Tool shutdown (around line 40)

Write-Output "Stopping New Backend..."
# For native process:
$pidFile = "$PSScriptRoot\.new_backend_pid"
$stopped = $false

if (Test-Path $pidFile) {
    $storedPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($storedPid -and (Get-Process -Id $storedPid -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $storedPid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        if (-not (Get-Process -Id $storedPid -ErrorAction SilentlyContinue)) {
            Write-Output "  [OK] New Backend stopped (PID: $storedPid)"
            $stopped = $true
        }
    }
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

# Fallback: Kill by port
if (-not $stopped) {
    $port8001Processes = netstat -ano | findstr ":8001" | findstr "LISTENING"
    if ($port8001Processes) {
        # Kill processes on port 8001
        # ... (similar to existing logic)
    }
}

# OR for Docker:
# docker compose -f NewBackend/docker-compose.yml down
Write-Output ""
```

---

## Adding a New Frontend Project

### Step 1: Create Flutter Project in Existing Frontend

The frontend is modular - you can add new projects within the existing Flutter app.

**Navigate to frontend:**

```powershell
cd Daily_Utility_Tool_Frontend
```

### Step 2: Create Project Structure

```
lib/
├── api_services/
│   └── NewProject/               # 🆕 New folder
│       ├── api_routes.dart
│       └── services/
│           └── new_service.dart
├── models/
│   └── NewProject/               # 🆕 New folder
│       └── new_model.dart
├── notifiers/
│   └── NewProject/               # 🆕 New folder
│       └── new_notifier.dart
├── providers/
│   └── NewProject/               # 🆕 New folder
│       └── new_provider.dart
├── routes/
│   └── NewProject/               # 🆕 New folder
│       ├── app_router.dart
│       └── app_pages.dart
├── screens/
│   └── NewProject/               # 🆕 New folder
│       └── home_screen.dart
└── widgets/
    └── NewProject/               # 🆕 New folder
        └── custom_widget.dart
```

### Step 3: Create API Service

**Create `lib/api_services/NewProject/api_routes.dart`:**

```dart
// API endpoints for New Project
const String newProjectBaseUrl = '/api/v2';

const String newProjectHealthEndpoint = '$newProjectBaseUrl/health';
const String newProjectDataEndpoint = '$newProjectBaseUrl/data';
// Add more endpoints...
```

**Create `lib/api_services/NewProject/services/new_service.dart`:**

```dart
import 'package:dio/dio.dart';
import '../api_routes.dart';
import '../../../models/NewProject/new_model.dart';

class NewProjectService {
  static final Dio _dio = Dio();
  
  static void initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: 'http://192.168.1.6',  // Your API base
      connectTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }
  
  Future<NewModel> fetchData() async {
    final response = await _dio.get(newProjectDataEndpoint);
    return NewModel.fromJson(response.data);
  }
  
  Future<void> postData(NewModel data) async {
    await _dio.post(
      newProjectDataEndpoint,
      data: data.toJson(),
    );
  }
}
```

### Step 4: Create Data Models

**Create `lib/models/NewProject/new_model.dart`:**

```dart
class NewModel {
  final String id;
  final String name;
  final String description;
  
  NewModel({
    required this.id,
    required this.name,
    required this.description,
  });
  
  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
```

### Step 5: Create State Management

**Create `lib/notifiers/NewProject/new_notifier.dart`:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/NewProject/new_model.dart';
import '../../api_services/NewProject/services/new_service.dart';

class NewProjectNotifier extends StateNotifier<List<NewModel>> {
  final NewProjectService _service = NewProjectService();
  
  NewProjectNotifier() : super([]);
  
  Future<void> loadData() async {
    try {
      final data = await _service.fetchData();
      state = [...state, data];
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
  
  Future<void> addData(NewModel model) async {
    try {
      await _service.postData(model);
      state = [...state, model];
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}
```

**Create `lib/providers/NewProject/new_provider.dart`:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/NewProject/new_model.dart';
import '../../notifiers/NewProject/new_notifier.dart';

final newProjectProvider = 
  StateNotifierProvider<NewProjectNotifier, List<NewModel>>(
    (ref) => NewProjectNotifier(),
  );
```

### Step 6: Create Routes

**Create `lib/routes/NewProject/app_pages.dart`:**

```dart
abstract final class NewProjectRoutes {
  static const String home = 'new-project-home';
  static const String details = 'new-project-details';
  // Add more route names...
}
```

**Create `lib/routes/NewProject/app_router.dart`:**

```dart
import 'package:go_router/go_router.dart';
import '../../screens/NewProject/home_screen.dart';
import 'app_pages.dart';

final newProjectRoutes = [
  GoRoute(
    path: '/new-project',
    name: NewProjectRoutes.home,
    builder: (context, state) => const NewProjectHomeScreen(),
  ),
  // Add more routes...
];
```

### Step 7: Register Routes in Main Router

**Edit `lib/routes/app_router.dart`:**

```dart
import 'NewProject/app_router.dart';  // 🆕 Add import

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'main-home',
        builder: (context, state) => const MainHomeScreen(),
      ),
      
      ...dailyUtilityToolRoutes,
      ...minimaRoutes,
      ...newProjectRoutes,  // 🆕 Add your routes
    ],
  );
}
```

### Step 8: Create Screens

**Create `lib/screens/NewProject/home_screen.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/NewProject/new_provider.dart';

class NewProjectHomeScreen extends ConsumerWidget {
  const NewProjectHomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(newProjectProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.description),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item
          ref.read(newProjectProvider.notifier).loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Step 9: Add to Home Screen

**Edit `lib/screens/main_home_screen.dart`:**

```dart
// Add project card
ProjectCard(
  title: "New Project",
  description: "Description of your new project",
  icon: LucideIcons.star,  // Choose appropriate icon
  onTap: () => context.go('/new-project'),
  gradient: const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  ),
)
```

---

## Integrating Backend with Nginx

### Routing Patterns

**Choose a routing strategy:**

#### Strategy 1: Path-Based Routing (Recommended)

```nginx
location /api/v1 {
    proxy_pass http://daily_utility_backend;
}

location /api/v2 {
    proxy_pass http://new_backend;
}

location /api/v3 {
    proxy_pass http://another_backend;
}
```

#### Strategy 2: Subdomain Routing

```nginx
server {
    server_name api.example.com;
    location / {
        proxy_pass http://daily_utility_backend;
    }
}

server {
    server_name new-api.example.com;
    location / {
        proxy_pass http://new_backend;
    }
}
```

#### Strategy 3: Feature-Based Routing

```nginx
location /qr {
    proxy_pass http://qr_service;
}

location /analytics {
    proxy_pass http://analytics_service;
}

location /billing {
    proxy_pass http://billing_service;
}
```

### Nginx Configuration Template

```nginx
# Add to nginx.conf

upstream new_backend {
    server host.docker.internal:8001;
}

server {
    listen 80;
    
    # Your new location block
    location /api/v2 {
        # Rate limiting (optional)
        limit_req zone=api_limit burst=20 nodelay;
        
        # Handle CORS preflight
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
        
        # Proxy to backend
        proxy_pass http://new_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

---

## Updating Automation Scripts

### Checklist for Script Updates

- [ ] Update `start-all.ps1` to start new backend
- [ ] Update `stop-all.ps1` to stop new backend
- [ ] Add PID file management (for native processes)
- [ ] Update success messages and status displays
- [ ] Test startup/shutdown sequence

### Example: Complete start-all.ps1 Addition

```powershell
Write-Output "Step X/Y: Starting New Backend..."
Push-Location NewBackend

$newBackendRunning = netstat -ano | findstr ":8001" | findstr "LISTENING"
if (-not $newBackendRunning) {
    Write-Output "  Starting backend as background process..."
    $process = Start-Process "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--reload" -WindowStyle Hidden -PassThru
    $process.Id | Out-File -FilePath "$PSScriptRoot\.new_backend_pid" -Force
    Start-Sleep -Seconds 3
    Write-Output "  Backend started (PID: $($process.Id))"
} else {
    Write-Output "  Backend already running"
}
Pop-Location
Write-Output ""
```

---

## Testing Your New Project

### Backend Testing

```powershell
# Start just your backend
cd NewBackend
python main.py

# Test health endpoint
curl http://localhost:8001/health

# Test through Nginx
curl http://localhost/api/v2/health

# View logs
# Check terminal output
```

### Frontend Testing

```powershell
cd Daily_Utility_Tool_Frontend

# Run in dev mode
flutter run -d chrome

# Navigate to your new project
# Click on project card or go to /new-project

# Check console for errors
# Press F12 in Chrome
```

### Integration Testing

```powershell
# Start all services
.\start-all.ps1

# Test backend directly
curl http://localhost:8001/docs

# Test through Nginx
curl http://localhost/api/v2/

# Test frontend
# Open browser: http://localhost:PORT
# Navigate to new project

# Check logs
docker logs nginx
docker logs backend
# Check PowerShell output
```

---

## Best Practices

### Backend Development

1. **Use Unique Ports**
   - 8000: Daily Utility Tool
   - 8001: Your first new backend
   - 8002+: Additional backends

2. **Environment Variables**
   - Never hardcode credentials
   - Use `.env` files
   - Document all variables in README

3. **API Versioning**
   - Use `/api/v1`, `/api/v2` patterns
   - Maintain backward compatibility
   - Document breaking changes

4. **Error Handling**
   - Return consistent error formats
   - Use appropriate HTTP status codes
   - Log errors for debugging

5. **Documentation**
   - Enable FastAPI docs (`/docs`)
   - Write clear README
   - Document API endpoints

### Frontend Development

1. **Project Isolation**
   - Keep each project in separate folders
   - No cross-project dependencies
   - Shared code goes in `lib/shared/`

2. **State Management**
   - One notifier per feature
   - Keep state simple
   - Use providers for dependency injection

3. **Routing**
   - Use meaningful route names
   - Group related routes
   - Handle deep linking

4. **API Integration**
   - Centralize API configuration
   - Handle errors gracefully
   - Show loading states

5. **Performance**
   - Use `const` constructors
   - Lazy load routes
   - Optimize images

### General Best Practices

1. **Testing**
   - Test each service independently
   - Test integration points
   - Write automated tests

2. **Documentation**
   - Update architecture docs
   - Document new endpoints
   - Keep README current

3. **Version Control**
   - Commit frequently
   - Write clear commit messages
   - Use feature branches

4. **Security**
   - Validate all inputs
   - Use HTTPS in production
   - Implement rate limiting
   - Keep dependencies updated

---

## Examples

### Example 1: Analytics Backend

**Purpose**: Add analytics tracking service

**Backend Structure:**
```
AnalyticsBackend/
├── main.py
├── requirements.txt
├── models/
│   └── event_model.py
├── routes/
│   ├── events.py
│   └── reports.py
└── services/
    └── analytics_service.py
```

**Port**: 8002  
**Nginx Route**: `/api/analytics`  
**Frontend Path**: `lib/*/Analytics/`

### Example 2: Payment Processing

**Purpose**: Handle payments and subscriptions

**Backend**: Dockerized Node.js/Express
**Port**: 8003  
**Nginx Route**: `/api/payments`  
**Database**: Shared PostgreSQL
**Frontend**: New Flutter project screens

### Example 3: File Storage Service

**Purpose**: Upload and manage files

**Backend**: Python/FastAPI with S3 integration
**Port**: 8004  
**Nginx Route**: `/api/files`  
**Features**:
- File upload
- Download with signed URLs
- Image processing
- CDN integration

---

## Troubleshooting

### Issue: Port Conflict

```powershell
# Find and kill process
netstat -ano | findstr ":8001"
Stop-Process -Id <PID> -Force
```

### Issue: Nginx Can't Connect

```powershell
# Restart Nginx after adding new backend
docker restart nginx

# Check Nginx logs
docker logs nginx --tail 50
```

### Issue: Frontend Can't Find Route

```dart
// Ensure route is registered in app_router.dart
// Check route path matches navigation call
context.go('/new-project');  // Must match GoRoute path
```

### Issue: CORS Errors

```nginx
# Ensure CORS headers in Nginx config
add_header 'Access-Control-Allow-Origin' '*' always;
```

---

## Quick Start Checklist

### Adding Backend

- [ ] Create backend folder and files
- [ ] Choose unique port
- [ ] Install dependencies
- [ ] Test backend locally
- [ ] Add to Nginx configuration
- [ ] Update start-all.ps1
- [ ] Update stop-all.ps1
- [ ] Test through Nginx
- [ ] Update documentation

### Adding Frontend Project

- [ ] Create project folders
- [ ] Create API service
- [ ] Create models
- [ ] Create notifiers/providers
- [ ] Create routes
- [ ] Register routes in main router
- [ ] Create screens
- [ ] Add to home screen
- [ ] Test navigation
- [ ] Test API integration

---

## Resources

- **Architecture Docs**: `ARCHITECTURE.md`, `FRONTEND_ARCHITECTURE.md`
- **Getting Started**: `GETTING_STARTED.md`
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev/
- **Nginx Docs**: https://nginx.org/en/docs/

---

**Version**: 1.0.0  
**Last Updated**: June 28, 2026  
**Maintained by**: Architecture Team

---

## Congratulations! 🎉

You now know how to extend the integrated application stack with new backends and frontend projects. Happy building!
