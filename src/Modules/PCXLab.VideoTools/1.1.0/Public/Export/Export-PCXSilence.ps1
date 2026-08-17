function Export-PCXSilence {

    <#
    .SYNOPSIS
        Exports PCXLab.Silence objects to a JSON file.

    .DESCRIPTION
        Saves the output of Find-PCXSilence so it can later be imported
        without running FFmpeg again. If -Path is not specified, a default
        output path is generated based on the source media file.

    .PARAMETER InputObject
        PCXLab.Silence objects.

    .PARAMETER Path
        Destination JSON file. If omitted, a default path is generated.

    .PARAMETER Force
        Overwrite an existing file.

    .EXAMPLE
        Find-PCXSilence -Path Test.mp4 |
            Export-PCXSilence -Path Test.silence.json

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

        [switch]$Force

    )

    begin {

        $Silence = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }

        [void]$Silence.Add($InputObject)

    }

    end {

        if ($Silence.Count -eq 0) {
            throw 'No silence objects were provided.'
        }

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXArtifactPath `
                -SourcePath $Silence[0].SourcePath `
                -ArtifactType Silence

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
            -CollectionName 'Silence' `
            -Items $Silence

        if ($PSCmdlet.ShouldProcess($Path, 'Export silence analysis')) {

            $Document |
            ConvertTo-Json -Depth 10 |
            Set-Content `
                -Path $Path `
                -Encoding UTF8 `
                -Force:$Force

            Get-Item -LiteralPath $Path

        }

    }

}