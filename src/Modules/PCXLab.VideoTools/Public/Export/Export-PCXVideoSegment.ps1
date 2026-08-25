function Export-PCXVideoSegment {

    <#
    .SYNOPSIS
        Exports PCXLab.VideoSegment objects to a JSON file.

    .DESCRIPTION
        Saves a collection of PCXLab.VideoSegment objects so the exact
        timeline used for rendering can be persisted and resumed without
        repeating upstream analysis or edit-point generation.

        If -Path is not specified, a default output path is generated based
        on the source media file.

    .PARAMETER InputObject
        PCXLab.VideoSegment objects from the pipeline.

    .PARAMETER Path
        Destination JSON file. If omitted, a default path is generated.

    .PARAMETER Force
        Overwrite an existing file.

    .EXAMPLE
        Get-PCXVideoSegments -InputObject $silence |
            Export-PCXVideoSegment

    .EXAMPLE
        Get-PCXVideoSegments -InputObject $silence |
            Export-PCXVideoSegment -Path 'C:\Cache\Timeline.json'

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter()]
        [Alias('OutputPath')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Force

    )

    begin {

        $Segments = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.VideoSegment') {
            throw 'InputObject must be a PCXLab.VideoSegment object.'
        }

        $Segments.Add($InputObject)

    }

    end {

        if ($Segments.Count -eq 0) {
            throw 'No video segment objects were provided.'
        }

        $uniqueSourcePaths = @($Segments.SourcePath | Sort-Object -Unique)

        if ($uniqueSourcePaths.Count -gt 1) {
            throw "All video segments must belong to the same source. Found: $($uniqueSourcePaths -join ', ')."
        }

        $SourcePath = $Segments[0].SourcePath

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType VideoSegment

        }

        if (-not (Test-PCXShouldGenerateArtifact -Path $Path -Force:$Force)) {
            return (Get-Item -LiteralPath $Path)
        }

        $Parent = [System.IO.Path]::GetDirectoryName($Path)

        if ([string]::IsNullOrWhiteSpace($Parent)) {
            throw "Unable to determine parent folder from path '$Path'."
        }

        if (-not (Test-Path -LiteralPath $Parent)) {

            New-Item `
                -ItemType Directory `
                -Path $Parent `
                -Force | Out-Null

        }

        $Document = New-PCXExportDocument `
            -CollectionName 'VideoSegments' `
            -Items $Segments

        if ($PSCmdlet.ShouldProcess($Path, 'Export video segments')) {

            $Document |
                ConvertTo-Json -Depth 10 |
                Set-Content `
                    -LiteralPath $Path `
                    -Encoding UTF8

            Get-Item -LiteralPath $Path

        }

    }

}
