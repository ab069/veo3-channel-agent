# veo-session — shared rules (all modes)

**Architecture:** `docs/VEO-SESSION-ARCHITECTURE.md`

## Chat vs unattended (read this first)

| Method | Command | Stops at 30? | You say `continue`? |
|--------|---------|--------------|---------------------|
| **Unattended (default)** | `.\tools\veo_session_auto.ps1 -Mode shorts\|long` | No — loops to 900 | **No** |
| Chat-only AI writing | `/veo-session-shorts` without auto script | Often yes | Yes (annoying) |

**User expectation:** one run → all 900 → one “done” message → use **`veo_session_auto.ps1`**.

---

## Step 0 — Guards (before scaffold or auto)

```powershell
cd D:\veo3
$g = .\tools\veo_session_guards.ps1 -Channel {channel} -Mode {shorts|long|both}
```

| If `$g.Ok` | Do |
|------------|-----|
| `$false` | **STOP.** Fix errors. |
| `scaffold` | `.\tools\new_session_scaffold.ps1 -Channel {ch} -Mode {mode}` |
| `resume` | `.\tools\veo_session_auto.ps1 -Channel {ch} -Mode {mode}` |

---

## Patch writing (if not using auto script)

| File | Per append |
|------|------------|
| `prompts-shorts.md` | 10 prompts |
| `youtube-metadata-shorts.md` | 10 blocks OR `veo_session_metadata_pack.ps1` |

Never one Write with 900 lines.

## Shorts pack cycle

```
30 prompts (3× Add-Content of 10) → metadata 10 Shorts → next pack …
```

Auto script does this in a `while` loop.

## Channel complete → next channel

1. Auto script prints **COMPLETE**
2. User: **`/clear`**
3. `.\tools\veo_session_auto.ps1 -Mode {mode}` (next channel)

## Required reads (AI-crafted packs only)

`info.md`, `VEO3-PROMPT-SPEC.md`, `YOUTUBE-METADATA-SPEC.md`

## Queue

`.\tools\veo_session_list.ps1 -Mode shorts`
