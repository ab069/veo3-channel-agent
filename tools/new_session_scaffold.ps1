# Create next session folder. Mode: shorts | long | both
# Usage: .\tools\new_session_scaffold.ps1 -Channel cinematic -Mode shorts

param(
    [Parameter(Mandatory = $true)]
    [string] $Channel,

    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'both'
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ChannelDir = Join-Path $Root "channels\$Channel"
$SessionsDir = Join-Path $ChannelDir 'sessions'
$Scenes = 900

if (-not (Test-Path (Join-Path $ChannelDir 'info.md'))) {
    throw "Channel not found or missing info.md: $ChannelDir"
}

if (-not (Test-Path $SessionsDir)) {
    New-Item -ItemType Directory -Path $SessionsDir -Force | Out-Null
}

# New session number = max existing + 1 (any mode)
$nums = @(Get-ChildItem -Path $SessionsDir -Directory -Filter 'session-*' -ErrorAction SilentlyContinue |
    ForEach-Object {
        if ($_.Name -match '^session-(\d+)$') { [int]$Matches[1] }
    })
$next = if ($nums.Count -gt 0) { ($nums | Measure-Object -Maximum).Maximum + 1 } else { 1 }
$sessionName = 'session-{0:D2}' -f $next
$sessionDir = Join-Path $SessionsDir $sessionName

if (Test-Path $sessionDir) {
    throw "Session already exists: $sessionDir"
}

$projectBase = "$Channel-$sessionName"
$created = Get-Date -Format 'yyyy-MM-dd'
$modeLabel = switch ($Mode) {
    'shorts' { 'Shorts only (portrait 9:16)' }
    'long' { 'Long videos only (landscape 16:9)' }
    default { 'Shorts + long (full library)' }
}

New-Item -ItemType Directory -Path (Join-Path $sessionDir 'videos') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $sessionDir 'output\shorts') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $sessionDir 'output\long-videos') -Force | Out-Null

$deliverRows = @()
if ($Mode -in @('shorts', 'both')) {
    $deliverRows += '| prompts-shorts.md | **900** portrait scenes |'
    $deliverRows += '| youtube-metadata-shorts.md | **300** Shorts |'
}
if ($Mode -in @('long', 'both')) {
    $deliverRows += '| prompts-long-videos.md | **900** landscape scenes |'
    $deliverRows += '| youtube-metadata-long-videos.md | **5** long videos |'
}
$deliverTable = $deliverRows -join "`n"

$sessionMd = @"
# Session $sessionName - $Channel

- **Mode:** ``$Mode`` ($modeLabel)
- **Channel context:** [../info.md](../info.md)
- **Progress:** ``.progress.json`` (updated by /veo-session-$Mode)
- **Created:** $created
- **Spec:** [docs/VEO3-PROMPT-SPEC.md](../../../docs/VEO3-PROMPT-SPEC.md)

## Deliverables

| File | Target |
|------|--------|
$deliverTable
| plan.md | merge/stitch for this mode |

"@

$planParts = @("# Plan - $sessionName ($Channel) - mode: **$Mode**`n")
if ($Mode -in @('shorts', 'both')) {
    $planParts += @"

## Shorts (900 scenes, 9:16)

- **300** Shorts (3x8s = 24s each)
- **30** veo3 packs x **30** prompts (~4 min raw -> 10 Shorts)
- Projects: ``$projectBase-shorts-pack-01`` ... ``30``

### FFmpeg trim

Short k (0-based): start k*24s, duration 24s -> ``output/shorts/short-NNN.mp4``
"@
}
if ($Mode -in @('long', 'both')) {
    $planParts += @"

## Long videos (900 scenes, 16:9)

- **5** films x **180** scenes (~24 min each)
- Projects: ``$projectBase-long-01`` (1-180) ... ``05`` (721-900)
"@
}
$planMd = $planParts -join "`n"

Set-Content -Path (Join-Path $sessionDir 'session.md') -Value $sessionMd -Encoding utf8
Set-Content -Path (Join-Path $sessionDir 'plan.md') -Value $planMd -Encoding utf8

if ($Mode -in @('shorts', 'both')) {
    $headerShorts = @"
# Prompts - Shorts | $Channel - $sessionName

> **900** portrait prompts - **8 sec/scene** - **3 prompts = 1 Short** (24s)
> **30 veo3 packs** x **30 prompts** | Mode: **$Mode**
> Platform: **veo3.pk** | Model: **Google Flow VEO** | Spec: ``docs/VEO3-PROMPT-SPEC.md``
> **Variety:** 3 unique places + 3 unique voices per Short — never clone the previous triplet.

---

"@
    Set-Content -Path (Join-Path $sessionDir 'prompts-shorts.md') -Value $headerShorts -Encoding utf8
}

if ($Mode -in @('long', 'both')) {
    $headerLong = @"
# Prompts - Long Videos | $Channel - $sessionName

> **900** landscape prompts - **8 sec/scene** - **5** x 180 scenes (~24 min)
> Mode: **$Mode** | Platform: **veo3.pk** | Model: **Google Flow VEO**
> Spec: ``docs/VEO3-PROMPT-SPEC.md``

---

"@
    Set-Content -Path (Join-Path $sessionDir 'prompts-long-videos.md') -Value $headerLong -Encoding utf8
}

$progress = @{
    channel = $Channel
    session = $sessionName
    mode    = $Mode
    status  = 'in_progress'
    phase   = if ($Mode -eq 'long') { 'prompts-long' } else { 'prompts-shorts' }
    updated = (Get-Date).ToString('o')
}
$progress | ConvertTo-Json | Set-Content -Path (Join-Path $sessionDir '.progress.json') -Encoding utf8

Write-Output @{
    Channel    = $Channel
    Session    = $sessionName
    SessionDir = $sessionDir
    Mode       = $Mode
    Scenes     = $Scenes
}
