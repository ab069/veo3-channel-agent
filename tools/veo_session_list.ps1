# List all channels and /veo-session status (for 10-100 channel scale).
# Usage: .\tools\veo_session_list.ps1 [-Mode shorts|long|both]

param(
    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'both'
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ChannelsRoot = Join-Path $Root 'channels'
$ProgressScript = Join-Path $Root 'tools\veo_session_progress.ps1'
$QueuePath = Join-Path $ChannelsRoot '.veo-session-queue.json'

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

$rows = @(foreach ($ch in $merged) {
    $prog = & $ProgressScript -Channel $ch -Mode $Mode
  [PSCustomObject]@{
        Channel   = $ch
        Session   = $prog.Session
        Mode      = $prog.Mode
        Phase     = $prog.Phase
        Shorts    = "$($prog.ShortsPrompts)/900"
        Long      = "$($prog.LongPrompts)/900"
        MetaS     = "$($prog.MetadataShorts)/300"
        MetaL     = "$($prog.MetadataLong)/5"
        Complete  = $prog.Complete
    }
})

$rows | Format-Table -AutoSize
$done = @($rows | Where-Object { $_.Complete }).Count
Write-Host "`nChannels: $($rows.Count) | Complete ($Mode): $done | Remaining: $($rows.Count - $done)"

$next = & (Join-Path $Root 'tools\veo_session_next_channel.ps1') -Mode $Mode
if ($next) { Write-Host "Next for -Mode $Mode : $next" }
else { Write-Host "All channels complete for mode: $Mode" }
