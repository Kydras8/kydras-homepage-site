#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Creates the Kydras eBook Studio Pro product page and wires it into the Products index.

.DESCRIPTION
  - Ensures products directory exists
  - Backs up index.html and products/index.html into _backup\<timestamp>
  - Writes products/ebook-studio-pro.html
  - Updates the Kydras eBook Studio Pro card in products/index.html
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- CONFIG ---
$RepoRoot     = "K:\Kydras\Repos\kydras-homepage-site"
$ProductsDir  = Join-Path $RepoRoot "products"
$RootIndex    = Join-Path $RepoRoot "index.html"
$ProductsIndex = Join-Path $ProductsDir "index.html"
$ProductPage  = Join-Path $ProductsDir "ebook-studio-pro.html"

Write-Host "=== Setup-KydrasEBookStudioProPage ==="
Write-Host "[INFO] Repo root       : $RepoRoot"
Write-Host "[INFO] Products dir    : $ProductsDir"
Write-Host "[INFO] Root index      : $RootIndex"
Write-Host "[INFO] Products index  : $ProductsIndex"
Write-Host "[INFO] Product page    : $ProductPage"

if (-not (Test-Path -LiteralPath $RootIndex)) {
    throw "Root index.html not found at $RootIndex"
}
if (-not (Test-Path -LiteralPath $ProductsIndex)) {
    throw "Products index.html not found at $ProductsIndex"
}

# --- Ensure directories ---
if (-not (Test-Path -LiteralPath $ProductsDir)) {
    New-Item -ItemType Directory -Path $ProductsDir | Out-Null
    Write-Host "[DIR] Created products directory: $ProductsDir"
}

# --- Backup both index files ---
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRoot = Join-Path $RepoRoot ("_backup\" + $timestamp)

if (-not (Test-Path -LiteralPath $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

$backupRootIndex    = Join-Path $backupRoot "index.html"
$backupProductsIndex = Join-Path $backupRoot "products_index.html"

Copy-Item -LiteralPath $RootIndex     -Destination $backupRootIndex -Force
Copy-Item -LiteralPath $ProductsIndex -Destination $backupProductsIndex -Force

Write-Host "[BACKUP] Root index    -> $backupRootIndex"
Write-Host "[BACKUP] Products index-> $backupProductsIndex"

# --- Write product page ---
$productHtml = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Kydras eBook Studio Pro — Product Overview</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta
    name="description"
    content="Kydras eBook Studio Pro — a multi-tier eBook production engine with Free, Lite, and Pro options."
  />
  <link rel="stylesheet" href="../assets/css/styles.css" />
</head>
<body class="k-body">
  <header class="k-header">
    <div class="k-header-inner">
      <div class="k-logo-block">
        <div class="k-logo-placeholder" aria-hidden="true"></div>
        <div class="k-logo-text">
          <span class="k-logo-main">Kydras Systems Inc.</span>
          <span class="k-logo-sub">God-Mode Automation & Intelligence</span>
        </div>
      </div>
      <nav class="k-nav">
        <a href="../index.html" class="k-nav-link">Home</a>
        <a href="../about.html" class="k-nav-link">About</a>
        <a href="index.html" class="k-nav-link k-nav-link-active">Products</a>
        <a href="../contact.html" class="k-nav-link">Contact</a>
      </nav>
    </div>
  </header>

  <main class="k-main k-main-narrow">
    <section class="k-section">
      <h1 class="k-page-title">Kydras eBook Studio Pro</h1>
      <p>
        Kydras eBook Studio Pro is a desktop-focused eBook production engine
        for authors, small publishers, and operators who want a repeatable,
        automated pipeline for generating professional eBooks.
      </p>
      <p>
        The tool is designed around batch conversion, layout templates, and
        license tiers, so you can start free and scale up as your catalog grows.
      </p>
    </section>

    <section class="k-section">
      <header class="k-section-header">
        <h2 class="k-section-title">License Tiers & Pricing</h2>
        <p class="k-section-subtitle">
          Start free, then unlock higher throughput and features as needed.
        </p>
      </header>

      <div class="k-grid">
        <article class="k-card">
          <h3 class="k-card-title">Free</h3>
          <p class="k-card-body">
            Ideal for testing the workflow and producing a small number of
            eBooks with Kydras branding.
          </p>
          <ul class="k-card-list">
            <li>Single-project usage</li>
            <li>Basic conversion features</li>
            <li>Kydras watermark on output</li>
            <li>Community support only</li>
          </ul>
          <div class="k-card-actions">
            <span class="k-card-body">Price: $0</span>
          </div>
        </article>

        <article class="k-card">
          <h3 class="k-card-title">Lite</h3>
          <p class="k-card-body">
            For solo authors and small teams who need more capacity and
            fewer restrictions, without the full Pro stack.
          </p>
          <ul class="k-card-list">
            <li>Higher project / file limits</li>
            <li>Reduced or no watermarking</li>
            <li>Access to basic layout templates</li>
            <li>Email-based support (best effort)</li>
          </ul>
          <div class="k-card-actions">
            <span class="k-card-body">Price: $14.99 (one-time)</span>
          </div>
        </article>

        <article class="k-card">
          <h3 class="k-card-title">Pro</h3>
          <p class="k-card-body">
            For power users and micro-publishers running ongoing catalogs.
          </p>
          <ul class="k-card-list">
            <li>Batch conversion and queued jobs</li>
            <li>Advanced layout templates</li>
            <li>Priority support / faster updates</li>
            <li>License key verification with secure hash checks</li>
          </ul>
          <div class="k-card-actions">
            <span class="k-card-body">Price: $29.99 (one-time)</span>
          </div>
        </article>
      </div>
    </section>

    <section class="k-section k-section-alt">
      <header class="k-section-header">
        <h2 class="k-section-title">Planned / In-Progress Features</h2>
        <p class="k-section-subtitle">
          These items match the internal roadmap and will be surfaced in release notes.
        </p>
      </header>
      <div class="k-grid">
        <article class="k-card">
          <h3 class="k-card-title">Batch Conversion & Queues</h3>
          <p class="k-card-body">
            Run multiple conversions in sequence with retry logic and structured logs.
          </p>
        </article>
        <article class="k-card">
          <h3 class="k-card-title">Template System</h3>
          <p class="k-card-body">
            Reusable layout templates so every eBook feels consistent with your brand.
          </p>
        </article>
        <article class="k-card">
          <h3 class="k-card-title">Offline GUI Modes</h3>
          <p class="k-card-body">
            GTK / desktop UI and a web-style UI that both work offline, packaged together.
          </p>
        </article>
      </div>
    </section>

    <section class="k-section">
      <header class="k-section-header">
        <h2 class="k-section-title">Download & Purchase</h2>
        <p class="k-section-subtitle">
          These buttons will be wired to releases and payment links as the product
          packaging is finalized.
        </p>
      </header>

      <div class="k-grid">
        <article class="k-card">
          <h3 class="k-card-title">Get the App</h3>
          <p class="k-card-body">
            Download the latest build or follow development on GitHub.
          </p>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-primary k-btn-small">
              GitHub Releases (coming soon)
            </a>
          </div>
        </article>

        <article class="k-card">
          <h3 class="k-card-title">Buy a License</h3>
          <p class="k-card-body">
            Purchase Lite or Pro via Gumroad or another payment handler.
          </p>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-primary k-btn-small">
              Gumroad / Store (coming soon)
            </a>
          </div>
        </article>
      </div>
    </section>
  </main>

  <footer class="k-footer">
    <div class="k-footer-inner">
      <span>© <span id="k-year"></span> Kydras Systems Inc.</span>
      <span>Built in God-Mode.</span>
    </div>
  </footer>

  <script>
    document.getElementById("k-year").textContent = new Date().getFullYear();
  </script>
</body>
</html>
'@

Set-Content -LiteralPath $ProductPage -Value $productHtml -Encoding UTF8
Write-Host "[WRITE] $ProductPage"

# --- Update Products index card ---
$productsContent = Get-Content -LiteralPath $ProductsIndex -Raw

$oldCardButton = @'
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">
              Coming soon
            </a>
          </div>
'@

$newCardButton = @'
          <div class="k-card-actions">
            <a href="ebook-studio-pro.html" class="k-btn k-btn-small k-btn-primary">
              View details
            </a>
          </div>
'@

if ($productsContent -notlike "*Kydras eBook Studio Pro*") {
    Write-Host "[WARN] Could not find the Kydras eBook Studio Pro card title. No card update applied."
} elseif ($productsContent -notlike "*Coming soon*") {
    Write-Host "[WARN] Could not find the placeholder 'Coming soon' button. No card update applied."
} else {
    $updatedProducts = $productsContent.Replace($oldCardButton, $newCardButton)
    Set-Content -LiteralPath $ProductsIndex -Value $updatedProducts -Encoding UTF8
    Write-Host "[WRITE] Updated eBook Studio Pro card button in products/index.html"
}

Write-Host "[DONE] Kydras eBook Studio Pro product page and card wiring complete."
Write-Host "[INFO] Backup directory: $backupRoot"
