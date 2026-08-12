function Read-PCXMonoWavSampleBlock {

    <#
    .SYNOPSIS
        Reads a block of 16-bit mono WAV samples.

    .DESCRIPTION
        Reads a bounded block of samples from a 16-bit mono PCM WAV file
        without loading the entire file into memory. Parses the RIFF/WAV
        structure to locate the data chunk and validates the format.

    .PARAMETER Path
        Path to the WAV file.

    .PARAMETER SampleRate
        Expected sample rate of the WAV file.

    .PARAMETER StartSeconds
        Start position in seconds.

    .PARAMETER DurationSeconds
        Duration to read in seconds.

    .OUTPUTS
        System.Int16[]
    #>

    [CmdletBinding()]
    [OutputType([System.Int16[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path -LiteralPath $_ -PathType Leaf
        })]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$SampleRate,

        [Parameter()]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$StartSeconds = 0,

        [Parameter()]
        [ValidateRange(1, 600)]
        [int]$DurationSeconds = 60

    )

    $fileStream = [System.IO.FileStream]::new(
        $Path,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )

    try {

        # Read RIFF header
        $headerBuffer = [byte[]]::new(12)
        $read = 0
        while ($read -lt 12) {
            $bytes = $fileStream.Read($headerBuffer, $read, 12 - $read)
            if ($bytes -eq 0) { break }
            $read += $bytes
        }

        if ($read -lt 12) {
            throw "WAV file is too small to contain a valid RIFF header: $Path"
        }

        $riffId = [System.Text.Encoding]::ASCII.GetString($headerBuffer, 0, 4)
        $waveId = [System.Text.Encoding]::ASCII.GetString($headerBuffer, 8, 4)

        if ($riffId -ne 'RIFF' -or $waveId -ne 'WAVE') {
            throw "File is not a valid RIFF/WAVE file: $Path"
        }

        # Locate fmt and data chunks
        $fmtChunk = $null
        $dataOffset = 0
        $dataSize = 0

        while ($fileStream.Position -lt $fileStream.Length) {

            $chunkHeader = [byte[]]::new(8)
            $read = 0
            while ($read -lt 8) {
                $bytes = $fileStream.Read($chunkHeader, $read, 8 - $read)
                if ($bytes -eq 0) { break }
                $read += $bytes
            }

            if ($read -lt 8) { break }

            $chunkId = [System.Text.Encoding]::ASCII.GetString($chunkHeader, 0, 4)
            $chunkSize = [BitConverter]::ToUInt32($chunkHeader, 4)

            if ($chunkId -eq 'fmt ') {
                $fmtChunk = [byte[]]::new($chunkSize)
                $read = 0
                while ($read -lt $chunkSize) {
                    $bytes = $fileStream.Read($fmtChunk, $read, $chunkSize - $read)
                    if ($bytes -eq 0) { break }
                    $read += $bytes
                }

                if ($read -lt $chunkSize) {
                    throw "WAV fmt chunk is truncated in: $Path"
                }

                if (($chunkSize % 2) -ne 0) {
                    $fileStream.Position += 1
                }
            }
            elseif ($chunkId -eq 'data') {
                $dataOffset = $fileStream.Position
                $dataSize = $chunkSize
                break
            }
            else {
                if ($chunkSize -gt 0) {
                    $fileStream.Position += $chunkSize
                    if (($chunkSize % 2) -ne 0) {
                        $fileStream.Position += 1
                    }
                }
            }

        }

        if ($null -eq $fmtChunk) {
            throw "WAV file does not contain a fmt chunk: $Path"
        }

        if ($fmtChunk.Length -lt 16) {
            throw "WAV fmt chunk is too small: $Path"
        }

        if ($dataSize -eq 0) {
            throw "WAV file does not contain a data chunk: $Path"
        }

        # Validate fmt
        $audioFormat = [BitConverter]::ToUInt16($fmtChunk, 0)
        $channels = [BitConverter]::ToUInt16($fmtChunk, 2)
        $fileSampleRate = [BitConverter]::ToUInt32($fmtChunk, 4)
        $bitsPerSample = [BitConverter]::ToUInt16($fmtChunk, 14)

        if ($audioFormat -ne 1) {
            throw "WAV file is not PCM (audio format $audioFormat): $Path"
        }

        if ($channels -ne 1) {
            throw "WAV file is not mono (channels $channels): $Path"
        }

        if ($fileSampleRate -ne $SampleRate) {
            throw "WAV sample rate $fileSampleRate does not match expected $SampleRate : $Path"
        }

        if ($bitsPerSample -ne 16) {
            throw "WAV file is not 16-bit (bits per sample $bitsPerSample): $Path"
        }

        # Calculate requested sample block
        $startSample = [long]($StartSeconds * $SampleRate)
        $sampleCount = [long]$DurationSeconds * $SampleRate

        if ($startSample -lt 0 -or $sampleCount -lt 0 -or $sampleCount -gt [int]::MaxValue) {
            throw "Requested sample range is out of bounds for: $Path"
        }

        $dataStart = [long]$dataOffset
        $byteOffset = $dataStart + ($startSample * 2)

        if ($byteOffset -gt ([long]$dataOffset + [long]$dataSize)) {
            return [System.Int16[]]::new(0)
        }

        $maxBytes = [long]$dataSize - ($byteOffset - $dataStart)
        if ($maxBytes -lt 0) { $maxBytes = 0 }

        $requestedBytes = $sampleCount * 2
        if ($requestedBytes -gt [int]::MaxValue) { $requestedBytes = [int]::MaxValue }

        $bytesToRead = [Math]::Min($requestedBytes, $maxBytes)

        if ($bytesToRead -le 0) {
            return [System.Int16[]]::new(0)
        }

        $fileStream.Position = $byteOffset

        $samples = [System.Int16[]]::new([int]($bytesToRead / 2))
        $byteBuffer = [byte[]]::new($bytesToRead)

        $read = 0
        while ($read -lt $bytesToRead) {
            $bytes = $fileStream.Read($byteBuffer, $read, $bytesToRead - $read)
            if ($bytes -eq 0) { break }
            $read += $bytes
        }

        if ($read -lt $bytesToRead) {
            $samples = [System.Int16[]]::new([int]($read / 2))
        }

        [System.Buffer]::BlockCopy($byteBuffer, 0, $samples, 0, $samples.Length * 2)

        return $samples

    }
    finally {
        $fileStream.Dispose()
    }

}
