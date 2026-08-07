function New-PCXVideoAnalysisObject {

<#
.SYNOPSIS
    Creates a PCXLab.VideoAnalysis object.

.DESCRIPTION
    Represents the complete analysis of a media file.

.OUTPUTS
    PCXLab.VideoAnalysis
#>

[CmdletBinding()]
[OutputType([PSCustomObject])]
param(

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SourcePath,

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [object]$Media,

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [object[]]$Silence,

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [object[]]$Segments,

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [object]$SilenceStatistics

)

[PSCustomObject]@{

    PSTypeName = 'PCXLab.VideoAnalysis'

    SourcePath = $SourcePath

    Created = Get-Date

    ModuleVersion = Get-PCXModuleVersion

    Media = $Media

    Analysis = [PSCustomObject]@{

        Silence = $Silence

        Segments = $Segments

        SilenceStatistics = $SilenceStatistics

    }

}

}