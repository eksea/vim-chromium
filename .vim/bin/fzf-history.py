#!/usr/bin/env python3

import json
import os
import sys
from typing import Any


def load_history(path: str) -> list[str]:
    if not os.path.exists(path):
        return []

    with open(path, 'r', encoding='utf-8', errors='ignore') as file:
        lines = [line.rstrip('\n') for line in file]

    seen = set()
    items = []
    for line in reversed(lines):
        if not line or line in seen:
            continue
        seen.add(line)
        items.append(line)
    return items


def fuzzy_score(text: str, query: str) -> int | None:
    if not query:
        return 0

    text_lower = text.lower()
    query_lower = query.lower()

    positions = []
    start = 0
    for char in query_lower:
        index = text_lower.find(char, start)
        if index == -1:
            return None
        positions.append(index)
        start = index + 1

    score = 0
    previous = None

    if query_lower == text_lower:
        score += 120
    elif text_lower.startswith(query_lower):
        score += 80
    elif query_lower in text_lower:
        score += 40

    for i, index in enumerate(positions):
        score += 10

        if i == 0:
            if index == 0:
                score += 40
            elif text_lower[index - 1] in ' /_-.:':
                score += 20

        if previous is not None:
            gap = index - previous - 1
            if gap == 0:
                score += 25
            else:
                score -= min(gap, 12)

        previous = index

    score -= max(len(text_lower) - len(query_lower), 0)
    return score


def matched_history(items: list[str], query: str) -> list[str]:
    if not query:
        return items

    scored = []
    for recency, item in enumerate(items):
        score = fuzzy_score(item, query)
        if score is None:
            continue
        scored.append((-score, recency, item))

    scored.sort()
    return [item for _, _, item in scored]


def load_state(path: str) -> dict[str, Any] | None:
    if not os.path.exists(path):
        return None

    try:
        with open(path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except (OSError, json.JSONDecodeError):
        return None


def save_state(path: str, seed_query: str, index: int, last_result: str) -> None:
    state = {
        'seed_query': seed_query,
        'index': index,
        'last_result': last_result,
    }
    with open(path, 'w', encoding='utf-8') as file:
        json.dump(state, file)


def active_query(state: dict[str, Any]) -> str:
    if state.get('index', -1) >= 0:
        return str(state.get('last_result', ''))
    return str(state.get('seed_query', ''))


def main() -> int:
    if len(sys.argv) < 4:
        return 1

    history_path = sys.argv[1]
    state_path = sys.argv[2]
    direction = sys.argv[3]
    current_query = ' '.join(sys.argv[4:])

    state = load_state(state_path)
    if state and current_query == active_query(state):
        seed_query = str(state.get('seed_query', ''))
        index = int(state.get('index', -1))
    else:
        seed_query = current_query
        index = -1

    matches = matched_history(load_history(history_path), seed_query)

    if direction == 'up':
        if not matches:
            save_state(state_path, seed_query, -1, seed_query)
            sys.stdout.write(seed_query)
            return 0

        index = min(index + 1, len(matches) - 1)
        result = matches[index]
        save_state(state_path, seed_query, index, result)
        sys.stdout.write(result)
        return 0

    if direction == 'down':
        if index <= -1:
            save_state(state_path, seed_query, -1, seed_query)
            sys.stdout.write(seed_query)
            return 0

        index -= 1
        result = seed_query if index == -1 else matches[index]
        save_state(state_path, seed_query, index, result)
        sys.stdout.write(result)
        return 0

    return 1


if __name__ == '__main__':
    raise SystemExit(main())
