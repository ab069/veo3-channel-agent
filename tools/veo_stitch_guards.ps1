# Preflight for /veo-stitch-shorts | -long | -both
# Usage: .\tools\veo_stitch_guards.ps1 -Channel cinematic -ScenesDir "D:\path\to\scenes" -Mode shorts

param(
    [Parameter(Mandatory = $true)]
    [string] $Channel,

    [Parameter(Mandatory = $true)]
    [string] $ScenesDir,

    [ValidateSet('shorts', 'long', 'both')]
    [string] $Mode = 'shorts',

    [string] $Session = '',

    [int] $Count = 900,

    [string] $FilePrefix = 'scene-'
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Add-Err($m) { $errors.Add($m) }
function Add-Warn($m) { $warnings.Add($m) }

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Add-Err "ffmpeg not in PATH. Install: winget install ffmpeg"
}
if (-not (Get-Command ffprobe -ErrorAction SilentlyContinue)) {
    Add-Warn "ffprobe not in PATH - corrupt-file detection may fail."
}

$channelDir = Join-Path $Root "channels\$Channel"
if (-not (Test-Path (Join-Path $channelDir 'info.md'))) {
    Add-Err "Channel missing or no info.md: $channelDir"
}

if (-not (Test-Path -LiteralPath $ScenesDir)) {
    Add-Err "ScenesDir does not exist: $ScenesDir"
}
else {
    $ScenesDir = (Resolve-Path -LiteralPath $ScenesDir).Path
    $sample = Get-ChildItem -LiteralPath $ScenesDir -File -Filter '*.mp4' -ErrorAction SilentlyContinue | Select-Object -First 5
    if (-not $sample) {
        Add-Warn "No .mp4 files found in ScenesDir yet."
    }
}

# Count present scenes
$present = 0
$missing = [System.Collections.Generic.List[int]]::new()
for ($i = 1; $i -le $Count; $i++) {
    $name = "{0}{1:D3}.mp4" -f $FilePrefix, $i
    $path = Join-Path $ScenesDir $name
    if (Test-Path -LiteralPath $path) { $present++ }
    else { $missing.Add($i) | Out-Null }
}

if ($present -eq 0) {
    Add-Err "No scene files matching $FilePrefix###.mp4 in 1..$Count"
}

if ($missing.Count -gt 0) {
    $pct = [Math]::Round(100.0 * $missing.Count / $Count, 1)
    Add-Warn "Missing $($missing.Count)/$Count scenes ($pct%). Stitch will use -SkipMissingScenes by default."
    if ($Mode -eq 'long' -and $missing.Count -gt ($Count * 0.05)) {
        Add-Warn "Many missing scenes - long outputs will be shorter than ~24 min."
    }
}

if ($Mode -eq 'shorts' -and ($Count % 3) -ne 0) {
    Add-Warn "Count $Count is not a multiple of 3; last $($Count % 3) scene(s) will not form a complete Short."
}

$ok = ($errors.Count -eq 0)

[PSCustomObject]@{
    Ok             = $ok
    Channel        = $Channel
    Mode           = $Mode
    ScenesDir      = $ScenesDir
    Count          = $Count
    FilePrefix     = $FilePrefix
    PresentScenes  = $present
    MissingScenes  = $missing.Count
    MissingSample  = @($missing | Select-Object -First 15)
    Errors         = $errors
    Warnings       = $warnings
    StitchCommand  = ".\tools\veo_stitch.ps1 -Channel $Channel -ScenesDir `"$ScenesDir`" -Mode $Mode -Count $Count -FilePrefix $FilePrefix -SkipMissingScenes"
}
