function Export-PCXEditPoint {

    <#
    .SYNOPSIS
        Exports edit points to a JSON document.

    .DESCRIPTION
        Exports one or more PCXLab.EditPoint objects to a JSON document.
        If -Path is not specified, a default output path is generated based
        on the source media file.

    .PARAMETER InputObject
        One or more PCXLab.EditPoint objects.

    .PARAMETER Path
        Output JSON file. If omitted, a default path is generated.

    .PARAMETER Force
        Overwrite an existing file.

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Force

    )

    begin {

        $EditPoints = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.EditPoint') {
            throw 'InputObject must be a PCXLab.EditPoint object.'
        }

        $EditPoints.Add($InputObject)

    }

    end {

        if ($EditPoints.Count -eq 0) {
            throw 'No edit points were provided.'
        }

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXArtifactPath `
                -SourcePath $EditPoints[0].SourcePath `
                -ArtifactType EditPoint

        }

        $Parent = Split-Path -Path $Path -Parent

        if (-not (Test-Path -LiteralPath $Parent)) {

            New-Item `
                -ItemType Directory `
                -Path $Parent `
                -Force | Out-Null

        }

        $Document = New-PCXExportDocument `
            -CollectionName 'EditPoints' `
            -Items $EditPoints

        $Document |
            ConvertTo-Json -Depth 10 |
            Set-Content `
                -Path $Path `
                -Encoding UTF8 `
                -Force:$Force

        Get-Item -LiteralPath $Path

    }

}