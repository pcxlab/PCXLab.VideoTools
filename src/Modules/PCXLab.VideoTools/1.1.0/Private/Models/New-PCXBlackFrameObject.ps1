function New-PCXBlackFrameObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.BlackFrame object.

    .DESCRIPTION
        Represents a region of video that is visually black, typically
        indicating a transition, pause, or section that can be removed
        during editing.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [TimeSpan]$Start,

        [Parameter(Mandatory)]
        [TimeSpan]$End,

        [Parameter(Mandatory)]
        [double]$DurationSeconds,

        [Parameter(Mandatory)]
        [string]$SourcePath

    )

    [PSCustomObject]@{

        PSTypeName      = 'PCXLab.BlackFrame'

        EventType       = 'BlackFrame'

        # Source
        SourcePath      = $SourcePath
        Source          = [System.IO.Path]::GetFileName($SourcePath)

        # Time
        Start           = $Start
        End             = $End
        Duration        = [TimeSpan]::FromSeconds($DurationSeconds)

        # Numeric
        StartSeconds    = [Math]::Round($Start.TotalSeconds, 3)
        EndSeconds      = [Math]::Round($End.TotalSeconds, 3)
        DurationSeconds = [Math]::Round($DurationSeconds, 3)

    }

}
