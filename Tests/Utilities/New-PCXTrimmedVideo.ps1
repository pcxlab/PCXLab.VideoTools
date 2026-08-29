function New-PCXTrimmedVideo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [int]$Minutes = 5,

        [string]$FFmpeg = $ffmpeg
    )

    if (-not (Test-Path $FFmpeg)) {
        throw "FFmpeg not found: $FFmpeg"
    }

    $duration = "00:{0:D2}:00" -f $Minutes

    if (Test-Path $Path -PathType Leaf) {
        $files = Get-Item $Path
    }
    elseif (Test-Path $Path -PathType Container) {
        $files = Get-ChildItem $Path -File -Filter *.mp4 |
            Where-Object { $_.BaseName -notmatch "_\d+min$" }
    }
    else {
        throw "Path not found: $Path"
    }

    foreach ($file in $files) {

        $outputFile = Join-Path $file.DirectoryName (
            "{0}_{1}min{2}" -f $file.BaseName, $Minutes, $file.Extension
        )

        Write-Host "Cutting $($file.Name)..."

        & $FFmpeg `
            -y `
            -i $file.FullName `
            -t $duration `
            -c copy `
            $outputFile

        if ($LASTEXITCODE -ne 0) {
            throw "FFmpeg failed for '$($file.FullName)'."
        }
    }
}