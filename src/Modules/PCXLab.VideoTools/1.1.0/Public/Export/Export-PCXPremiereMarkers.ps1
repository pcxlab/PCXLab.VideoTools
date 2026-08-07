function Export-PCXPremiereMarkers {

    <#
    .SYNOPSIS
        Exports silence-analysis results as Adobe Premiere Pro markers.

    .DESCRIPTION
        Creates an ExtendScript (.jsx) file that adds range comment markers to
        the active Adobe Premiere Pro sequence. By default, only actionable
        silence regions are exported; use IncludeShortPause to include every
        detected silence region. If -Path is not specified, a default output
        path is generated based on the source media file.

    .PARAMETER InputObject
        PCXLab.Silence objects, normally from Find-PCXSilence.

    .PARAMETER Path
        Destination path for the generated .jsx file. If omitted, a default path is generated.

    .PARAMETER IncludeShortPause
        Includes silence regions classified as ShortPause.

    .PARAMETER TimeOffsetSeconds
        Offset added to every marker position. Use this when the source clip
        begins later than zero on the target sequence.

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereMarkers -Path '.\Tutorial-SilenceMarkers.jsx'

    .EXAMPLE
        Find-PCXSilence -Path 'C:\Videos\Tutorial.mp4' |
            Export-PCXPremiereMarkers -Path '.\Markers.jsx' -TimeOffsetSeconds 15

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
        [double]$TimeOffsetSeconds = 0

    )

    begin {
        $Markers = [System.Collections.Generic.List[object]]::new()
    }

    process {
        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }

        if ($IncludeShortPause -or $InputObject.Classification -ne 'ShortPause') {
            [void]$Markers.Add($InputObject)
        }
    }

    end {
        if ($Markers.Count -eq 0) {
            Write-Warning 'No silence markers matched the export criteria.'
            return
        }

        if ([string]::IsNullOrWhiteSpace($Path)) {
            $Suffix = if ($IncludeShortPause) { 'PremiereMarkers-ShortPause' } else { 'PremiereMarkers' }
            $Path = Get-PCXDefaultOutputPath `
                -SourcePath $Markers[0].SourcePath `
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

        if ($PSCmdlet.ShouldProcess($Path, 'Create Premiere Pro marker script')) {
            $ScriptContent = ConvertTo-PCXPremiereMarkerScript `
                -Marker $Markers.ToArray() `
                -TimeOffsetSeconds $TimeOffsetSeconds

            Set-Content -LiteralPath $Path -Value $ScriptContent -Encoding UTF8
            Get-Item -LiteralPath $Path
        }
    }
}
