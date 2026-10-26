$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = Split-Path $PSScriptRoot -Parent
function Assert-Bytes([byte[]]$Actual, [byte[]]$Expected, [string]$Name) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        if ($Actual.Length -ne $Expected.Length -or
            [Convert]::ToBase64String($sha.ComputeHash($Actual)) -cne
            [Convert]::ToBase64String($sha.ComputeHash($Expected))) { throw "Content mismatch: $Name" }
    } finally { $sha.Dispose() }
}
function Read-ZipEntry($Archive, [string]$Name) {
    $entry = $Archive.GetEntry($Name)
    if (-not $entry) { throw "Missing ZIP entry: $Name" }
    $inputStream = $entry.Open()
    $memory = [IO.MemoryStream]::new()
    try { $inputStream.CopyTo($memory); return ,$memory.ToArray() }
    finally { $inputStream.Dispose(); $memory.Dispose() }
}
function Assert-X64([byte[]]$Bytes, [string]$Name) {
    $pe = [BitConverter]::ToInt32($Bytes, 60)
    if ([BitConverter]::ToUInt32($Bytes, $pe) -ne 0x4550 -or
        [BitConverter]::ToUInt16($Bytes, $pe + 4) -ne 0x8664) { throw "Not Windows x64: $Name" }
}
$modules = @('main.lua','conf.lua','game.lua','progress.lua','skins.lua','skin-search.lua',
    'dino.lua','halloween.lua','ocean.lua','pirate.lua','robot.lua','sponge.lua','candy.lua',
    'fruit.lua','heroes.lua','i18n.lua')
$names = @($modules) + @(Get-ChildItem -LiteralPath (Join-Path $root 'assets\fonts') -File |
    ForEach-Object { 'assets/fonts/' + $_.Name })
foreach ($package in @(@('Dino.love',''), @('android/dist/Dino-Android.apk','assets/'))) {
    $zip = [IO.Compression.ZipFile]::OpenRead((Join-Path $root $package[0]))
    try {
        foreach ($name in $names) {
            Assert-Bytes (Read-ZipEntry $zip ($package[1] + $name)) ([IO.File]::ReadAllBytes((Join-Path $root $name))) $name
        }
    } finally { $zip.Dispose() }
    Write-Host "$($package[0]): all game modules, fonts and font licenses match sources"
}
$game = [IO.File]::ReadAllBytes((Join-Path $root 'Dino.love'))
$exe = Join-Path $root 'dist\Dino-Windows-x64.exe'
$exeBytes = [IO.File]::ReadAllBytes($exe)
Assert-X64 $exeBytes $exe
$assembly = [Reflection.Assembly]::Load($exeBytes)
$resource = $assembly.GetManifestResourceStream('Dino.Payload.zip')
$payload = [IO.Compression.ZipArchive]::new($resource, [IO.Compression.ZipArchiveMode]::Read)
try {
    $fused = Read-ZipEntry $payload 'Dino.exe'
    Assert-X64 $fused 'Dino.exe'
    $tail = [byte[]]::new($game.Length)
    [Buffer]::BlockCopy($fused, $fused.Length - $tail.Length, $tail, 0, $tail.Length)
    Assert-Bytes $tail $game 'Windows fused game'
    $engine = Join-Path $root '.runtime\desktop\love-win64\love-11.5-win64'
    foreach ($file in Get-ChildItem -LiteralPath $engine -File | Where-Object { $_.Extension -eq '.dll' -or $_.Name -eq 'license.txt' }) {
        $contents = Read-ZipEntry $payload $file.Name
        Assert-Bytes $contents ([IO.File]::ReadAllBytes($file.FullName)) $file.Name
        if ($file.Extension -eq '.dll') { Assert-X64 $contents $file.Name }
    }
} finally { $payload.Dispose(); $resource.Dispose() }
Write-Host 'Windows: x64 launcher, fused game, every runtime DLL and engine license verified'

$git = (Get-Command git -ErrorAction Stop).Source
$gitBin = Join-Path (Split-Path (Split-Path $git -Parent) -Parent) 'usr\bin'
$oldPath = $env:PATH
try {
    $env:PATH = $gitBin + ';' + $oldPath
    $appImage = Join-Path $root 'dist\Dino-Linux-x86_64.AppImage'
    $bytes = [IO.File]::ReadAllBytes($appImage)
    if ($bytes[0] -ne 127 -or [Text.Encoding]::ASCII.GetString($bytes, 1, 3) -ne 'ELF' -or
        [BitConverter]::ToUInt16($bytes, 18) -ne 62 -or $bytes[8] -ne 65 -or $bytes[9] -ne 73 -or $bytes[10] -ne 2) {
        throw 'Not a type 2 x86_64 AppImage'
    }
    $offset = 193728 # Official LÖVE 11.5 AppImage, pinned by SHA-256 in build-desktop.ps1.
    $prefix = [byte[]]::new($offset)
    [Buffer]::BlockCopy($bytes, 0, $prefix, 0, $offset)
    $official = [IO.File]::ReadAllBytes((Join-Path $root '.runtime\desktop\love-11.5-x86_64.AppImage'))
    $expected = [byte[]]::new($offset)
    [Buffer]::BlockCopy($official, 0, $expected, 0, $offset)
    Assert-Bytes $prefix $expected 'Official AppImage runtime'
    $pseudo = Join-Path $root ('.runtime\desktop\verify-' + [guid]::NewGuid().ToString('N') + '.pseudo')
    & (Join-Path $root '.runtime\desktop\squashfs-tools\usr\bin\unsquashfs.exe') -no-progress -offset $offset -pf $pseudo $appImage
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the generated AppImage' }
    $bytes = [IO.File]::ReadAllBytes($pseudo)
    $marker = "#`n# START OF DATA - DO NOT MODIFY`n#`n"
    $headerEnd = [Text.Encoding]::ASCII.GetString($bytes).IndexOf($marker)
    if ($headerEnd -lt 0) { throw 'Invalid pseudo file' }
    $header = [Text.Encoding]::UTF8.GetString($bytes, 0, $headerEnd)
    $dataStart = $headerEnd + $marker.Length
    foreach ($name in @('bin/Dino', 'AppRun', 'dino.desktop', 'dino.svg', 'license.txt')) {
        $line = @($header.Split("`n") | Where-Object { $_.StartsWith($name + ' R ') })
        if ($line.Count -ne 1) { throw "Missing AppImage entry: $name" }
        $fields = $line[0].Split(' ')
        $contents = [byte[]]::new([int]$fields[6])
        [Buffer]::BlockCopy($bytes, $dataStart + [int]$fields[7], $contents, 0, $contents.Length)
        if ($name -eq 'bin/Dino') {
            if ($fields[3] -ne '755' -or $contents[0] -ne 127 -or $contents[4] -ne 2 -or
                [BitConverter]::ToUInt16($contents, 18) -ne 62) { throw 'Invalid fused Linux x86_64 executable' }
            $tail = [byte[]]::new($game.Length)
            [Buffer]::BlockCopy($contents, $contents.Length - $tail.Length, $tail, 0, $tail.Length)
            Assert-Bytes $tail $game 'Linux fused game'
        } elseif ($name -eq 'AppRun' -or $name -eq 'dino.desktop') {
            $expected = [Text.Encoding]::UTF8.GetBytes([IO.File]::ReadAllText((Join-Path $PSScriptRoot $name)).Replace("`r`n", "`n"))
            Assert-Bytes $contents $expected $name
            if ($name -eq 'AppRun' -and $fields[3] -ne '755') { throw 'AppRun is not executable' }
        } elseif ($name -eq 'license.txt') {
            Assert-Bytes $contents ([IO.File]::ReadAllBytes((Join-Path $root 'android\LICENSE-LOVE.txt'))) 'Linux engine license'
        } else { Assert-Bytes $contents ([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot $name))) $name }
    }
    if ($header -notmatch '(?m)^\.DirIcon S \d+ 777 0 0 dino.svg$') { throw 'Missing AppImage icon symlink' }
    Write-Host 'Linux: official runtime, SquashFS contents, x86_64 fused game, permissions, icon symlink and engine license verified'
} finally { $env:PATH = $oldPath }
foreach ($relative in @('dist\Dino-Windows-x64.exe', 'dist\Dino-Linux-x86_64.AppImage', 'android\dist\Dino-Android.apk')) {
    $path = Join-Path $root $relative
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    $recorded = (Get-Content -LiteralPath ($path + '.sha256') -Raw).Split(' ')[0]
    if ($hash -cne $recorded) { throw "Checksum mismatch: $relative" }
}
Write-Host 'All three distribution checksums match'
