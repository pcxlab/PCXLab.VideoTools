function Export-PCXPremiereEditPoints {

    <#
    .SYNOPSIS
        Exports video segments as Premiere Pro edit points.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds edits at the beginning
        and end of supplied segments in the active Premiere Pro sequence.
        It creates cuts only; it never removes or ripple-deletes media.

        This command accepts PCXLab.VideoSegment objects directly, or
        PCXLab.Silence objects for backward compatibility.

    .PARAMETER InputObject
        PCXLab.VideoSegment or PCXLab.Silence objects.

    .PARAMETER Path
        Destination path for the generated .jsx file. If omitted, a default path is generated.

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
        $segments | Export-PCXPremiereEditPoints -Path '.\Tutorial-EditPoints.jsx'

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
        [double]$TimeOffsetSeconds = 0,

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]$VideoTrackIndex = 0,

        [Parameter()]
        [ValidateRange(0, 99)]
        [int]$AudioTrackIndex = 0,

        [Parameter()]
        [ValidateSet('Selected', 'All')]
        [string]$TrackMode = 'Selected',

        [Parameter()]
        [switch]$Force

    )

    begin {
        $Silences = [System.Collections.Generic.List[object]]::new()
        $InputType = $null
    }

    process {

        $objectType = if ($InputObject.PSTypeNames -contains 'PCXLab.VideoSegment') {
            'VideoSegment'
        }
        elseif ($InputObject.PSTypeNames -contains 'PCXLab.Silence') {
            'Silence'
        }
        else {
            'Unknown'
        }

        if ($null -eq $InputType) {

            if ($objectType -eq 'Unknown') {
                throw 'InputObject must be a PCXLab.VideoSegment or PCXLab.Silence object.'
            }

            $InputType = $objectType

        }
        elseif ($objectType -ne $InputType) {
            throw "All input objects must be of the same type. Expected '$InputType', found '$objectType'."
        }

        $Silences.Add($InputObject)

    }

    end {

        if ($Silences.Count -eq 0) {
            Write-Warning 'No edit points were supplied.'
            return
        }

        $SourcePath = $Silences[0].SourcePath

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType PremiereEditPoint

        }

        if (-not (Test-PCXShouldGenerateArtifact -Path $Path -Force:$Force)) {
            return (Get-Item -LiteralPath $Path)
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

        $Segments = if ($InputType -eq 'Silence') {
            $Silences | Get-PCXVideoSegments
        }
        else {
            $Silences
        }

        if ($PSCmdlet.ShouldProcess($Path, 'Create Premiere Pro edit-point script')) {

            $ScriptContent = ConvertTo-PCXPremiereEditPointScript `
                -Segment @($Segments) `
                -TimeOffsetSeconds $TimeOffsetSeconds `
                -VideoTrackIndex $VideoTrackIndex `
                -AudioTrackIndex $AudioTrackIndex `
                -TrackMode $TrackMode

            Set-Content -LiteralPath $Path -Value $ScriptContent -Encoding UTF8
            Get-Item -LiteralPath $Path

        }
    }
}
