function Export-PCXPremiereMarkers {

    <#
    .SYNOPSIS
        Exports video segments as Adobe Premiere Pro markers.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds range comment markers to
        the active Adobe Premiere Pro sequence. By default, all supplied
        segments are exported.

        This command accepts PCXLab.VideoSegment objects directly, or
        PCXLab.Silence objects for backward compatibility.

    .PARAMETER InputObject
        PCXLab.VideoSegment or PCXLab.Silence objects.

    .PARAMETER Path
        Destination path for the generated .jsx file. If omitted, a default path is generated.

    .PARAMETER TimeOffsetSeconds
        Offset added to every marker position. Use this when the source clip
        begins later than zero on the target sequence.

    .EXAMPLE
        Get-PCXVideoSegments -InputObject (Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4') |
            Export-PCXPremiereMarkers -Path '.\Tutorial-Markers.jsx'

    .EXAMPLE
        $segments | Export-PCXPremiereMarkers -Path '.\Markers.jsx' -TimeOffsetSeconds 15

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
        [switch]$Force

    )

    begin {
        $Markers = [System.Collections.Generic.List[object]]::new()
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

        $Markers.Add($InputObject)

    }

    end {

        if ($Markers.Count -eq 0) {
            Write-Warning 'No markers were supplied.'
            return
        }

        $SourcePath = $Markers[0].SourcePath

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType PremiereMarker

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
            $Markers | Get-PCXVideoSegments
        }
        else {
            $Markers
        }

        if ($PSCmdlet.ShouldProcess($Path, 'Create Premiere Pro marker script')) {

            $ScriptContent = ConvertTo-PCXPremiereMarkerScript `
                -Marker @($Segments) `
                -TimeOffsetSeconds $TimeOffsetSeconds

            Set-Content -LiteralPath $Path -Value $ScriptContent -Encoding UTF8
            Get-Item -LiteralPath $Path

        }
    }
}
