# Master Stop Script for ToolHub
# Stops Backend APIs, Daily Utility Tool, and Nginx, but PRESERVES Database

Write-Output "========================================="
Write-Output "  ToolHub - Stopping Services"
Write-Output "========================================="
Write-Output ""

Write-Output "Stopping Nginx..."
Push-Location "$PSScriptRoot\Nginx"
docker compose down
Pop-Location
Write-Output "  [OK] Nginx stopped"
Write-Output ""

Write-Output "Stopping Daily Utility Tool backend..."
# Try to stop using stored PID first
$pidFile = "$PSScriptRoot\.daily_util_pid"
$stopped = $false

if (Test-Path $pidFile) {
    $storedPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($storedPid -and (Get-Process -Id $storedPid -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $storedPid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        # Verify it's stopped
        if (-not (Get-Process -Id $storedPid -ErrorAction SilentlyContinue)) {
            Write-Output "  [OK] Daily Utility backend stopped (PID: $storedPid)"
            $stopped = $true
        }
    }
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

# If not stopped by PID, fallback to kill any process using port 8000
if (-not $stopped) {
    $port8000Processes = netstat -ano | findstr ":8000" | findstr "LISTENING"
    if ($port8000Processes) {
        $processPids = $port8000Processes | ForEach-Object { 
            ($_ -split '\s+')[-1] 
        } | Where-Object { $_ -match '^\d+$' }
        
        foreach ($processPid in $processPids) {
            try {
                $process = Get-Process -Id $processPid -ErrorAction SilentlyContinue
                if ($process) {
                    Stop-Process -Id $processPid -Force
                    Write-Output "  [OK] Stopped process on port 8000 (PID: $processPid)"
                    $stopped = $true
                }
            }
            catch {
                # Process might already be terminated
            }
        }
    }
}

if (-not $stopped) {
    Write-Output "  [INFO] No Daily Utility Tool backend process found"
}
Write-Output ""

Write-Output "Stopping Minima Backend API..."
Push-Location "$PSScriptRoot\Minima"
docker compose -f docker-compose.api.yml down
Pop-Location
Write-Output "  [OK] Minima Backend API stopped"
Write-Output ""

Write-Output "Stopping File Sharing Backend API..."
Push-Location "$PSScriptRoot\FileSharing"
docker compose -f docker-compose.api.yml down
Pop-Location
Write-Output "  [OK] File Sharing Backend API stopped"
Write-Output ""

Write-Output "========================================="
Write-Output "  Services Stopped Successfully!"
Write-Output "========================================="
Write-Output ""
Write-Output "Status:"
Write-Output "  [X] Nginx                   : Stopped"
Write-Output "  [X] Daily Utility Tool      : Stopped"
Write-Output "  [X] Minima Backend API      : Stopped"
Write-Output "  [X] File Sharing Backend    : Stopped"
Write-Output "  [OK] PostgreSQL             : Still running (data preserved)"
Write-Output "  [OK] Redis                  : Still running (cache preserved)"
Write-Output ""
Write-Output "Database is kept running to preserve your data."
Write-Output ""
Write-Output "To restart services:"
Write-Output "  .\start-all.ps1"
Write-Output ""
Write-Output "To stop database (WARNING: May lose data in memory):"
Write-Output "  cd Database"
Write-Output "  .\stop-database.ps1"
Write-Output ""