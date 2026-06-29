# Database Services

Independent database infrastructure for URL Shortener application.

## Services

- **PostgreSQL 15**: Main database (Port 5650)
- **Redis 7**: Cache and message broker (Port 6379)

## Quick Start

### Start Database
```powershell
.\start-database.ps1
```

### Stop Database
```powershell
.\stop-database.ps1
```

### View Logs
```powershell
docker compose -f docker-compose.database.yml logs -f
```

### Status
```powershell
docker compose -f docker-compose.database.yml ps
```

## Connection Information

**PostgreSQL:**
```
Host: localhost
Port: 5650
Database: url_db
User: user
Password: password

Connection String: postgresql://user:password@localhost:5650/url_db
```

**Redis:**
```
Host: localhost
Port: 6379

Connection String: redis://localhost:6379/0
```

## Data Management

### Backup Database
```powershell
docker exec postgres pg_dump -U user url_db > backup.sql
```

### Restore Database
```powershell
docker exec -i postgres psql -U user url_db < backup.sql
```

### Clear All Data
```powershell
docker compose -f docker-compose.database.yml down -v
```

## Configuration

Edit `.env` file to change database credentials:
```env
POSTGRES_DB=url_db
POSTGRES_USER=user
POSTGRES_PASSWORD=password
```

## Network

These services use a shared Docker network: `url-shortener-network`

Other services (API, workers) can connect to this network to access the database.

---

**Location**: `c:\Users\NITRO\Desktop\Integrate\Database`
