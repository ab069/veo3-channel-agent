# Unattended session fill: loop 30-scene packs + metadata until Complete.
# No "continue" in chat — run once in terminal (or agent runs this once).
#
# Usage:
#   .\tools\veo_session_auto.ps1 -Channel cinematic -Mode shorts
#   .\tools\veo_session_auto.ps1 -Mode shorts   # next channel from queue

param(
    [string] $Channel = '',

    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'shorts',

    [string] $Session = '',

    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$NextScript = Join-Path $Root 'tools\veo_session_next_channel.ps1'
$GuardsScript = Join-Path $Root 'tools\veo_session_guards.ps1'
$ProgressScript = Join-Path $Root 'tools\veo_session_progress.ps1'
$ScaffoldScript = Join-Path $Root 'tools\new_session_scaffold.ps1'
$MetaScript = Join-Path $Root 'tools\veo_session_metadata_pack.ps1'
$GenShorts = Join-Path $Root 'tools\generate_shorts_prompts_900.py'

function Get-Python() {
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) { return $py.Source }
    $py = Get-Command python -ErrorAction SilentlyContinue
    if ($py) { return $py.Source }
    throw 'Python not found (install py or python).'
}

if (-not $Channel) {
    $Channel = & $NextScript -Mode $Mode
    if (-not $Channel) { throw 'No channel to process (queue empty or all complete?).' }
    Write-Host "Channel: $Channel"
}

$g = & $GuardsScript -Channel $Channel -Mode $Mode -Session $Session
if (-not $g.Ok) {
    $g.Errors | ForEach-Object { Write-Error $_ }
    exit 1
}
if ($g.Action -eq 'scaffold') {
    if ($WhatIf) { Write-Host "Would scaffold: $($g.ScaffoldCommand)"; exit 0 }
    & $ScaffoldScript -Channel $Channel -Mode $Mode
}

$iter = 0
$maxIter = 200

while ($iter -lt $maxIter) {
    $iter++
    $prog = & $ProgressScript -Channel $Channel -Mode $Mode -Session $Session

    if ($prog.Complete) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host " COMPLETE: $Channel $($prog.Session) [$Mode]" -ForegroundColor Green
        Write-Host " Prompts: $($prog.ShortsPrompts) shorts / $($prog.LongPrompts) long" -ForegroundColor Green
        Write-Host " Metadata: $($prog.MetadataShorts) shorts / $($prog.MetadataLong) long" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Next: /clear then .\tools\veo_session_auto.ps1 -Mode $Mode for next channel."
        exit 0
    }

    $phase = $prog.Phase
    Write-Host "[$Channel] $($prog.Session) — $phase — shorts $($prog.ShortsPrompts)/900, meta $($prog.MetadataShorts)/300"

    if ($WhatIf) {
        Write-Host "  Would process batch $($prog.NextBatchStart)-$($prog.NextBatchEnd) (phase $phase)"
        break
    }

    if ($phase -eq 'prompts-shorts') {
        if ($Mode -eq 'long') { throw "Phase prompts-shorts but Mode is long." }
        $pack = [int][Math]::Floor($prog.ShortsPrompts / 30) + 1
        if ($pack -gt 30) { throw "Pack index $pack out of range." }
        $py = Get-Python
        & $py $GenShorts `
            --session-dir $prog.SessionDir `
            --channel $Channel `
            --session $prog.Session `
            --pack $pack `
            --append
    }
    elseif ($phase -eq 'metadata-shorts') {
        & $MetaScript -Channel $Channel -Session $prog.Session `
            -FromShort $prog.NextBatchStart -ToShort $prog.NextBatchEnd
    }
    elseif ($phase -like 'prompts-long*' -or $phase -like 'metadata-long*') {
        Write-Error "veo_session_auto.ps1: long/both prompt generation not automated yet. Use /veo-session-long in chat or extend this script."
        exit 2
    }
    else {
        Write-Error "Unknown phase: $phase"
        exit 3
    }
}

throw "Exceeded $maxIter iterations - check session state."
