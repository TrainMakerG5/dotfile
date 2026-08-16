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

function Set-HerdrConfigLink {
    param(
        [string]$Source,
        [string]$Target
    )

    $legacyPath = [Environment]::GetEnvironmentVariable("HERDR_CONFIG_PATH", "User")
    if (-not [string]::IsNullOrWhiteSpace($legacyPath) -and
        -not (Test-SamePath -First $legacyPath -Second $Source)) {
        Write-Failure "HERDR_CONFIG_PATHには別のパスが設定されています: $legacyPath"
        return
    }

    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        $linkTarget = @($item.Target)[0]
        if ($null -eq $linkTarget -or -not (Test-SamePath -First $linkTarget -Second $Source)) {
            Write-Failure "$Target が既にあります。バックアップまたは削除してから再実行してください。"
            return
        }

        Write-Info "Herdr設定はシンボリックリンクとして登録済みです。"
    } elseif ($Check) {
        Write-Failure "Herdr設定のシンボリックリンクは未登録です。"
        return
    } else {
        $parent = Split-Path -Parent $Target
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
        Write-Info "Herdr設定をシンボリックリンクとして登録しました。"
    }

    if (-not [string]::IsNullOrWhiteSpace($legacyPath)) {
        if ($Check) {
            Write-WarningMessage "旧HERDR_CONFIG_PATHも同じ設定を指しています。通常実行で解除できます。"
            return
        }

        [Environment]::SetEnvironmentVariable("HERDR_CONFIG_PATH", $null, "User")
        Remove-Item Env:HERDR_CONFIG_PATH -ErrorAction SilentlyContinue
        Write-Info "旧HERDR_CONFIG_PATHを解除しました。"
    }
}

function Test-CommandAvailable {
    param(
        [string]$Name,
        [string]$Requirement
    )

    $currentPath = $env:Path
    try {
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = [Environment]::ExpandEnvironmentVariables("$machinePath;$userPath")
        $command = Get-Command $Name -ErrorAction SilentlyContinue
    } finally {
        $env:Path = $currentPath
    }

    if ($null -ne $command) {
        Write-Info "${Name}: $($command.Source)"
    } else {
        Write-WarningMessage "$Name がありません（$Requirement）。"
    }
}

$repoDirectory = $PSScriptRoot
$neovimSource = Join-Path $repoDirectory "nvim"
$neovimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$herdrSource = Join-Path $repoDirectory "herdr\config.windows.toml"
$herdrTarget = Join-Path $env:APPDATA "herdr\config.toml"

Write-Host "dotfile setup for Windows"
Write-Host "Repository: $repoDirectory"

Write-Host "`n設定"
Set-NeovimJunction -Source $neovimSource -Target $neovimTarget
Set-HerdrConfigLink -Source $herdrSource -Target $herdrTarget

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
