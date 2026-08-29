#!/bin/sh

# Linux／WSL向けに、このリポジトリの設定を安全にリンクします。
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
check_only=false
errors=0

usage() {
    printf '%s\n' "Usage: ./install.sh [--check]"
    printf '%s\n' "  --check  設定を変更せず、導入状態と依存コマンドを確認します。"
}

info() {
    printf '  [OK] %s\n' "$1"
}

warn() {
    printf '  [--] %s\n' "$1"
}

fail() {
    printf '  [NG] %s\n' "$1" >&2
    errors=$((errors + 1))
}

link_config() {
    source_path=$1
    target_path=$2
    label=$3

    if [ -L "$target_path" ] && [ "$(readlink -f "$target_path" 2>/dev/null || true)" = "$source_path" ]; then
        info "$label は設定済みです。"
        return
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        fail "$target_path が既にあります。バックアップまたは削除してから再実行してください。"
        return
    fi

    if [ "$check_only" = true ]; then
        fail "$label は未設定です。"
        return
    fi

    mkdir -p "$(dirname -- "$target_path")"
    ln -s "$source_path" "$target_path"
    info "$label をリンクしました。"
}

check_command() {
    command_name=$1
    requirement=$2

    if command -v "$command_name" >/dev/null 2>&1; then
        info "$command_name: $(command -v "$command_name")"
    else
        warn "$command_name がありません（$requirement）。"
    fi
}

check_fd() {
    if command -v fd >/dev/null 2>&1; then
        info "fd: $(command -v fd)"
    elif command -v fdfind >/dev/null 2>&1; then
        info "fdfind: $(command -v fdfind)"
    else
        warn "fd／fdfind がありません（Telescopeのファイル検索に推奨です）。"
    fi
}

setup_herdr_plugin() {
    plugin_source="$repo_dir/herdr/plugins/btop-sidebar"
    plugin_json=""
    registered_root=""

    if ! command -v herdr >/dev/null 2>&1; then
        warn "herdr がないため、btop-sidebarの登録を省略します。"
        return
    fi

    if ! plugin_json=$(herdr plugin list --plugin local.btop-sidebar --json 2>/dev/null); then
        fail "Herdrのプラグイン一覧を取得できませんでした。Herdrの起動状態とログを確認してください。"
        return
    fi

    if command -v python3 >/dev/null 2>&1; then
        registered_root=$(printf '%s\n' "$plugin_json" | python3 -c '
import json
import sys

plugins = json.load(sys.stdin).get("result", {}).get("plugins", [])
print(plugins[0].get("plugin_root", "") if plugins else "")
')
    elif printf '%s\n' "$plugin_json" | grep -Fq 'local.btop-sidebar'; then
        warn "python3がないため、Herdrプラグインの登録先を照合できません。"
        return
    fi

    if [ -n "$registered_root" ]; then
        resolved_plugin_source=$(readlink -f "$plugin_source" 2>/dev/null || true)
        resolved_registered_root=$(readlink -f "$registered_root" 2>/dev/null || true)

        if [ -n "$resolved_registered_root" ] && [ "$resolved_registered_root" = "$resolved_plugin_source" ]; then
            info "Herdrプラグイン local.btop-sidebar は現在のリポジトリから登録済みです。"
            return
        fi

        if [ "$check_only" = true ]; then
            fail "Herdrプラグインは別の場所を参照しています: $registered_root"
            return
        fi

        if ! herdr plugin unlink local.btop-sidebar >/dev/null; then
            fail "古いHerdrプラグイン登録の解除に失敗しました。"
            return
        fi
    fi

    if [ "$check_only" = true ]; then
        fail "Herdrプラグイン local.btop-sidebar は未登録です。"
        return
    fi

    if [ -L "$config_home/herdr/plugins" ]; then
        fail "$config_home/herdr/plugins がシンボリックリンクです。ディレクトリ全体ではなく、herdr plugin linkで個別登録してください。"
        return
    fi

    if herdr plugin link "$plugin_source" >/dev/null; then
        info "Herdrプラグイン local.btop-sidebar を現在のリポジトリから登録しました。"
    else
        fail "Herdrプラグインの登録に失敗しました。"
    fi
}

case ${1:-} in
    "")
        ;;
    --check)
        check_only=true
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

printf '%s\n' "dotfile setup"
printf '%s\n' "Repository: $repo_dir"
printf '%s\n' "Config home: $config_home"

printf '\n%s\n' "設定リンク"
link_config "$repo_dir/nvim" "$config_home/nvim" "Neovim設定"
link_config "$repo_dir/herdr/config.toml" "$config_home/herdr/config.toml" "Herdr設定"

printf '\n%s\n' "Herdrプラグイン"
setup_herdr_plugin

printf '\n%s\n' "依存コマンド"
check_command git "Neovimプラグインの取得に必須です"
check_command nvim "Neovim設定を利用する場合に必須です"
check_command rg "Telescopeの全文検索に推奨です"
check_fd
check_command btop "btop-sidebarを利用する場合に必要です"
check_command python3 "btop-sidebarとPython開発機能に必要です"

printf '\n'
if [ "$errors" -ne 0 ]; then
    printf '%s\n' "$errors 件の要確認項目があります。" >&2
    exit 1
fi

printf '%s\n' "セットアップ状態に問題はありません。"
