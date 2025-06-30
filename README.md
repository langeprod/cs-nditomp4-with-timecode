# NDItoMP4 Transcode Native NDI recordings to MP4 with timecode
## A Cloudstudiomasters Utility

[image](https://www.cloudstudiomasters.com/content/images/2025/06/CSD_Logo-1.png)

## Overview

This script batch transcodes native NDI and MOV files to fault-tolerant MP4 files with timecode. 
It is designed for robust, user-friendly operation, with support for drag-and-drop, SendTo shortcut, and flexible command-line usage. The script preserves timecode and metadata, and will not overwrite existing files.

## Features
- Batch transcode multiple files at once using Windows > Sendto Menu
- Preserves timecode and all metadata
- Will not overwrite existing files
- User-friendly: supports drag-and-drop, SendTo shortcut, and command-line
- Initialization mode to set up SendTo shortcut and PATH

## Requirements
- Windows with PowerShell
- `ffmpeg2` must be installed and available in your PATH (the script can add it for you with `-Init`)

This script utilizes the ffmpeg build that is installed with vMix. If you do not have vMix installed to the default location, this script will not work.
The vMix ffmpeg build has the ability to decode NDI native recordings, which is why it is used.

## Setup 

### Initialization (creates SendTo shortcut and adds ffmpeg2 to PATH)
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -Init
```

## Usage

### Basic Command
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 <files>
```

### With -File Parameters
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -File "C:\Videos\input1.mov" "C:\Videos\input2.mov"
```

### Help
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -help
```

## Parameters
- `-File` or positional arguments: One or more files to transcode.
- `-Init`: Initializes the script (copies to Public Documents, creates SendTo shortcut, adds ffmpeg2 to PATH).
- `-help`: Shows help message and exits.

## Output
- Output files are written to the same directory as the input, with `_transcoded.mov` appended to the filename.
- If the output file already exists, it will be skipped.

## Example
```powershell
powershell -ExecutionPolicy Bypass -File NDItoMp4v2.ps1 -Preset mp4 "C:\Videos\input1.mov" "C:\Videos\input2.mov"
```

## Notes
- The script will skip files that do not exist or if the output file already exists.
- All transcoding is done using ffmpeg2 with the selected preset.
- Timecode and all metadata are preserved in the output files.

---

© Cloudstudiomasters. See LICENSE for details.
