---
name: myhistory
description: Summarize Codex session history from ~/.codex/sessions in a readable list. Use when the user types `myhistory` or asks for an overview of prior Codex sessions with session id, size, date, and a short summary.
---

# Myhistory

Run `scripts/list_sessions.py` to enumerate session files under `~/.codex/sessions` and print a readable paragraph per session.

## Workflow

1. Run `python3 scripts/list_sessions.py`.
2. Return the script output directly when the user asks for `myhistory` or `/myhistory`.
3. If the user asks for a subset, pass `--limit N` or `--root <path>`.

## Output Rules

- Sort sessions newest first
- Print each session as a two-line paragraph
- First line: session id, human-readable size, session date
- Second line: a concise summary derived from the earliest meaningful user request in that session
