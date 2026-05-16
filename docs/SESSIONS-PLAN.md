# Sessions workflow — plan (corrected)

## Core idea

- **One session** = **full channel package** ending with **900** scenes per prompt file (not 30).
- **Small patches** = how we *write* (10 prompts per disk flush, ~30 new per chat turn) so the agent does not hang.
- **`/veo-session`** alone = work **cinematic first**, then next channel in queue.
- **`/clear`** = user starts a **new chat** between channels; handoff file points to next `/veo-session`.

## Folder layout

```
channels/{channel}/
  info.md                         ← channel identity (always here)
  sessions/
    session-01/                   ← first full 900 library for this channel
      session.md
      plan.md
      .progress.json              ← resume pointer
      prompts-shorts.md           → 900
      prompts-long-videos.md      → 900
      youtube-metadata-shorts.md  → 300 Shorts
      youtube-metadata-long-videos.md → 5 longs
      videos/
      output/
```

## Targets per session

| File | Count |
|------|--------|
| prompts-shorts.md | 900 |
| prompts-long-videos.md | 900 |
| youtube-metadata-shorts.md | 300 |
| youtube-metadata-long-videos.md | 5 |

## Writing rules

1. Append **10** prompts at a time (`Add-Content`).
2. Stop after **~30 new** prompts per chat turn (unless user says keep going).
3. Resume next run from last `Prompt N` (see `tools/veo_session_progress.ps1`).
4. Never one-shot 900 lines in a single tool call.

## Multi-channel flow

```
/veo-session          → cinematic (patches until 900+900+metadata done)
/clear                → new chat
/veo-session          → wildverse (or next in queue)
/clear
/veo-session          → …
```

Queue: `channels/.veo-session-queue.json`

## Prompt format (veo3.pk)

All session prompt files must follow **`docs/VEO3-PROMPT-SPEC.md`**:

- `Prompt N:` + `Voice:` (one scene = 8s)
- Shorts: portrait 9:16, HOOK/RISE/LAND every 3 prompts, pack headers every 30
- Long: landscape 16:9, batch headers every 180
- Channel tone from `info.md`

## Commands (pick one mode)

| Command | Session mode | Delivers |
|---------|--------------|----------|
| `/veo-session-shorts` | `shorts` | 900 portrait prompts + 300 Shorts metadata |
| `/veo-session-long` | `long` | 900 landscape prompts + 5 long metadata |
| `/veo-session-both` | `both` | Everything |
| `/veo-session` | router | defaults to **both** |
| `/clear` | — | New chat, then same command for next channel |

Scaffold: `.\tools\new_session_scaffold.ps1 -Channel cinematic -Mode shorts|long|both`  
Progress: `.\tools\veo_session_progress.ps1 -Channel cinematic -Mode shorts`

## Tools

- `tools/new_session_scaffold.ps1` — create `session-NN` + headers
- `tools/veo_session_progress.ps1` — count prompts, next batch range
- `tools/veo_session_next_channel.ps1` — which channel to work on
- `tools/veo_session_list.ps1` — dashboard for all channels (10–100 scale)

## Scaling to 10–100 channels

**Yes — the design supports it.**

| Concern | How |
|---------|-----|
| Isolation | `channels/{name}/sessions/` per channel — no cross-talk |
| Discovery | Auto: any folder with `info.md` |
| Priority | Optional `channel_order` in `.veo-session-queue.json` (pin cinematic first; rest A–Z) |
| Resume | `.progress.json` per session + `-Mode shorts\|long\|both` |
| Context | `/clear` between channels — required at scale |
| Volume | 100 × 900 prompts = many runs (patches intentional) |

You do **not** need all 100 names in the queue JSON.

```powershell
.\tools\veo_session_list.ps1 -Mode shorts
```
