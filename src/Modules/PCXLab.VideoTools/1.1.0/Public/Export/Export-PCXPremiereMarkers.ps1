function Export-PCXPremiereMarkers {

    <#
    .SYNOPSIS
        Exports analysis events or video segments as Adobe Premiere Pro markers.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds range comment markers to
        the active Adobe Premiere Pro sequence.

        This command accepts raw analysis events (e.g. from Find-PCXSilence,
        Find-PCXBlackFrames), complete analysis containers (Analyze-PCXVideo),
        or editing segments (Get-PCXVideoSegments).

    .PARAMETER InputObject
        Analysis events, PCXLab.VideoAnalysis, or PCXLab.VideoSegment objects
        from the pipeline.

    .PARAMETER Path
        Destination path for the generated .jsx file. If omitted, a default path is generated.

    .PARAMETER TimeOffsetSeconds
        Offset added to every marker position. Use this when the source clip
        begins later than zero on the target sequence.

    .PARAMETER Force
        Overwrite an existing file.

    .EXAMPLE
        Find-PCXSilence -Path '.\Tutorial.mp4' |
            Export-PCXPremiereMarkers -Path '.\Tutorial-Markers.jsx'

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
        $RawItems = [System.Collections.Generic.List[object]]::new()
    }

    process {
        $RawItems.Add($InputObject)
    }

    end {

        if ($RawItems.Count -eq 0) {
            Write-Warning 'No markers were supplied.'
            return
        }

        # Validate and normalize markers through internal dispatcher
        $normalizedMarkers = [System.Collections.Generic.List[object]]::new()
        $sourcePaths = [System.Collections.Generic.List[string]]::new()

        foreach ($item in $RawItems) {

            $markers = ConvertTo-PCXPremiereMarker -InputObject $item

            if ($null -ne $markers) {
                foreach ($m in $markers) {
                    $normalizedMarkers.Add($m)
                }
            }

            $sourceProp = $item.PSObject.Properties['SourcePath']
            if ($null -ne $sourceProp -and -not [string]::IsNullOrWhiteSpace($sourceProp.Value)) {
                $sourcePaths.Add([string]$sourceProp.Value)
            }

        }

        if ($normalizedMarkers.Count -eq 0) {
            Write-Warning 'No markers were generated from the supplied input.'
            return
        }

        $uniqueSourcePaths = @($sourcePaths | Sort-Object -Unique)

        if ($uniqueSourcePaths.Count -gt 1) {
            throw "All input objects must belong to the same source. Found: $($uniqueSourcePaths -join ', ')."
        }

        $source = if ($uniqueSourcePaths.Count -ge 1) { $uniqueSourcePaths[0] } else { $null }

        if ([string]::IsNullOrWhiteSpace($Path)) {

            if ([string]::IsNullOrWhiteSpace($source)) {
                throw 'Unable to determine default output path because no SourcePath was found on input objects.'
            }

            $Path = Get-PCXArtifactPath `
                -SourcePath $source `
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

        if ($PSCmdlet.ShouldProcess($Path, 'Create Premiere Pro marker script')) {

            $ScriptContent = ConvertTo-PCXPremiereMarkerScript `
                -Marker @($normalizedMarkers) `
                -TimeOffsetSeconds $TimeOffsetSeconds

            Set-Content -LiteralPath $Path -Value $ScriptContent -Encoding UTF8
            Get-Item -LiteralPath $Path

        }
    }
}
