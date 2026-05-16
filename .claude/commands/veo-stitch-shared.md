# veo-stitch — shared rules

Used by `/veo-stitch-shorts`, `/veo-stitch-long`, `/veo-stitch-both`.

**Architecture:** `docs/VEO-STITCH-ARCHITECTURE.md`

## Step 0 — Guards (MANDATORY)

User must provide **ScenesDir** = folder with per-scene `.mp4` files.

```powershell
cd D:\veo3
$g = .\tools\veo_stitch_guards.ps1 -Channel {channel} -ScenesDir "{full path}" -Mode {shorts|long|both}
$g | Format-List
```

| If `$g.Ok` | Do |
|------------|-----|
| `$false` | **STOP.** Fix errors (ffmpeg, path, naming). |
| `$true` | Run stitch (below). Read `$g.Warnings` for missing scenes. |

## Stitch command

```powershell
.\tools\veo_stitch.ps1 -Channel {channel} -ScenesDir "{path}" -Mode {shorts|long|both} -SkipMissingScenes
```

Optional:

| Flag | Meaning |
|------|---------|
| `-Session session-01` | Output under `sessions/session-01/output/` |
| `-FilePrefix "scene_"` | If files are `scene_001.mp4` not `scene-001.mp4` |
| `-Count 900` | Total scenes (default 900) |
| `-LongsSkipIncomplete` | Skip a long segment if any of its 180 scenes missing (strict) |
| `-DryRun` | Only write concat lists, do not run ffmpeg |

## Missing / corrupt scenes (default)

**`-SkipMissingScenes` is ON by default** in `veo_stitch.ps1`.

- Missing file → skip scene, continue
- Corrupt (ffprobe fails) → skip scene, continue
- Short with 0 valid clips → skip that Short
- Short with 1–2 clips → output shorter Short + warning
- Long with gaps → shorter video + warning (or use `-LongsSkipIncomplete` to skip whole long)

Tell user which scene numbers to re-download from the console output.

## Requirements

- **ffmpeg** + **ffprobe** in PATH
- Same resolution/codec across all scene files
- Scene `N` = file `{prefix}{NNN}.mp4` matching `Prompt N` order

## Do NOT

- Stitch without `ScenesDir` from user
- Abort entire job because one scene is missing (use skip mode)
- Assume pack downloads (`pack-01-shorts.mp4`) — that is `/veo-merge` trim workflow
