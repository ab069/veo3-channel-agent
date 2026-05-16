# Veo3 Project Rules

## Large File Generation Rule (CRITICAL)

When generating prompt files or any file with more than 30 items:
- NEVER write all items in one Write tool call
- Write 30 items at a time using PowerShell append (`Add-Content` or `Out-File -Append`)
- After each batch of 30, immediately write it to disk, then generate the next 30
- Tell the user which batch you just wrote (e.g. "Wrote prompts 1-30, writing 31-60...")
- This keeps the output flowing and prevents timeouts

## Prompt File Structure

- Long video prompts → `channels/{name}/prompts-long-videos.md` (900 prompts: **5×180** ≈ five ~24‑minute exports; regenerate via `tools/generate_long_prompts_900.py` if needed)
- Shorts prompts → `channels/{name}/prompts-shorts.md` (**900** prompts, portrait **9:16**, **30×30** packs → **300** Shorts; regenerate via `tools/generate_shorts_prompts_900.py`)
- Each batch clearly labeled with scene numbers and veo3.pk project name

## Batch Write Pattern

Use this PowerShell pattern for appending batches:
```powershell
@"
[content here]
"@ | Add-Content -Path "path\to\file.md" -Encoding utf8
```

## Channel Folder Structure

```
D:\veo3\channels\{channel-name}\
  info.md                  ← channel identity (stays here)
  plan.md                  ← optional channel-wide plan
  prompts-long-videos.md   ← optional bulk library
  prompts-shorts.md
  sessions\                ← production runs (/veo-session)
    session-01\
      session.md
      plan.md
      prompts-shorts.md
      youtube-metadata-shorts.md
      videos\
      output\shorts\
    session-02\
      ...
  videos\
  output\
```

## Session Generation Rule (CRITICAL)

When `/veo-session` or filling a session folder:
- **Goal per session:** **900** prompts in `prompts-shorts.md` + **900** in `prompts-long-videos.md` + metadata
- **How to write:** **10** prompts per `Add-Content` flush; **~30 new prompts max per chat turn** then stop/resume
- **Never** dump all 900 in one Write call
- **Resume:** `.\tools\veo_session_progress.ps1 -Channel {name}` before continuing
- **Mode commands:** `/veo-session-shorts`, `/veo-session-long`, `/veo-session-both` (or `/veo-session` = both)
- **Multi-channel:** command with no channel arg → cinematic first; after channel done → `/clear` (new chat) → same command again
- See `docs/SESSIONS-PLAN.md`

## Platform

veo3.pk — Google Flow VEO. Prompts mode format: `Prompt 1:`, `Prompt 2:` etc.
Each prompt = 1 scene = 8 seconds. Voice script on the next line: `Voice: ...`

**Full prompt file rules:** `docs/VEO3-PROMPT-SPEC.md` (headers, 9:16 vs 16:9, HOOK/RISE/LAND, pack/batch sections).  
**Shorts variety:** each triplet = 3 unique places, camera moves, and Voice lines — do not repeat the same Short (see spec).  
`/veo-session-*` must read that spec + channel `info.md` before writing prompts.
