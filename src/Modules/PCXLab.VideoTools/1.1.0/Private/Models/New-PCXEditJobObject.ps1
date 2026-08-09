function New-PCXEditJobObject {

    <#
.SYNOPSIS
    Creates a PCXLab.EditJob object.

.DESCRIPTION
    Represents a complete editing job that can be executed
    by one of the editing providers.

.OUTPUTS
    PCXLab.EditJob
#>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterGraph,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$VideoCodec = 'libx264',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$AudioCodec = 'aac',

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$InputIndex = 0,

        [Parameter()]
        [ValidateRange(0, 192000)]
        [int]$SampleRate = 0

    )

    [PSCustomObject]@{

        PSTypeName  = 'PCXLab.EditJob'

        SourcePath  = $SourcePath

        OutputPath  = $OutputPath

        FilterGraph = $FilterGraph

        VideoCodec  = $VideoCodec

        AudioCodec  = $AudioCodec

        InputIndex  = $InputIndex

        SampleRate  = $SampleRate

    }

}