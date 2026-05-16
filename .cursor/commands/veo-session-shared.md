# veo-session — shared rules (all modes)

Used by `/veo-session-shorts`, `/veo-session-long`, `/veo-session-both`, and `/veo-session`.

**Architecture:** `docs/VEO-SESSION-ARCHITECTURE.md`

## Step 0 — Guards (MANDATORY before any write)

```powershell
cd D:\veo3
$g = .\tools\veo_session_guards.ps1 -Channel {channel} -Mode {shorts|long|both}
$g | Format-List
```

| If `$g.Ok` | Do |
|------------|-----|
| `$false` | **STOP.** Fix `$g.Errors`. Do not write files. |
| `$true` + `Action=scaffold` | Run `$g.ScaffoldCommand` then continue. |
| `$true` + `Action=resume` | Write only `Prompt $g.NextBatchStart` … `$g.NextBatchEnd` for `$g.Phase`. |

**Never write if guards return errors.** Never skip guards to "go faster."

### Guard checklist (agent)

- [ ] Channel has `info.md`
- [ ] Command **mode** matches session (`shorts` / `long` / `both`)
- [ ] Session not `complete` unless user asked to start new session
- [ ] Max **30** new items this turn; **10** per `Add-Content`
- [ ] Correct file for `$g.Phase` only
- [ ] Shorts: read last 9 prompts; 3 unique places/voices per Short
- [ ] Metadata: unique per Short (`YOUTUBE-METADATA-SPEC.md`)
- [ ] Channel complete → tell user `/clear` then same command (do not start next channel here)

## Patch writing (every file)

| File | Per append | Max per chat turn |
|------|------------|-------------------|
| `prompts-shorts.md` | 10 prompts | 30 |
| `prompts-long-videos.md` | 10 prompts | 30 |
| `youtube-metadata-shorts.md` | 10 Short blocks | 30 |
| `youtube-metadata-long-videos.md` | 1-2 blocks | 5 total OK |
| `plan.md` | 1 section | small file OK |

Never one Write with 900 prompts or 300 metadata blocks.

## Required reads

1. `channels/{channel}/info.md`
2. `channels/{channel}/plan.md` (if present)
3. `docs/VEO3-PROMPT-SPEC.md`
4. Example structure: `channels/cinematic/prompts-shorts.md` or `prompts-long-videos.md`
5. **Metadata:** `docs/YOUTUBE-METADATA-SPEC.md` — unique per Short, not one template
6. **Shorts prompts:** `docs/VEO3-PROMPT-SPEC.md` → **Shorts variety** — no duplicate Short (3 unique places/voices per triplet)

## Prompt block (veo3.pk)

```text
Prompt N: [one line visual, semicolon segments]
Voice: [one line, ~20-28 words]

```

## PowerShell

```powershell
cd D:\veo3
.\tools\veo_session_progress.ps1 -Channel {channel} -Mode {shorts|long|both}
.\tools\new_session_scaffold.ps1 -Channel {channel} -Mode {shorts|long|both}
```

Append:

```powershell
@" ... "@ | Add-Content -Path "...\prompts-shorts.md" -Encoding utf8
```

## Resume

- Continue at `NextBatchStart` from progress script.
- Do not overwrite finished prompts.
- If `SessionDir` missing for active work: run scaffold with correct `-Mode`.

## Channel complete → next channel

When progress `Complete` = true for this **mode**:

1. Tell user: **`/clear`** (new chat)
2. Then run the same command again (no channel arg) for next channel in queue.

## Queue (10–100 channels)

- Every `channels/{name}/` with `info.md` is auto-discovered.
- `channels/.veo-session-queue.json` — **optional** priority list (cinematic first); unlisted channels run A–Z.
- Status: `.\tools\veo_session_list.ps1 -Mode shorts|long|both`
- One channel per wave; **`/clear`** between channels at scale.
