function Restore-PCXVideoAnalysisTypes {

<#
.SYNOPSIS
    Restores custom PCXLab type names after importing JSON.

.DESCRIPTION
    ConvertFrom-Json returns PSCustomObject instances and removes
    custom PSTypeNames. This function restores all nested PCXLab
    types so imported analysis objects behave exactly like freshly
    generated analysis objects.

.PARAMETER InputObject
    PCXLab.VideoAnalysis object.

.OUTPUTS
    PCXLab.VideoAnalysis
#>

[CmdletBinding()]
[OutputType('PCXLab.VideoAnalysis')]
param(

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [object]$InputObject

)

#
# VideoAnalysis
#

if ($InputObject.PSTypeNames -notcontains 'PCXLab.VideoAnalysis') {

    $InputObject.PSObject.TypeNames.Insert(
        0,
        'PCXLab.VideoAnalysis'
    )

}

#
# Media
#

if ($null -ne $InputObject.Media) {

    if ($InputObject.Media.PSTypeNames -notcontains 'PCXLab.MediaInformation') {

        $InputObject.Media.PSObject.TypeNames.Insert(
            0,
            'PCXLab.MediaInformation'
        )

    }

}

#
# Silence
#

if ($null -ne $InputObject.Analysis.Silence) {

    Restore-PCXAnalysisEventTimeSpans `
        -Items $InputObject.Analysis.Silence `
        -TypeName 'PCXLab.Silence'

}

#
# BlackFrames
#

if ($null -ne $InputObject.Analysis.BlackFrames) {

    Restore-PCXAnalysisEventTimeSpans `
        -Items $InputObject.Analysis.BlackFrames `
        -TypeName 'PCXLab.BlackFrame'

}

#
# Silence Statistics
#

if ($null -ne $InputObject.Analysis.SilenceStatistics) {

    if ($InputObject.Analysis.SilenceStatistics.PSTypeNames -notcontains 'PCXLab.SilenceReport') {

        $InputObject.Analysis.SilenceStatistics.PSObject.TypeNames.Insert(
            0,
            'PCXLab.SilenceReport'
        )

    }

}

return $InputObject

}