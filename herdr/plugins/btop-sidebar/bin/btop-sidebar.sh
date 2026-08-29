#!/bin/sh

# Herdrの現在のワークスペースでbtopペインを開閉します。
set -eu

if ! command -v herdr >/dev/null 2>&1; then
    printf '%s\n' "btop-sidebar: herdr is required" >&2
    exit 0
fi

if ! command -v btop >/dev/null 2>&1; then
    printf '%s\n' "btop-sidebar: btop is required" >&2
    exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "btop-sidebar: python3 is required" >&2
    exit 0
fi

target_pane=${HERDR_PANE_ID:-}
workspace_id=${HERDR_WORKSPACE_ID:-}
tab_id=${HERDR_TAB_ID:-}

# アクションの実行コンテキストがない場合だけ、現在のペインから補完します。
if [ -z "$target_pane" ] || [ -z "$workspace_id" ] || [ -z "$tab_id" ]; then
    current_json=""
    attempt=0
    while [ "$attempt" -lt 10 ]; do
        if current_json=$(herdr pane current 2>/dev/null); then
            break
        fi
        attempt=$((attempt + 1))
        sleep 0.2
    done

    if [ -z "$current_json" ]; then
        printf '%s\n' "btop-sidebar: current pane is unavailable" >&2
        exit 0
    fi

    target_info=$(printf '%s' "$current_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
pane = data.get("result", {}).get("pane", {})
pane_id = pane.get("pane_id", "")
workspace_id = pane.get("workspace_id", "")
tab_id = pane.get("tab_id", "")
print(f"{pane_id}\t{workspace_id}\t{tab_id}")
')

    target_pane=$(printf '%s' "$target_info" | cut -f1)
    workspace_id=$(printf '%s' "$target_info" | cut -f2)
    tab_id=$(printf '%s' "$target_info" | cut -f3)
fi

if [ -z "$target_pane" ] || [ -z "$workspace_id" ] || [ -z "$tab_id" ]; then
    printf '%s\n' "btop-sidebar: pane context is incomplete" >&2
    exit 0
fi

# 同じタブのbtopペインを探します。
existing_btop_pane=$(herdr pane list 2>/dev/null | python3 -c '
import json
import sys

workspace_id = sys.argv[1]
tab_id = sys.argv[2]
panes = json.load(sys.stdin).get("result", {}).get("panes", [])
pane_id = next(
    (
        pane.get("pane_id", "")
        for pane in panes
        if pane.get("workspace_id") == workspace_id
        and pane.get("tab_id") == tab_id
        and (
            pane.get("label") == "btop"
            or pane.get("terminal_title_stripped", "").lower() == "btop"
        )
    ),
    "",
)
print(pane_id)
' "$workspace_id" "$tab_id")

if [ -n "$existing_btop_pane" ]; then
    # ラベルだけ残ったペインは、新規分割せずbtopを再起動します。
    if herdr pane process-info --pane "$existing_btop_pane" 2>/dev/null | python3 -c '
import json
import sys

processes = json.load(sys.stdin).get("result", {}).get("process_info", {}).get(
    "foreground_processes", []
)
running = any(process.get("name", "").lower() == "btop" for process in processes)
raise SystemExit(0 if running else 1)
'; then
        herdr pane close "$existing_btop_pane" >/dev/null
        exit 0
    fi

    herdr pane run "$existing_btop_pane" btop >/dev/null
    exit 0
fi

# btopには最低80桁×24行が必要なため、下側へ26行を確保する比率を計算します。
layout_info=$(herdr pane layout --pane "$target_pane" 2>/dev/null | python3 -c '
import json
import sys

layout = json.load(sys.stdin).get("result", {}).get("layout", {})
area = layout.get("area", {})
width = int(area.get("width", 0))
height = int(area.get("height", 0))

if width < 80 or height < 36:
    print("")
else:
    ratio = max(0.20, min(0.75, (height - 26) / height))
    print(f"{ratio:.4f}")
')

if [ -z "$layout_info" ]; then
    printf '%s\n' "btop-sidebar: at least 80 columns and 36 rows are required" >&2
    exit 0
fi

split_json=$(herdr pane split "$target_pane" \
    --direction down \
    --ratio "$layout_info" \
    --no-focus)

btop_pane=$(printf '%s' "$split_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data.get("result", {}).get("pane", {}).get("pane_id", ""))
')

if [ -z "$btop_pane" ]; then
    exit 0
fi

herdr pane rename "$btop_pane" btop >/dev/null
herdr pane run "$btop_pane" btop >/dev/null
