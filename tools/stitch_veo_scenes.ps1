<#
.SYNOPSIS
  Concatenate veo3 / VEO scene clips (8s each) with FFmpeg — e.g. 900 scenes from prompts-long-videos.md.

.DESCRIPTION
  Expects one .mp4 per scene, same resolution, codec, and frame rate (use -c copy).
  If your clips differ, re-encode once to a common format, or change $CodecArgs below.

.PARAMETER ScenesDir
  Folder containing scene-001.mp4 … scene-NNN.mp4 (default naming).

.PARAMETER Count
  Number of scenes to stitch (default 900).

.PARAMETER FilePrefix
  Files named {Prefix}{000}.mp4 — default "scene-" → scene-001.mp4. OpenClaw / veo3 bulk often uses "scene_" → scene_001.mp4 (pass `-FilePrefix "scene_"`).

.PARAMETER Mode
  full   — one output: all scenes concatenated (~7200s for 900×8s).
  longs  — five files: 180 scenes each (~1440s each), names 01-…05-….
  shorts — one file per Short: every **3** consecutive scenes → `short-001.mp4` (~24s), … (`Count` should be total scene count; remainder scenes are warned and skipped).
  list   — only write concat_list.txt (inspect before running ffmpeg yourself).

.PARAMETER OutDir
  Output directory (created if missing).

.PARAMETER SkipMissingScenes
  Omit missing or unreadable (ffprobe fails) .mp4 files from concat lists; still emit one output per long segment / full master.
  Min duration check uses only included clip count (order preserved by scene number).

.EXAMPLE
  cd D:\veo3
  .\tools\stitch_veo_scenes.ps1 -ScenesDir "D:\veo3\channels\cinematic\videos\scenes" -Count 900 -Mode full

.EXAMPLE
  .\tools\stitch_veo_scenes.ps1 -ScenesDir "...\scenes" -Count 900 -Mode longs -OutDir "D:\veo3\channels\cinematic\output\long-videos"

.EXAMPLE
  .\tools\stitch_veo_scenes.ps1 -ScenesDir "...\veo3_06dd8baf" -Count 900 -FilePrefix "scene_" -Mode longs -SkipMissingScenes -OutDir "D:\veo3\channels\cinematic\output\long-videos"

.EXAMPLE
  # 500 downloaded scenes → 166 Shorts (scenes 499–500 unused unless you add one more scene)
  .\tools\stitch_veo_scenes.ps1 -ScenesDir "D:\veo3\channels\cinematic\videos\shorts-scenes" -Count 500 -Mode shorts -OutDir "D:\veo3\channels\cinematic\output\shorts"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ScenesDir,

    [int] $Count = 900,

    [string] $FilePrefix = "scene-",

    [switch] $LongsSkipIncomplete,

    [switch] $SkipMissingScenes,

    [ValidateSet("full", "longs", "shorts", "list")]
    [string] $Mode = "full",

    [string] $OutDir = ""
)

$ErrorActionPreference = "Stop"
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg not found in PATH. Install FFmpeg and reopen the terminal."
}

$ScenesDir = (Resolve-Path $ScenesDir).Path
if (-not $OutDir) {
    $OutDir = Join-Path (Split-Path $ScenesDir -Parent) "stitched"
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Get-SceneName([int] $n) {
    return "{0}{1:D3}.mp4" -f $FilePrefix, $n
}

function Test-SceneFiles {
    param([int] $From, [int] $To)
    $missing = @()
    for ($i = $From; $i -le $To; $i++) {
        $name = Get-SceneName $i
        $path = Join-Path $ScenesDir $name
        if (-not (Test-Path -LiteralPath $path)) { $missing += $name }
    }
    if ($missing.Count -gt 0) {
        Write-Warning "Missing $($missing.Count) file(s). First few: $($missing[0..([Math]::Min(4,$missing.Count-1))] -join ', ')"
        return $false
    }
    return $true
}

function Test-SceneFfprobeOk {
    param([string] $MediaPath)
    # ffprobe writes diagnostics to stderr; with $ErrorActionPreference Stop that can terminate unless suppressed.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $null = & ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 $MediaPath 2>$null
        return ($LASTEXITCODE -eq 0)
    }
    finally {
        $ErrorActionPreference = $prev
    }
}

function Write-ConcatList {
    param([int] $From, [int] $To, [string] $ListPath)
    $lines = @()
    for ($i = $From; $i -le $To; $i++) {
        $rel = Get-SceneName $i
        $abs = (Join-Path $ScenesDir $rel)
        $abs = $abs.Replace("\", "/").Replace("'", "'\''")
        $lines += "file '$abs'"
    }
    $body = ($lines -join "`n")
    # FFmpeg concat demuxer requires UTF-8 without BOM (BOM breaks the first "file" line).
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($ListPath, $body, $enc)
    Write-Host "Wrote $ListPath ($($To - $From + 1) entries)"
}

function Write-ConcatListSkipMissing {
    param([int] $From, [int] $To, [string] $ListPath)
    $lines = @()
    $skippedMissing = [System.Collections.Generic.List[int]]::new()
    $skippedBad = [System.Collections.Generic.List[int]]::new()
    for ($i = $From; $i -le $To; $i++) {
        $rel = Get-SceneName $i
        $path = Join-Path $ScenesDir $rel
        if (-not (Test-Path -LiteralPath $path)) {
            $skippedMissing.Add($i) | Out-Null
            continue
        }
        if (-not (Test-SceneFfprobeOk $path)) {
            $skippedBad.Add($i) | Out-Null
            continue
        }
        $abs = $path.Replace("\", "/").Replace("'", "'\''")
        $lines += "file '$abs'"
    }
    if ($lines.Count -eq 0) {
        if (Test-Path -LiteralPath $ListPath) { Remove-Item -LiteralPath $ListPath -Force }
        return @{
            Included = 0
            SkippedMissing = $skippedMissing
            SkippedBad     = $skippedBad
        }
    }
    $body = ($lines -join "`n")
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($ListPath, $body, $enc)
    $warn = "Wrote $ListPath ($($lines.Count) clips; range $From-$To)"
    if ($skippedMissing.Count -gt 0) {
        $sample = ($skippedMissing | Select-Object -First 20) -join ","
        $more = if ($skippedMissing.Count -gt 20) { " …" } else { "" }
        $warn += "`n  Skipped missing ($($skippedMissing.Count)): $sample$more"
    }
    if ($skippedBad.Count -gt 0) {
        $sampleB = ($skippedBad | Select-Object -First 20) -join ","
        $moreB = if ($skippedBad.Count -gt 20) { " …" } else { "" }
        $warn += "`n  Skipped unreadable/corrupt ($($skippedBad.Count)): $sampleB$moreB"
    }
    Write-Host $warn
    return @{
        Included         = $lines.Count
        SkippedMissing   = $skippedMissing
        SkippedBad       = $skippedBad
    }
}

function Get-MediaDurationSeconds {
    param([string] $MediaPath)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    try {
        $out = & ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $MediaPath 2>$null
    }
    finally {
        $ErrorActionPreference = $prev
    }
    if ($LASTEXITCODE -ne 0) { return $null }
    $d = 0.0
    if (-not [double]::TryParse($out, [ref]$d)) { return $null }
    return $d
}

function Invoke-Concat {
    param([string] $ListPath, [string] $OutFile, [double] $MinDurationSeconds = 0)
    $args = @(
        "-y", "-hide_banner", "-loglevel", "error",
        "-f", "concat", "-safe", "0",
        "-i", $ListPath,
        "-c", "copy",
        $OutFile
    )
    & ffmpeg @args
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed ($LASTEXITCODE) for $OutFile" }
    if ($MinDurationSeconds -gt 0) {
        $dur = Get-MediaDurationSeconds $OutFile
        if ($null -eq $dur -or $dur -lt $MinDurationSeconds) {
            Remove-Item -LiteralPath $OutFile -Force -ErrorAction SilentlyContinue
            throw "Output duration ($dur s) is below expected minimum ($MinDurationSeconds s). One or more inputs may be corrupt (e.g. missing moov). Fix scene files and re-run."
        }
    }
    Write-Host "OK: $OutFile"
}

if ($Mode -eq "list") {
    $list = Join-Path $OutDir "concat_list.txt"
    if ($SkipMissingScenes) {
        $meta = Write-ConcatListSkipMissing -From 1 -To $Count -ListPath $list
        if ($meta.Included -eq 0) { throw "No valid scene files in 1-$Count." }
    }
    else {
        Write-ConcatList -From 1 -To $Count -ListPath $list
    }
    Write-Host "Wrote concat list only. Run: ffmpeg -f concat -safe 0 -i `"$list`" -c copy output.mp4"
    exit 0
}

if ($Mode -eq "full") {
    $list = Join-Path $OutDir "concat_full.txt"
    $out = Join-Path $OutDir "long-master-all-scenes.mp4"
    if ($SkipMissingScenes) {
        $meta = Write-ConcatListSkipMissing -From 1 -To $Count -ListPath $list
        if ($meta.Included -eq 0) { throw "No valid scene files in 1-$Count." }
        $minFull = [double]$meta.Included * 7.5
        Invoke-Concat -ListPath $list -OutFile $out -MinDurationSeconds $minFull
    }
    else {
        if (-not (Test-SceneFiles -From 1 -To $Count)) {
            throw "Missing scene files - finish downloads (check for .part), use -SkipMissingScenes, or use -Mode longs -LongsSkipIncomplete."
        }
        Write-ConcatList -From 1 -To $Count -ListPath $list
        $minFull = [double]$Count * 7.5
        Invoke-Concat -ListPath $list -OutFile $out -MinDurationSeconds $minFull
    }
}
elseif ($Mode -eq "longs") {
    $seg = 180
    $idx = 1
    for ($start = 1; $start -le $Count; $start += $seg) {
        $end = [Math]::Min($start + $seg - 1, $Count)
        $list = Join-Path $OutDir ("concat_long_{0:D2}.txt" -f $idx)
        $out = Join-Path $OutDir ("long-{0:D2}-scenes-{1}-{2}.mp4" -f $idx, $start, $end)

        if ($SkipMissingScenes) {
            $meta = Write-ConcatListSkipMissing -From $start -To $end -ListPath $list
            if ($meta.Included -eq 0) {
                Write-Warning "Skipping long $idx (scenes $start-$end): no valid clips after skipping missing/unreadable."
                $idx++
                continue
            }
            $minDur = [double]$meta.Included * 7.5
            Invoke-Concat -ListPath $list -OutFile $out -MinDurationSeconds $minDur
            $idx++
            continue
        }

        if (-not (Test-SceneFiles -From $start -To $end)) {
            if ($LongsSkipIncomplete) {
                Write-Warning "Skipping long $idx (scenes $start-$end): one or more .mp4 files missing - finish .part downloads, then re-run."
                $idx++
                continue
            }
            throw "Missing files in scenes $start-$end. Re-download, use -SkipMissingScenes, or use -LongsSkipIncomplete."
        }
        Write-ConcatList -From $start -To $end -ListPath $list
        $nScenes = $end - $start + 1
        $minDur = [double]$nScenes * 7.5
        Invoke-Concat -ListPath $list -OutFile $out -MinDurationSeconds $minDur
        $idx++
    }
}
elseif ($Mode -eq "shorts") {
    $numShorts = [Math]::Floor($Count / 3)
    if ($numShorts -lt 1) {
        throw "Need at least 3 scenes for one Short (-Count must be >= 3)."
    }
    $rem = $Count % 3
    if ($rem -ne 0) {
        # Avoid "scene(s)" inside double quotes — PowerShell parses it as command `scene` with arg `s`.
        Write-Warning ("Scene count $Count is not a multiple of 3; the last $rem " + 'scene(s) are not merged into any Short (triplets: 1-3, 4-6).')
    }
    for ($s = 1; $s -le $numShorts; $s++) {
        $from = ($s - 1) * 3 + 1
        $to = $s * 3
        $list = Join-Path $OutDir ("concat_short_{0:D3}.txt" -f $s)
        $out = Join-Path $OutDir ("short-{0:D3}.mp4" -f $s)

        if ($SkipMissingScenes) {
            $meta = Write-ConcatListSkipMissing -From $from -To $to -ListPath $list
            if ($meta.Included -eq 0) {
                Write-Warning "Skipping Short $s (scenes $from-$to): no valid clips."
                continue
            }
            $minDur = [double]$meta.Included * 7.5
            Invoke-Concat -ListPath $list -OutFile $out -MinDurationSeconds $minDur
            continue
        }

        if (-not (Test-SceneFiles -From $from -To $to)) {
            throw "Missing files for Short $s (scenes $from-$to). Re-download, use -SkipMissingScenes, or fix naming ($FilePrefix###.mp4)."
        }
        Write-ConcatList -From $from -To $to -ListPath $list
        $minDur = 22.5
        Invoke-Concat -ListPath $list -OutFile $out -MinDurationSeconds $minDur
    }
}

Write-Host "Done. Outputs in: $OutDir"
