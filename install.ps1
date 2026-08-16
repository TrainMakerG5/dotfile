[CmdletBinding()]
param(
    [switch]$Check
)

# Windows向けに、このリポジトリの設定を安全に登録します。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$script:Errors = 0

function Write-Info {
    param([string]$Message)

    Write-Host "  [OK] $Message"
}

function Write-WarningMessage {
    param([string]$Message)

    Write-Host "  [--] $Message"
}

function Write-Failure {
    param([string]$Message)

    Write-Error $Message -ErrorAction Continue
    $script:Errors += 1
}

function Test-SamePath {
    param(
        [string]$First,
        [string]$Second
    )

    $firstPath = [IO.Path]::GetFullPath($First).TrimEnd(
        [IO.Path]::DirectorySeparatorChar,
        [IO.Path]::AltDirectorySeparatorChar
    )
    $secondPath = [IO.Path]::GetFullPath($Second).TrimEnd(
        [IO.Path]::DirectorySeparatorChar,
        [IO.Path]::AltDirectorySeparatorChar
    )
    return $firstPath.Equals($secondPath, [StringComparison]::OrdinalIgnoreCase)
}

function Set-NeovimJunction {
    param(
        [string]$Source,
        [string]$Target
    )

    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        $linkTarget = @($item.Target)[0]
        if ($null -ne $linkTarget -and (Test-SamePath -First $linkTarget -Second $Source)) {
            Write-Info "Neovim設定は登録済みです。"
            return
        }

        Write-Failure "$Target が既にあります。バックアップまたは削除してから再実行してください。"
        return
    }

    if ($Check) {
        Write-Failure "Neovim設定は未登録です。"
        return
    }

    $parent = Split-Path -Parent $Target
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
    Write-Info "Neovim設定をジャンクションとして登録しました。"
}

function Set-HerdrConfig {
    param([string]$ConfigPath)

    $currentPath = [Environment]::GetEnvironmentVariable("HERDR_CONFIG_PATH", "User")
    if (-not [string]::IsNullOrWhiteSpace($currentPath)) {
        if (Test-SamePath -First $currentPath -Second $ConfigPath) {
            Write-Info "HERDR_CONFIG_PATHは設定済みです。"
            return
        }

        Write-Failure "HERDR_CONFIG_PATHには別のパスが設定されています: $currentPath"
        return
    }

    if ($Check) {
        Write-Failure "HERDR_CONFIG_PATHは未設定です。"
        return
    }

    [Environment]::SetEnvironmentVariable("HERDR_CONFIG_PATH", $ConfigPath, "User")
    $env:HERDR_CONFIG_PATH = $ConfigPath
    Write-Info "HERDR_CONFIG_PATHをユーザー環境変数へ登録しました。"
}

function Test-CommandAvailable {
    param(
        [string]$Name,
        [string]$Requirement
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        Write-Info "${Name}: $($command.Source)"
    } else {
        Write-WarningMessage "$Name がありません（$Requirement）。"
    }
}

$repoDirectory = $PSScriptRoot
$neovimSource = Join-Path $repoDirectory "nvim"
$neovimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$herdrConfig = Join-Path $repoDirectory "herdr\config.windows.toml"

Write-Host "dotfile setup for Windows"
Write-Host "Repository: $repoDirectory"

Write-Host "`n設定"
Set-NeovimJunction -Source $neovimSource -Target $neovimTarget
Set-HerdrConfig -ConfigPath $herdrConfig

Write-Host "`n依存コマンド"
Test-CommandAvailable -Name "git" -Requirement "Neovimプラグインの取得に必須です"
Test-CommandAvailable -Name "nvim" -Requirement "Neovim設定を利用する場合に必須です"
Test-CommandAvailable -Name "pwsh" -Requirement "Windows用Herdr設定の既定シェルです"
Test-CommandAvailable -Name "rg" -Requirement "Telescopeの全文検索に推奨です"
Test-CommandAvailable -Name "fd" -Requirement "Telescopeのファイル検索に推奨です"

Write-Host ""
if ($script:Errors -ne 0) {
    Write-Error "$($script:Errors) 件の要確認項目があります。" -ErrorAction Continue
    exit 1
}

Write-Host "セットアップ状態に問題はありません。"
