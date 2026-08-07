function Invoke-PCXFFmpegEdit {

    <#
.SYNOPSIS
    Executes an FFmpeg editing job.

.DESCRIPTION
    Executes a PCXLab.EditJob by building the FFmpeg command
    and invoking FFmpeg.

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

    $Arguments = @(

        '-y'

        '-i'
        $EditJob.SourcePath

        '-filter_complex'
        $EditJob.FilterGraph

        '-map'
        '[outv]'

        '-map'
        '[outa]'

        '-c:v'
        $EditJob.VideoCodec

        '-c:a'
        $EditJob.AudioCodec

        $EditJob.OutputPath

    )

    Invoke-PCXFFmpeg `
        -ArgumentList $Arguments |
    Out-Null

    Get-Item $EditJob.OutputPath

}