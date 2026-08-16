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
    plugin_list=""

    if ! command -v herdr >/dev/null 2>&1; then
        warn "herdr がないため、btop-sidebarの登録を省略します。"
        return
    fi

    if ! plugin_list=$(herdr plugin list 2>/dev/null); then
        fail "Herdrのプラグイン一覧を取得できませんでした。Herdrの起動状態とログを確認してください。"
        return
    fi

    if printf '%s\n' "$plugin_list" | grep -Fq 'local.btop-sidebar'; then
        info "Herdrプラグイン local.btop-sidebar は登録済みです。"
        return
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
        info "Herdrプラグイン local.btop-sidebar を登録しました。"
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
