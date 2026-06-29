# Nginx Reverse Proxy Startup Script

Write-Output "========================================="
Write-Output "  URL Shortener - Nginx Reverse Proxy"
Write-Output "========================================="
Write-Output ""

# Ensure network exists
Write-Output "Ensuring shared Docker network exists..."
docker network create url-shortener-network 2>$null

# Check if backend is running
Write-Output "Checking if backend API is running..."
$backendRunning = docker ps --filter "name=backend" --filter "status=running" --format "{{.Names}}"

if (-not $backendRunning) {
    Write-Output ""
    Write-Output "⚠️  WARNING: Backend API is not running!"
    Write-Output ""
    Write-Output "Nginx will start, but it needs the backend to proxy requests."
    Write-Output ""
    Write-Output "Start the backend from:"
    Write-Output "  c:\Users\NITRO\Desktop\Integrate\Minima\"
    Write-Output "  .\start-api.ps1"
    Write-Output ""
    $response = Read-Host "Continue anyway? (y/n)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Output ""
        Write-Output "Exiting. Please start the backend first."
        exit 1
    }
}

Write-Output ""
Write-Output "Starting Nginx reverse proxy..."
Write-Output ""

docker compose up -d

Write-Output ""
Write-Output "========================================="
Write-Output "  Nginx Started Successfully!"
Write-Output "========================================="
Write-Output ""
Write-Output "Service Running:"
Write-Output "  ✅ Nginx Reverse Proxy : Port 80"
Write-Output ""
Write-Output "Nginx proxies requests to backend API"
Write-Output ""
Write-Output "Access Points:"
Write-Output "  Health Check : http://localhost/health"
Write-Output "  API Docs     : http://localhost/docs"
Write-Output ""
Write-Output "Configuration:"
Write-Output "  - Rate limiting: 10 req/sec"
Write-Output "  - CORS enabled"
Write-Output "  - Max upload: 10MB"
Write-Output ""
