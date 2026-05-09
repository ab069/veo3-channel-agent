# Veo3 Project Rules

## Large File Generation Rule (CRITICAL)

When generating prompt files or any file with more than 30 items:
- NEVER write all items in one Write tool call
- Write 30 items at a time using PowerShell append (`Add-Content` or `Out-File -Append`)
- After each batch of 30, immediately write it to disk, then generate the next 30
- Tell the user which batch you just wrote (e.g. "Wrote prompts 1-30, writing 31-60...")
- This keeps the output flowing and prevents timeouts

## Prompt File Structure

- Long video prompts → `channels/{name}/prompts-long-videos.md` (720 prompts, 4 batches of 180)
- Shorts prompts → `channels/{name}/prompts-shorts.md` (180 prompts, 6 batches of 30)
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
  info.md
  plan.md
  titles.md
  prompts-long-videos.md   (720 prompts)
  prompts-shorts.md        (180 prompts)
  videos\
  output\
    long-videos\
    shorts\
```

## Platform

veo3.pk — Google Flow VEO. Prompts mode format: `Prompt 1:`, `Prompt 2:` etc.
Each prompt = 1 scene = 8 seconds. Voice script on the next line: `Voice: ...`
