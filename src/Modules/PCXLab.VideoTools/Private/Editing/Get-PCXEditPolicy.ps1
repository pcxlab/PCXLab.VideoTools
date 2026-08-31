function Get-PCXEditPolicy {

    <#
    .SYNOPSIS
        Returns centralized edit-policy constants.

    .DESCRIPTION
        Provides standard editing policy constants used across segment optimization,
        classification, and timeline operations.

    .OUTPUTS
        PSCustomObject
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    [PSCustomObject]@{
        PSTypeName              = 'PCXLab.EditPolicy'
        MinimumSegmentDuration  = [TimeSpan]::FromMilliseconds(250)
        RecordingBreakThreshold = [TimeSpan]::FromSeconds(15)
        EditCandidateThreshold  = [TimeSpan]::FromSeconds(5)
    }

}
