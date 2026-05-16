# /clear — Reset context between channels (after /veo-session completes one channel)

Use when a channel's **full session** is done (900 shorts + 900 long prompts + metadata).  
Next channel should start with a **fresh chat** so the agent is not carrying 900 prompts in memory.

## When to run

User finished one channel via `/veo-session` and saw:

```
{cinematic} session-01 COMPLETE.
Run /clear, then /veo-session for the next channel.
```

## Step 1 — Write handoff file

Update `D:\veo3\channels\.veo-session-handoff.md`:

```markdown
# veo-session handoff

- **Completed channel:** {name}
- **Completed session:** session-NN
- **Completed at:** {date}
- **Next:** run `/veo-session` (no args) for next channel in queue
- **Queue:** see `.veo-session-queue.json`

## Do not reload in this chat

The previous channel's 900 prompts are on disk under:
`channels/{name}/sessions/session-NN/`
```

## Step 2 — Tell the user (required)

Reply with **only** this workflow (short):

1. **Start a new Cursor chat** (this clears context — there is no API to wipe the current thread).
2. In the new chat, run: **`/veo-session`**
3. The agent will pick the **next incomplete channel** (cinematic first, then queue order).

## Step 3 — Do NOT in this turn

- Do not start writing prompts for the next channel in this same chat.
- Do not re-read the completed channel's prompt files into context.
- Do not summarize all 900 prompts.

## Optional check

```powershell
cd D:\veo3
.\tools\veo_session_next_channel.ps1
```

If output is empty, all queued channels are complete.
