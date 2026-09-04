[CmdletBinding()]
param(
    [switch]$Check
)

# デスクトップへHerdr終了付きシャットダウンのショートカットを登録します。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$shutdownScript = Join-Path $PSScriptRoot "Shutdown-WithHerdr.ps1"
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Herdrを終了してシャットダウン.lnk"
$pwsh = (Get-Command pwsh -ErrorAction Stop).Source
$expectedArguments = "-NoLogo -NoProfile -File `"$shutdownScript`" -Force"

if (Test-Path -LiteralPath $shortcutPath) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    if ($shortcut.TargetPath -eq $pwsh -and $shortcut.Arguments -eq $expectedArguments) {
        Write-Host "ショートカットは登録済みです: $shortcutPath"
        exit 0
    }

    throw "$shortcutPath には別のショートカットがあります。"
}

if ($Check) {
    Write-Error "シャットダウン用ショートカットは未登録です: $shortcutPath"
    exit 1
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $pwsh
$shortcut.Arguments = $expectedArguments
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,27"
$shortcut.Description = "Herdrを正常停止してからWindowsをシャットダウンします。"
$shortcut.Save()

Write-Host "ショートカットを登録しました: $shortcutPath"
