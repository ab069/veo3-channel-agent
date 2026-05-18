# Append YouTube metadata for a range of Shorts after prompts exist.
# Usage:
#   .\tools\veo_session_metadata_pack.ps1 -Channel cinematic -FromShort 1 -ToShort 10
#   .\tools\veo_session_metadata_pack.ps1 -Channel cinematic   # uses progress NextBatchStart/End

param(
    [Parameter(Mandatory = $true)]
    [string] $Channel,

    [string] $Session = '',

    [int] $FromShort = 0,
    [int] $ToShort = 0
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$prog = & (Join-Path $Root 'tools\veo_session_progress.ps1') -Channel $Channel -Mode shorts -Session $Session

if ($FromShort -le 0) { $FromShort = [int]$prog.NextBatchStart }
if ($ToShort -le 0) { $ToShort = [int]$prog.NextBatchEnd }

$prompts = Join-Path $prog.SessionDir 'prompts-shorts.md'
$out = Join-Path $prog.SessionDir 'youtube-metadata-shorts.md'
$channelLabel = (Get-Content (Join-Path $Root "channels\$Channel\info.md") -TotalCount 5 -ErrorAction SilentlyContinue |
    Select-String -Pattern '^\s*#\s+' | Select-Object -First 1).Matches.Value.Trim('# ')

if (-not $channelLabel) { $channelLabel = $Channel }

$py = Get-Command py -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
if (-not $py) { throw 'Python not found (py or python).' }

$append = if (Test-Path $out) { '--append' } else { '' }
$args = @(
    $py.Source,
    (Join-Path $Root 'tools\generate_shorts_youtube_metadata.py'),
    '--prompts', $prompts,
    '--out', $out,
    '--from-short', $FromShort,
    '--to-short', $ToShort,
    '--channel', $channelLabel
)
if ($append) { $args += $append }

& $args[0] $args[1..($args.Length - 1)]
Write-Host "Metadata Shorts $FromShort-$ToShort -> $out"
