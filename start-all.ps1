param (
    [string]$Domain = ""
)

Write-Output "========================================="
Write-Output "  URL Shortener - Master Startup"
Write-Output "========================================="
Write-Output ""

$activeRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Where-Object { $_.NextHop -ne "0.0.0.0" } | Select-Object -First 1
$ip = $null

if ($activeRoute) {
    $ip = (Get-NetIPAddress -InterfaceIndex $activeRoute.InterfaceIndex -AddressFamily IPv4 | Select-Object -First 1).IPAddress
}

if (-not $ip) {
    $ip = "192.168.1.6"
}

Write-Output "Detected IP: $ip"
Write-Output ""

Write-Output "Step 1/4: Creating shared Docker network..."
docker network create url-shortener-network 2>$null
Write-Output "  Network ready"
Write-Output ""

Write-Output "Step 2/5: Checking database services..."
# Check for exact container names (postgres and redis for Minima)
$postgresRunning = docker ps --filter name=^postgres$ --filter status=running -q
$redisRunning = docker ps --filter name=^redis$ --filter status=running -q

# Check if containers exist but are stopped
$postgresStopped = docker ps -a --filter name=^postgres$ --filter status=exited -q
$redisStopped = docker ps -a --filter name=^redis$ --filter status=exited -q

if ($postgresStopped -or $redisStopped) {
    Write-Output "  Database containers exist but stopped. Starting them..."
    if ($postgresStopped) {
        docker start postgres | Out-Null
        Write-Output "  PostgreSQL started"
    }
    if ($redisStopped) {
        docker start redis | Out-Null
        Write-Output "  Redis started"
    }
    Write-Output "  Waiting for databases to be ready..."
    Start-Sleep -Seconds 5
} elseif (-not $postgresRunning -or -not $redisRunning) {
    Write-Output "  Creating and starting database services..."
    Push-Location Database
    docker compose up -d
    Pop-Location
    Write-Output "  Database started"
    Write-Output "  Waiting for databases to be ready..."
    Start-Sleep -Seconds 5
} else {
    Write-Output "  Database already running"
}
Write-Output ""

Write-Output "Step 3/6: Starting Daily Utility Tool backend..."
Push-Location Daily_Utility_Tool

# Check if dependencies are installed
$depsInstalled = Test-Path "$PSScriptRoot\.daily_util_deps_installed"
if (-not $depsInstalled) {
    Write-Output "  First time setup detected..."
    Write-Output "  Installing Python dependencies..."
    pip install -r requirements.txt --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Output "  Dependencies installed successfully"
        New-Item -Path "$PSScriptRoot\.daily_util_deps_installed" -ItemType File -Force | Out-Null
    } else {
        Write-Output "  [WARNING] Failed to install dependencies. Please run manually:"
        Write-Output "  cd Daily_Utility_Tool && pip install -r requirements.txt"
    }
}

# Check if already running
$dailyUtilRunning = netstat -ano | findstr ":8000" | findstr "LISTENING"
if (-not $dailyUtilRunning) {
    Write-Output "  Starting backend as background process..."
    # Start as background process without new window
    $process = Start-Process "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload" -WindowStyle Hidden -PassThru
    # Store process ID for later termination
    $process.Id | Out-File -FilePath "$PSScriptRoot\.daily_util_pid" -Force
    Start-Sleep -Seconds 3
    Write-Output "  Backend started (PID: $($process.Id))"
} else {
    Write-Output "  Backend already running"
}
Pop-Location
Write-Output ""

Write-Output "Step 4/6: Starting Minima backend API..."
Push-Location Minima
docker compose -f docker-compose.api.yml up -d
Pop-Location
Write-Output "  Backend API started"
Write-Output "  Waiting for backend to be ready..."
Start-Sleep -Seconds 5
Write-Output ""

Write-Output "Step 5/6: Starting Nginx reverse proxy..."
Push-Location Nginx
docker compose up -d
Pop-Location
Write-Output "  Nginx started"
Write-Output ""

Write-Output "Step 6/6: Ensuring Nginx can connect to backends..."
Write-Output "  Restarting Nginx to refresh DNS resolution..."
docker restart nginx 2>&1 | Out-Null
Start-Sleep -Seconds 2
Write-Output "  Nginx DNS refreshed"
Write-Output ""

Write-Output "========================================="
Write-Output "  All Services Started Successfully!"
Write-Output "========================================="
Write-Output ""
Write-Output "Services Running:"
Write-Output "  ✅ PostgreSQL          : Database"
Write-Output "  ✅ Redis               : Cache"
Write-Output "  ✅ Daily Utility Tool  : Port 8000"
Write-Output "  ✅ Backend API         : Containerized"
Write-Output "  ✅ Nginx               : Reverse Proxy"
Write-Output ""
Write-Output "Access Your Application:"
Write-Output "  API Documentation : http://$ip/docs"
Write-Output "  Health Check      : http://$ip/health"
Write-Output "  Base URL          : http://$ip"
Write-Output ""
