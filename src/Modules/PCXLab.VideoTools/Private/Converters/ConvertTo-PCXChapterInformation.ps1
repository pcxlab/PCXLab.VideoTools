function ConvertTo-PCXChapterInformation {

<#
.SYNOPSIS
    Converts FFprobe chapter data into PCXLab chapter information objects.
#>

    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$InputObject

    )

    $ChapterNumber = 1

    foreach ($Chapter in @(Get-PCXChapterStreams -InputObject $InputObject)) {

        $StartSeconds = [double]$Chapter.start_time
        $EndSeconds   = [double]$Chapter.end_time

        New-PCXChapterInformationObject `
            -ChapterNumber $ChapterNumber `
            -StartTime (ConvertTo-PCXDuration -Seconds $StartSeconds) `
            -EndTime (ConvertTo-PCXDuration -Seconds $EndSeconds) `
            -StartSeconds $StartSeconds `
            -EndSeconds $EndSeconds `
            -Title $Chapter.tags.title

        $ChapterNumber++

    }

}