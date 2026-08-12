function New-PCXSynchronizationSegmentObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.SynchronizationSegment object.

    .DESCRIPTION
        Represents a contiguous range of the synchronized timeline and
        the source contributions that cover it.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [double]$StartSeconds,

        [Parameter(Mandatory)]
        [ValidateScript({
            if ($_ -lt $PSBoundParameters['StartSeconds']) {
                throw 'EndSeconds must be greater than or equal to StartSeconds.'
            }
            return $true
        })]
        [double]$EndSeconds,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Contributions

    )

    $DurationSeconds = [Math]::Round(
        $EndSeconds - $StartSeconds,
        3
    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SynchronizationSegment'

        StartSeconds = $StartSeconds
        EndSeconds   = $EndSeconds
        DurationSeconds = $DurationSeconds

        Contributions = $Contributions

    }

}
