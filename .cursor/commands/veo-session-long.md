# /veo-session-long — 900 landscape long-form only

Build **long-only** session: `prompts-long-videos.md` (900) + `youtube-metadata-long-videos.md` (5) + plan.  
**No** Shorts prompts or Shorts metadata in this mode.

**Shared rules:** read `.cursor/commands/veo-session-shared.md` (patches, veo3 format, resume).

## Usage

```
/veo-session-long
/veo-session-long cinematic
```

## Mode: `long`

| Phase | File | Target |
|-------|------|--------|
| 1 | `prompts-long-videos.md` | 900 prompts (16:9) |
| 2 | `youtube-metadata-long-videos.md` | 5 long videos |

**Complete when:** both phases done. Then `/clear` → `/veo-session-long` for next channel.

## Steps

0. **Guards:** `.\tools\veo_session_guards.ps1 -Channel {ch} -Mode long` — if `Ok` is false, **stop**.
1. `.\tools\veo_session_next_channel.ps1 -Mode long` (if no channel in message)
2. If guards say `scaffold`: `.\tools\new_session_scaffold.ps1 -Channel {ch} -Mode long`
3. Follow `$g.Phase` and `$g.NextBatchStart`–`$g.NextBatchEnd` only
4. **10 prompts per append**, max **30** per turn
5. Batch header every **180** prompts (`## Batch — {channel}-long-0N`)
6. Visual: ultra-wide 16:9 — see `docs/VEO3-PROMPT-SPEC.md`

## End message

```
{cinematic} session-NN [long] — prompts 31-60 / 900
Next: /veo-session-long cinematic
```

When complete:

```
{cinematic} [long] COMPLETE. /clear then /veo-session-long for next channel.
```
