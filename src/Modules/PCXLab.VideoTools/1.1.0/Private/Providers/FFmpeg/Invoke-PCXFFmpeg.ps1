function Invoke-PCXFFmpeg {

    <#
    .SYNOPSIS
        Invokes FFmpeg and returns its diagnostic output.

    .DESCRIPTION
        Runs FFmpeg with the supplied arguments, captures diagnostic output
        from standard error, and throws when FFmpeg returns a non-zero exit
        code.

    .PARAMETER ArgumentList
        Arguments to pass to FFmpeg.

    .OUTPUTS
        System.String

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ArgumentList

    )

    $ffmpegPath = Get-PCXToolPath -Tool FFmpeg

    if ([string]::IsNullOrWhiteSpace($ffmpegPath)) {
        throw 'Unable to locate ffmpeg.exe.'
    }

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $ffmpegPath
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $false
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    foreach ($argument in $ArgumentList) {
        [void]$startInfo.ArgumentList.Add($argument)
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo

    try {
        [void]$process.Start()

        $standardError = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        $exitCode = $process.ExitCode
    }
    finally {
        $process.Dispose()
    }

    if ($exitCode -ne 0) {
        throw "FFmpeg failed with exit code $exitCode. $standardError"
    }

    return $standardError.Trim()
}
