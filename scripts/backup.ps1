# Saves a copy of the n8n database into backups\ (ignored by git).
# Run from the repo folder:  powershell -ExecutionPolicy Bypass -File scripts\backup.ps1

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force -Path "backups" | Out-Null

$file = "backups\n8n-" + (Get-Date -Format "yyyy-MM-dd_HHmm") + ".sql"
# cmd /c keeps the dump byte-for-byte (PowerShell pipes can change the encoding)
cmd /c "docker compose exec -T postgres pg_dump -U n8n -d n8n > `"$file`""
if ($LASTEXITCODE -ne 0) { throw "Backup failed. Is the stack running?" }
Write-Host "Saved $file" -ForegroundColor Green
Write-Host "Keep your .env (N8N_ENCRYPTION_KEY) with it, or saved credentials can't be decrypted."
