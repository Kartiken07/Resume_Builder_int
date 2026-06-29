# Stop Nginx Reverse Proxy Script

Write-Output "========================================="
Write-Output "  Stopping Nginx Reverse Proxy"
Write-Output "========================================="
Write-Output ""

docker compose down

Write-Output ""
Write-Output "Nginx stopped."
Write-Output ""
Write-Output "Backend API and Database are still running."
Write-Output ""
