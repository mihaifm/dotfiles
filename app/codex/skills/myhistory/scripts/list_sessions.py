#!/usr/bin/env python3

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

IGNORE_PREFIXES = (
    '# AGENTS.md instructions',
    '<environment_context>',
    '<skill>',
)
IGNORE_EXACT = {'myhistory', '/myhistory'}
MAX_SUMMARY_LEN = 160


@dataclass
class SessionInfo:
    session_id: str
    size_bytes: int
    timestamp: datetime
    summary: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description='List Codex sessions with id, size, date, and short summary.'
    )
    parser.add_argument(
        '--root',
        default='~/.codex/sessions',
        help='Session root directory. Default: ~/.codex/sessions',
    )
    parser.add_argument(
        '--limit',
        type=int,
        default=0,
        help='Optional maximum number of sessions to print. 0 means all.',
    )
    return parser.parse_args()


def human_size(size: int) -> str:
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    value = float(size)
    for unit in units:
        if value < 1024 or unit == units[-1]:
            if unit == 'B':
                return f'{int(value)}{unit}'
            return f'{value:.1f}{unit}'
        value /= 1024
    return f'{size}B'


def parse_timestamp(raw: str | None, fallback: Path) -> datetime:
    if raw:
        try:
            return datetime.fromisoformat(raw.replace('Z', '+00:00')).astimezone()
        except ValueError:
            pass
    return datetime.fromtimestamp(fallback.stat().st_mtime).astimezone()


def normalize_text(text: str) -> str:
    text = text.strip()
    if not text:
        return ''
    if text in IGNORE_EXACT:
        return ''
    if any(text.startswith(prefix) for prefix in IGNORE_PREFIXES):
        return ''
    text = re.sub(r'```.*?```', ' ', text, flags=re.S)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()


def first_meaningful_summary(texts: Iterable[str]) -> str:
    for text in texts:
        cleaned = normalize_text(text)
        if not cleaned:
            continue
        if len(cleaned) > MAX_SUMMARY_LEN:
            cleaned = cleaned[: MAX_SUMMARY_LEN - 1].rstrip() + '...'
        return cleaned
    return 'No meaningful user prompt captured.'


def extract_texts(payload: dict) -> list[str]:
    texts: list[str] = []
    if payload.get('type') != 'message' or payload.get('role') != 'user':
        return texts
    for item in payload.get('content', []):
        if item.get('type') == 'input_text':
            texts.append(item.get('text', ''))
    return texts


def fallback_session_id(path: Path) -> str:
    match = re.search(r'([0-9a-f]{8,}-[0-9a-f-]+)\.jsonl$', path.name)
    return match.group(1) if match else path.stem


def parse_session(path: Path) -> SessionInfo:
    session_id = fallback_session_id(path)
    timestamp = datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc).astimezone()
    user_texts: list[str] = []

    with path.open('r', encoding='utf-8') as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            if entry.get('type') == 'session_meta':
                payload = entry.get('payload', {})
                session_id = payload.get('id', session_id)
                timestamp = parse_timestamp(payload.get('timestamp'), path)
                continue

            if entry.get('type') == 'response_item':
                user_texts.extend(extract_texts(entry.get('payload', {})))

    return SessionInfo(
        session_id=session_id,
        size_bytes=path.stat().st_size,
        timestamp=timestamp,
        summary=first_meaningful_summary(user_texts),
    )


def iter_session_files(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob('*.jsonl') if p.is_file())


def main() -> int:
    args = parse_args()
    root = Path(args.root).expanduser()

    if not root.exists():
        print(f'No session directory found at {root}')
        return 1

    sessions = [parse_session(path) for path in iter_session_files(root)]
    sessions.sort(key=lambda item: item.timestamp, reverse=True)

    if args.limit > 0:
        sessions = sessions[: args.limit]

    if not sessions:
        print(f'No sessions found under {root}')
        return 0

    for index, session in enumerate(sessions, start=1):
        date_str = session.timestamp.strftime('%Y-%m-%d %H:%M')
        print(f'{index}. {session.session_id} | {human_size(session.size_bytes)} | {date_str}')
        print(f'   {session.summary}')
        if index != len(sessions):
            print()

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
