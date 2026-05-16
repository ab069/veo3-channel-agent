# Pick next channel for /veo-session variants (incomplete for given mode).
param(
    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'both'
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ChannelsRoot = Join-Path $Root 'channels'
$QueuePath = Join-Path $ChannelsRoot '.veo-session-queue.json'
$ProgressScript = Join-Path $Root 'tools\veo_session_progress.ps1'

$order = @('cinematic')
if (Test-Path $QueuePath) {
    $q = Get-Content $QueuePath -Raw | ConvertFrom-Json
    if ($q.channel_order) { $order = @($q.channel_order) }
}

$discovered = @(Get-ChildItem -Path $ChannelsRoot -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'info.md') } |
    ForEach-Object { $_.Name })

$merged = @($order | Where-Object { $_ -in $discovered })
$merged += @($discovered | Where-Object { $_ -notin $merged } | Sort-Object)

foreach ($ch in $merged) {
    $prog = & $ProgressScript -Channel $ch -Mode $Mode
    if (-not $prog.Complete) {
        Write-Output $ch
        exit 0
    }
}

Write-Output ''
