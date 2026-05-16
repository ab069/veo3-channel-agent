# Preflight guards for /veo-session-shorts | -long | -both
# Usage:
#   .\tools\veo_session_guards.ps1 -Channel cinematic -Mode shorts
#   .\tools\veo_session_guards.ps1 -Channel cinematic -Mode both -PlannedBatchSize 30

param(
    [Parameter(Mandatory = $true)]
    [string] $Channel,

    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode,

    [string] $Session = '',

    [int] $PlannedBatchSize = 30,

    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ChannelDir = Join-Path $Root "channels\$Channel"
$InfoPath = Join-Path $ChannelDir 'info.md'
$SessionsDir = Join-Path $ChannelDir 'sessions'
$ProgressScript = Join-Path $Root 'tools\veo_session_progress.ps1'
$ScaffoldScript = Join-Path $Root 'tools\new_session_scaffold.ps1'

$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Add-Err($m) { $errors.Add($m) }
function Add-Warn($m) { $warnings.Add($m) }

# --- Guard 1: channel exists ---
if (-not (Test-Path $ChannelDir)) {
    Add-Err "Channel folder missing: $ChannelDir - run /veo-channel $Channel first."
}
if (-not (Test-Path $InfoPath)) {
    Add-Err "Missing info.md - run /veo-channel $Channel first."
}

# --- Guard 2: batch size ---
if ($PlannedBatchSize -gt 30) {
    Add-Err "PlannedBatchSize $PlannedBatchSize exceeds max 30 per chat turn."
}
if ($PlannedBatchSize -lt 1) {
    Add-Err "PlannedBatchSize must be >= 1."
}

# --- Guard 3: specs exist ---
foreach ($spec in @(
        (Join-Path $Root 'docs\VEO3-PROMPT-SPEC.md'),
        (Join-Path $Root 'docs\YOUTUBE-METADATA-SPEC.md')
    )) {
    if (-not (Test-Path $spec)) {
        Add-Warn "Missing doc: $spec"
    }
}

if ($errors.Count -gt 0) {
    return [PSCustomObject]@{
        Ok = $false
        Action = 'blocked'
        Channel = $Channel
        Mode = $Mode
        Errors = $errors
        Warnings = $warnings
    }
}

# --- progress / session ---
$prog = & $ProgressScript -Channel $Channel -Mode $Mode -Session $Session
$sessionDir = $prog.SessionDir
$progressPath = Join-Path $sessionDir '.progress.json'

$storedMode = $Mode
if (Test-Path $progressPath) {
    $pj = Get-Content $progressPath -Raw | ConvertFrom-Json
    if ($pj.mode) { $storedMode = [string]$pj.mode }
}

# --- Guard 4: mode mismatch ---
if ($storedMode -ne $Mode) {
    if ($storedMode -eq 'both' -and $Mode -in @('shorts', 'long')) {
        Add-Warn "Session mode is 'both'; running as '$Mode' will only advance that track."
    }
    else {
        Add-Err "Mode mismatch: session is '$storedMode' but command is '$Mode'. Use matching command or new session."
    }
}

# --- Guard 5: already complete ---
if ($prog.Complete -and -not $Force) {
    Add-Err "Session $($prog.Session) is COMPLETE for mode '$Mode'. Use -Force or new session folder."
}

# --- Guard 6: scaffold needed ---
$action = 'resume'
if (-not (Test-Path $sessionDir)) {
    $action = 'scaffold'
    Add-Warn "Session folder will be created: $sessionDir (mode=$Mode)"
}
elseif (-not (Test-Path $progressPath)) {
    $action = 'scaffold'
    Add-Warn "Missing .progress.json - scaffold metadata recommended."
}

# --- Guard 7: file regression ---
$shortsPath = Join-Path $sessionDir 'prompts-shorts.md'
$longPath = Join-Path $sessionDir 'prompts-long-videos.md'
if (Test-Path $progressPath) {
    $pj = Get-Content $progressPath -Raw | ConvertFrom-Json
    if ($pj.shorts_prompts -and (Test-Path $shortsPath)) {
        $onDisk = ([regex]::Matches((Get-Content -Raw $shortsPath), '(?m)^Prompt \d+:')).Count
        if ($onDisk -lt [int]$pj.shorts_prompts) {
            Add-Err "prompts-shorts.md has $onDisk prompts but progress says $($pj.shorts_prompts) - possible file corruption."
        }
    }
    if ($pj.long_prompts -and (Test-Path $longPath)) {
        $onDisk = ([regex]::Matches((Get-Content -Raw $longPath), '(?m)^Prompt \d+:')).Count
        if ($onDisk -lt [int]$pj.long_prompts) {
            Add-Err "prompts-long-videos.md regression detected."
        }
    }
}

# --- Guard 8: phase vs mode ---
$phase = $prog.Phase
if ($Mode -eq 'shorts' -and $phase -in @('prompts-long', 'metadata-long')) {
    Add-Err "Phase '$phase' is not part of shorts-only mode."
}
if ($Mode -eq 'long' -and $phase -in @('prompts-shorts', 'metadata-shorts')) {
    if ($prog.ShortsPrompts -eq 0 -and -not (Test-Path $shortsPath)) {
        # ok - long-only session
    }
    elseif ($prog.ShortsPrompts -gt 0) {
        Add-Warn "Long mode but shorts prompts exist in this session."
    }
}

# --- Guard 9: wrong file for phase ---
$fileForPhase = @{
    'prompts-shorts'    = 'prompts-shorts.md'
    'prompts-long'      = 'prompts-long-videos.md'
    'metadata-shorts'   = 'youtube-metadata-shorts.md'
    'metadata-long'     = 'youtube-metadata-long-videos.md'
}
$expectedFile = $fileForPhase[$phase]
if ($expectedFile -and $action -eq 'resume') {
    if ($phase -like 'prompts-*' -and $Mode -eq 'shorts' -and $phase -eq 'prompts-long') {
        Add-Err "Shorts command cannot write long prompts phase."
    }
    if ($phase -like 'prompts-*' -and $Mode -eq 'long' -and $phase -eq 'prompts-shorts') {
        Add-Err "Long command cannot write shorts prompts phase."
    }
}

# --- Guard 10: numbering hint ---
if ($prog.NextBatchStart -gt 0 -and $phase -like 'prompts-*') {
    $warnings.Add("Write Prompt $($prog.NextBatchStart) through $($prog.NextBatchEnd) only (phase: $phase).")
}

# --- outcome ---
$ok = ($errors.Count -eq 0)
if ($prog.Complete -and $Force) {
    $action = 'force-new'
    $warnings.Add("Force flag set - consider new session-NN via scaffold.")
}

[PSCustomObject]@{
    Ok               = $ok
    Action           = if ($ok) { $action } else { 'blocked' }
    Channel          = $Channel
    Mode             = $Mode
    Session          = $prog.Session
    SessionDir       = $sessionDir
    Phase            = $phase
    Complete         = $prog.Complete
    NextBatchStart   = $prog.NextBatchStart
    NextBatchEnd     = $prog.NextBatchEnd
    ShortsPrompts    = $prog.ShortsPrompts
    LongPrompts      = $prog.LongPrompts
    MetadataShorts   = $prog.MetadataShorts
    MetadataLong     = $prog.MetadataLong
    Errors           = $errors
    Warnings         = $warnings
    ScaffoldCommand  = ".\tools\new_session_scaffold.ps1 -Channel $Channel -Mode $Mode"
    ProgressCommand  = ".\tools\veo_session_progress.ps1 -Channel $Channel -Mode $Mode"
}
