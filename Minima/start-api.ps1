param (
    [string]$Domain = ""
)

# Backend API Services Startup Script
# Starts FastAPI Backend and Celery Worker only

Write-Output "========================================="
Write-Output "  URL Shortener - Backend API"
Write-Output "========================================="
Write-Output ""

# 1. Discover Primary IPv4 Address
$activeRoute = Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Where-Object { $_.NextHop -ne '0.0.0.0' } | Select-Object -First 1
$ip = $null

if ($activeRoute) {
    $ip = (Get-NetIPAddress -InterfaceIndex $activeRoute.InterfaceIndex -AddressFamily IPv4 | Select-Object -First 1).IPAddress
}

if (-not $ip) {
    $addresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        $_.InterfaceAlias -notmatch 'Loopback|VirtualBox|VMware|vEthernet|WSL|Docker|Hyper-V|Virtual|Pseudo|Host-Only|Tailscale|TAP' -and 
        $_.IPAddress -notmatch '^169\.254\.' 
    }
    $ip = ($addresses | Where-Object { 
        $_.IPAddress -like '192.168.*' -or 
        $_.IPAddress -like '10.*' -or 
        $_.IPAddress -match '^172\.(1[6-9]|2[0-9]|3[0-1])\.'
    } | Select-Object -First 1).IPAddress
    
    if (-not $ip) {
        $ip = ($addresses | Select-Object -First 1).IPAddress
    }
}

if (-not $ip) {
    Write-Output "Warning: Could not automatically detect primary LAN IP. Falling back to localhost."
    $ip = "localhost"
}

if ($Domain) {
    $ip = $Domain
    $apiBase = "http://$($Domain)"
} else {
    $apiBase = "http://$($ip)"
}

Write-Output "Primary IP: $ip"
Write-Output "API Base URL: $apiBase"
Write-Output ""

# 2. Update .env file
$env:API_BASE_URL = $apiBase

$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
    Write-Output "Creating default .env file..."
    $defaultEnv = @(
        "# Environment variables for Backend Services",
        "API_BASE_URL=http://localhost:8000",
        "DATABASE_URL=postgresql://user:password@postgres/url_db",
        "REDIS_URL=redis://redis:6379/0",
        "ALLOWED_ORIGINS=*",
        "PYTHONPATH=./url_shortener_backend"
    )
    $defaultEnv | Set-Content $envFile
}

$content = Get-Content $envFile
$newContent = @()
$found = $false
foreach ($line in $content) {
    if ($line -match '^#?\s*API_BASE_URL=') {
        $newContent += "API_BASE_URL=$apiBase"
        $found = $true
    } else {
        $newContent += $line
    }
}
if (-not $found) {
    $newContent += "API_BASE_URL=$apiBase"
}
$newContent | Set-Content $envFile

# 3. Ensure network exists
Write-Output "Ensuring shared Docker network exists..."
docker network create url-shortener-network 2>$null

# 4. Check if database is running
Write-Output "Checking database services..."
$postgresRunning = docker ps --filter "name=postgres" --filter "status=running" --format "{{.Names}}"
$redisRunning = docker ps --filter "name=redis" --filter "status=running" --format "{{.Names}}"

if (-not $postgresRunning -or -not $redisRunning) {
    Write-Output ""
    Write-Output "⚠️  WARNING: Database services are not running!"
    Write-Output ""
    Write-Output "Please start the database first from:"
    Write-Output "  c:\Users\NITRO\Desktop\Integrate\Database\"
    Write-Output "  .\start-database.ps1"
    Write-Output ""
    $response = Read-Host "Do you want to navigate and start the database now? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Output ""
        Write-Output "Starting database services..."
        Push-Location "c:\Users\NITRO\Desktop\Integrate\Database"
        & ".\start-database.ps1"
        Pop-Location
        Write-Output ""
        Write-Output "Waiting for database to be ready..."
        Start-Sleep -Seconds 5
    } else {
        Write-Output ""
        Write-Output "Exiting. Please start the database before running the API."
        exit 1
    }
}

Write-Output ""
Write-Output "Starting backend API services..."
Write-Output ""

docker compose -f docker-compose.api.yml up --build -d

Write-Output ""
Write-Output "========================================="
Write-Output "  Backend API Started Successfully!"
Write-Output "========================================="
Write-Output ""
Write-Output "Services Running:"
Write-Output "  ✅ FastAPI Backend : Internal (port 8000)"
Write-Output "  ✅ Celery Worker   : Background"
Write-Output ""
Write-Output "Backend is running on internal network."
Write-Output "Access via Nginx reverse proxy (port 80)."
Write-Output ""
Write-Output "To start Nginx:"
Write-Output "  cd ..\Nginx"
Write-Output "  .\start-nginx.ps1"
Write-Output ""
Write-Output "Database Services:"
Write-Output "  ✅ PostgreSQL : Port 5650"
Write-Output "  ✅ Redis      : Port 6379"
Write-Output ""
