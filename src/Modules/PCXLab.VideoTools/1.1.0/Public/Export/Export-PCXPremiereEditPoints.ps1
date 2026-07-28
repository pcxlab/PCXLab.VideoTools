function Export-PCXPremiereEditPoints {

    <#
    .SYNOPSIS
        Exports silence-analysis results as Premiere Pro edit points.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds edits at the beginning
        and end of actionable silence regions in the active Premiere Pro
        sequence. It creates cuts only; it never removes or ripple-deletes
        media.

        The generated script uses Premiere Pro's QE razor interface because
        Premiere's supported scripting API does not currently provide a split
        operation at an arbitrary time. Test on a copy of a sequence first.

    .PARAMETER InputObject
        PCXLab.Silence objects, normally from Find-PCXSilence.

    .PARAMETER OutputPath
        Destination path for the generated .jsx file.

    .PARAMETER IncludeShortPause
        Includes silence regions classified as ShortPause.

    .PARAMETER TimeOffsetSeconds
        Offset added to every edit point. Use this when the source clip begins
        later than zero on the target sequence.

    .PARAMETER VideoTrackIndex
        Zero-based target video-track index. The default is 0 (V1).

    .PARAMETER AudioTrackIndex
        Zero-based target audio-track index. The default is 0 (A1).

    .PARAMETER AllTracks
        Creates edit points on every sequence track rather than V1 and A1.

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereEditPoints -OutputPath '.\Tutorial-EditPoints.jsx'

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter()]
        [switch]$IncludeShortPause,

        [Parameter()]
        [double]$TimeOffsetSeconds = 0,

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]$VideoTrackIndex = 0,

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]$AudioTrackIndex = 0,

        [Parameter()]
        [switch]$AllTracks

    )

    begin {
        $silences = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }

        if ($IncludeShortPause -or $InputObject.Classification -ne 'ShortPause') {
            [void]$silences.Add($InputObject)
        }
    }

    end {
        if ($silences.Count -eq 0) {
            Write-Warning 'No silence regions matched the export criteria.'
            return
        }

        $resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
        $outputFolder = Split-Path -Path $resolvedOutputPath -Parent

        if (-not (Test-Path -LiteralPath $outputFolder -PathType Container)) {
            throw "Output folder does not exist: $outputFolder"
        }

        if ([System.IO.Path]::GetExtension($resolvedOutputPath) -ne '.jsx') {
            throw 'OutputPath must use the .jsx extension.'
        }

        if ($PSCmdlet.ShouldProcess($resolvedOutputPath, 'Create Premiere Pro edit-point script')) {
            $scriptContent = ConvertTo-PCXPremiereEditPointScript `
                -Silence $silences.ToArray() `
                -TimeOffsetSeconds $TimeOffsetSeconds `
                -VideoTrackIndex $VideoTrackIndex `
                -AudioTrackIndex $AudioTrackIndex `
                -AllTracks:$AllTracks

            Set-Content -LiteralPath $resolvedOutputPath -Value $scriptContent -Encoding utf8
            Get-Item -LiteralPath $resolvedOutputPath
        }
    }
}
