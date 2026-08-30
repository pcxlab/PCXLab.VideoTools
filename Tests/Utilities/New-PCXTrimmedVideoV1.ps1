function New-PCXTrimmedVideo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [ValidateRange(1, 600)]
        [int]$Minutes = 5,

        [Parameter()]
        [string]$StartAt = "00:00:00",

        [Parameter()]
        [string]$FFmpeg = $ffmpeg
    )

    if (-not (Test-Path $FFmpeg)) {
        throw "FFmpeg not found: $FFmpeg"
    }

    if (-not (Test-Path $Path)) {
        throw "Path not found: $Path"
    }

    $duration = "00:{0:D2}:00" -f $Minutes

    if (Test-Path $Path -PathType Leaf) {
        $files = @(Get-Item $Path)
    }
    else {
        $files = Get-ChildItem $Path -File -Filter *.mp4 |
            Where-Object {
                $_.BaseName -notmatch "_\d+min$"
            }
    }

    foreach ($file in $files) {

        #
        # Output file name
        #

        if ($StartAt -eq "00:00:00") {
            $suffix = "_${Minutes}min"
        }
        else {
            $start = $StartAt.Replace(":", "-")
            $suffix = "_${Minutes}min_From_$start"
        }

        $outputFile = Join-Path $file.DirectoryName (
            "{0}{1}{2}" -f
            $file.BaseName,
            $suffix,
            $file.Extension
        )

        Write-Host "Creating $([IO.Path]::GetFileName($outputFile))"
        Write-Host "  Start : $StartAt"
        Write-Host "  Length: $Minutes minute(s)"

        & $FFmpeg `
            -y `
            -ss $StartAt `
            -i $file.FullName `
            -t $duration `
            -c copy `
            $outputFile

        if ($LASTEXITCODE -ne 0) {
            throw "FFmpeg failed for '$($file.FullName)'."
        }
    }
}