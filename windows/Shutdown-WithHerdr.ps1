[CmdletBinding()]
param(
    [switch]$Force
)

# 実行中のHerdrセッションを正常停止してからWindowsをシャットダウンします。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $Force) {
    $answer = Read-Host "Herdrを停止してPCをシャットダウンします。続行しますか？ [y/N]"
    if ($answer -notmatch "^(y|yes)$") {
        Write-Host "キャンセルしました。"
        exit 0
    }
}

$herdr = Get-Command herdr -ErrorAction SilentlyContinue
if ($null -ne $herdr) {
    try {
        $sessionJson = & $herdr.Source session list --json 2>$null
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($sessionJson)) {
            $sessions = ($sessionJson | ConvertFrom-Json).sessions
            foreach ($session in $sessions) {
                if ($session.running) {
                    Write-Host "Herdrセッションを停止しています: $($session.name)"
                    & $herdr.Source session stop $session.name --json | Out-Null
                    if ($LASTEXITCODE -ne 0) {
                        throw "Herdrセッション $($session.name) を停止できませんでした。"
                    }
                }
            }
        }
    } catch {
        Write-Error "Herdrの停止中にエラーが発生したため、シャットダウンを中止しました: $_"
        exit 1
    }
}

Start-Process -FilePath "$env:SystemRoot\System32\shutdown.exe" -ArgumentList "/s", "/t", "0"
