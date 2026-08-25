function New-PCXSynchronizationContributionObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.SynchronizationContribution object.

    .DESCRIPTION
        Represents the participation of a single media source within a
        synchronized timeline segment.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateSet(
            'Primary',
            'Video',
            'Audio'
        )]
        [string]$Role,

        [Parameter(Mandatory)]
        [double]$OffsetSeconds,

        [Parameter(Mandatory)]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$TrimStart,

        [Parameter(Mandatory)]
        [ValidateScript({
            if ($_ -lt 0) { throw 'TrimEnd must be greater than or equal to 0.' }
            if ($_ -lt $PSBoundParameters['TrimStart']) { throw 'TrimEnd must be greater than or equal to TrimStart.' }
            return $true
        })]
        [double]$TrimEnd

    )

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.SynchronizationContribution'

        SourcePath = $SourcePath
        Role       = $Role
        OffsetSeconds = $OffsetSeconds
        TrimStart  = $TrimStart
        TrimEnd    = $TrimEnd

    }

}
