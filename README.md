# dotfile

Windows 11・WSL2・VS Code Neovimで共有している、個人用のNeovim／Herdr設定です。

OS固有の絶対パスをできるだけ避け、ホームディレクトリ、Python、ビルドツール、画像表示への対応状況を起動時に判定します。通常のNeovimでは開発環境一式を読み込み、VS Code NeovimではVS Codeに必要な軽量設定だけを読み込みます。

> [!IMPORTANT]
> このリポジトリは完成済みディストリビューションではなく、作者の作業環境に合わせて継続的に変更しているdotfilesです。導入前に内容を確認し、既存の設定をバックアップしてください。

## 特徴

- Windows 11、WSL2、通常のLinuxを考慮した環境判定
- [lazy.nvim](https://github.com/folke/lazy.nvim)によるプラグイン管理
- Telescope、Oil、Treesitter、LSP、nvim-cmpによる編集支援
- Masonとconform.nvimによる開発ツール・フォーマッタ連携
- Neogit、Gitsigns、Diffview、OctoによるGit／GitHub操作
- MoltenとNotebookNavigatorによるJupyterセル実行
- VS Code Neovim向けの軽量な専用設定
- NeovimとVS Codeの両方で使えるVim操作チートシート
- StyLuaによるスペース4個のLuaフォーマット

## 対応環境

- Neovim 0.11.3以上
- Git
- Windows 11またはWSL2

通常のLinuxでも動作するよう実装していますが、主な動作確認対象はWindows 11とWSL2です。macOS向けの環境判定もありますが、動作保証はしていません。

## リポジトリ構成

```text
.
├── herdr/
│   ├── config.toml
│   ├── config.windows.toml
│   └── plugins/                     # ローカルHerdrプラグイン
│       └── btop-sidebar/             # btopペインの開閉
│           ├── herdr-plugin.toml
│           └── bin/btop-sidebar.sh
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── plugins/                 # lazy.nvimのプラグイン定義
│       │   ├── core.lua             # UI、補完、LSPなどの基盤
│       │   ├── dev.lua              # 開発・Git関連
│       │   └── workspace.lua        # Notebook、Markdown、作業環境
│       ├── autocmds.lua             # 自動コマンド
│       ├── cmp-config.lua           # 補完設定
│       ├── colorscheme.lua          # 配色設定
│       ├── keymaps.lua              # 基本キーマップ
│       ├── lsp.lua                  # 言語サーバー設定
│       ├── mycommand.lua            # 独自コマンド
│       ├── options.lua              # Neovimオプション
│       ├── platform.lua             # OS・実行ファイル・パスの判定
│       ├── plugins.lua              # プラグイン定義の入口
│       ├── vscode-config.lua        # VS Code Neovim専用設定
│       ├── vim_cheatsheet.lua       # 通常Neovim用チートシート
│       └── vim_cheatsheet_data.lua  # 両環境で共有する表示内容
├── stylua.toml
└── README.md
```

## インストール

### Windows PowerShell

既存の`%LOCALAPPDATA%\nvim`がある場合は、先に別の場所へ移動してください。その後、PowerShellで次を実行します。

```powershell
$repo = Join-Path $env:USERPROFILE "dotfile"
git clone https://github.com/TrainMakerG5/dotfile.git $repo

$config = Join-Path $env:LOCALAPPDATA "nvim"
$target = Join-Path $repo "nvim"
New-Item -ItemType Junction -Path $config -Target $target

$herdrConfig = Join-Path $repo "herdr\config.windows.toml"
[Environment]::SetEnvironmentVariable("HERDR_CONFIG_PATH", $herdrConfig, "User")
```

ジャンクションを作成するため、cloneしたリポジトリの変更がNeovim設定へ直接反映されます。Windows用のHerdr設定ではPowerShell 7（`pwsh`）を使用します。Herdrを使わない場合、`HERDR_CONFIG_PATH`の設定は不要です。

### WSL2／Linux

既存の`~/.config/nvim`がある場合は、先に別の場所へ移動してください。

```bash
git clone https://github.com/TrainMakerG5/dotfile.git ~/dotfile
mkdir -p ~/.config
ln -s ~/dotfile/nvim ~/.config/nvim

# Herdrを使う場合だけ実行します。
mkdir -p ~/.config/herdr
ln -s ~/dotfile/herdr/config.toml ~/.config/herdr/config.toml

# btopペインを使う場合だけ実行します。
herdr plugin link ~/dotfile/herdr/plugins/btop-sidebar
```

Windows側とWSL側では、それぞれリポジトリをcloneし、Git経由で同期する運用を想定しています。WSLからWindows側のリポジトリを直接参照すると、ファイルシステム性能や実行ファイルの違いで問題が起きることがあります。

初回起動時にlazy.nvimと各プラグインがダウンロードされます。

## 基本ツール

プラグイン本体はlazy.nvimが管理しますが、外部コマンドはOS側へのインストールが必要です。

| ツール | 用途 | 必須度 |
| --- | --- | --- |
| `git` | プラグイン取得とGit操作 | 必須 |
| `rg` | Telescopeの全文検索 | 推奨 |
| `fd` / `fdfind` | ファイル・Python仮想環境検索 | 推奨 |
| `curl`、`unzip` | Masonなどのダウンロード・展開 | 開発機能利用時 |
| `python` / `python3` | Python実行、Molten | Python利用時 |
| `node`、`npm` | JavaScript／TypeScript開発 | Web開発時 |
| `gh` | OctoによるGitHub操作 | GitHub連携時 |
| `cmake`または`make` | telescope-fzf-nativeのビルド | 任意 |
| `magick` | 対応ターミナルでの画像表示 | 任意 |

Windowsでは、必要なものだけ次のように導入できます。

```powershell
winget install --id Git.Git --exact --source winget
winget install --id Neovim.Neovim --exact --source winget
winget install --id BurntSushi.ripgrep.MSVC --exact --source winget
winget install --id sharkdp.fd --exact --source winget
```

Ubuntu系のWSLでは次が基本構成です。Neovimはディストリビューション付属版が古い場合があるため、[Neovim公式のインストール手順](https://neovim.io/doc/install/)も確認してください。

```bash
sudo apt update
sudo apt install git curl unzip ripgrep fd-find build-essential cmake
```

## LSPとフォーマッタ

`:Mason`を開き、利用する言語に必要なものだけインストールします。

```vim
:MasonInstall pyright ruff
:MasonInstall typescript-language-server html-lsp css-lsp emmet-language-server prettier
:MasonInstall lua-language-server stylua marksman
:MasonInstall omnisharp
```

Dart／FlutterにはFlutter SDK、C#のビルドには.NET SDKが別途必要です。

Lua設定はリポジトリ直下からStyLuaで整形できます。

```powershell
stylua nvim
stylua --check nvim
```

## VS Code Neovim

[VS Code Neovim](https://github.com/vscode-neovim/vscode-neovim)から起動された場合、`vim.g.vscode`を検出し、通常のUI・LSP・補完プラグインを読み込まずに`vscode-config.lua`だけを利用します。

```powershell
code --install-extension asvetliakov.vscode-neovim
```

Neovimの実行パスやWSL利用の有無は、VS Code Neovimの設定画面で環境に合わせて指定してください。

| キー | VS Codeでの動作 |
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
| `Space ?` | Vim操作ガイドを開閉 |

## Vim操作チートシート

`Space ?`で、移動・編集・選択などの早見表を開閉できます。

- 通常Neovimでは、フォーカスを奪わない右端のフローティングウィンドウとして表示します。
- VS Codeでは、テーマ色へ追従するWebviewを右側に表示します。

表示内容は[vim_cheatsheet_data.lua](nvim/lua/vim_cheatsheet_data.lua)で共有しています。セクションや項目を追加すると、両方の表示へ反映されます。

```lua
{
    title = "高度な編集",
    items = {
        { "q{文字}", "マクロの記録を開始" },
        { "@{文字}", "記録したマクロを実行" },
    },
},
```

## 主なキーマップ

LeaderキーはSpaceです。すべての割り当ては`which-key.nvim`からも確認できます。

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

### LSPとGit

| キー | 動作 |
| --- | --- |
| `gd` / `gD` | 定義・宣言へ移動 |
| `gr` / `gi` | 参照・実装へ移動 |
| `K` | Hoverドキュメント |
| `Space la` | Code Action |
| `Space lr` | Rename |
| `[d` / `]d` | 前・次の診断 |
| `Space cf` | フォーマット |
| `Space gg` | Neogitを開く |
| `Space gc` / `Space gp` | Commit／Push |
| `]c` / `[c` | 次・前のHunk |

### Notebook

| キー | 動作 |
| --- | --- |
| `Space ni` | Moltenを初期化 |
| `Space nr` | 現在のセルを実行 |
| `Space nx` | セルを実行して次へ移動 |
| `]n` / `[n` | 次・前のセルへ移動 |
| `Space no` / `Space nh` | 出力を開く／隠す |

## Notebook機能

Moltenを使う場合、Neovimが利用するPython環境へ依存パッケージを導入します。

```bash
python3 -m pip install --user pynvim jupyter_client ipykernel
python3 -m ipykernel install --user --name python3
```

Windowsでコマンド名が`python`の場合は、`python3`を`python`に読み替えてください。

Windowsネイティブではimage.nvimを無効化し、テキスト出力を利用します。WSL2／Linuxでは、ImageMagickとKitty Graphics Protocol対応ターミナルを検出できた場合だけ画像表示を有効化します。

## 環境変数と個人用コマンド

個人用パスやJupyterカーネル名は、Git管理ファイルを変更せず環境変数で上書きできます。

| 変数 | 用途 | 既定値 |
| --- | --- | --- |
| `NVIM_MEMO_DIR` | メモの保存先 | `~/Desktop/memo` |
| `NVIM_DAILY_LOG_DIR` | 日記の保存先 | `~/Desktop/daily_log` |
| `NVIM_PYTHON_KERNEL` | Moltenのカーネル名 | `python3` |

| コマンド | 動作 |
| --- | --- |
| `:Memo` / `:Smemo` | メモファイルを開く |
| `:Dmemo` / `:Dlog` | 今日のメモ・日記を開く |
| `:P` | テスト用Pythonファイルを開く |
| `:Py` | 現在のPythonファイルをターミナルで実行 |
| `:Ap` | `test.txt`を標準入力としてPythonを実行 |
| `:MemoPush` / `:DailyPush` | 対象ディレクトリを確認後、commitしてpush |

これらは作者のワークフロー向け機能です。不要な場合は`mycommand.lua`と`autocmds.lua`から削除してください。`:MemoPush`と`:DailyPush`は、実行前に確認ダイアログを表示します。

## Herdr

Unix向けの`config.toml`は環境に依存しにくい共通項目だけを持ち、Windows向けの`config.windows.toml`はPowerShell 7を既定シェルに指定します。Herdrを利用しない場合、`herdr`ディレクトリは無視できます。

Linuxで`btop`と`python3`が利用できる場合、`btop-sidebar`プラグインで現在のワークスペース下部にbtopを表示できます。`Ctrl+B`を押して離し、`Shift+B`を押すと開閉できます。開いても元のペインからフォーカスは移動しません。Windowsではこのプラグインは動作しません。

設定変更後はHerdr内のメニュー、または次のコマンドで再読み込みできます。

```bash
herdr server reload-config
```

## カスタマイズ時の注意

- `lazy-lock.json`をGit管理すると、環境間でプラグインのバージョンを揃えられます。
- LSPやフォーマッタの実行ファイルは、この設定をcloneしただけでは導入されません。
- 秘密情報、トークン、秘密鍵、端末固有の絶対パスはcommitしないでください。
- 外部スクリプトやインストールコマンドは、実行前にリンク先と内容を確認してください。
