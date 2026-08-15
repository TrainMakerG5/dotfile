#!/bin/sh

# Herdrの復元完了直後に下側へbtopペインを一度だけ作成します。
set -eu

if ! command -v herdr >/dev/null 2>&1 || ! command -v btop >/dev/null 2>&1; then
    exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "btop-sidebar: python3 is required" >&2
    exit 0
fi

# 起動直後はフォーカス中のペインが確定していない場合があるため、少し待機します。
attempt=0
current_json=""
while [ "$attempt" -lt 10 ]; do
    if current_json=$(herdr pane current 2>/dev/null); then
        break
    fi
    attempt=$((attempt + 1))
    sleep 0.2
done

if [ -z "$current_json" ]; then
    exit 0
fi

target_info=$(printf '%s' "$current_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
pane = data.get("result", {}).get("pane", {})
pane_id = pane.get("pane_id", "")
workspace_id = pane.get("workspace_id", "")
print(f"{pane_id}\t{workspace_id}")
')

target_pane=$(printf '%s' "$target_info" | cut -f1)
workspace_id=$(printf '%s' "$target_info" | cut -f2)

if [ -z "$target_pane" ] || [ -z "$workspace_id" ]; then
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
    exit 0
fi

# 同じワークスペースに既存のbtopペインがあれば重複作成しません。
if herdr pane list 2>/dev/null | python3 -c '
import json
import sys

workspace_id = sys.argv[1]
panes = json.load(sys.stdin).get("result", {}).get("panes", [])
exists = any(
    pane.get("workspace_id") == workspace_id
    and (
        pane.get("label") == "btop"
        or pane.get("terminal_title_stripped", "").lower() == "btop"
    )
    for pane in panes
)
raise SystemExit(0 if exists else 1)
' "$workspace_id"; then
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
