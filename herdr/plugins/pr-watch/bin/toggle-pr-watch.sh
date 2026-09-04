#!/bin/sh

# Herdrの現在のタブでPR Watchペインを開閉します。
set -eu

herdr_bin=${HERDR_BIN_PATH:-herdr}
target_pane=${HERDR_PANE_ID:-}
workspace_id=${HERDR_WORKSPACE_ID:-}
tab_id=${HERDR_TAB_ID:-}

if [ -z "$target_pane" ] || [ -z "$workspace_id" ] || [ -z "$tab_id" ]; then
    current_json=$($herdr_bin pane current)
    target_info=$(printf '%s' "$current_json" | python3 -c '
import json
import sys

pane = json.load(sys.stdin).get("result", {}).get("pane", {})
print("\t".join((pane.get("pane_id", ""), pane.get("workspace_id", ""), pane.get("tab_id", ""))))
')
    target_pane=$(printf '%s' "$target_info" | cut -f1)
    workspace_id=$(printf '%s' "$target_info" | cut -f2)
    tab_id=$(printf '%s' "$target_info" | cut -f3)
fi

existing_pane=$($herdr_bin pane list | python3 -c '
import json
import sys

workspace_id = sys.argv[1]
tab_id = sys.argv[2]
panes = json.load(sys.stdin).get("result", {}).get("panes", [])
print(next((pane.get("pane_id", "") for pane in panes if pane.get("workspace_id") == workspace_id and pane.get("tab_id") == tab_id and pane.get("label") == "PR Watch"), ""))
' "$workspace_id" "$tab_id")

if [ -n "$existing_pane" ]; then
    "$herdr_bin" pane close "$existing_pane" >/dev/null
    exit 0
fi

working_directory=$("$herdr_bin" pane get "$target_pane" | python3 -c '
import json
import os
import sys

pane = json.load(sys.stdin).get("result", {}).get("pane", {})
print(pane.get("foreground_cwd") or pane.get("cwd") or os.getcwd())
')
split_json=$("$herdr_bin" pane split "$target_pane" --direction right --ratio 0.78 --cwd "$working_directory" --no-focus)
watch_pane=$(printf '%s' "$split_json" | python3 -c '
import json
import sys

print(json.load(sys.stdin).get("result", {}).get("pane", {}).get("pane_id", ""))
')

"$herdr_bin" pane rename "$watch_pane" "PR Watch" >/dev/null
"$herdr_bin" pane run "$watch_pane" python3 "$HERDR_PLUGIN_ROOT/bin/pr-watch.py" --cwd "$working_directory" >/dev/null
