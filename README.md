# Integrated Application Stack

A comprehensive full-stack application combining multiple backend services (FastAPI) with a Flutter web frontend, orchestrated through Docker and Nginx.

---

## 👋 Setting Up on Your Computer

**If someone shared this project with you:**

1. **Install prerequisites**: Docker Desktop, Python 3.11+, Flutter 3.10+ (see [Prerequisites](#-prerequisites))
2. **Read setup guide**: Open [`GETTING_STARTED.md`](./GETTING_STARTED.md) and follow the configuration steps
3. **One config change**: Update your IP address in `Daily_Utility_Tool_Frontend/lib/api_services/api_routes.dart`
4. **Run it**: Execute `.\start-all.ps1` in PowerShell

That's it! The script automatically:
- ✅ Installs Python dependencies (first time)
- ✅ Starts/restarts databases (even after computer restart)
- ✅ Starts all backend services
- ✅ Configures networking

---

## 🚀 Quick Start

**New to this project? Start here:**

1. **First Time Setup**: Read [`GETTING_STARTED.md`](./GETTING_STARTED.md)
2. **Understanding Architecture**: Read [`ARCHITECTURE.md`](./ARCHITECTURE.md)
3. **Adding New Features**: Read [`ADDING_NEW_PROJECTS.md`](./ADDING_NEW_PROJECTS.md)

## 📋 What's Included

### Backend Services
- **Daily Utility Tool** - Multi-purpose utility API (QR codes, barcodes, age calculator, EMI calculator, unit converter)
- **Minima** - URL shortener service with analytics

### Frontend
- **Flutter Web App** - Unified web interface for all services

### Infrastructure
- **Nginx** - Reverse proxy and load balancer
- **PostgreSQL** - Primary database
- **Redis** - Caching layer
- **Docker** - Container orchestration

## ⚡ Quick Commands

```powershell
# Start all services (auto-installs dependencies first time)
.\start-all.ps1

# Stop all services (keeps databases running)
.\stop-all.ps1

# Start frontend (in separate terminal)
cd Daily_Utility_Tool_Frontend
flutter pub get              # First time only
flutter run -d chrome
```

**After Computer Restart:**
```powershell
.\start-all.ps1              # Automatically restarts databases
```

## 📍 Access Points

After running `start-all.ps1`, services are available at:

| Service | URL | Description |
|---------|-----|-------------|
| Main API | http://YOUR_IP | Nginx reverse proxy |
| API Docs | http://YOUR_IP/docs | Interactive API documentation |
| Health Check | http://YOUR_IP/health | Service health status |
| QR Generator | http://YOUR_IP/api/v1/qr/ | QR code generation |
| URL Shortener | http://YOUR_IP/shorten | Link shortening |

> 💡 Replace `YOUR_IP` with your computer's IP address (find it by running `ipconfig`)

## 🏗️ Project Structure

```
Integrate/
├── Daily_Utility_Tool/          # FastAPI backend #1
│   ├── main.py
│   ├── routes/
│   ├── services/
│   └── models/
├── Minima/                      # FastAPI backend #2 (Dockerized)
│   ├── backend/
│   └── docker-compose.api.yml
├── Daily_Utility_Tool_Frontend/ # Flutter web app
│   ├── lib/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── api_services/
│   │   └── providers/
│   └── pubspec.yaml
├── Database/                    # Database configurations
│   └── docker-compose.yml
├── Nginx/                       # Reverse proxy
│   ├── nginx.conf
│   └── docker-compose.yml
├── start-all.ps1               # Startup automation
├── stop-all.ps1                # Shutdown automation
├── GETTING_STARTED.md          # 👈 Start here for setup
├── ARCHITECTURE.md             # Backend architecture details
├── FRONTEND_ARCHITECTURE.md    # Frontend architecture details
└── ADDING_NEW_PROJECTS.md     # Guide for extending the app
```

## 🔧 Prerequisites

Before you start, make sure you have:

- **Windows 10/11** (64-bit)
- **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)
- **Python 3.11+** - [Download here](https://www.python.org/downloads/)
- **Flutter 3.10+** - [Download here](https://flutter.dev/docs/get-started/install)
- **Git** (optional) - [Download here](https://git-scm.com/downloads)

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [`GETTING_STARTED.md`](./GETTING_STARTED.md) | Complete setup guide for new users |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | Backend architecture and how services connect |
| [`FRONTEND_ARCHITECTURE.md`](./FRONTEND_ARCHITECTURE.md) | Frontend structure and patterns |
| [`ADDING_NEW_PROJECTS.md`](./ADDING_NEW_PROJECTS.md) | How to add new backends and frontend modules |

## 🎯 Features

### Daily Utility Tool
- 📱 QR Code Generator & Reader
- 🔖 Barcode Generator & Scanner
- 🎂 Age Calculator
- 💰 EMI Calculator
- 📏 Unit Converter

### Minima URL Shortener
- 🔗 Create short URLs
- 📊 Click analytics
- 🔒 Custom aliases
- ⏱️ Expiry management

## 🐛 Troubleshooting

### Services won't start?
```powershell
# Make sure Docker Desktop is running
docker --version

# Check if ports are available
netstat -ano | findstr ":8000"
netstat -ano | findstr ":80"
```

### Dependencies not installing?
```powershell
# Manually install Python dependencies
cd Daily_Utility_Tool
pip install -r requirements.txt

# Delete marker file to trigger reinstall
del ..\.daily_util_deps_installed
```

### Can't access the API?
```powershell
# Find your IP address
ipconfig | findstr IPv4

# Make sure Nginx is running
docker ps | findstr nginx

# Restart Nginx to refresh DNS
docker restart nginx
```

### Database connection errors after restart?
```powershell
# The script should auto-start databases, but if not:
docker start postgres
docker start redis

# Or use the startup script
.\start-all.ps1
```

More troubleshooting: See [`GETTING_STARTED.md`](./GETTING_STARTED.md#troubleshooting)

## 🔐 Security Notes

⚠️ **Before deploying to production:**

1. Change default database passwords in `Database/.env` and `Minima/.env`
2. Update `SECRET_KEY` in `Minima/.env`
3. Configure proper CORS origins (remove `*` wildcard)
4. Set up SSL/TLS certificates in Nginx
5. Enable rate limiting
6. Implement authentication/authorization

## 📚 Learning Path

**For Complete Beginners:**
1. Read the [Quick Start](#-quick-start) section above
2. Follow the [`GETTING_STARTED.md`](./GETTING_STARTED.md) guide step-by-step
3. Run `.\start-all.ps1` and explore the running services
4. Try the API documentation at http://YOUR_IP/docs

**For Developers:**
1. Read [`ARCHITECTURE.md`](./ARCHITECTURE.md) to understand the backend
2. Read [`FRONTEND_ARCHITECTURE.md`](./FRONTEND_ARCHITECTURE.md) for frontend patterns
3. Review the codebase structure
4. Try adding a feature using [`ADDING_NEW_PROJECTS.md`](./ADDING_NEW_PROJECTS.md)

## 🤝 Contributing

Want to add a new backend or frontend module? Follow the guide in [`ADDING_NEW_PROJECTS.md`](./ADDING_NEW_PROJECTS.md)

## 📞 Support

Having issues? Check these in order:

1. **Troubleshooting section** in [`GETTING_STARTED.md`](./GETTING_STARTED.md#troubleshooting)
2. **Docker logs**: `docker logs nginx`, `docker logs backend`
3. **Service status**: `docker ps`
4. **Port conflicts**: `netstat -ano | findstr ":8000"`

## 📊 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 8GB | 16GB |
| CPU | 2 cores | 4+ cores |
| Disk Space | 10GB | 20GB |
| OS | Windows 10 | Windows 11 |

## 🗺️ Roadmap

- [ ] Add authentication system
- [ ] Implement API rate limiting
- [ ] Add comprehensive test suite
- [ ] Create mobile app versions
- [ ] Add more utility tools
- [ ] Implement user dashboard

## 📄 License

[Add your license here]

## 👥 Authors

[Add your name/team here]

---

**Version**: 1.0.0  
**Last Updated**: June 29, 2026

---

## 🎉 Ready to Start?

Follow the **[Getting Started Guide](./GETTING_STARTED.md)** now!
