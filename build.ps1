param(
    [ValidateSet('Windows', 'Android', 'Linux')]
    [string[]]$Targets = @('Windows', 'Android', 'Linux'),
    [string]$SdkRoot = $env:ANDROID_HOME
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'build-love.ps1')
$desktopTargets = @($Targets | Where-Object { $_ -ne 'Android' })
if ($desktopTargets.Count) {
    & (Join-Path $PSScriptRoot 'packaging\build-desktop.ps1') -Targets $desktopTargets
}
if ($Targets -contains 'Android') {
    & (Join-Path $PSScriptRoot 'android\build.ps1') -SdkRoot $SdkRoot
}
