function New-PCXSynchronizationEvidenceObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.SynchronizationEvidence object.

    .DESCRIPTION
        Represents the evidence used to derive a synchronization offset.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Method,

        [Parameter(Mandatory)]
        [double]$Correlation,

        [Parameter(Mandatory)]
        [int]$PeakSample,

        [Parameter(Mandatory)]
        [int]$SampleRate,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter()]
        [Nullable[int]]$WindowSize,

        [Parameter()]
        [Nullable[int]]$ReferenceWindowStart,

        [Parameter()]
        [Nullable[int]]$TargetWindowStart

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SynchronizationEvidence'

        Method     = $Method
        Correlation = $Correlation
        PeakSample = $PeakSample
        SampleRate = $SampleRate
        Description = $Description

        WindowSize = $WindowSize
        ReferenceWindowStart = $ReferenceWindowStart
        TargetWindowStart = $TargetWindowStart

    }

}
