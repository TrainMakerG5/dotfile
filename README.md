# Neovim and Herdr config for Windows and WSL2

WindowsネイティブとWSL2の両方で使うNeovimとHerdrの設定です。

設定ファイルにはユーザー名を含む固定パスを書かず、OS、ホームディレクトリ、Python、ビルドツールを起動時に判定します。GitHubを経由して複数環境で同じ設定を同期できます。

## 対応環境

- Neovim 0.11.3以上
- Windows 11
- WSL2
- Git

macOS向けの判定も一部残していますが、主な対象はWindowsとWSL2です。

## 構成

```text
.
├── README.md
├── herdr
│   └── config.toml
├── nvim
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua
│       ├── autocmds.lua
│       ├── cmp-config.lua
│       ├── colorscheme.lua
│       ├── keymaps.lua
│       ├── lsp.lua
│       ├── mycommand.lua
│       ├── options.lua
│       ├── platform.lua
│       ├── vscode-config.lua
│       └── plugins
```

Neovimでは `platform.lua` がWindows、WSL2、Linux、macOSの差を吸収します。Herdrは両環境で共通利用できる項目だけを管理します。

## インストール

既存のNeovim設定がある場合は、先にバックアップしてください。以下のリンク作成は、リンク先がすでに存在する場合には失敗します。

### Windows PowerShell

```powershell
$repo = Join-Path $env:USERPROFILE "dotfile"
git clone https://github.com/TrainMakerG5/dotfile.git $repo

$config = Join-Path $env:LOCALAPPDATA "nvim"
$target = Join-Path $repo "nvim"
New-Item -ItemType Junction -Path $config -Target $target

$herdrConfig = Join-Path $repo "herdr\config.toml"
[Environment]::SetEnvironmentVariable("HERDR_CONFIG_PATH", $herdrConfig, "User")
```

ディレクトリジャンクションを使うため、リポジトリを編集するとNeovim設定へそのまま反映されます。

### WSL2

```bash
git clone https://github.com/TrainMakerG5/dotfile.git ~/dotfile
mkdir -p ~/.config
ln -s ~/dotfile/nvim ~/.config/nvim

mkdir -p ~/.config/herdr
ln -s ~/dotfile/herdr/config.toml ~/.config/herdr/config.toml
```

Windows側とWSL側にはそれぞれリポジトリをcloneし、GitHub経由で同期する運用を推奨します。WSLからWindows側のリポジトリを直接参照するより、プラグインやGitの動作が安定します。

Neovimを初めて起動すると、lazy.nvimと各プラグインが自動的に取得されます。Windowsで `HERDR_CONFIG_PATH` を設定した後は、ターミナルとHerdrを再起動してください。

## Herdr

共有設定は意図的に最小限にしています。

WSLでは安定版、Windowsではプレビュー版を公式インストーラから導入できます。

WSL:

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

Windows（プレビュー版）:

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"
```

詳細や手動インストール方法は[Herdr公式ドキュメント](https://herdr.dev/docs/install/)を参照してください。

```toml
onboarding = false

[theme]
name = "tokyo-night"
auto_switch = false
```

WindowsとWSL2では既定シェルや実際の作業場所が異なるため、`terminal.default_shell` や固定作業ディレクトリはGit管理していません。未指定時はHerdrが各環境の既定シェルを利用します。

設定変更後はHerdr内のメニュー、または次のコマンドで再読み込みできます。

```bash
herdr server reload-config
```

## 外部ツール

プラグイン本体はlazy.nvimが管理しますが、次のコマンドは必要に応じてOS側へ導入してください。

| ツール | 用途 | 必須度 |
| --- | --- | --- |
| `git` | プラグイン取得、Neogit | 必須 |
| `rg` | Telescopeの全文検索 | 推奨 |
| `fd` / `fdfind` | Python仮想環境とファイルの検索 | venv-selector利用時 |
| `curl`、`unzip` | Masonなどのダウンロードと展開 | 開発機能の導入時 |
| `python` / `python3` | Python実行、Molten | Python利用時 |
| `node`、`npm` | JavaScript、TypeScript、Masonの一部パッケージ | Web開発時 |
| `.NET SDK` | OmniSharpによるC#開発 | C#利用時 |
| `flutter` / `dart` | Flutter ToolsとDart LSP | Dart・Flutter利用時 |
| `make` | WSLでのtelescope-fzf-nativeビルド | 任意 |
| `cmake` | Windowsでのtelescope-fzf-nativeビルド | 任意 |
| `gh` | OctoによるGitHub操作 | GitHub連携時 |
| `magick` | MarkdownやNotebookの画像表示 | 画像表示時 |

### Windowsの基本ツール

入っていないものだけ実行してください。`fd`は今回インストール済みです。

```powershell
winget install --id Git.Git --exact --source winget
winget install --id Neovim.Neovim --exact --source winget
winget install --id BurntSushi.ripgrep.MSVC --exact --source winget
winget install --id sharkdp.fd --exact --source winget
```

### WSLの基本ツール

Ubuntu系のWSLでは次を導入します。Neovimはディストリビューション付属版が古い場合があるため、[Neovim公式手順](https://neovim.io/doc/install/)で0.11.3以上を導入してください。

```bash
sudo apt update
sudo apt install git curl unzip ripgrep fd-find build-essential cmake
```

`make`または`cmake`がない場合、telescope-fzf-nativeだけを省略し、Telescope本体は通常どおり利用します。

### LSPとフォーマッタ

Neovim内の`:Mason`で一覧を開けます。使う言語だけ、次のように導入してください。

```vim
:MasonInstall pyright ruff
:MasonInstall typescript-language-server html-lsp css-lsp emmet-language-server prettier
:MasonInstall lua-language-server stylua marksman
:MasonInstall omnisharp
```

Dart・FlutterはMasonではなくFlutter SDKの`flutter`と`dart`をPATHへ通します。C#のビルドには.NET SDKが必要です。

### Notebook機能

Moltenを使う場合は、Neovimが利用するPython環境へ次を導入します。

Ubuntu系WSLでは、先にPythonの基本パッケージを導入してください。

```bash
sudo apt install python3 python3-venv python3-pip
python3 -m pip install --user pynvim jupyter_client ipykernel
python3 -m ipykernel install --user --name python3
```

WindowsでPythonのコマンド名が `python` の場合は、`python3` を `python` に読み替えてください。

## WindowsとWSL2の違い

### シェル

WindowsではNeovimの既定シェルを維持します。WSL2では `zsh` がPATHにあればzshを使い、なければ既定シェルを使います。

### Python

Windowsでは `python`、WSL2では `python3` を優先し、利用可能な実行ファイルを自動選択します。

### クリップボード

WSL2では `clip.exe` と `powershell.exe` がPATHにある場合、`unnamedplus` をWindows側のクリップボードへ接続します。

WSLのWindows連携を無効化している場合は、OSC 52、Wayland、X11など環境に合うNeovimのclipboard providerが別途必要です。

### 画像表示

Windowsネイティブではimage.nvimとdiagram.nvimを無効化します。

WSL2では、次の両方を満たす場合だけ有効になります。

- `magick` がPATHにある
- WezTerm、Kitty、GhosttyなどKitty Graphics Protocol対応ターミナルを使っている

通常のWindows TerminalではMoltenのテキスト出力を利用できますが、ターミナル内画像は表示しません。

## 環境変数

個人用パスやPythonのカーネル名は、リポジトリへ書き込まず環境ごとに設定できます。

| 変数 | 用途 | 既定値 |
| --- | --- | --- |
| `NVIM_MEMO_DIR` | メモの保存先 | ホームディレクトリ内の `Desktop/memo` |
| `NVIM_DAILY_LOG_DIR` | 日記の保存先 | ホームディレクトリ内の `Desktop/daily_log` |
| `NVIM_PYTHON_KERNEL` | MoltenのJupyterカーネル名 | `python3` |

WSL2のホームとWindows側のホームは別です。Windows側のフォルダを使いたい場合も、そのパスはGit管理ファイルではなくWSLのシェル設定へ記述してください。

## 主な機能

- lazy.nvimによるプラグイン管理
- Telescopeによるファイル・全文検索
- Oilによるファイル操作
- Treesitter、LSP、nvim-cmpによるコード編集支援
- venv-selector.nvimによるPython仮想環境の選択
- fidget.nvimによるLSP進捗表示
- Masonによる開発ツール管理
- conform.nvimによる手動フォーマット
- Neogit、Gitsigns、Diffview、OctoによるGit/GitHub操作
- MoltenとNotebookNavigatorによるセル実行
- persistence.nvimによるセッション復元

## VSCode Neovim

普段はVSCodeを使いながら、編集操作だけを本物のNeovimで処理できます。VSCode Neovimから起動された場合は `vim.g.vscode` を検出し、通常のプラグイン群を読み込まず `vscode-config.lua` だけを利用します。

拡張機能をインストールします。

```powershell
code --install-extension asvetliakov.vscode-neovim
```

WSLのNeovimをバックエンドとして使う場合は、VSCode Neovimの設定画面でWSL利用を有効にします。Neovimの実行パスは環境によって異なるため、このリポジトリには固定していません。

VSCode内では次の処理をVSCode本体へ委譲します。

| キー | VSCodeの動作 |
| --- | --- |
| `Space ff` | Quick Open |
| `Space fg` | Find in Files |
| `Space fb` | 開いているエディタ一覧 |
| `Space e` | Explorer |
| `Space bd` | エディタを閉じる |
| `Space tt` | ターミナル切り替え |
| `gd` / `gr` / `gi` | 定義・参照・実装へ移動 |
| `K` | Hover表示 |
| `Space lr` | Rename |
| `Space la` | Code Action |
| `Space cf` | Format |
| `[d` / `]d` | 前・次の診断 |
| `Space gg` | Source Control |

## 主なキーマップ

LeaderキーはSpaceです。

### 検索とファイル

| キー | 動作 |
| --- | --- |
| `Space ff` | ファイル検索 |
| `Space fg` | 全文検索 |
| `Space fb` | バッファ検索 |
| `Space fh` | ヘルプ検索 |
| `Space e` / `-` | Oilを開く |
| `Tab` / `Shift+Tab` | 次・前のバッファ |
| `Space bd` | バッファを閉じる |

### LSPと診断

LSP接続中のバッファで利用できます。

| キー | 動作 |
| --- | --- |
| `gd` | 定義へ移動 |
| `gD` | 宣言へ移動 |
| `gr` | 参照一覧 |
| `gi` | 実装へ移動 |
| `K` | Hoverドキュメント |
| `Space la` | Code Action |
| `Space lr` | Rename |
| `[d` / `]d` | 前・次の診断 |
| `Space cf` | フォーマット |
| `Space vs` | Python仮想環境を選択 |

### Git

| キー | 動作 |
| --- | --- |
| `Space gg` | Neogitを開く |
| `Space gc` | コミット画面 |
| `Space gp` | Push |
| `]c` / `[c` | 次・前のHunk |
| `Space hp` | Hunkをプレビュー |
| `Space op` | Pull Request一覧 |

### Notebook

| キー | 動作 |
| --- | --- |
| `Space ni` | Moltenを初期化 |
| `Space nr` | 現在のセルを実行 |
| `Space nx` | セルを実行して次へ移動 |
| `]n` / `[n` | 次・前のセルへ移動 |
| `Space no` | 出力を開く |
| `Space nh` | 出力を隠す |

## 独自コマンド

| コマンド | 動作 |
| --- | --- |
| `:Memo` / `:Smemo` | メモファイルを開く |
| `:Dmemo` / `:Dlog` | 今日のメモ・日記を開く |
| `:P` | テスト用Pythonファイルを開く |
| `:Py` | 現在のPythonファイルを分割ターミナルで実行 |
| `:Ap` | `test.txt` を標準入力としてPythonを実行 |
| `:MemoPush` / `:DailyPush` | 個人用リポジトリをcommitしてpush |
| `:W` / `:Wq` | 保存・保存終了 |

## 同期方法

設定を変更した環境でcommitしてpushし、もう一方の環境でpullします。

```bash
git add README.md nvim herdr
git commit -m "Update Neovim config"
git push
```

別の環境では次を実行します。

```bash
git pull
```

`lazy-lock.json` もGit管理することで、WindowsとWSL2でプラグインのバージョンを揃えられます。

## 注意

- APIの都合上、Neovim 0.11未満は対象外です。
- LSPやフォーマッタの実行ファイルは設定だけでは自動導入されません。必要に応じて `:Mason` を使ってください。
- 秘密情報、GitHubトークン、端末固有の絶対パスはcommitしないでください。
