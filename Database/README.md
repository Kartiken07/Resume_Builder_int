# Database Services

Shared database infrastructure for all ToolHub projects.

## Services

- **PostgreSQL 15**: Main database (Port 5650)
- **Redis 7**: Cache and message broker (Port 6379)

## Databases

The PostgreSQL container automatically creates these databases on first startup:

- **url_db**: Used by Minima (URL Shortener)
- **filesharingsystem**: Used by FileSharing System
- **postgres**: Default admin database

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
User: user
Password: password

Databases:
  - url_db (Minima URL Shortener)
  - filesharingsystem (FileSharing System)

Connection String Examples:
  postgresql://user:password@localhost:5650/url_db
  postgresql://user:password@localhost:5650/filesharingsystem
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
# Backup Minima database
docker exec postgres pg_dump -U user url_db > backup_minima.sql

# Backup FileSharing database
docker exec postgres pg_dump -U user filesharingsystem > backup_filesharing.sql
```

### Restore Database
```powershell
# Restore Minima database
docker exec -i postgres psql -U user url_db < backup_minima.sql

# Restore FileSharing database
docker exec -i postgres psql -U user filesharingsystem < backup_filesharing.sql
```

### Clear All Data
```powershell
docker compose -f docker-compose.database.yml down -v
```

## Configuration

Edit `.env` file to change database credentials:
```env
POSTGRES_DB=postgres
POSTGRES_USER=user
POSTGRES_PASSWORD=password
```

**Note**: Individual project databases are created automatically via `init-databases.sh`. To add new databases, edit that script and recreate the container.

## Adding New Project Databases

To add a database for a new project:

1. Edit `init-databases.sh`
2. Add your database creation statement:
   ```sql
   SELECT 'CREATE DATABASE your_new_db'
   WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'your_new_db')\gexec
   
   GRANT ALL PRIVILEGES ON DATABASE your_new_db TO "$POSTGRES_USER";
   ```
3. **If postgres container already exists**, either:
   - Manually create via: `docker exec postgres psql -U user -d postgres -c "CREATE DATABASE your_new_db;"`
   - Or destroy and recreate: `docker compose -f docker-compose.database.yml down -v` then start again

## Network

These services use a shared Docker network: `url-shortener-network`

Other services (API, workers) can connect to this network to access the database.

---

**Location**: `c:\Users\NITRO\Desktop\Integrate\Database`
