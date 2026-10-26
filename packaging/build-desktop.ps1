param(
    [ValidateSet('Windows', 'Linux')]
    [string[]]$Targets = @('Windows', 'Linux')
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$projectRoot = Split-Path $PSScriptRoot -Parent
$cache = Join-Path $projectRoot '.runtime\desktop'
$output = Join-Path $projectRoot 'dist'
New-Item -ItemType Directory -Force $cache, $output | Out-Null
$love = Join-Path $projectRoot 'Dino.love'
if (-not (Test-Path -LiteralPath $love)) { throw 'Run build.ps1 to create Dino.love first.' }

function Invoke-Checked([string]$Exe, [string[]]$Arguments) {
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Exe failed with exit code $LASTEXITCODE" }
}
function Get-VerifiedDownload([string]$Url, [string]$Name, [string]$Sha256) {
    $path = Join-Path $cache $Name
    if (-not (Test-Path -LiteralPath $path)) { Invoke-WebRequest $Url -OutFile $path }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $Sha256) {
        throw "Checksum mismatch: $path"
    }
    return $path
}
function Join-BinaryFiles([string[]]$Files, [string]$Destination) {
    $stream = [IO.File]::Create($Destination)
    try {
        foreach ($file in $Files) {
            $inputStream = [IO.File]::OpenRead($file)
            try { $inputStream.CopyTo($stream) } finally { $inputStream.Dispose() }
        }
    } finally { $stream.Dispose() }
}
function Write-Checksum([string]$Path) {
    $hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText($Path + '.sha256', "$hash  $([IO.Path]::GetFileName($Path))`n")
    Write-Host "Ready: $Path"
}

if ($Targets -contains 'Windows') {
    $zip = Get-VerifiedDownload 'https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip' 'love-11.5-win64.zip' 'BA6E56BE2685E53C817749C4A5007F51137136FE5A3AB64920508BABC2E74369'
    $engineRoot = Join-Path $cache 'love-win64'
    Expand-Archive -LiteralPath $zip -DestinationPath $engineRoot -Force
    $engine = Join-Path $engineRoot 'love-11.5-win64'
    $work = Join-Path $cache ('windows-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory $work | Out-Null
    Join-BinaryFiles @((Join-Path $engine 'love.exe'), $love) (Join-Path $work 'Dino.exe')
    Get-ChildItem -LiteralPath $engine -Filter '*.dll' | Copy-Item -Destination $work
    Copy-Item -LiteralPath (Join-Path $engine 'license.txt') -Destination $work
    $payload = $work + '.zip'
    [IO.Compression.ZipFile]::CreateFromDirectory($work, $payload)
    $compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
    if (-not (Test-Path -LiteralPath $compiler)) { throw '.NET Framework 4.x C# compiler is required.' }
    $exe = Join-Path $output 'Dino-Windows-x64.exe'
    Invoke-Checked $compiler @('/nologo', '/target:winexe', '/platform:x64', '/optimize+',
        '/reference:System.IO.Compression.dll', '/reference:System.IO.Compression.FileSystem.dll',
        '/reference:System.Windows.Forms.dll', ('/win32icon:' + (Join-Path $engine 'game.ico')),
        ('/resource:' + $payload + ',Dino.Payload.zip'), ('/out:' + $exe),
        (Join-Path $PSScriptRoot 'Launcher.cs'))
    Write-Checksum $exe
}

if ($Targets -contains 'Linux') {
    # Pseudo files preserve Linux permissions and symlinks without unpacking onto NTFS.
    $appImage = Get-VerifiedDownload 'https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage' 'love-11.5-x86_64.AppImage' '65A673406431EFF7167A15A032BF7A2E4BA50108E091EB7B176465831F9B5E00'
    $toolsPackage = Get-VerifiedDownload 'https://mirror.msys2.org/msys/x86_64/squashfs-tools-4.7.5-1-x86_64.pkg.tar.zst' 'squashfs-tools.pkg.tar.zst' 'E80C0303EB74D95318E3FDBE084403EAD2D7141AEE31C744CA24BB24A0F61FC7'
    $lzoPackage = Get-VerifiedDownload 'https://mirror.msys2.org/msys/x86_64/liblzo2-2.10-3-x86_64.pkg.tar.zst' 'liblzo2.pkg.tar.zst' '5881251A3B73EBF7A6B2491E092BAFBD62A44925D538D69D0776903D26119794'
    $toolsRoot = Join-Path $cache 'squashfs-tools'
    New-Item -ItemType Directory -Force $toolsRoot | Out-Null
    Invoke-Checked 'tar.exe' @('-xf', $toolsPackage, '-C', $toolsRoot)
    Invoke-Checked 'tar.exe' @('-xf', $lzoPackage, '-C', $toolsRoot)
    $git = (Get-Command git -ErrorAction Stop).Source
    $gitRoot = Split-Path (Split-Path $git -Parent) -Parent
    $gitBin = Join-Path $gitRoot 'usr\bin'
    if (-not (Test-Path -LiteralPath (Join-Path $gitBin 'msys-2.0.dll'))) {
        throw 'Git for Windows with its usr/bin MSYS2 runtime is required for the Linux build.'
    }
    $oldPath = $env:PATH
    try {
        $env:PATH = $gitBin + ';' + $oldPath
        $unsquashfs = Join-Path $toolsRoot 'usr\bin\unsquashfs.exe'
        $mksquashfs = Join-Path $toolsRoot 'usr\bin\mksquashfs.exe'
        $imageBytes = [IO.File]::ReadAllBytes($appImage)
        $ascii = [Text.Encoding]::ASCII.GetString($imageBytes)
        $offset = $ascii.IndexOf('hsqs')
        while ($offset -ge 0 -and ([BitConverter]::ToUInt16($imageBytes, $offset + 28) -ne 4 -or
                [BitConverter]::ToUInt16($imageBytes, $offset + 30) -ne 0)) {
            $offset = $ascii.IndexOf('hsqs', $offset + 4)
        }
        if ($offset -lt 0) { throw 'SquashFS 4.0 header not found in the official AppImage.' }
        $work = Join-Path $cache ('linux-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory $work | Out-Null
        $pseudo = Join-Path $work 'love.pseudo'
        Invoke-Checked $unsquashfs @('-no-progress', '-offset', [string]$offset, '-pf', $pseudo, $appImage)
        $bytes = [IO.File]::ReadAllBytes($pseudo)
        $marker = "#`n# START OF DATA - DO NOT MODIFY`n#`n"
        $dataStart = [Text.Encoding]::ASCII.GetString($bytes).IndexOf($marker)
        if ($dataStart -lt 0) { throw 'Invalid SquashFS pseudo file.' }
        $header = [Text.Encoding]::UTF8.GetString($bytes, 0, $dataStart)
        $dataStart += $marker.Length
        $data = [IO.MemoryStream]::new()
        try {
            $data.Write($bytes, $dataStart, $bytes.Length - $dataStart)
            $entries = [Collections.Generic.List[string]]::new()
            foreach ($line in $header.TrimEnd("`n").Split("`n")) { $entries.Add($line) }
            # Replace the original executable with an ELF + ZIP fused game.
            $engineEntry = @($entries | Where-Object { $_ -match '^bin/love R ' })[0].Split(' ')
            $engineSize = [int]$engineEntry[6]
            $engineOffset = [int]$engineEntry[7]
            $fused = [IO.MemoryStream]::new()
            try {
                $fused.Write($bytes, $dataStart + $engineOffset, $engineSize)
                $gameBytes = [IO.File]::ReadAllBytes($love)
                $fused.Write($gameBytes, 0, $gameBytes.Length)
                $newFiles = @{
                    'bin/Dino' = @('755', $fused.ToArray())
                    'AppRun' = @('755', [Text.Encoding]::UTF8.GetBytes([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AppRun')).Replace("`r`n", "`n")))
                    'dino.desktop' = @('644', [Text.Encoding]::UTF8.GetBytes([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'dino.desktop')).Replace("`r`n", "`n")))
                    'dino.svg' = @('644', [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'dino.svg')))
                }
                $entries = [Collections.Generic.List[string]]@($entries | Where-Object {
                    $_ -notmatch '^(bin/love|AppRun|love.desktop|love.svg|\.DirIcon|share/applications/love.desktop) '
                })
                $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
                foreach ($name in @($newFiles.Keys | Sort-Object)) {
                    $mode, $contents = $newFiles[$name]
                    $entries.Add("$name R $timestamp $mode 0 0 $($contents.Length) $($data.Length) 0")
                    $data.Write($contents, 0, $contents.Length)
                }
                $entries.Add(".DirIcon S $timestamp 777 0 0 dino.svg")
                $newPseudo = Join-Path $work 'dino.pseudo'
                $stream = [IO.File]::Create($newPseudo)
                try {
                    $headerBytes = [Text.Encoding]::UTF8.GetBytes(($entries -join "`n") + "`n" + $marker)
                    $stream.Write($headerBytes, 0, $headerBytes.Length)
                    $data.Position = 0
                    $data.CopyTo($stream)
                } finally { $stream.Dispose() }
            } finally { $fused.Dispose() }
        } finally { $data.Dispose() }
        $squashfs = Join-Path $work 'dino.squashfs'
        Invoke-Checked $mksquashfs @('-', $squashfs, '-pf', $newPseudo, '-comp', 'gzip', '-noappend',
            '-no-progress', '-processors', '2', '-all-root', '-no-xattrs')
        # Keep the official AppImage runtime and its original SquashFS offset.
        $result = Join-Path $output 'Dino-Linux-x86_64.AppImage'
        $stream = [IO.File]::Create($result)
        try {
            $stream.Write($imageBytes, 0, $offset)
            $inputStream = [IO.File]::OpenRead($squashfs)
            try { $inputStream.CopyTo($stream) } finally { $inputStream.Dispose() }
        } finally { $stream.Dispose() }
        Invoke-Checked $unsquashfs @('-offset', [string]$offset, '-stat', $result)
        Write-Checksum $result
    } finally { $env:PATH = $oldPath }
}
