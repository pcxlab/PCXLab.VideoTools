function Get-PCXChapterInformation {

<#
.SYNOPSIS
    Gets chapter information from one or more media files.

.DESCRIPTION
    Retrieves chapter information using FFprobe and returns one or more
    PCXLab.ChapterInformation objects.

.PARAMETER Path
    One or more media file paths.

.EXAMPLE
    Get-PCXChapterInformation -Path "C:\Videos\Movie.mkv"

.OUTPUTS
    PCXLab.ChapterInformation
#>

    [CmdletBinding()]
    [OutputType('PCXLab.ChapterInformation')]
    param(

        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path

    )

    process {

        foreach ($MediaFile in $Path) {

            $Media = Invoke-PCXFFprobe -Path $MediaFile

            if ($null -eq $Media) {
                continue
            }

            ConvertTo-PCXChapterInformation -InputObject $Media

        }

    }

}