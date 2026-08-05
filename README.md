# Terminal Development Environment Configs (macOS / Windows)

Ghostty、Herdr、Fish、Neovim、Starshipを中心に、macOSの開発環境とウィンドウ操作の設定をまとめたリポジトリです。
自分用のバックアップであると同時に、友達が環境を再現したり、Neovimの操作を確認したりするためのチートシートとして使えます。

macOSが主対象ですが、Neovim・Starship・GitはWindowsネイティブでも利用できます。

> [!WARNING]
> **実ファイル管理について**
> このリポジトリは、主に `~/.config` で実際に使っている設定ファイルのコピーです。
> ここを編集してもホームディレクトリ側へ自動反映・同期はされません。既存設定へコピーする前にバックアップしてください。

> [!NOTE]
> **Windows利用時の注意**
> NeovimとStarshipはWindowsネイティブで利用できます。Ghostty、yabai、skhd、Karabiner-ElementsはmacOS向けです。
> Unix系のシェル環境も含めて近い構成を作りたい場合は、**WSL2 (Ubuntu)** とWindows TerminalまたはWezTermの組み合わせがおすすめです。
> 詳細は [🪟 Windows対応について](#-windows対応について) を参照してください。

---

## 🛠️ ファイル構成

```text
.
├── README.md
├── ghostty/                 # Ghosttyの外観・分割・キーバインド
├── herdr/                   # Herdr本体とSpreaderのworkspace設定
├── fish/                    # FishのPATH・Conda・Starship初期化
├── nvim/                    # Neovim (v0.11+) 設定
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── autocmds.lua
│       ├── keymaps.lua
│       ├── lsp.lua
│       ├── mycommand.lua
│       ├── mydap/           # Python / Swift / DartのDAP設定
│       └── plugins/         # core / dev / workspace別のプラグイン定義
├── starship.toml            # Starshipプロンプト
├── yabai/                   # macOSウィンドウマネージャ
├── skhd/                    # yabai操作・アプリ起動ショートカット
├── karabiner/               # Karabiner-Elements
├── cmux.json                # cmuxのUI・キーバインド
├── calyx/                   # Calyxの表示・実行設定
├── gh/config.yml            # GitHub CLI（認証情報を除く）
└── NuGet/NuGet.Config       # NuGetパッケージソース
```

---

## 📦 事前に必要な依存ツール

`lazy.nvim` はプラグイン本体を自動インストールしますが、LSP・フォーマッタ・画像表示などが依存する**外部コマンド**は事前に用意する必要があります。

### 基本ツール（macOS / Windows）

| ツール             | 用途                                                       | macOS (Homebrew)                                    | Windows (winget)                                                                            |
| ------------------ | ---------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Git                | プラグイン管理 / 自動push                                  | `brew install git`                                  | `winget install Git.Git`                                                                    |
| Neovim (v0.11+)    | エディタ本体（`vim.lsp.enable` API使用のため0.11以上必須） | `brew install neovim`                               | `winget install Neovim.Neovim`                                                              |
| ripgrep            | Telescope Live Grep (`Space+fg`)                           | `brew install ripgrep`                              | `winget install BurntSushi.ripgrep.MSVC`                                                    |
| fd                 | Telescope高速ファイル検索                                  | `brew install fd`                                   | `winget install sharkdp.fd`                                                                 |
| Node.js (LTS)      | ts_ls / emmet_ls / prettier 等                             | `brew install node`                                 | `winget install OpenJS.NodeJS.LTS`                                                          |
| Python3 + pip      | pyright / ruff / Molten(REPL)                              | `brew install python`                               | `winget install Python.Python.3.12`                                                         |
| Java (JDK 17+)     | Java利用時のjdtls                                          | `brew install openjdk`                              | `winget install EclipseAdoptium.Temurin.21.JDK`                                             |
| Cコンパイラ + make | treesitter / telescope-fzf-native のビルド                 | Xcode Command Line Tools (`xcode-select --install`) | `winget install Microsoft.VisualStudio.2022.BuildTools` または `winget install MSYS2.MSYS2` |
| Nerd Font          | アイコン表示 (nvim-web-devicons, lualine等)                | `brew install --cask font-jetbrains-mono-nerd-font` | `winget install DEVCOM.JetBrainsMonoNerdFont`                                               |
| Starship           | プロンプト                                                 | `brew install starship`                             | `winget install Starship.Starship`                                                          |
| Herdr              | 永続ペイン・workspace・AI agent管理                        | `brew install herdr`                                | **非対応**                                                                                  |

Python側は追加で以下をpip導入（Molten用REPL連携）:

```bash
pip install pynvim jupyter_client ipykernel --user
```

### 任意（機能を使う場合のみ）

| ツール                | 用途                                                      | macOS                             | Windows                                             |
| --------------------- | --------------------------------------------------------- | --------------------------------- | --------------------------------------------------- |
| ImageMagick           | image.nvim / diagram.nvim の画像描画                      | `brew install imagemagick`        | `winget install ImageMagick.ImageMagick`            |
| glow                  | `:Glow` によるMarkdownプレビュー                          | `brew install glow`               | `winget install charmbracelet.glow`                 |
| gh (GitHub CLI)       | octo.nvim のPR/Issue操作を安定化                          | `brew install gh`                 | `winget install GitHub.cli`                         |
| Dart / Flutter        | flutter-tools.nvim、Dart開発                              | Flutter SDKを導入                 | Flutter SDKを導入                                   |
| SourceKit-LSP / Swift | Swift LSP・`:As`/`:Sw`実行コマンド                        | Xcode同梱（追加インストール不要） | **非対応**（Swift for Windowsは実験的、非推奨）     |
| Ghostty               | ターミナル本体                                            | `brew install --cask ghostty`     | **非対応**（WSL2 + Windows Terminal / WezTerm推奨） |
| WezTerm               | Kittyグラフィックスプロトコル対応ターミナル(image.nvim用) | `brew install --cask wezterm`     | `winget install wez.wezterm`                        |

Rust製CLI（ripgrep/fd/starship等）は `cargo install` でも共通コマンドとして導入可能です:

```bash
cargo install ripgrep fd-find starship
```

---

## 🚀 クイックセットアップ

### macOS

このリポジトリを `~/.config` の外にcloneした場合は、必要な設定だけコピーします。

```bash
mkdir -p ~/.config
cp -R ghostty fish nvim yabai skhd karabiner calyx NuGet ~/.config/
cp starship.toml ~/.config/starship.toml

mkdir -p ~/.config/herdr/plugins/config/herdr-spreader
cp herdr/config.toml ~/.config/herdr/config.toml
cp herdr/spreader/config.yaml ~/.config/herdr/plugins/config/herdr-spreader/config.yaml

herdr integration install codex
herdr plugin install smarzban/herdr-file-viewer --yes
herdr plugin install persiyanov/herdr-reviewr --yes
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
herdr plugin install yuk1ty/herdr-spreader --yes

mkdir -p ~/.config/cmux ~/.config/gh
cp cmux.json ~/.config/cmux/cmux.json
cp gh/config.yml ~/.config/gh/config.yml
```

既存設定がある場合は、先に `~/.config/nvim` などをバックアップしてください。

### Windows (PowerShell)

Windowsネイティブでは、NeovimとStarshipを次の場所へ配置できます。

```powershell
# Neovim（設定先: %LOCALAPPDATA%\nvim）
New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\nvim"
Copy-Item -Recurse -Force nvim\* "$env:LOCALAPPDATA\nvim\"

# Starship（設定先は任意。ここでは %USERPROFILE%\.config）
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config"
Copy-Item -Force starship.toml "$env:USERPROFILE\.config\starship.toml"

# Starshipに設定ファイルの場所を伝える
[Environment]::SetEnvironmentVariable(
  "STARSHIP_CONFIG",
  "$env:USERPROFILE\.config\starship.toml",
  "User"
)
```

PowerShellプロファイル（`notepad $PROFILE`）へ次を追加すると、Starshipが起動します。

```powershell
Invoke-Expression (&starship init powershell)
```

WSL2を使う場合は、Ubuntu内の `~/.config/nvim` と `~/.config/starship.toml` へmacOSと同様にコピーします。Windows側とWSL側は別環境なので、それぞれにNeovimや依存ツールのインストールが必要です。

---

## 🪟 Windows対応について

このNeovim設定をWindowsで使う場合は、次の点に注意してください。

1. **Swift関連機能はmacOS前提**
   `lsp.lua` のSourceKit-LSP、`mycommand.lua` の `:S` / `:Sw` / `:As`、Swift用DAPはXcode環境を前提にしています。
2. **個人用パスを変更する**
   `mycommand.lua` と `autocmds.lua` には `~/Desktop/memo` や `~/Desktop/daily_log` を使う処理があります。Windowsでも `~` はユーザーディレクトリへ解決されますが、実際の保存場所に合わせて変更してください。
3. **画像表示はターミナル依存**
   Windowsでは `image.nvim` を読み込まない設定です。画像表示も使いたい場合は、WezTermなど対応ターミナルを用意し、プラグイン側の条件を調整してください。
4. **jdtlsはOSを自動判定**
   Java用設定はWindowsで `config_win`、それ以外で `config_mac` を選びます。Masonからjdtlsを導入してください。
5. **macOS専用設定はコピー不要**
   `ghostty/`、`yabai/`、`skhd/`、`karabiner/` はWindowsでは使いません。近いターミナル・シェル環境が必要ならWSL2 + Windows Terminal / WezTermを利用してください。
6. **Neovimのシェル設定を変更する**
   `options.lua` は現在 `shell = "/bin/zsh"` です。Windowsネイティブで使う場合はこの行を削除するか、PowerShellなど実在するシェルへ変更してください。

---

## 📝 各設定のハイライト

### Herdr (`herdr/`)

- `Ctrl+A`をprefixにした、キーボード中心のタブ・ペイン操作
- `prefix+e`: ファイルビューア、`prefix+g`: 差分レビュー、`prefix+s`: Spreaderレイアウト適用
- `Ctrl+h/j/k/l`: Neovim splitとHerdr paneをシームレスに移動
- Codexの状態通知、セッション復元、日本語IME向けの入力補助を有効化
- `herdr/spreader/config.yaml`からdotfiles用workspaceを作成し、Neovimとシェルを上下に配置

起動は`herdr`、設定変更後の反映は`herdr server reload-config`です。

### 1. Ghostty Terminal (`ghostty/config`)

- `background-opacity = 0.6` と背景画像の透過で見た目を調整しています。
- `Cmd+Enter`: 右に分割 / `Cmd+Shift+Enter`: 下に分割 / `Cmd+矢印`: ペイン移動 / `Cmd+Shift+矢印`: リサイズ / `Cmd+W`: ペインを閉じる

### 2. Neovim (`nvim/`)

`lazy.nvim` をパッケージマネージャにした開発・メモ環境です。

#### 自動化機能 (`autocmds.lua`)

- 保存時に行末の不要な空白を自動削除
- ファイルを開くと最後のカーソル位置を復元
- `:MemoPush` / `:DailyPush` でメモや日記の差分を確認し、commit・pushする
- LSP接続時に定義・宣言・参照・実装ジャンプとinlay hint切り替えを設定
- 2MBを超えるファイルではswap・undo・syntaxを抑えるLarge file modeを有効化

#### 独自コマンド (`mycommand.lua` & `keymaps.lua`)

- `:Memo` / `:Smemo` / `:Dmemo` / `:Dlog` で各種メモ・日記ファイルを開く
- `:P` / `:S` でテスト用 Python / Swift ファイルを開く（`:S` は macOS 専用）
- `:Py` / `:Sw` で現在のコードを分割ターミナルから実行する（`:Sw` は macOS 専用）
- `:As` / `:Ap` で `test.txt` を標準入力にして AtCoder 用に実行する（`:As` は macOS 専用）
- `:MemoPush` / `:DailyPush` で個人メモをcommit・pushする
- `Space+ff` / `Space+fg` / `Space+fb` / `Space+fh` で Telescope によるファイル / 全文 / バッファ / ヘルプ検索を行う
- `molten-nvim` + `notebook-navigator` により `# %%` セルを認識し、`Space+nr` で実行、`]n` / `[n` でセル移動、`image.nvim` でプロットを描画する

#### 主要プラグイン (`plugins/`)

| カテゴリ           | プラグイン                                                                                                |
| ------------------ | --------------------------------------------------------------------------------------------------------- |
| ファイラー・検索   | oil.nvim, telescope.nvim, telescope-fzf-native, grug-far.nvim                                             |
| 開発支援           | nvim-lspconfig, mason.nvim, nvim-cmp, conform.nvim, nvim-treesitter, trouble.nvim, lspsaga.nvim           |
| 実行・デバッグ     | jaq-nvim, nvim-dap, nvim-dap-ui, nvim-dap-python, nvim-dap-virtual-text, flutter-tools.nvim               |
| 編集スピード       | flash.nvim, nvim-surround, Comment.nvim, treesj, nvim-spider, mini.ai, substitute.nvim                    |
| Jupyter/ビジュアル | molten-nvim, NotebookNavigator.nvim, image.nvim, diagram.nvim, render-markdown.nvim                       |
| 外観・操作         | nightfox.nvim, barbar.nvim, lualine.nvim, smart-splits.nvim, which-key.nvim, dropbar.nvim, dashboard-nvim |
| Git・GitHub連携    | gitsigns.nvim, diffview.nvim, octo.nvim, neogit                                                           |
| 作業管理           | persistence.nvim, todo-comments.nvim, toggleterm.nvim                                                     |

#### 🌱 Neogit の使い方（add / commit / push を Neovim 内で完結）

`Space+gg`（`:Neogit`）を実行すると、専用のステータス画面が開きます。表示はおおむね次のような構成です。

```text
Untracked files (1)
  new_file.py

Unstaged changes (2)
  modified: plugins/
  modified: keymaps.lua

Staged changes (0)

Recent commits
  a1b2c3d 前回のコミット
```

**基本操作**

| キー      | 動作                                                                    |
| --------- | ----------------------------------------------------------------------- |
| `s`       | カーソル位置のファイル（またはhunk）をステージ（add相当）               |
| `u`       | ステージ解除（unstage）                                                 |
| `x`       | 変更を破棄（discard。取り消せないので注意）                             |
| `Tab`     | ファイルを展開してdiffをインライン表示（hunk単位で`s`できるようになる） |
| `c` → `c` | コミットメッセージ入力画面を開いてコミット                              |
| `P` → `p` | push                                                                    |
| `F` → `p` | pull                                                                    |
| `g?`      | 今使えるキー一覧をオーバーレイ表示（迷ったらこれ）                      |
| `q`       | 画面を閉じる                                                            |

つまずきやすい原因は主に3つです。

1. **カーソル位置がファイル名の行からずれている** - 見出し行（`Unstaged changes (2)` など）や空行の上で `s` を押しても反応しません。ファイル名の行に合わせる必要があります。
2. **`Tab` で hunk を展開した状態のまま `s` を押している** - 展開中の `s` は、その hunk にだけ効きます。ファイル全体をステージしたい場合は、畳んだ状態で `s` を押してください。
3. **見た目だけの問題で、実は成功している** - 確認したい場合は、別ターミナルで以下を実行するのが確実です。
   ```bash
   git status
   ```
   `Changes to be committed:` の下に対象ファイルが出ていればステージ成功です。

---

## 📄 設定ファイルの内容メモ

### `starship.toml`

- Python環境、Gitブランチ・状態・差分件数、コマンド実行時間などを表示
- macOS、Linux、Windowsで共通利用可能

### `fish/config.fish`

- `~/.local/bin` をPATHへ追加
- Minicondaを初期化
- 対話シェルでStarshipを初期化

### `ghostty/config`

- `theme = nightfox`、背景透過、余白を設定
- `Cmd+Enter` 系で分割、`Cmd+矢印` で移動、`Cmd+Shift+矢印` でリサイズ
- `Cmd+W` で現在のペインを閉じる

### macOS操作系

- `yabai/`: ウィンドウ配置、余白、透明度、除外ルール
- `skhd/`: yabai操作とアプリ起動のショートカット
- `karabiner/`: Karabiner-Elementsのキー変更
- `cmux.json`: cmuxのキーバインドとUI
- `calyx/`: Calyxの表示・実行設定

**一連の流れの例**

1. `Space+gg` でNeogitを開く
2. `modified: plugins/` の行にカーソルを合わせて `s` → Staged changesへ移動すれば成功
3. `c` → `c` でコミットメッセージバッファが開く。メッセージを書いて `<C-c><C-c>`（または保存して閉じる）でコミット確定
4. `P` → `p` でpush

**補足**

- `octo.nvim`（PR/Issue管理）とは役割が別なので共存に問題ありません。Neogitでコミット・push → `Space+oc`でPR作成、という流れで使えます。
- `diffview`統合を有効にしているので、Neogit画面から差分を開くと使い慣れたdiffview.nvimのUIで表示されます。

---

## ⌨️ キーバインド・コマンド チートシート

### Neovim — 基礎

| キー                                 | 動作                                                    |
| ------------------------------------ | ------------------------------------------------------- |
| **モード変換（自モード以外で作動）** |                                                         |
| `<Esc>`                              | Normalモードに変更（デフォルト）                        |
| `i`                                  | Insertモード（文字入力モード）                          |
| `v`                                  | Visualモード（選択モード）                              |
| `;` / `:`                            | コマンドモード                                          |
| **ちょっと特殊なモード**             |                                                         |
| `V`                                  | 行選択モード（行ごとに選択）                            |
| `<C-v>`                              | 矩形（範囲）選択モード                                  |
| **移動 (Normalモード)**              |                                                         |
| `h` / `j` / `k` / `l`                | 左 / 下 / 上 / 右                                       |
| `w` / `b`                            | 次/前の単語頭へ（**nvim-spiderにより拡張**、下記参照）  |
| `e`                                  | 単語末尾へ（**nvim-spiderにより拡張**、下記参照）       |
| `0` / `$`                            | 行頭へ / 行末へ                                         |
| `gg` / `G`                           | ファイル先頭へ / ファイル末尾へ                         |
| `{数字}G`                            | 指定行へジャンプ（例: `10G`で10行目）                   |
| `Ctrl+d` / `Ctrl+u`                  | 半ページ下/上スクロール                                 |
| **削除・変更**                       |                                                         |
| `x`                                  | カーソル位置の1文字削除                                 |
| `dd`                                 | 行を1行削除（カット）                                   |
| `{数字}dd`                           | 指定行数だけ削除（例: `3dd`で3行削除）                  |
| `dw`                                 | カーソル位置から単語末尾まで削除                        |
| `d$` （または`D`）                   | カーソル位置から行末まで削除                            |
| `cc`                                 | 行を削除してInsertモードへ（変更）                      |
| `cw`                                 | 単語を削除してInsertモードへ                            |
| `r{文字}`                            | カーソル位置の1文字を置換                               |
| `u` / `Ctrl+r`                       | 元に戻す（undo） / やり直す（redo）                     |
| **ヤンク（コピー）・ペースト**       |                                                         |
| `yy`                                 | 行を1行ヤンク（コピー）                                 |
| `{数字}yy`                           | 指定行数だけヤンク（例: `3yy`で3行コピー）              |
| `yw`                                 | カーソル位置から単語末尾までヤンク                      |
| `y$`                                 | カーソル位置から行末までヤンク                          |
| `p`                                  | ヤンク/削除した内容をカーソルの**後ろ（下）**に貼り付け |
| `P`                                  | ヤンク/削除した内容をカーソルの**前（上）**に貼り付け   |
| **Visualモードでの操作**             |                                                         |
| `v` → 移動 → `d`                     | 選択範囲を削除                                          |
| `v` → 移動 → `y`                     | 選択範囲をヤンク                                        |
| `v` → 移動 → `c`                     | 選択範囲を削除してInsertモードへ                        |
| **検索**                             |                                                         |
| `/{文字列}` → `Enter`                | 前方検索、`n`/`N`で次/前の候補へ                        |
| `*`                                  | カーソル位置の単語を前方検索                            |

> **補足: `w`/`e`/`b`について**
> `nvim-spider`により、`camelCase`や`snake_case`の区切りも単語境界として認識するようになっています。素のVimより少ない回数の移動で目的の単語に到達できます（`dw`/`cw`等の組み合わせにも適用されます。ただ、相変わらず日本語には弱いです。）。

### Neovim — 一般・編集

| キー                    | 動作                                     |
| ----------------------- | ---------------------------------------- |
| `Space`                 | Leaderキー                               |
| `;`                     | `:` (コマンドラインモード)               |
| `jk` (挿入モード)       | `<ESC>`                                  |
| `x`                     | ヤンクせず1文字削除                      |
| `dw`                    | 単語を後方削除                           |
| `Y`                     | 行末までヤンク                           |
| `Space+l`               | 行末へ移動                               |
| `Space+Q`               | 強制終了                                 |
| `Esc`                   | 検索ハイライト消去                       |
| `s` / `S`               | flash.nvim ジャンプ / Treesitterジャンプ |
| `J`                     | ブロックの1行化/複数行化トグル (treesj)  |
| `Tab` / `Shift+Tab`     | 次/前のバッファへ移動                    |
| `Space+bd` / `Space+bt` | バッファ / Vimタブを閉じる               |
| `Ctrl+\`                | フロートターミナルを開閉                 |

### Neovim — ウィンドウ・コード移動

| キー           | 動作                                      |
| -------------- | ----------------------------------------- |
| `Ctrl+h/j/k/l` | 左/下/上/右のウィンドウへ移動             |
| `Alt+h/j/k/l`  | ウィンドウをリサイズ                      |
| `gd` / `gD`    | 定義 / 宣言へ移動                         |
| `gr` / `gi`    | 参照一覧 / 実装へ移動                     |
| `Space+li`     | inlay hintの表示切り替え                  |
| `Space+;`      | dropbarで現在のシンボルを選択             |
| `[;` / `];`    | 現在のコンテキスト先頭 / 次のコンテキスト |

### Neovim — ファイラー・検索

| キー                                              | 動作                                                |
| ------------------------------------------------- | --------------------------------------------------- |
| `Space+ff` / `Space+fg` / `Space+fb` / `Space+fh` | ファイル検索 / 全文検索 / バッファ検索 / ヘルプ検索 |
| `-` / `Space+e`                                   | oil.nvim起動                                        |
| `Space+ft`                                        | TODOコメントをTelescopeで検索                       |
| `Space+sr`                                        | プロジェクト内の検索・置換                          |

### Neovim — Jupyter風環境

| キー                    | 動作                        |
| ----------------------- | --------------------------- |
| `Space+ni`              | `:MoltenInit python3`       |
| `Space+nr` / `Space+nx` | セル実行 / セル実行して次へ |
| `]n` / `[n`             | 次/前のセルへ移動           |
| `Space+nl` / `Space+nv` | 行実行 / 選択範囲実行       |
| `Space+nR`              | セル再実行                  |

### Neovim — Git連携

| キー                                 | 動作                                   |
| ------------------------------------ | -------------------------------------- |
| `]c` / `[c`                          | 次/前のHunkへ移動                      |
| `Space+hs` / `Space+hr` / `Space+hp` | Hunkのステージ / リセット / プレビュー |
| `Space+xx`                           | Trouble診断一覧                        |
| `Space+gg`                           | Neogitを開く（Git Status画面）         |
| `Space+gc`                           | Neogit: コミット画面を開く             |
| `Space+gp`                           | Neogit: push                           |
| `Space+gd`                           | NeogitとOcto PR一覧を左右に開く        |
| `Space+oc`                           | Octo PR作成                            |
| `Space+op` / `Space+oi`              | Octo PR一覧 / Issue一覧                |
| `Space+oI`                           | Octo Issue作成                         |
| `Space+or` / `Space+os`              | Octoレビュー開始 / 検索                |

### Neovim — コード実行 (jaq-nvim)

| キー      | 動作                                         |
| --------- | -------------------------------------------- |
| `Space+j` | カーソルのあるファイルをfloat windowで即実行 |

### Neovim — デバッガ (nvim-dap / nvim-dap-ui)

| キー                                 | 動作                                          |
| ------------------------------------ | --------------------------------------------- |
| `Space+dc`                           | Continue（実行/再開）                         |
| `Space+do` / `Space+di` / `Space+dO` | Step Over / Step Into / Step Out              |
| `Space+db`                           | ブレークポイントの切り替え                    |
| `Space+dB`                           | 条件付きブレークポイントを設定                |
| `Space+dl`                           | ログポイントを設定                            |
| `Space+du`                           | DAP UIの開閉                                  |
| `Space+de`                           | 選択範囲/カーソル下の値を評価 (Normal/Visual) |

> Python以外の言語でデバッグしたい場合は、対応する`nvim-dap-*`アダプタ（例: `leoluz/nvim-dap-go`）を`plugins/`に追記してください。

### Neovim — フォーマット・Flutter・セッション

| キー                    | 動作                                      |
| ----------------------- | ----------------------------------------- |
| `Space+cf`              | 現在のバッファをConformで整形             |
| `Space+cc`              | Flutterコマンド一覧（Dartバッファで有効） |
| `Space+cr` / `Space+cR` | Flutter Reload / Restart                  |
| `Space+qs`              | 現在のディレクトリのセッションを復元      |
| `Space+ql`              | 最後のセッションを復元                    |
| `Space+qd`              | 現在のセッションの自動保存を停止          |
| `]t` / `[t`             | 次/前のTODOコメントへ移動                 |

### Neovim — LSP UI強化 (Lspsaga)

| キー        | 動作                           |
| ----------- | ------------------------------ |
| `K`         | リッチなHover表示              |
| `Space+lf`  | LSP Finder（参照・実装元一覧） |
| `Space+lr`  | Rename                         |
| `Space+la`  | Code Action                    |
| `Space+ld`  | 現在行の診断を表示             |
| `Space+lp`  | 定義をPeek表示                 |
| `[d` / `]d` | 前/次の診断へジャンプ          |

### Neovim — 独自コマンド

| コマンド           | 動作                       | プラットフォーム                |
| ------------------ | -------------------------- | ------------------------------- |
| `:Memo` / `:Smemo` | メモファイルを開く         | 全対応\*                        |
| `:Dmemo` / `:Dlog` | 今日のメモ/日記を開く      | 全対応\*                        |
| `:P` / `:S`        | テスト用Python/Swiftを開く | Python:全対応 / Swift:macOSのみ |
| `:Py` / `:Sw`      | 分割ターミナルで実行       | Python:全対応 / Swift:macOSのみ |
| `:W` / `:Wq`       | 保存 / 保存終了            | 全対応                          |
| `:As` / `:Ap`      | AtCoder標準入力実行        | Python:全対応 / Swift:macOSのみ |

\* パスがmacOSハードコードのため、Windowsで使う場合は前述の修正が必要です。

### Ghostty (macOS/Linux)

| キー                            | 動作                  |
| ------------------------------- | --------------------- |
| `Cmd+Enter` / `Cmd+Shift+Enter` | 右/下に分割           |
| `Cmd+矢印` / `Cmd+Shift+矢印`   | ペイン移動 / リサイズ |
| `Cmd+W`                         | ペインを閉じる        |

### yabai / skhd (macOS)

| キー                        | 動作                                    |
| --------------------------- | --------------------------------------- |
| `Option+h/j/k/l`            | 左/下/上/右のウィンドウへフォーカス移動 |
| `Shift+Option+h/j/k/l`      | ウィンドウサイズを変更                  |
| `Option+Enter` / `Option+f` | 最大化を切り替え                        |
| `Option+t`                  | フロート表示を切り替えて中央へ配置      |
| `Option+b`                  | 現在のSpaceのウィンドウ比率を均等化     |
| `Option+1/2/3`              | Space 1 / 2 / 3へ移動                   |
| `Option+a/c/d`              | Arc / cmux / Discordを起動              |

---

## 🔒 セキュリティ方針

- パスワード、APIキー、トークンをリポジトリへ直接記述しないでください。
- `gh/hosts.yml` は認証情報を含むため管理対象外です。
- Windowsでは `%USERPROFILE%\.secrets.ps1` を作り、PowerShellプロファイルから `. $HOME\.secrets.ps1` で読み込む運用にできます。
- 履歴、ログ、キャッシュ、バックアップ、PIDなどの実行状態ファイルはコミットしません。
