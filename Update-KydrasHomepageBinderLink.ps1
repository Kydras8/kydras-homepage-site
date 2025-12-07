#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Updates the Corporate Binder button on the Kydras homepage.

.DESCRIPTION
  - Backs up index.html into _backup\<timestamp>\index.html
  - Replaces the placeholder "View binder (coming soon)" button
    with a real link to the GitHub Corporate Binder repo.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- CONFIG ---
$RepoRoot  = "K:\Kydras\Repos\kydras-homepage-site"
$indexPath = Join-Path $RepoRoot "index.html"

Write-Host "=== Update-KydrasHomepageBinderLink ==="
Write-Host "[INFO] Repo root : $RepoRoot"
Write-Host "[INFO] Index path: $indexPath"

if (-not (Test-Path -LiteralPath $indexPath)) {
    throw "index.html not found at $indexPath"
}

# --- BACKUP ---
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRoot = Join-Path $RepoRoot ("_backup\" + $timestamp)

if (-not (Test-Path -LiteralPath $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

$backupIndex = Join-Path $backupRoot "index.html"
Copy-Item -LiteralPath $indexPath -Destination $backupIndex -Force

Write-Host "[BACKUP] index.html -> $backupIndex"

# --- LOAD CONTENT ---
$content = Get-Content -LiteralPath $indexPath -Raw

# This is the old placeholder button block we created earlier
$oldButton = @'
            <a href="#" class="k-btn k-btn-primary k-btn-small">
              View binder (coming soon)
            </a>
'@

# This is the new live link button
$newButton = @'
            <a href="https://github.com/Kydras8/Kydras-CorporateBinder"
               class="k-btn k-btn-primary k-btn-small"
               target="_blank"
               rel="noopener noreferrer">
              View Corporate Binder
            </a>
'@

if ($content -notlike "*View binder (coming soon)*") {
    Write-Host "[WARN] Could not find the placeholder binder button text. No changes applied."
} else {
    $updated = $content.Replace($oldButton, $newButton)
    Set-Content -LiteralPath $indexPath -Value $updated -Encoding UTF8
    Write-Host "[WRITE] Updated binder button link in index.html"
}

Write-Host "[DONE] Homepage binder link update complete."
Write-Host "[INFO] Backup directory: $backupRoot"
