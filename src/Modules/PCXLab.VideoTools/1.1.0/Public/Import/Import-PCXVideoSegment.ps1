function Import-PCXVideoSegment {

    <#
    .SYNOPSIS
        Imports PCXLab.VideoSegment objects from a JSON file.

    .DESCRIPTION
        Imports a previously exported video segment document and restores
        all PCXLab custom types and TimeSpan properties.

    .PARAMETER Path
        Path to a VideoSegment JSON file.

    .EXAMPLE
        Import-PCXVideoSegment -Path 'C:\Videos\Test-VideoSegments.json'

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path

    )

    process {

        foreach ($File in $Path) {

            if (-not (Test-Path -LiteralPath $File)) {
                throw "File not found: $File"
            }

            $Document = Get-Content `
                -LiteralPath $File `
                -Raw |
                ConvertFrom-Json

            if ($null -eq $Document.VideoSegments) {
                throw "File '$File' is not a PCXLab.VideoSegment export."
            }

            foreach ($Item in $Document.VideoSegments) {

                $Start = [TimeSpan]::FromTicks([Int64]$Item.Start.Ticks)
                $End = [TimeSpan]::FromTicks([Int64]$Item.End.Ticks)

                New-PCXVideoSegmentObject `
                    -SourcePath $Item.SourcePath `
                    -Start $Start `
                    -End $End `
                    -Action $Item.Action

            }

        }

    }

}
