# Starts the local AI stack and opens n8n.
# Run from the repo folder:  powershell -ExecutionPolicy Bypass -File scripts\start.ps1

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

if (-not (Test-Path ".env")) {
    Write-Host "No .env file yet. Copy .env.example to .env and fill it in first." -ForegroundColor Yellow
    exit 1
}

# 1. Docker Desktop
docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Starting Docker Desktop..."
    Start-Process "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    do { Start-Sleep -Seconds 3; docker info *> $null } until ($LASTEXITCODE -eq 0)
}
Write-Host "Docker is running." -ForegroundColor Green

# 2. Ollama (runs on Windows so it can use the GPU)
try {
    Invoke-RestMethod "http://localhost:11434/api/version" -TimeoutSec 3 | Out-Null
    Write-Host "Ollama is running." -ForegroundColor Green
} catch {
    Write-Host "Ollama isn't answering on port 11434. Open the Ollama app, then run this again." -ForegroundColor Yellow
}

# 3. n8n + Postgres
docker compose up -d
Write-Host "Waiting for n8n..."
do {
    Start-Sleep -Seconds 2
    try { $ok = (Invoke-WebRequest "http://localhost:5678/healthz" -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200 } catch { $ok = $false }
} until ($ok)

Write-Host "n8n is ready at http://localhost:5678" -ForegroundColor Green
Start-Process "http://localhost:5678"
