function New-PCXChapterInformationObject {

<#
.SYNOPSIS
    Creates a PCXLab.ChapterInformation object.
#>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [int]$ChapterNumber,

        [Parameter(Mandatory)]
        [timespan]$StartTime,

        [Parameter(Mandatory)]
        [timespan]$EndTime,

        [Parameter(Mandatory)]
        [double]$StartSeconds,

        [Parameter(Mandatory)]
        [double]$EndSeconds,

        [string]$Title

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.ChapterInformation'

        ChapterNumber = $ChapterNumber

        StartTime = $StartTime
        EndTime = $EndTime

        StartSeconds = $StartSeconds
        EndSeconds = $EndSeconds

        Duration = $EndTime - $StartTime

        Title = $Title

    }

}