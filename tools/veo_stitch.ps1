# Stitch downloaded per-scene .mp4 files (FFmpeg concat).
# Usage:
#   .\tools\veo_stitch.ps1 -Channel cinematic -ScenesDir "D:\downloads\veo-scenes" -Mode shorts
#   .\tools\veo_stitch.ps1 -Channel cinematic -ScenesDir "..." -Mode long -Session session-01

param(
    [Parameter(Mandatory = $true)]
    [string] $Channel,

    [Parameter(Mandatory = $true)]
    [string] $ScenesDir,

    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'shorts',

    [string] $Session = '',

    [int] $Count = 900,

    [string] $FilePrefix = 'scene-',

    [switch] $SkipMissingScenes,

    [switch] $LongsSkipIncomplete,

    [switch] $DryRun,

    [string] $OutDir = ''
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$StitchScript = Join-Path $Root 'tools\stitch_veo_scenes.ps1'
$ChannelDir = Join-Path $Root "channels\$Channel"
$SessionsDir = Join-Path $ChannelDir 'sessions'

if (-not (Test-Path $StitchScript)) { throw "Missing $StitchScript" }
if (-not (Test-Path $ChannelDir)) { throw "Channel not found: $ChannelDir" }

# Default: skip missing/corrupt (user preference)
if (-not $PSBoundParameters.ContainsKey('SkipMissingScenes')) {
    $SkipMissingScenes = $true
}

if (-not (Test-Path -LiteralPath $ScenesDir)) {
    throw "ScenesDir not found: $ScenesDir"
}
$ScenesDir = (Resolve-Path -LiteralPath $ScenesDir).Path

if (-not $Session) {
    $candidates = @(Get-ChildItem -Path $SessionsDir -Directory -Filter 'session-*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending)
    if ($candidates.Count -gt 0) { $Session = $candidates[0].Name }
}

if (-not $OutDir) {
    if ($Session -and (Test-Path (Join-Path $SessionsDir $Session))) {
        $base = Join-Path $SessionsDir $Session
    }
    else {
        $base = $ChannelDir
    }
    $OutDir = if ($Mode -eq 'long') {
        Join-Path $base 'output\long-videos'
    }
    elseif ($Mode -eq 'shorts') {
        Join-Path $base 'output\shorts'
    }
    else {
        Join-Path $base 'output\stitched'
    }
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$reportPath = Join-Path $OutDir 'stitch-report.json'
$started = (Get-Date).ToString('o')

function Invoke-StitchMode {
    param([string] $StitchMode, [string] $TargetOutDir)
    New-Item -ItemType Directory -Force -Path $TargetOutDir | Out-Null
    $args = @{
        ScenesDir           = $ScenesDir
        Count               = $Count
        FilePrefix          = $FilePrefix
        Mode                = $StitchMode
        OutDir              = $TargetOutDir
    }
    if ($SkipMissingScenes) { $args.SkipMissingScenes = $true }
    if ($LongsSkipIncomplete) { $args.LongsSkipIncomplete = $true }
    if ($DryRun) {
        $args.Mode = 'list'
        $args.OutDir = $TargetOutDir
    }
    & $StitchScript @args
}

$results = @()

if ($Mode -eq 'shorts' -or $Mode -eq 'both') {
    $shortOut = if ($Mode -eq 'both') { Join-Path $OutDir 'shorts' } else { $OutDir }
    Write-Host "=== Stitch SHORTS (3 scenes -> short-NNN.mp4) ===" -ForegroundColor Cyan
    Invoke-StitchMode -StitchMode 'shorts' -TargetOutDir $shortOut
    $results += @{ type = 'shorts'; out = $shortOut; count = [Math]::Floor($Count / 3) }
}

if ($Mode -eq 'long' -or $Mode -eq 'both') {
    $longOut = if ($Mode -eq 'both') { Join-Path $OutDir 'long-videos' } else { $OutDir }
    Write-Host "=== Stitch LONG (180 scenes -> long-NN) ===" -ForegroundColor Cyan
    Invoke-StitchMode -StitchMode 'longs' -TargetOutDir $longOut
    $results += @{ type = 'long'; out = $longOut; segments = [Math]::Ceiling($Count / 180.0) }
}

$report = @{
    channel            = $Channel
    session            = $Session
    mode               = $Mode
    scenes_dir         = $ScenesDir
    count              = $Count
    file_prefix        = $FilePrefix
    skip_missing       = [bool]$SkipMissingScenes
    longs_skip_incomplete = [bool]$LongsSkipIncomplete
    dry_run            = [bool]$DryRun
    output_dir         = $OutDir
    started            = $started
    finished           = (Get-Date).ToString('o')
    results            = $results
}
$report | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath -Encoding utf8

Write-Host "Report: $reportPath" -ForegroundColor Green

[PSCustomObject]@{
    Channel   = $Channel
    Session   = $Session
    Mode      = $Mode
    ScenesDir = $ScenesDir
    OutDir    = $OutDir
    Report    = $reportPath
    DryRun    = [bool]$DryRun
}
