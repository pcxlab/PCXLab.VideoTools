function Invoke-PCXFFmpegEdit {

    <#
.SYNOPSIS
    Executes an FFmpeg editing job.

.DESCRIPTION
    Executes a PCXLab.EditJob by building the FFmpeg command
    and invoking FFmpeg.

    The filter graph is written to a named script file and
    supplied to FFmpeg via -filter_complex_script. This avoids
    the Windows command-line length limit (32 767 characters)
    that is reached when long recordings produce many timeline
    segments.

    Filter-script file naming:
      The base name is derived from the source video filename
      so the artifact is immediately recognisable. A timestamp
      suffix prevents collisions during bulk processing.

      Example:
        Source:  C:\Recording\bandicam 2026-01-27 11-20-02-160.mp4
        Script:  %TEMP%\PCXLab\VideoTools\FilterGraphs\
                   bandicam 2026-01-27 11-20-02-160-PCXFilterGraph-20260809-041500.txt

    Cleanup policy:
      Success  — filter-script file is deleted automatically.
      Failure  — filter-script file is preserved for diagnostics.
                 Its path is appended to the exception message.

.PARAMETER EditJob
    PCXLab.EditJob object.

.OUTPUTS
    System.IO.FileInfo
#>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$EditJob

    )

    if ($EditJob.PSTypeNames -notcontains 'PCXLab.EditJob') {
        throw 'InputObject must be a PCXLab.EditJob object.'
    }

    #----------------------------------------------------------
    # Build a safe, collision-resistant filter-script path.
    #
    # Illegal Windows filename characters are replaced with '_'.
    # A yyyyMMdd-HHmmss timestamp is appended so simultaneous
    # bulk runs on files with the same base name do not collide.
    #----------------------------------------------------------

    $FilterGraphDir = Join-Path `
        ([System.IO.Path]::GetTempPath()) `
        'PCXLab\VideoTools\FilterGraphs'

    if (-not (Test-Path -LiteralPath $FilterGraphDir)) {
        [void][System.IO.Directory]::CreateDirectory($FilterGraphDir)
    }

    $InvalidChars = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $InvalidPattern = "[{0}]" -f [System.Text.RegularExpressions.Regex]::Escape($InvalidChars)

    $SourceBaseName = [System.IO.Path]::GetFileNameWithoutExtension($EditJob.SourcePath)
    $SafeBaseName   = $SourceBaseName -replace $InvalidPattern, '_'
    $Timestamp      = (Get-Date -Format 'yyyyMMdd-HHmmss')
    $ScriptFileName = '{0}-PCXFilterGraph-{1}.txt' -f $SafeBaseName, $Timestamp

    $FilterScriptPath = Join-Path $FilterGraphDir $ScriptFileName

    #----------------------------------------------------------
    # Write the filter graph to the script file.
    # UTF-8 without BOM — FFmpeg reads the file as plain text.
    #----------------------------------------------------------

    [System.IO.File]::WriteAllText(
        $FilterScriptPath,
        $EditJob.FilterGraph,
        [System.Text.UTF8Encoding]::new($false)
    )

    #----------------------------------------------------------
    # Execute FFmpeg.
    #
    # $Success tracks whether FFmpeg completed without error.
    # The finally block uses this flag to decide whether to
    # delete (success) or preserve (failure) the script file.
    #----------------------------------------------------------

    $Success = $false

    try {

        $hasAudio = if ($null -ne $EditJob.PSObject.Properties['HasAudio']) {
            [bool]$EditJob.HasAudio
        } else {
            $true
        }

        $Arguments = @(

            '-y'

            '-i'
            $EditJob.SourcePath

            '-filter_complex_script'
            $FilterScriptPath

            '-map'
            '[outv]'

            if ($hasAudio) {
                '-map'
                '[outa]'
            }

            '-c:v'
            $EditJob.VideoCodec

            if ($hasAudio) {
                '-c:a'
                $EditJob.AudioCodec
            }

            if ($hasAudio -and $EditJob.SampleRate -gt 0) {
                '-ar'
                $EditJob.SampleRate.ToString()
            }

            $EditJob.OutputPath

        )

        Invoke-PCXFFmpeg `
            -ArgumentList $Arguments |
        Out-Null

        $Success = $true

    }
    catch {

        #
        # Re-throw with the preserved filter-script path appended
        # so the caller knows where to find the diagnostic file.
        #

        $PreservedMessage = "Filter graph preserved for diagnostics: $FilterScriptPath"
        throw "$($_.Exception.Message) $PreservedMessage"

    }
    finally {

        #
        # Delete the script file only on success.
        # On failure it is retained for troubleshooting.
        #

        if ($Success -and (Test-Path -LiteralPath $FilterScriptPath)) {
            Remove-Item -LiteralPath $FilterScriptPath -Force
        }

    }

    Get-Item $EditJob.OutputPath

}