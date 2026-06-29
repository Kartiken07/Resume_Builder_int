# Stop Backend API Services Script

Write-Output "========================================="
Write-Output "  Stopping Backend API Services"
Write-Output "========================================="
Write-Output ""

docker compose -f docker-compose.api.yml down

Write-Output ""
Write-Output "Backend API services stopped."
Write-Output ""
Write-Output "Database services are still running."
Write-Output "To stop database:"
Write-Output "  cd ..\Database"
Write-Output "  .\stop-database.ps1"
Write-Output ""
