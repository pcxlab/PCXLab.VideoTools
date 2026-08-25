function Resolve-PCXSourceSynchronizationMethod {

    <#
    .SYNOPSIS
        Resolves a MediaSource's SynchronizationMethod to a concrete value.

    .DESCRIPTION
        Pure resolver that inspects a PCXLab.MediaSource and returns the
        concrete synchronization method to use.

        If the source has an explicit non-Auto method, that value is returned.
        If the method is Auto, the resolver selects a default based on the
        source's capabilities:

        - AudioCorrelation when the source has audio suitable for correlation.
        - OffsetHint when the source has an OffsetHint but no audio.
        - None when the source has no audio and no OffsetHint.

        This function does not modify the source object.

    .PARAMETER Source
        PCXLab.MediaSource object.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Source

    )

    Assert-PCXMediaSource -Source $Source

    if ($Source.SynchronizationMethod -and $Source.SynchronizationMethod -ne 'Auto') {
        return $Source.SynchronizationMethod
    }

    if (Test-PCXSourceAudioSuitableForSynchronization -Source $Source) {
        return 'AudioCorrelation'
    }

    if ($null -ne $Source.OffsetHint) {
        return 'OffsetHint'
    }

    return 'None'

}
