# /veo-session-shorts — 900 portrait Shorts only

Build **Shorts-only** session: `prompts-shorts.md` (900) + `youtube-metadata-shorts.md` (300).

**Shared rules:** `.cursor/commands/veo-session-shared.md`

---

## The problem with “just keep going” in chat

`/veo-session-shorts` is **instructions for the AI**. Each chat **reply ends** when the model stops typing — it is **not** a background job. Nothing in Cursor auto-runs the next 30 prompts unless **you** send another message (or a **script** loops).

So “don’t stop at 30” in markdown **cannot** guarantee 900 in one chat; context limits still apply.

---

## What you want (run once → notify when 900 done)

**Run this in the terminal** (PowerShell). It loops pack-by-pack (30 prompts → 10 metadata) until complete — **no `continue`**:

```powershell
cd D:\veo3
.\tools\veo_session_auto.ps1 -Channel cinematic -Mode shorts
```

Or next channel from queue:

```powershell
.\tools\veo_session_auto.ps1 -Mode shorts
```

When it exits green, you get one message: **COMPLETE** (900 + 300). Then `/clear` and run again for the next channel.

---

## What the agent should do when you type `/veo-session-shorts`

1. **Do not** hand-write 30 prompts and stop.
2. Run guards; scaffold if needed.
3. **Run `veo_session_auto.ps1`** for the channel (same command as above).
4. Report the script’s final **COMPLETE** or error — only then end.

Optional: user asked for **AI-crafted** packs only → then loop packs in chat (slow, may still need multiple chats). Default is **auto script**.

---

## Usage

```
/veo-session-shorts
/veo-session-shorts cinematic
```

## Mode: `shorts`

| Per pack | Prompts | Then |
|----------|---------|------|
| 1 veo3 pack | +30 | +10 Short metadata blocks |
| Full session | ×30 packs | 900 + 300 |

**Complete when:** auto script prints COMPLETE. Then `/clear` → next channel.

## End message (agent)

Only after **auto script** success:

```
{cinematic} session-NN [shorts] COMPLETE (900 prompts, 300 metadata).
/clear then .\tools\veo_session_auto.ps1 -Mode shorts for next channel.
```
