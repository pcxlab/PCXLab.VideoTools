function Import-PCXRecordingSession {

    <#
    .SYNOPSIS
        Imports a PCXLab.MediaSynchronization object from JSON.

    .DESCRIPTION
        Imports a previously exported recording session document and
        restores all PCXLab custom types.

    .PARAMETER Path
        Path to a RecordingSession JSON file.

    .EXAMPLE
        Import-PCXRecordingSession `
            -Path 'C:\Videos\RecordingSession.json'

    .OUTPUTS
        PCXLab.MediaSynchronization
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.MediaSynchronization')]
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

            if ($null -eq $Document.MediaSynchronization) {
                throw "File '$File' is not a PCXLab.MediaSynchronization export."
            }

            foreach ($Session in $Document.MediaSynchronization) {

                Restore-PCXRecordingSessionTypes `
                    -InputObject $Session

            }

        }

    }

}
