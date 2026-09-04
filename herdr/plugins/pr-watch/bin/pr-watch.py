#!/usr/bin/env python3

"""GitHubのレビュー依頼と現在のリポジトリのPRを定期表示します。"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
import unicodedata
from datetime import datetime
from pathlib import Path
from typing import Any


def run_gh(arguments: list[str], cwd: Path | None = None) -> tuple[list[Any] | dict[str, Any] | None, str]:
    """GitHub CLIを実行し、JSONまたは読みやすいエラーを返します。"""
    try:
        completed = subprocess.run(
            ["gh", *arguments],
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
    except OSError as error:
        return None, str(error)

    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip() or "GitHub CLIの実行に失敗しました。"
        return None, message.splitlines()[0]

    try:
        return json.loads(completed.stdout), ""
    except json.JSONDecodeError:
        return None, "GitHub CLIから不正なJSONが返されました。"


def trim(text: str, width: int) -> str:
    """狭いペインに収まるよう文字列を省略します。"""
    if display_width(text) <= width:
        return text

    result = ""
    available = max(0, width - 1)
    for character in text:
        character_width = display_width(character)
        if display_width(result) + character_width > available:
            break
        result += character
    return f"{result}…"


def display_width(text: str) -> int:
    """端末上での日本語を考慮したおおよその表示幅を返します。"""
    return sum(2 if unicodedata.east_asian_width(character) in {"W", "F", "A"} else 1 for character in text)


def is_authenticated() -> bool:
    """GitHub CLIが認証済みか確認します。"""
    completed = subprocess.run(
        ["gh", "auth", "status"],
        capture_output=True,
        check=False,
    )
    return completed.returncode == 0


def print_items(items: list[dict[str, Any]], include_repository: bool, width: int) -> None:
    """PR一覧をコンパクトな1行形式で表示します。"""
    if not items:
        print("  なし")
        return

    for item in items:
        number = item.get("number", "?")
        title = str(item.get("title", "(no title)"))
        draft = " [draft]" if item.get("isDraft") else ""
        prefix = f"#{number}{draft}"
        if include_repository:
            repository = item.get("repository") or {}
            repo_name = repository.get("nameWithOwner", "unknown/repository")
            prefix = f"{repo_name} {prefix}"
        print(f"  {trim(prefix, width)}")
        print(f"    {trim(title, max(1, width - 4))}")


def refresh(working_directory: Path, limit: int) -> None:
    """画面を消去して最新のPR情報を表示します。"""
    width = max(24, shutil.get_terminal_size((42, 24)).columns - 1)
    print("\033[2J\033[H", end="")
    print("PR Watch")
    print(datetime.now().strftime("更新 %Y-%m-%d %H:%M:%S"))
    print("-" * min(width, 42))

    if not is_authenticated():
        print("GitHub CLIの認証が必要です。")
        print("別の端末で次を実行してください。")
        print("  gh auth login")
        sys.stdout.flush()
        return

    review_items, review_error = run_gh(
        [
            "search",
            "prs",
            "--review-requested=@me",
            "--state=open",
            f"--limit={limit}",
            "--sort=updated",
            "--order=desc",
            "--json=repository,number,title,url,isDraft",
        ]
    )
    print("レビュー依頼")
    if isinstance(review_items, list):
        print_items(review_items, include_repository=True, width=width)
    else:
        print(f"  {trim(review_error, width - 2)}")

    print()
    print("このリポジトリのOpen PR")
    local_items, local_error = run_gh(
        [
            "pr",
            "list",
            f"--limit={limit}",
            "--json=number,title,url,isDraft",
        ],
        cwd=working_directory,
    )
    if isinstance(local_items, list):
        print_items(local_items, include_repository=False, width=width)
    else:
        print(f"  {trim(local_error, width - 2)}")

    print()
    print("Ctrl+C: 閉じる / 60秒ごとに更新")
    sys.stdout.flush()


def main() -> int:
    """PR監視ループを開始します。"""
    if os.name == "nt":
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("--cwd", default=os.getcwd())
    parser.add_argument("--interval", type=max_one, default=60)
    parser.add_argument("--limit", type=max_one, default=10)
    arguments = parser.parse_args()

    if shutil.which("gh") is None:
        print("PR WatchにはGitHub CLI（gh）が必要です。")
        print("導入後に gh auth login を実行してください。")
        return 0

    working_directory = Path(arguments.cwd).expanduser()
    try:
        while True:
            refresh(working_directory, arguments.limit)
            time.sleep(arguments.interval)
    except KeyboardInterrupt:
        return 0


def max_one(value: str) -> int:
    """1以上の整数だけを受け付けます。"""
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError("1以上を指定してください。")
    return number


if __name__ == "__main__":
    raise SystemExit(main())
