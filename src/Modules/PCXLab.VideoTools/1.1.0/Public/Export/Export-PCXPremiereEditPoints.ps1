function Export-PCXPremiereEditPoints {

    <#
    .SYNOPSIS
        Exports silence-analysis results as Premiere Pro edit points.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds edits at the beginning
        and end of actionable silence regions in the active Premiere Pro
        sequence. It creates cuts only; it never removes or ripple-deletes
        media. If -Path is not specified, a default output path is generated
        based on the source media file.

        The generated script uses Premiere Pro's QE razor interface because
        Premiere's supported scripting API does not currently provide a split
        operation at an arbitrary time. Test on a copy of a sequence first.

    .PARAMETER InputObject
        PCXLab.Silence objects, normally from Find-PCXSilence.

    .PARAMETER Path
        Destination path for the generated .jsx file. If omitted, a default path is generated.

    .PARAMETER IncludeShortPause
        Includes silence regions classified as ShortPause.

    .PARAMETER TimeOffsetSeconds
        Offset added to every edit point. Use this when the source clip begins
        later than zero on the target sequence.

    .PARAMETER VideoTrackIndex
        Zero-based target video-track index. The default is 0 (V1).

    .PARAMETER AudioTrackIndex
        Zero-based target audio-track index. The default is 0 (A1).

    .PARAMETER TrackMode
        Controls which tracks receive edit points.

        Selected
            Creates edit points on the specified video and audio tracks.

        All
            Creates edit points on every video and audio track in the active sequence.

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereEditPoints -Path '.\Tutorial-EditPoints.jsx'

        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereEditPoints `
                -Path '.\Tutorial-TrackMode-All.jsx' `
                -TrackMode All

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter()]
        [Alias('OutputPath')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

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
        [ValidateSet('Selected', 'All')]
        [string]$TrackMode = 'Selected'

    )

    begin {
        $Silences = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }

        if ($IncludeShortPause -or $InputObject.Classification -ne 'ShortPause') {
            [void]$Silences.Add($InputObject)
        }
    }

    end {
        if ($Silences.Count -eq 0) {
            Write-Warning 'No silence regions matched the export criteria.'
            return
        }

        if ([string]::IsNullOrWhiteSpace($Path)) {
            $Suffix = if ($TrackMode -eq 'All') { 'PremiereEditPoints-AllTracks' } else { 'PremiereEditPoints' }
            $Path = Get-PCXDefaultOutputPath `
                -SourcePath $Silences[0].SourcePath `
                -Suffix $Suffix `
                -Extension '.jsx'
        }

        $Parent = Split-Path -Path $Path -Parent

        if (-not [string]::IsNullOrWhiteSpace($Parent) -and -not (Test-Path -LiteralPath $Parent)) {
            New-Item `
                -ItemType Directory `
                -Path $Parent `
                -Force | Out-Null
        }

        if ([System.IO.Path]::GetExtension($Path) -ne '.jsx') {
            throw 'Path must use the .jsx extension.'
        }

        if ($PSCmdlet.ShouldProcess($Path, 'Create Premiere Pro edit-point script')) {
            $ScriptContent = ConvertTo-PCXPremiereEditPointScript `
                -Silence $Silences.ToArray() `
                -TimeOffsetSeconds $TimeOffsetSeconds `
                -VideoTrackIndex $VideoTrackIndex `
                -AudioTrackIndex $AudioTrackIndex `
                -TrackMode $TrackMode

            Set-Content -LiteralPath $Path -Value $ScriptContent -Encoding UTF8
            Get-Item -LiteralPath $Path
        }
    }
}
