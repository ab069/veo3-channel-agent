# /veo-session — Choose Shorts, long, or both

Pick the workflow you need:

| Command | What it builds |
|---------|----------------|
| **`/veo-session-shorts`** | 900 portrait prompts + 300 Shorts metadata only |
| **`/veo-session-long`** | 900 landscape prompts + 5 long metadata only |
| **`/veo-session-both`** | Full package (shorts + long + all metadata) |

`/veo-session` with no suffix defaults to **`/veo-session-both`**.

## Quick usage

```
/veo-session-shorts cinematic    ← only Shorts this session
/veo-session-long cinematic      ← only long videos this session
/veo-session-both cinematic      ← everything (900+900+metadata)
/veo-session-shorts              ← auto-pick next channel (shorts queue)
```

## Same rules for all

- **900** scenes per prompt file (written in **patches of 10**, max **30** per chat turn)
- Resume via `tools/veo_session_progress.ps1 -Mode shorts|long|both`
- Channel `info.md` stays at channel root
- After one channel finishes: **`/clear`** → run the same command again

**Architecture + guards:** `docs/VEO-SESSION-ARCHITECTURE.md`  
**Shared rules:** `.cursor/commands/veo-session-shared.md` (run `veo_session_guards.ps1` before every write)

## If user typed only `/veo-session`

Run **`/veo-session-both`** instructions (or ask: “Shorts only, long only, or both?”).
