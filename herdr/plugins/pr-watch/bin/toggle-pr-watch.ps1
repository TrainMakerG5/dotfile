# Herdrの現在のタブでPR Watchペインを開閉します。
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$herdr = if ([string]::IsNullOrWhiteSpace($env:HERDR_BIN_PATH)) { "herdr" } else { $env:HERDR_BIN_PATH }
$targetPane = $env:HERDR_PANE_ID
$workspaceId = $env:HERDR_WORKSPACE_ID
$tabId = $env:HERDR_TAB_ID

if ([string]::IsNullOrWhiteSpace($targetPane) -or
    [string]::IsNullOrWhiteSpace($workspaceId) -or
    [string]::IsNullOrWhiteSpace($tabId)) {
    $current = (& $herdr pane current | ConvertFrom-Json).result.pane
    $targetPane = $current.pane_id
    $workspaceId = $current.workspace_id
    $tabId = $current.tab_id
}

$existingPane = (& $herdr pane list | ConvertFrom-Json).result.panes |
    Where-Object {
        $label = $_.PSObject.Properties["label"]
        $_.workspace_id -eq $workspaceId -and
        $_.tab_id -eq $tabId -and
        $null -ne $label -and
        $label.Value -eq "PR Watch"
    } |
    Select-Object -First 1

if ($null -ne $existingPane) {
    & $herdr pane close $existingPane.pane_id | Out-Null
    exit 0
}

$paneInfo = (& $herdr pane get $targetPane | ConvertFrom-Json).result.pane
$foregroundCwd = $paneInfo.PSObject.Properties["foreground_cwd"]
$paneCwd = $paneInfo.PSObject.Properties["cwd"]
$workingDirectory = if ($null -ne $foregroundCwd -and -not [string]::IsNullOrWhiteSpace($foregroundCwd.Value)) {
    $foregroundCwd.Value
} elseif ($null -ne $paneCwd -and -not [string]::IsNullOrWhiteSpace($paneCwd.Value)) {
    $paneCwd.Value
} else {
    (Get-Location).Path
}

$split = & $herdr pane split $targetPane --direction right --ratio 0.78 --cwd $workingDirectory --no-focus |
    ConvertFrom-Json
$watchPane = $split.result.pane.pane_id
$pluginRoot = $env:HERDR_PLUGIN_ROOT -replace '^\\\\\?\\', ''
$watcher = Join-Path $pluginRoot "bin\pr-watch.py"
$python = if ($null -ne (Get-Command python -ErrorAction SilentlyContinue)) { "python" } else { "py" }

& $herdr pane rename $watchPane "PR Watch" | Out-Null
& $herdr pane run $watchPane $python $watcher --cwd $workingDirectory | Out-Null
