function Export-PCXPremiereMarkers {

    <#
    .SYNOPSIS
        Exports silence-analysis results as Adobe Premiere Pro markers.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds range comment markers to
        the active Adobe Premiere Pro sequence. By default, only actionable
        silence regions are exported; use IncludeShortPause to include every
        detected silence region.

    .PARAMETER InputObject
        PCXLab.Silence objects, normally from Find-PCXSilence.

    .PARAMETER OutputPath
        Destination path for the generated .jsx file.

    .PARAMETER IncludeShortPause
        Includes silence regions classified as ShortPause.

    .PARAMETER TimeOffsetSeconds
        Offset added to every marker position. Use this when the source clip
        begins later than zero on the target sequence.

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereMarkers -OutputPath '.\Tutorial-SilenceMarkers.jsx'

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereMarkers -OutputPath '.\Markers.jsx' -TimeOffsetSeconds 15

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
        [double]$TimeOffsetSeconds = 0

    )

    begin {
        $markers = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }

        if ($IncludeShortPause -or $InputObject.Classification -ne 'ShortPause') {
            [void]$markers.Add($InputObject)
        }
    }

    end {
        if ($markers.Count -eq 0) {
            Write-Warning 'No silence markers matched the export criteria.'
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

        if ($PSCmdlet.ShouldProcess($resolvedOutputPath, 'Create Premiere Pro marker script')) {
            $scriptContent = ConvertTo-PCXPremiereMarkerScript `
                -Marker $markers.ToArray() `
                -TimeOffsetSeconds $TimeOffsetSeconds

            Set-Content -LiteralPath $resolvedOutputPath -Value $scriptContent -Encoding utf8
            Get-Item -LiteralPath $resolvedOutputPath
        }
    }
}
