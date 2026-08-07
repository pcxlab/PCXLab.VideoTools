function New-PCXEditPointObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.EditPoint object.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [TimeSpan]$Start,

        [Parameter(Mandatory)]
        [TimeSpan]$End,

        [Parameter(Mandatory)]
        [TimeSpan]$Duration,

        [Parameter(Mandatory)]
        [string]$Classification,

        [Parameter(Mandatory)]
        [string]$Reason,

        [Parameter(Mandatory)]
        [double]$Confidence

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.EditPoint'

        # Source
        SourcePath = $SourcePath
        Source     = [System.IO.Path]::GetFileName($SourcePath)

        # Position
        Start    = $Start
        End      = $End
        Duration = $Duration

        StartSeconds    = [Math]::Round($Start.TotalSeconds,3)
        EndSeconds      = [Math]::Round($End.TotalSeconds,3)
        DurationSeconds = [Math]::Round($Duration.TotalSeconds,3)

        # Recommendation
        Classification = $Classification
        Reason         = $Reason
        Confidence     = [Math]::Round($Confidence,1)

    }

}