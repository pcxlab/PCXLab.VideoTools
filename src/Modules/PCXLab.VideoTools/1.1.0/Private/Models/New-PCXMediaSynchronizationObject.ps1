function New-PCXMediaSynchronizationObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.MediaSynchronization object.

    .DESCRIPTION
        Represents the top-level result of synchronizing multiple
        media sources.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Sources,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Timeline,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Strategy = 'AudioCorrelation',

        [Parameter()]
        [ValidateRange(0.0, 1.0)]
        [double]$MinimumConfidence = 0,

        [Parameter()]
        [ValidateScript({
            if ($_ -lt 0) {
                throw 'MaxOffsetSeconds must be greater than or equal to 0.'
            }
            return $true
        })]
        [Nullable[double]]$MaxOffsetSeconds

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.MediaSynchronization'

        Created = Get-Date
        ModuleVersion = Get-PCXModuleVersion

        Sources = $Sources
        Timeline = $Timeline

        Strategy = $Strategy
        MinimumConfidence = $MinimumConfidence
        MaxOffsetSeconds = $MaxOffsetSeconds

    }

}
