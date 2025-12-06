#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Sets up the Kydras homepage structure, theme, and GitHub Pages workflow.

.DESCRIPTION
  - Creates .github/workflows/pages.yml
  - Creates index.html, about.html, contact.html, products/index.html
  - Creates assets/css/styles.css
  - Backs up any existing files into _backup\<timestamp>
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -------- CONFIG --------
$RepoRoot = "K:\Kydras\Repos\kydras-homepage-site"

# -------- HELPERS --------
function New-DirSafe {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Backup-FileIfExists {
    param(
        [string]$FilePath,
        [string]$BackupRoot
    )
    if (Test-Path -LiteralPath $FilePath) {
        $relative = Resolve-Path $FilePath | ForEach-Object {
            $_.Path.Replace((Resolve-Path $RepoRoot).Path + [IO.Path]::DirectorySeparatorChar, "")
        }
        $dest = Join-Path $BackupRoot $relative
        $destDir = Split-Path $dest -Parent
        New-DirSafe -Path $destDir
        Copy-Item -LiteralPath $FilePath -Destination $dest -Force
        Write-Host "[BACKUP] $relative -> $dest"
    }
}

Write-Host "=== Setup-KydrasHomepage ==="
Write-Host "[INFO] Repo root: $RepoRoot"

if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "Repo root not found: $RepoRoot"
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRoot = Join-Path $RepoRoot ("_backup\" + $timestamp)
New-DirSafe -Path $backupRoot
Write-Host "[INFO] Backup root: $backupRoot"

# Directories
$githubDir    = Join-Path $RepoRoot ".github"
$workflowsDir = Join-Path $githubDir "workflows"
$assetsDir    = Join-Path $RepoRoot "assets"
$cssDir       = Join-Path $assetsDir "css"
$imgDir       = Join-Path $assetsDir "img"
$productsDir  = Join-Path $RepoRoot "products"

$dirs = @($githubDir, $workflowsDir, $assetsDir, $cssDir, $imgDir, $productsDir)
foreach ($d in $dirs) {
    New-DirSafe -Path $d
    Write-Host "[DIR] Ensured: $d"
}

# Files to back up
$filesToBackup = @(
    (Join-Path $RepoRoot "index.html"),
    (Join-Path $RepoRoot "about.html"),
    (Join-Path $RepoRoot "contact.html"),
    (Join-Path $productsDir "index.html"),
    (Join-Path $cssDir "styles.css"),
    (Join-Path $workflowsDir "pages.yml")
)

foreach ($f in $filesToBackup) {
    Backup-FileIfExists -FilePath $f -BackupRoot $backupRoot
}

# ---------------- pages.yml (GitHub Pages workflow) ----------------
$pagesYmlPath = Join-Path $workflowsDir "pages.yml"
@'
name: Deploy Kydras Homepage to GitHub Pages

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "."

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
'@ | Set-Content -LiteralPath $pagesYmlPath -Encoding UTF8
Write-Host "[WRITE] $pagesYmlPath"

# ---------------- index.html ----------------
$indexHtmlPath = Join-Path $RepoRoot "index.html"
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Kydras Systems Inc. — God-Mode Architecture Hub</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta
    name="description"
    content="Kydras Systems Inc. — Black-and-gold God-Mode platforms for automation, security, and creative systems."
  />
  <link rel="stylesheet" href="assets/css/styles.css" />
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
        <a href="index.html" class="k-nav-link k-nav-link-active">Home</a>
        <a href="about.html" class="k-nav-link">About</a>
        <a href="products/index.html" class="k-nav-link">Products</a>
        <a href="contact.html" class="k-nav-link">Contact</a>
      </nav>
    </div>
  </header>

  <main class="k-main">
    <section class="k-hero">
      <div class="k-hero-content">
        <h1 class="k-hero-title">
          Build in <span class="k-gold">God-Mode</span>.
        </h1>
        <p class="k-hero-subtitle">
          Kydras Systems Inc. designs automation stacks, security tooling, and
          creative platforms for people who treat their systems like an empire,
          not a hobby.
        </p>
        <div class="k-hero-actions">
          <a href="products/index.html" class="k-btn k-btn-primary">
            Explore the Product Suite
          </a>
          <a href="contact.html" class="k-btn k-btn-ghost">
            Talk to Kydras Systems
          </a>
        </div>
      </div>
      <div class="k-hero-panel">
        <div class="k-hero-badge">
          <span class="k-dot"></span>
          Live: Kydras God-Mode Architecture
        </div>
        <div class="k-hero-card">
          <h2>Core Pillars</h2>
          <ul>
            <li>Automation-first: zsh/PowerShell, CI/CD, reproducible builds</li>
            <li>Security-aware: penetration testing & red-team mindset</li>
            <li>Brand-driven: black-and-gold, Eye-of-Horus identity</li>
            <li>Monetization-ready: productized tools & services</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="k-section">
      <header class="k-section-header">
        <h2 class="k-section-title">Kydras Product Suite</h2>
        <p class="k-section-subtitle">
          Ships as code, installers, and deployable stacks — designed for creators,
          security teams, and operators.
        </p>
      </header>

      <div class="k-grid">
        <article class="k-card">
          <h3 class="k-card-title">Kydras eBook Studio Pro</h3>
          <p class="k-card-body">
            A multi-tier eBook production engine with batch conversion, layout
            templates, and Pro-grade licensing. Designed for authors and digital
            publishers who need a repeatable pipeline.
          </p>
          <ul class="k-card-list">
            <li>Free / Lite / Pro tiers</li>
            <li>License key verification with hash checks</li>
            <li>Planned: batch queue, offline GTK UI</li>
          </ul>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">View details</a>
          </div>
        </article>

        <article class="k-card">
          <h3 class="k-card-title">Kydras GodBox</h3>
          <p class="k-card-body">
            A hardened automation box for backups, drive management, and
            God-Mode tooling. Built for Kali/Windows hybrid operators.
          </p>
          <ul class="k-card-list">
            <li>Backup & restore scripts with verbose logging</li>
            <li>Drive mapping and recovery helpers</li>
            <li>Planned: one-click Recovery Mode</li>
          </ul>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">View details</a>
          </div>
        </article>

        <article class="k-card">
          <h3 class="k-card-title">Neo-Godmode VS Code Extension</h3>
          <p class="k-card-body">
            A VS Code extension that embeds the Kydras Prime Directive and
            operation prompts directly into your editor.
          </p>
          <ul class="k-card-list">
            <li>Prompt sets for DevOps, security, and automation</li>
            <li>Planned: auto-build VSIX CI and releases</li>
          </ul>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">View details</a>
          </div>
        </article>

        <article class="k-card">
          <h3 class="k-card-title">Kydras Enterprise CLI</h3>
          <p class="k-card-body">
            Command-line launchpad for the entire Kydras ecosystem: cloning,
            packaging, releasing, and deploying projects with a single command.
          </p>
          <ul class="k-card-list">
            <li>GitHub repo ops</li>
            <li>Zip builder & release pipelines</li>
            <li>Planned: plugin architecture and templates</li>
          </ul>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">View details</a>
          </div>
        </article>
      </div>
    </section>

    <section class="k-section k-section-alt">
      <header class="k-section-header">
        <h2 class="k-section-title">Kydras Corporate Binder</h2>
        <p class="k-section-subtitle">
          A living, versioned binder covering governance, operations, product
          catalog, and security posture for Kydras Systems Inc.
        </p>
      </header>
      <div class="k-binder-layout">
        <div class="k-binder-copy">
          <p>
            The Corporate Binder is where investors, partners, and auditors see
            how the company thinks. It consolidates brand, legal, operational,
            and security documentation into a single automatable artifact.
          </p>
          <ul class="k-card-list">
            <li>Version-controlled in GitHub</li>
            <li>Scripted PDF generation (in progress)</li>
            <li>Black-and-gold Eye-of-Horus branding</li>
          </ul>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-primary k-btn-small">
              View binder (coming soon)
            </a>
          </div>
        </div>
        <div class="k-binder-panel">
          <div class="k-binder-badge">v1 — Foundation</div>
          <div class="k-binder-box">
            <span>Governance</span>
            <span>Brand & Design</span>
            <span>Operations</span>
            <span>Security</span>
          </div>
        </div>
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
'@ | Set-Content -LiteralPath $indexHtmlPath -Encoding UTF8
Write-Host "[WRITE] $indexHtmlPath"

# ---------------- about.html ----------------
$aboutPath = Join-Path $RepoRoot "about.html"
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>About — Kydras Systems Inc.</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="assets/css/styles.css" />
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
        <a href="index.html" class="k-nav-link">Home</a>
        <a href="about.html" class="k-nav-link k-nav-link-active">About</a>
        <a href="products/index.html" class="k-nav-link">Products</a>
        <a href="contact.html" class="k-nav-link">Contact</a>
      </nav>
    </div>
  </header>

  <main class="k-main k-main-narrow">
    <section class="k-section">
      <h1 class="k-page-title">About Kydras Systems Inc.</h1>
      <p>
        Kydras Systems Inc. is a Wyoming-based company focused on building
        automation, security, and creative platforms designed for operators
        who think in systems, not one-off tools.
      </p>
      <p>
        Our work spans secure remote operations, DevOps and CI/CD automation,
        cyber-security tooling, and creator-centric applications. Every product
        is designed to be scriptable, auditable, and brand-consistent.
      </p>
      <p>
        Under the hood, we lean heavily on zsh/PowerShell, GitHub Actions,
        reproducible builds, and a red-team mindset for designing resilient
        systems.
      </p>
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
'@ | Set-Content -LiteralPath $aboutPath -Encoding UTF8
Write-Host "[WRITE] $aboutPath"

# ---------------- contact.html ----------------
$contactPath = Join-Path $RepoRoot "contact.html"
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Contact — Kydras Systems Inc.</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="assets/css/styles.css" />
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
        <a href="index.html" class="k-nav-link">Home</a>
        <a href="about.html" class="k-nav-link">About</a>
        <a href="products/index.html" class="k-nav-link">Products</a>
        <a href="contact.html" class="k-nav-link k-nav-link-active">Contact</a>
      </nav>
    </div>
  </header>

  <main class="k-main k-main-narrow">
    <section class="k-section">
      <h1 class="k-page-title">Contact</h1>
      <p>
        To discuss projects, partnerships, or product licensing, use the
        channels below. This page can later be wired to a form backend or CRM.
      </p>
      <ul class="k-card-list">
        <li>Email: <strong>admin@kydras-systems-inc.com</strong></li>
        <li>Alternate: <strong>kyle@kydras-systems-inc.com</strong></li>
        <li>Location: Wyoming, United States</li>
      </ul>
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
'@ | Set-Content -LiteralPath $contactPath -Encoding UTF8
Write-Host "[WRITE] $contactPath"

# ---------------- products/index.html ----------------
$productsIndexPath = Join-Path $productsDir "index.html"
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Products — Kydras Systems Inc.</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
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

  <main class="k-main">
    <section class="k-section">
      <header class="k-section-header">
        <h1 class="k-page-title">Product Suite</h1>
        <p class="k-section-subtitle">
          A growing ecosystem of tools, extensions, and automations.
        </p>
      </header>

      <div class="k-grid">
        <article class="k-card">
          <h2 class="k-card-title">Kydras eBook Studio Pro</h2>
          <p class="k-card-body">
            A professional-grade eBook production and conversion studio with
            tiered licensing and automation-ready pipelines.
          </p>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">
              Coming soon
            </a>
          </div>
        </article>

        <article class="k-card">
          <h2 class="k-card-title">Kydras GodBox</h2>
          <p class="k-card-body">
            Backup, recovery, and drive-oriented automation for power users.
          </p>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">
              Coming soon
            </a>
          </div>
        </article>

        <article class="k-card">
          <h2 class="k-card-title">Neo-Godmode VS Code Extension</h2>
          <p class="k-card-body">
            God-Mode prompts and workflows, embedded directly in your editor.
          </p>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">
              Coming soon
            </a>
          </div>
        </article>

        <article class="k-card">
          <h2 class="k-card-title">Kydras Enterprise CLI</h2>
          <p class="k-card-body">
            Unified command-line interface to scaffold, package, and ship Kydras
            projects.
          </p>
          <div class="k-card-actions">
            <a href="#" class="k-btn k-btn-small k-btn-primary">
              Coming soon
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
'@ | Set-Content -LiteralPath $productsIndexPath -Encoding UTF8
Write-Host "[WRITE] $productsIndexPath"

# ---------------- assets/css/styles.css ----------------
$cssPath = Join-Path $cssDir "styles.css"
@'
:root {
  --k-bg: #050509;
  --k-bg-alt: #0b0b14;
  --k-panel: #10101a;
  --k-border: #2a2a3a;
  --k-gold: #f5c542;
  --k-gold-soft: #caa03a;
  --k-text: #f5f5f7;
  --k-text-muted: #a0a0b8;
  --k-accent: #46b3ff;
  --k-radius-lg: 1.25rem;
  --k-radius-md: 0.75rem;
  --k-shadow-soft: 0 20px 40px rgba(0, 0, 0, 0.6);
  --k-shadow-small: 0 8px 20px rgba(0, 0, 0, 0.65);
  --k-font-sans: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
    Roboto, sans-serif;
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  padding: 0;
}

.k-body {
  min-height: 100vh;
  background: radial-gradient(circle at top left, #181820 0, #050509 45%, #020308 100%);
  color: var(--k-text);
  font-family: var(--k-font-sans);
}

/* Layout */

.k-header {
  position: sticky;
  top: 0;
  z-index: 20;
  backdrop-filter: blur(18px);
  background: linear-gradient(
    to bottom,
    rgba(5, 5, 9, 0.96),
    rgba(5, 5, 9, 0.9),
    rgba(5, 5, 9, 0.7),
    transparent
  );
  border-bottom: 1px solid rgba(245, 197, 66, 0.18);
}

.k-header-inner {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0.85rem 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1.5rem;
}

.k-logo-block {
  display: flex;
  align-items: center;
  gap: 0.85rem;
}

.k-logo-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 999px;
  border: 2px solid var(--k-gold);
  box-shadow: 0 0 25px rgba(245, 197, 66, 0.6);
  background: radial-gradient(circle at 30% 20%, #fef8d0, #f5c542 55%, #61470c);
}

.k-logo-text {
  display: flex;
  flex-direction: column;
  line-height: 1.1;
}

.k-logo-main {
  font-weight: 650;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  font-size: 0.85rem;
}

.k-logo-sub {
  font-size: 0.75rem;
  color: var(--k-text-muted);
}

/* Navigation */

.k-nav {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.k-nav-link {
  position: relative;
  padding: 0.3rem 0.65rem;
  border-radius: 999px;
  font-size: 0.8rem;
  text-decoration: none;
  color: var(--k-text-muted);
  transition: color 0.2s ease, background 0.2s ease;
}

.k-nav-link::after {
  content: "";
  position: absolute;
  left: 0.9rem;
  right: 0.9rem;
  bottom: 0.1rem;
  height: 2px;
  border-radius: 999px;
  background: linear-gradient(to right, var(--k-gold), var(--k-accent));
  opacity: 0;
  transform: scaleX(0.5);
  transform-origin: center;
  transition: opacity 0.18s ease, transform 0.18s ease;
}

.k-nav-link:hover {
  color: var(--k-text);
}

.k-nav-link-active {
  color: var(--k-gold);
  background: rgba(245, 197, 66, 0.04);
}

.k-nav-link-active::after {
  opacity: 1;
  transform: scaleX(1);
}

/* Main */

.k-main {
  max-width: 1120px;
  margin: 0 auto;
  padding: 1.5rem 1.5rem 2.5rem;
}

.k-main-narrow {
  max-width: 760px;
}

/* Hero */

.k-hero {
  display: grid;
  grid-template-columns: minmax(0, 1.6fr) minmax(0, 1.1fr);
  gap: 2.25rem;
  align-items: center;
  margin-top: 1.2rem;
  margin-bottom: 2.5rem;
}

.k-hero-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.k-hero-title {
  font-size: clamp(2.25rem, 3vw + 1rem, 3.1rem);
  margin: 0;
  letter-spacing: 0.03em;
}

.k-gold {
  color: var(--k-gold);
}

.k-hero-subtitle {
  margin: 0;
  color: var(--k-text-muted);
  font-size: 0.98rem;
  max-width: 32rem;
}

.k-hero-actions {
  margin-top: 1rem;
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.k-hero-panel {
  background: radial-gradient(circle at top left, #26263a, #10101a 50%, #050509);
  border-radius: 1.5rem;
  padding: 1.25rem;
  box-shadow: var(--k-shadow-soft);
  border: 1px solid rgba(245, 197, 66, 0.25);
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
}

.k-hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.3rem 0.7rem;
  border-radius: 999px;
  border: 1px solid rgba(245, 197, 66, 0.4);
  background: rgba(5, 5, 9, 0.7);
  font-size: 0.75rem;
  width: fit-content;
}

.k-dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
  background: #00ff99;
  box-shadow: 0 0 10px rgba(0, 255, 153, 0.8);
}

.k-hero-card {
  background: rgba(5, 5, 9, 0.9);
  border-radius: 1rem;
  padding: 1rem;
  border: 1px solid rgba(255, 255, 255, 0.06);
  font-size: 0.9rem;
}

.k-hero-card h2 {
  margin: 0 0 0.6rem;
  font-size: 0.95rem;
}

.k-hero-card ul {
  margin: 0;
  padding-left: 1.1rem;
  color: var(--k-text-muted);
}

/* Sections */

.k-section {
  margin-bottom: 2.5rem;
}

.k-section-alt {
  background: radial-gradient(circle at top right, #181826, #0b0b14);
  border-radius: 1.5rem;
  padding: 1.75rem 1.5rem;
  border: 1px solid rgba(245, 197, 66, 0.2);
}

.k-section-header {
  margin-bottom: 1.25rem;
}

.k-section-title {
  margin: 0;
  font-size: 1.35rem;
}

.k-section-subtitle {
  margin: 0.35rem 0 0;
  font-size: 0.9rem;
  color: var(--k-text-muted);
}

.k-page-title {
  margin: 0 0 0.75rem;
  font-size: 1.5rem;
}

/* Grid & cards */

.k-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
}

.k-card {
  background: rgba(5, 5, 9, 0.9);
  border-radius: var(--k-radius-lg);
  padding: 1.05rem 1rem;
  border: 1px solid rgba(255, 255, 255, 0.06);
  box-shadow: var(--k-shadow-small);
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}

.k-card-title {
  margin: 0;
  font-size: 1.02rem;
}

.k-card-body {
  margin: 0;
  font-size: 0.9rem;
  color: var(--k-text-muted);
}

.k-card-list {
  margin: 0.3rem 0 0.4rem;
  padding-left: 1.1rem;
  font-size: 0.85rem;
  color: var(--k-text-muted);
}

.k-card-actions {
  margin-top: auto;
}

/* Binder section */

.k-binder-layout {
  display: grid;
  grid-template-columns: minmax(0, 1.5fr) minmax(0, 1fr);
  gap: 1.5rem;
  align-items: center;
}

.k-binder-copy p {
  margin-top: 0;
  margin-bottom: 0.6rem;
}

.k-binder-panel {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}

.k-binder-badge {
  align-self: flex-start;
  padding: 0.25rem 0.7rem;
  border-radius: 999px;
  border: 1px solid rgba(245, 197, 66, 0.5);
  font-size: 0.78rem;
  color: var(--k-gold);
}

.k-binder-box {
  display: grid;
  gap: 0.35rem;
  padding: 0.9rem 0.8rem;
  border-radius: 1rem;
  background: radial-gradient(circle at top left, #25253a, #10101a);
  border: 1px solid rgba(255, 255, 255, 0.08);
  font-size: 0.82rem;
}

.k-binder-box span {
  padding: 0.25rem 0.5rem;
  border-radius: 999px;
  background: rgba(5, 5, 9, 0.85);
}

/* Buttons */

.k-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  padding: 0.5rem 0.95rem;
  border-radius: 999px;
  border: 1px solid transparent;
  font-size: 0.82rem;
  text-decoration: none;
  cursor: pointer;
  transition: background 0.15s ease, color 0.15s ease, border-color 0.15s ease,
    transform 0.08s ease;
  white-space: nowrap;
}

.k-btn-primary {
  background: linear-gradient(120deg, var(--k-gold), var(--k-gold-soft));
  color: #1a1304;
  font-weight: 600;
}

.k-btn-primary:hover {
  background: linear-gradient(120deg, #ffe58a, var(--k-gold));
  transform: translateY(-1px);
}

.k-btn-ghost {
  background: transparent;
  border-color: rgba(245, 197, 66, 0.4);
  color: var(--k-gold);
}

.k-btn-ghost:hover {
  background: rgba(245, 197, 66, 0.06);
}

.k-btn-small {
  padding: 0.4rem 0.8rem;
  font-size: 0.78rem;
}

/* Footer */

.k-footer {
  border-top: 1px solid rgba(245, 197, 66, 0.2);
  padding: 0.9rem 0;
  margin-top: 1rem;
  background: rgba(5, 5, 9, 0.96);
}

.k-footer-inner {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0 1.5rem;
  display: flex;
  justify-content: space-between;
  gap: 0.75rem;
  font-size: 0.8rem;
  color: var(--k-text-muted);
}

/* Responsive */

@media (max-width: 900px) {
  .k-hero {
    grid-template-columns: minmax(0, 1fr);
  }

  .k-hero-panel {
    order: -1;
  }
}

@media (max-width: 720px) {
  .k-header-inner {
    flex-direction: column;
    align-items: flex-start;
  }

  .k-nav {
    width: 100%;
    justify-content: flex-start;
    flex-wrap: wrap;
  }

  .k-main {
    padding-inline: 1.1rem;
  }

  .k-section-alt {
    padding-inline: 1.1rem;
  }

  .k-binder-layout {
    grid-template-columns: minmax(0, 1fr);
  }

  .k-footer-inner {
    flex-direction: column;
  }
}
'@ | Set-Content -LiteralPath $cssPath -Encoding UTF8
Write-Host "[WRITE] $cssPath"

Write-Host ""
Write-Host "[DONE] Kydras homepage structure and workflow have been written."
Write-Host "[INFO] Backups are located at: $backupRoot"
Write-Host "Run 'git status' in the repo to review changes."
