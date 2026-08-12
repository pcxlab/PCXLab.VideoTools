function New-PCXSourceOffsetObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.SourceOffset object.

    .DESCRIPTION
        Represents the resolved relative timing offset of one media
        source with respect to a reference source.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferencePath,

        [Parameter(Mandatory)]
        [double]$OffsetSeconds,

        [Parameter()]
        [double]$Confidence = 0,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Method = 'Unknown',

        [Parameter()]
        [object]$Evidence

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SourceOffset'

        SourceId     = $SourceId
        ReferenceId  = $ReferenceId

        SourcePath     = $SourcePath
        ReferencePath  = $ReferencePath

        OffsetSeconds = $OffsetSeconds

        Confidence = $Confidence
        Method     = $Method
        Evidence   = $Evidence

    }

}
