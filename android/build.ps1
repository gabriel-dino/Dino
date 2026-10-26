param(
    [string]$SdkRoot = $env:ANDROID_HOME
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$cache = Join-Path $projectRoot '.runtime\android'
$output = Join-Path $PSScriptRoot 'dist'
New-Item -ItemType Directory -Force $cache, $output | Out-Null
if (-not $SdkRoot) { $SdkRoot = $env:ANDROID_SDK_ROOT }
if (-not $SdkRoot) { $SdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$buildTools = Get-ChildItem (Join-Path $SdkRoot 'build-tools') -Directory |
    Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
    Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1
if (-not $buildTools) { throw 'Android SDK build-tools is required. Set ANDROID_HOME or use -SdkRoot.' }
$java = (Get-Command java -ErrorAction Stop).Source
$keytool = Join-Path (Split-Path $java) 'keytool.exe'
$zipalign = Join-Path $buildTools.FullName 'zipalign.exe'
$aapt = Join-Path $buildTools.FullName 'aapt.exe'
$signer = Join-Path $buildTools.FullName 'lib\apksigner.jar'
foreach ($tool in @($keytool, $zipalign, $aapt, $signer)) {
    if (-not (Test-Path -LiteralPath $tool)) { throw "Required tool missing: $tool" }
}
function Invoke-Checked([string]$Exe, [string[]]$Arguments) {
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Exe failed with exit code $LASTEXITCODE" }
}
function Get-VerifiedDownload([string]$Url, [string]$Path, [string]$Sha256) {
    if (-not (Test-Path -LiteralPath $Path)) { Invoke-WebRequest $Url -OutFile $Path }
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Sha256) {
        throw "Checksum mismatch: $Path. Remove the cached file and retry."
    }
}
$engine = Join-Path $cache 'love-11.5a-embed.apk'
$apktool = Join-Path $cache 'apktool-3.0.3.jar'
Get-VerifiedDownload 'https://github.com/love2d/love-android/releases/download/11.5a/love-11.5-android-embed-norecording.apk' $engine 'DCF71C1B54C5B5A09598EF1E6CF4852CED5E5E612DE3D0F30CFDD39B5014E889'
Get-VerifiedDownload 'https://github.com/iBotPeaches/Apktool/releases/download/v3.0.3/apktool_3.0.3.jar' $apktool 'DBF930B076C6B9BE08D57C449CACEFC3BDD6B71EBD59B3066FC0E1F5B14F9423'
$work = Join-Path $cache ('build-' + [guid]::NewGuid().ToString('N'))
$framework = Join-Path $cache 'framework'
Invoke-Checked -Exe $java -Arguments @('-jar', $apktool, 'd', $engine, '-o', $work, '-p', $framework)

# Keep the engine's Java namespace intact: JNI refers to these class names.
# Only the application ID, provider authority and app-specific permission change.
$manifestPath = Join-Path $work 'AndroidManifest.xml'
[xml]$manifest = Get-Content -LiteralPath $manifestPath -Raw
$androidNs = 'http://schemas.android.com/apk/res/android'
$package = 'ro.dinodesertrun.game'
$manifest.manifest.SetAttribute('package', $package)
foreach ($permission in @($manifest.manifest.SelectNodes('uses-permission'))) {
    $name = $permission.GetAttribute('name', $androidNs)
    if ($name -eq 'org.love2d.android.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION') {
        $permission.SetAttribute('name', $androidNs, "$package.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION") | Out-Null
    } else { $manifest.manifest.RemoveChild($permission) | Out-Null }
}
$manifest.manifest.permission.SetAttribute('name', $androidNs, "$package.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION") | Out-Null
$app = $manifest.manifest.application
$app.SetAttribute('label', $androidNs, 'DINO - Desert Run') | Out-Null
$app.SetAttribute('usesCleartextTraffic', $androidNs, 'false') | Out-Null
$app.SetAttribute('isGame', $androidNs, 'true') | Out-Null
$activity = $app.activity
$activity.SetAttribute('label', $androidNs, 'DINO - Desert Run') | Out-Null
$activity.SetAttribute('screenOrientation', $androidNs, 'sensorLandscape') | Out-Null
$app.provider.SetAttribute('authorities', $androidNs, "$package.androidx-startup") | Out-Null
$manifest.Save($manifestPath)
$configPath = Join-Path $work 'apktool.yml'
$config = Get-Content -LiteralPath $configPath -Raw
$config = $config -replace 'versionCode: 32', 'versionCode: 3' -replace 'versionName: 11\.5a', 'versionName: 1.2.0'
Set-Content -LiteralPath $configPath -Value $config -Encoding utf8

# Draw the same Classic dino silhouette as dino.lua, without external artwork.
Add-Type -AssemblyName System.Drawing
foreach ($iconPath in Get-ChildItem (Join-Path $work 'res') -Recurse -Filter love.png) {
    $original = [System.Drawing.Image]::FromFile($iconPath.FullName)
    $size = $original.Width
    $original.Dispose()
    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::FromArgb(245, 240, 222))
    $graphics.ScaleTransform($size / 100.0, $size / 100.0)
    $ink = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(56, 97, 71))
    $paper = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(245, 240, 222))
    foreach ($rect in @(@(48,17,32,27), @(43,38,25,27), @(30,48,29,23), @(61,50,14,5), @(70,50,5,10), @(36,68,7,15), @(52,66,7,10), @(36,79,14,4), @(52,72,14,4), @(16,88,68,2))) {
        $graphics.FillRectangle($ink, [single]$rect[0], [single]$rect[1], [single]$rect[2], [single]$rect[3])
    }
    $tail = [System.Drawing.PointF[]]@([System.Drawing.PointF]::new(32,52), [System.Drawing.PointF]::new(13,38), [System.Drawing.PointF]::new(17,60), [System.Drawing.PointF]::new(36,68))
    $graphics.FillPolygon($ink, $tail)
    $graphics.FillRectangle($paper, 69, 24, 5, 5)
    $graphics.FillRectangle($paper, 65, 39, 15, 3)
    $bitmap.Save($iconPath.FullName, [System.Drawing.Imaging.ImageFormat]::Png)
    $paper.Dispose(); $ink.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
}
$gameFiles = @('main.lua', 'conf.lua', 'game.lua', 'progress.lua', 'skins.lua', 'skin-search.lua',
    'dino.lua', 'halloween.lua', 'ocean.lua', 'pirate.lua', 'robot.lua', 'sponge.lua', 'candy.lua',
    'fruit.lua', 'heroes.lua', 'i18n.lua')
foreach ($file in $gameFiles) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $file) -Destination (Join-Path $work "assets\$file")
}
# The APK assets directory is LÖVE's root; keep the game's assets/ prefix.
New-Item -ItemType Directory -Force (Join-Path $work 'assets\assets') | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot 'assets\fonts') -Destination (Join-Path $work 'assets\assets\fonts') -Recurse
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LICENSE-LOVE.txt') -Destination (Join-Path $work 'assets\LICENSE-LOVE.txt')
$unsigned = Join-Path $work 'dino-unsigned.apk'
$aligned = Join-Path $work 'dino-aligned.apk'
Invoke-Checked -Exe $java -Arguments @('-jar', $apktool, 'b', $work, '-o', $unsigned, '-p', $framework)
Invoke-Checked -Exe $zipalign -Arguments @('-f', '-p', '4', $unsigned, $aligned)

# Preserve this local key for installable updates over the same application.
$key = Join-Path $cache 'dino-signing.jks'
$keyPassword = Join-Path $cache 'dino-signing.password'
if (-not (Test-Path -LiteralPath $key)) {
    [IO.File]::WriteAllText($keyPassword, [guid]::NewGuid().ToString('N'))
    Invoke-Checked -Exe $keytool -Arguments @('-genkeypair', '-keystore', $key, '-storetype', 'JKS',
        '-storepass:file', $keyPassword, '-keypass:file', $keyPassword, '-alias', 'dino',
        '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000', '-dname', 'CN=DINO Desert Run')
}
if (-not (Test-Path -LiteralPath $keyPassword)) { throw 'Signing password file is missing. Restore it with the original keystore.' }
$apk = Join-Path $output 'Dino-Android.apk'
Invoke-Checked -Exe $java -Arguments @('-jar', $signer, 'sign', '--ks', $key, '--ks-key-alias', 'dino',
    '--ks-pass', "file:$keyPassword", '--out', $apk, $aligned)
Invoke-Checked -Exe $zipalign -Arguments @('-c', '-p', '4', $apk)
Invoke-Checked -Exe $java -Arguments @('-jar', $signer, 'verify', '--verbose', '--print-certs', $apk)
Invoke-Checked -Exe $aapt -Arguments @('dump', 'badging', $apk)
$hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $output 'Dino-Android.apk.sha256'), "$hash  Dino-Android.apk`n")
Write-Host "APK ready: $apk"
