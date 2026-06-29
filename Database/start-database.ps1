# Database Services Startup Script
# Starts PostgreSQL and Redis only

Write-Output "========================================="
Write-Output "  URL Shortener - Database Services"
Write-Output "========================================="
Write-Output ""

# Create shared network if it doesn't exist
Write-Output "Creating shared Docker network..."
docker network create url-shortener-network 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Output "Network created successfully."
} else {
    Write-Output "Network already exists (this is fine)."
}

Write-Output ""
Write-Output "Starting database services..."
Write-Output ""

docker compose -f docker-compose.database.yml up -d

Write-Output ""
Write-Output "========================================="
Write-Output "  Database Services Started!"
Write-Output "========================================="
Write-Output ""
Write-Output "Services Running:"
Write-Output "  ✅ PostgreSQL : Port 5650"
Write-Output "  ✅ Redis      : Port 6379"
Write-Output ""
Write-Output "Connection Strings:"
Write-Output "  PostgreSQL: postgresql://user:password@localhost:5650/url_db"
Write-Output "  Redis: redis://localhost:6379/0"
Write-Output ""
Write-Output "To start the backend API, run:"
Write-Output "  .\start-api.ps1"
Write-Output ""
