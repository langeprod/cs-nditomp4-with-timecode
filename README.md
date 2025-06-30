# NDItoMP4 PowerShell Script

## Overview

This script batch transcodes NDI or MOV files to fault-tolerant MP4, ProRes, or DNxHD files using ffmpeg2. It is designed for robust, user-friendly operation, with support for drag-and-drop, SendTo shortcut, and flexible command-line usage. The script preserves timecode and metadata, and will not overwrite existing files.

## Features
- Batch transcode multiple files at once
- Choose encoding preset: MP4 (H.264), ProRes, or DNxHD
- Preserves timecode and all metadata
- Will not overwrite existing files
- User-friendly: supports drag-and-drop, SendTo shortcut, and command-line
- Color-coded status and error messages
- Initialization mode to set up SendTo shortcut and PATH

## Usage

### Basic Command
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 <files>
```

### With Preset
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -Preset prores <files>
```

### With -File Parameter
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -File "C:\Videos\input1.mov" "C:\Videos\input2.mov"
```

### Initialization (creates SendTo shortcut and adds ffmpeg2 to PATH)
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -Init
```

### Help
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -help
```

## Parameters
- `-Preset` (optional): Encoding preset. Options: `mp4` (default), `prores`, `dnxhd`.
- `-File` or positional arguments: One or more files to transcode.
- `-Init`: Initializes the script (copies to Public Documents, creates SendTo shortcut, adds ffmpeg2 to PATH).
- `-help`: Shows help message and exits.

## Output
- Output files are written to the same directory as the input, with `_transcoded.mov` appended to the filename.
- If the output file already exists, it will be skipped.

## Requirements
- Windows with PowerShell
- `ffmpeg2` must be installed and available in your PATH (the script can add it for you with `-Init`)

## Example
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -Preset mp4 "C:\Videos\input1.mov" "C:\Videos\input2.mov"
```

## Notes
- The script will skip files that do not exist or if the output file already exists.
- All transcoding is done using ffmpeg2 with the selected preset.
- Timecode and all metadata are preserved in the output files.

---

© Michael Lange. See LICENSE for details.
