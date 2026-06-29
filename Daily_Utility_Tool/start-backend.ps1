# Daily Utility Tool Backend Startup Script

Write-Output "========================================="
Write-Output "  Daily Utility Tool - Backend"
Write-Output "========================================="
Write-Output ""

# Check if Python is available
$pythonCheck = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Output "❌ ERROR: Python is not installed or not in PATH"
    exit 1
}

Write-Output "✅ Python found"
Write-Output ""

# Check if dependencies are installed
Write-Output "Checking dependencies..."
$uvicornCheck = python -m uvicorn --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Output "Installing dependencies..."
    pip install -r requirements.txt
}

Write-Output "✅ Dependencies ready"
Write-Output ""

# Start the backend
Write-Output "Starting Daily Utility Tool backend..."
Write-Output ""
Write-Output "Backend will run on: http://0.0.0.0:8000"
Write-Output "Access via Nginx at: http://192.168.1.6/api"
Write-Output ""
Write-Output "Press Ctrl+C to stop"
Write-Output ""

# Run uvicorn
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
