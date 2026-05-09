# /veo-merge — FFmpeg Video Merger for veo3.pk Projects

Merge downloaded veo3.pk video clips into final YouTube videos and Shorts using FFmpeg.

## Usage
```
/veo-merge <channel-name> [options]
```

**Examples:**
```
/veo-merge cinematic-souls
/veo-merge cinematic-souls --video 1
/veo-merge cinematic-souls --shorts-only
/veo-merge cinematic-souls --short 5
```

---

## Step 1 — Load Channel Context

Read `D:\veo3\channels\{channel-name}\plan.md` to get:
- Which video files belong to which final output
- Scene numbers and timestamps
- Orientation per video (landscape vs portrait)
- FFmpeg merge plan section

Read `D:\veo3\channels\{channel-name}\titles.md` to get final filenames.

---

## Step 2 — Scan videos\ Folder

List all files in `D:\veo3\channels\{channel-name}\videos\`.

Match downloaded files to batches from plan.md. Report:
- Which batches are present
- Which are missing
- Whether all files needed for the requested merge are available

---

## Step 3 — Build FFmpeg Commands

### For Long Videos (concatenation)

If a long video is made from one veo3.pk batch (one downloaded file), just rename/copy:
```powershell
Copy-Item "videos\{batch}.mp4" "output\{sanitized-title}.mp4"
```

If a long video needs multiple batch files merged, create a concat list and use:
```powershell
# Create concat list
$concatList = @"
file 'videos\batch-01.mp4'
file 'videos\batch-02.mp4'
"@
$concatList | Out-File -Encoding utf8 "concat_temp.txt"

# Merge
ffmpeg -f concat -safe 0 -i concat_temp.txt -c copy "output\{title}.mp4"
Remove-Item "concat_temp.txt"
```

### For Shorts (trimming from a batch)

When a short uses specific scenes from within a batch, calculate timestamps:
- Each scene = 8 seconds
- Scene N within a batch starts at: (N - batch_start_scene) * 8 seconds
- Example: Scene 5 in Batch 1 (starts at scene 1) → 32 seconds into the file

```powershell
# Trim short from batch
$start = "{start_timestamp}"   # e.g., "00:00:32"
$duration = "{duration}"       # e.g., "00:00:24" for 3 scenes
ffmpeg -ss $start -i "videos\batch-01.mp4" -t $duration -c copy "output\shorts\{short-title}.mp4"
```

### For Portrait Shorts from Landscape Source

If a short was generated in landscape but needs portrait crop:
```powershell
ffmpeg -i "videos\batch-01.mp4" -ss {start} -t {duration} -vf "crop=ih*9/16:ih:(iw-ih*9/16)/2:0,scale=1080:1920" -c:a copy "output\shorts\{short-title}.mp4"
```

---

## Step 4 — Create Output Folder Structure

```
D:\veo3\channels\{channel-name}\
  output\
    long-videos\
      01 - {Video Title}.mp4
      02 - {Video Title}.mp4
      ...
    shorts\
      Short 01 - {Title}.mp4
      Short 02 - {Title}.mp4
      ...
```

Create the output folders before running FFmpeg:
```powershell
New-Item -ItemType Directory -Path "D:\veo3\channels\{channel-name}\output\long-videos" -Force
New-Item -ItemType Directory -Path "D:\veo3\channels\{channel-name}\output\shorts" -Force
```

---

## Step 5 — Execute or Print Commands

**Default behavior**: Print all FFmpeg commands first, ask user to confirm before running.

Show:
```
Ready to merge {channel-name}:

LONG VIDEOS:
  [1] "Video Title" → 01 - Video Title.mp4
      Source: batch-01.mp4 + batch-02.mp4 (concat)

  [2] "Video Title 2" → 02 - Video Title 2.mp4
      Source: batch-03.mp4 (direct copy)

SHORTS:
  [1] "Short Title" → Short 01 - Short Title.mp4
      Source: batch-01.mp4, scenes 5-7, trim 00:00:32 → 00:00:56

Proceed? (yes / only long / only shorts / specific number)
```

Wait for user confirmation, then run the appropriate FFmpeg commands via PowerShell.

---

## Step 6 — Completion Report

After merging:
```
Merge complete for "{channel-name}":

  Long videos: X files → output\long-videos\
  Shorts: X files → output\shorts\

Ready to upload to YouTube.
Titles and descriptions are in: channels\{channel-name}\titles.md
```

---

## Error Handling

- If FFmpeg is not installed: `winget install ffmpeg` or `choco install ffmpeg`
- If a source file is missing: list what's missing and skip that merge, don't abort all
- If timestamps seem off: warn the user that veo3.pk may have added an intro/outro clip that shifts timing
