# Report / resume /veo-session progress for a channel.
# Usage:
#   .\tools\veo_session_progress.ps1 -Channel cinematic -Mode shorts
#   .\tools\veo_session_progress.ps1 -Channel cinematic -Mode both -Session session-01

param(
    [Parameter(Mandatory = $true)]
    [string] $Channel,

    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'both',

    [string] $Session = '',

    [string] $SetPhase = '',
    [string] $SetStatus = ''
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ChannelDir = Join-Path $Root "channels\$Channel"
$SessionsDir = Join-Path $ChannelDir 'sessions'

function Count-Prompts([string]$Path) {
    if (-not (Test-Path $Path)) { return 0 }
    return ([regex]::Matches((Get-Content -Raw $Path), '(?m)^Prompt \d+:')).Count
}

function Count-ShortBlocks([string]$Path) {
    if (-not (Test-Path $Path)) { return 0 }
    return ([regex]::Matches((Get-Content -Raw $Path), '(?m)^## Short #\d+')).Count
}

function Get-SessionMode([string]$ProgressPath) {
    if (-not (Test-Path $ProgressPath)) { return $null }
    $j = Get-Content $ProgressPath -Raw | ConvertFrom-Json
    if ($j.mode) { return [string]$j.mode }
    return 'both'
}

if (-not $Session) {
    $candidates = @(Get-ChildItem -Path $SessionsDir -Directory -Filter 'session-*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending)
    foreach ($d in $candidates) {
        $pp = Join-Path $d.FullName '.progress.json'
        if (-not (Test-Path $pp)) { continue }
        $sm = Get-SessionMode $pp
        $j = Get-Content $pp -Raw | ConvertFrom-Json
        $modeOk = ($sm -eq $Mode) -or ($sm -eq 'both' -and $Mode -in @('shorts', 'long'))
        if ($modeOk -and $j.status -ne 'complete') {
            $Session = $d.Name
            break
        }
    }
    if (-not $Session) {
        $nums = @(Get-ChildItem -Path $SessionsDir -Directory -Filter 'session-*' -ErrorAction SilentlyContinue |
            ForEach-Object {
                if ($_.Name -match '^session-(\d+)$') { [int]$Matches[1] }
            })
        $nextNum = if ($nums.Count -gt 0) { ($nums | Measure-Object -Maximum).Maximum + 1 } else { 1 }
        $Session = 'session-{0:D2}' -f $nextNum
    }
}

$sessionDir = Join-Path $SessionsDir $Session
$progressPath = Join-Path $sessionDir '.progress.json'

$shortsPath = Join-Path $sessionDir 'prompts-shorts.md'
$longPath = Join-Path $sessionDir 'prompts-long-videos.md'
$metaShortsPath = Join-Path $sessionDir 'youtube-metadata-shorts.md'
$metaLongPath = Join-Path $sessionDir 'youtube-metadata-long-videos.md'

$shorts = Count-Prompts $shortsPath
$long = Count-Prompts $longPath
$metaShorts = Count-ShortBlocks $metaShortsPath
$metaLong = if (Test-Path $metaLongPath) {
    (Select-String -Path $metaLongPath -Pattern '^## ' -ErrorAction SilentlyContinue).Count
} else { 0 }

$targetScenes = 900
$targetShortsMeta = 300
$targetLongMeta = 5

$phase = 'complete'
$nextStart = 0
$nextEnd = 0

if ($Mode -eq 'shorts' -or $Mode -eq 'both') {
    if ($shorts -lt $targetScenes) {
        $phase = 'prompts-shorts'
        $nextStart = $shorts + 1
        $nextEnd = [Math]::Min($shorts + 30, $targetScenes)
    }
    elseif ($metaShorts -lt $targetShortsMeta) {
        $phase = 'metadata-shorts'
        $nextStart = $metaShorts + 1
        $nextEnd = [Math]::Min($metaShorts + 30, $targetShortsMeta)
    }
}

if ($phase -eq 'complete' -and ($Mode -eq 'long' -or $Mode -eq 'both')) {
    if ($long -lt $targetScenes) {
        $phase = 'prompts-long'
        $nextStart = $long + 1
        $nextEnd = [Math]::Min($long + 30, $targetScenes)
    }
    elseif ($metaLong -lt $targetLongMeta) {
        $phase = 'metadata-long'
        $nextStart = $metaLong + 1
        $nextEnd = [Math]::Min($metaLong + 5, $targetLongMeta)
    }
}

$complete = ($phase -eq 'complete')
$status = if ($complete) { 'complete' } else { 'in_progress' }

if ($SetPhase) { $phase = $SetPhase }
if ($SetStatus) { $status = $SetStatus }

if (Test-Path $sessionDir) {
    $progress = @{
        channel            = $Channel
        session            = $Session
        mode               = $Mode
        status             = $status
        phase              = $phase
        shorts_prompts     = $shorts
        long_prompts       = $long
        metadata_shorts    = $metaShorts
        metadata_long      = $metaLong
        target_scenes      = $targetScenes
        target_shorts_meta = $targetShortsMeta
        target_long_meta   = $targetLongMeta
        next_batch_start   = $nextStart
        next_batch_end     = $nextEnd
        updated            = (Get-Date).ToString('o')
    }
    $progress | ConvertTo-Json | Set-Content -Path $progressPath -Encoding utf8
}

[PSCustomObject]@{
    Channel        = $Channel
    Session        = $Session
    SessionDir     = $sessionDir
    Mode           = $Mode
    Status         = $status
    Phase          = $phase
    ShortsPrompts  = $shorts
    LongPrompts    = $long
    MetadataShorts = $metaShorts
    MetadataLong   = $metaLong
    Complete       = $complete
    NextBatchStart = $nextStart
    NextBatchEnd   = $nextEnd
}
