#author: Michael Lange
#Indexes and transcodes to fault-tolerant MP4 Files from Native NDI
#Will NOT overwrite existing files

param(
    [switch]$Init,
    [switch]$help,
    [ValidateSet("default","prores","dnxhr")]
    [string]$Preset = "default",
    [Alias("Files")]
    [string[]]$File,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$InputFiles
)

# Define your ffmpeg argument presets (single definition)
$ffmpegPresets = @{
    "default" = "-n -map_metadata 0 -movflags +faststart -c:v libx264 -preset fast -crf 18 -c:a aac -b:a 384k"
}

# Combine files from both -File parameter and positional arguments
$allFiles = @()
if ($File) {
    $allFiles += $File
}
if ($InputFiles) {
    $allFiles += $InputFiles
}

# Check if help is requested or no files are provided
if ($help -or ($allFiles.Count -eq 0 -and -not $Init)) {
    Write-Host "NDItoMP4.ps1 - Transcode NDI files to fault-tolerant MP4" -ForegroundColor Cyan
    Write-Host "" # blank line
    Write-Host "Parameters and Flags:" -ForegroundColor Yellow
    Write-Host "  -Init         " -NoNewline; Write-Host "Initializes the script: copies it to Public Documents, creates a SendTo shortcut, and adds ffmpeg2 to your PATH." -ForegroundColor Gray
    Write-Host "  -help         " -NoNewline; Write-Host "Shows this help message and exits." -ForegroundColor Gray
    Write-Host "  -Preset       " -NoNewline; Write-Host "Encoding preset: default, prores, or dnxhr (default: default)" -ForegroundColor Gray
    Write-Host "  -File, -Files " -NoNewline; Write-Host "One or more files to transcode (alternative to positional arguments)" -ForegroundColor Gray
    Write-Host "  <files>       " -NoNewline; Write-Host "One or more files to transcode as positional arguments" -ForegroundColor Gray
    Write-Host "" # blank line
    Write-Host "Example Usage:" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File NDItoMP4.ps1 -Init" -ForegroundColor Green
    Write-Host "  powershell -ExecutionPolicy Bypass -File NDItoMP4.ps1 -help" -ForegroundColor Green
    Write-Host "  powershell -ExecutionPolicy Bypass -File NDItoMP4.ps1 -File 'C:\Videos\input1.mov' 'C:\Videos\input2.mov'" -ForegroundColor Green
    Write-Host "  powershell -ExecutionPolicy Bypass -File NDItoMP4.ps1 -Preset prores -Files 'C:\Videos\input1.mov'" -ForegroundColor Green
    Write-Host "  powershell -ExecutionPolicy Bypass -File NDItoMP4.ps1 -Preset prores C:\Videos\input1.mov C:\Videos\input2.mov" -ForegroundColor Green
    Write-Host "" # blank line
    Write-Host "When installed via -Init, you can right-click files and use 'Send To > NDItoMP4'." -ForegroundColor Magenta
    exit
}

if ($Init) {
    # 1. Copy script to Public Documents
    $publicDocs = [Environment]::GetFolderPath('CommonDocuments')
    $targetScript = Join-Path $publicDocs 'NDItoMP4.ps1'
    if ($MyInvocation.MyCommand.Path -ne $targetScript) {
        try {
            Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $targetScript -Force
            Write-Host "Copied script to $targetScript" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to copy script: $_"
            exit 1
        }
    } else {
        Write-Host "Script already in Public Documents." -ForegroundColor Yellow
    }

    # 2. Create shortcut in SendTo folder
    try {
        $sendTo = [Environment]::GetFolderPath('SendTo')
        $shortcutPath = Join-Path $sendTo 'NDItoMP4.lnk'
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetScript`""
        $shortcut.WorkingDirectory = $publicDocs
        $shortcut.Save()
        Write-Host "Created SendTo shortcut at $shortcutPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create SendTo shortcut: $_"
    }

    # 3. Add ffmpeg2 to user PATH if not present
    $ffmpeg2Path = "C:\Program Files (x86)\vMix\streaming"
    $envPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($envPath -notlike "*${ffmpeg2Path}*") {
        try {
            [Environment]::SetEnvironmentVariable('Path', "$envPath;${ffmpeg2Path}", 'User')
            Write-Host "Added $ffmpeg2Path to user PATH. You may need to restart your session." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to add to PATH: $_"
        }
    } else {
        Write-Host "$ffmpeg2Path already in user PATH." -ForegroundColor Yellow
    }
    Write-Host "Initialization complete." -ForegroundColor Cyan
    exit
}

# Validate that files were provided
if ($allFiles.Count -eq 0) {
    Write-Error "No input files provided. Use -help for usage information."
    exit 1
}

# Validate preset
if (-not $ffmpegPresets.ContainsKey($Preset)) {
    Write-Error "Unknown preset '$Preset'. Valid presets: $($ffmpegPresets.Keys -join ', ')"
    exit 1
}

# Check if ffmpeg2 is available
try {
    $null = Get-Command ffmpeg2 -ErrorAction Stop
}
catch {
    Write-Error "ffmpeg2 not found in PATH. Please run with -Init first or ensure ffmpeg2 is installed and in your PATH."
    exit 1
}

$argsString = $ffmpegPresets[$Preset]

foreach ($inPath in $allFiles) {
    # Validate input file exists
    if (-not (Test-Path $inPath)) {
        Write-Warning "File not found: $inPath - skipping"
        continue
    }

    $inFile = Get-Item $inPath
    $outPath = Join-Path $inFile.DirectoryName ("{0}_transcoded.mov" -f $inFile.BaseName)

    # Check if output file already exists
    if (Test-Path $outPath) {
        Write-Warning "Output file already exists: $outPath - skipping (use -n flag prevents overwrite)"
        continue
    }

    Write-Host "Transcoding $($inFile.Name) → $($outPath | Split-Path -Leaf)" -ForegroundColor Cyan

    $cmd = "ffmpeg2 -i `"$inPath`" $argsString `"$outPath`""
    Write-Host "Running: $cmd" -ForegroundColor Yellow
    
    try {
        Invoke-Expression $cmd
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully transcoded: $($inFile.Name)" -ForegroundColor Green
        } else {
            Write-Error "ffmpeg2 failed with exit code $LASTEXITCODE for file: $($inFile.Name)"
        }
    }
    catch {
        Write-Error "Error running ffmpeg2 for file $($inFile.Name): $_"
    }
}

Read-Host -Prompt "Press Enter to exit"