$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$destination = Join-Path $PSScriptRoot 'Dino.love'
$temporary = Join-Path $PSScriptRoot 'Dino.love.tmp'
$modules = @('main.lua', 'conf.lua', 'game.lua', 'progress.lua', 'skins.lua', 'skin-search.lua',
    'dino.lua', 'halloween.lua', 'ocean.lua', 'pirate.lua', 'robot.lua', 'sponge.lua', 'candy.lua',
    'fruit.lua', 'heroes.lua', 'i18n.lua')
$archive = [System.IO.Compression.ZipFile]::Open($temporary, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($module in $modules) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,
            (Join-Path $PSScriptRoot $module), $module) | Out-Null
    }
    foreach ($font in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'assets\fonts') -File) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,
            $font.FullName, ('assets/fonts/' + $font.Name)) | Out-Null
    }
} finally { $archive.Dispose() }
Move-Item -LiteralPath $temporary -Destination $destination -Force
Write-Host "LOVE ready: $destination"
