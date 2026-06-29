# Stop Database Services Script

Write-Output "========================================="
Write-Output "  Stopping Database Services"
Write-Output "========================================="
Write-Output ""

docker compose -f docker-compose.database.yml down

Write-Output ""
Write-Output "Database services stopped."
Write-Output ""
Write-Output "To preserve data, volumes are kept."
Write-Output "To remove all data, run:"
Write-Output "  docker compose -f docker-compose.database.yml down -v"
Write-Output ""
