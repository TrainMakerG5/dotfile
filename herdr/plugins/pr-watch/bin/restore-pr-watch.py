#!/usr/bin/env python3

"""Herdrの復元後、開いていたPR Watchの監視を再開します。"""

from __future__ import annotations

import json
import os
import shlex
import subprocess
import sys
from pathlib import Path


def call_herdr(*arguments: str) -> dict:
    """現在のセッションのHerdr CLIを呼び出します。"""
    completed = subprocess.run(
        [os.environ.get("HERDR_BIN_PATH") or "herdr", *arguments],
        capture_output=True,
        text=True,
        encoding="utf-8",
        check=True,
        timeout=15,
    )
    response = json.loads(completed.stdout)
    if "error" in response:
        raise RuntimeError(str(response["error"]))
    return response["result"]


def is_idle_shell(info: dict) -> bool:
    """シェルだけが実行中と確認できる場合に限り再開します。"""
    shell_pid = info.get("shell_pid")
    processes = info.get("foreground_processes") or []
    return bool(shell_pid and processes) and all(
        process.get("pid") == shell_pid for process in processes
    )


def watcher_command(cwd: str) -> str:
    """復元したシェルに合わせて監視コマンドを引用します。"""
    arguments = [sys.executable, str(Path(__file__).with_name("pr-watch.py")), "--cwd", cwd]
    if os.name == "nt":
        return "& " + " ".join("'" + value.replace("'", "''") + "'" for value in arguments)
    return shlex.join(arguments)


def main() -> None:
    """既存のPR Watchペインを再開し、レイアウトとフォーカスを保ちます。"""
    if os.environ.get("HERDR_ENV") != "1":
        raise RuntimeError("Herdrの起動フックから実行してください。")
    for pane in call_herdr("pane", "list").get("panes", []):
        if pane.get("label") != "PR Watch" or pane.get("restore_error") or pane.get("agent"):
            continue
        try:
            pane_id = pane["pane_id"]
            info = call_herdr("pane", "process-info", pane_id)["process_info"]
            if not is_idle_shell(info):
                continue
            cwd = pane.get("foreground_cwd") or pane.get("cwd") or str(Path.home())
            call_herdr("pane", "run", pane_id, watcher_command(cwd))
        except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError) as error:
            print(f"PR Watchの再開に失敗しました: {error}", file=sys.stderr)


if __name__ == "__main__":
    main()
