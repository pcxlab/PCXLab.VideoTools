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

    foreach ($Item in $InputObject.Analysis.Silence) {

        if ($Item.PSTypeNames -notcontains 'PCXLab.Silence') {

            $Item.PSObject.TypeNames.Insert(
                0,
                'PCXLab.Silence'
            )

        }

        #
        # Restore TimeSpan properties
        #

        $Item.Start = [TimeSpan]::FromTicks(
            [Int64]$Item.Start.Ticks
        )

        $Item.End = [TimeSpan]::FromTicks(
            [Int64]$Item.End.Ticks
        )

        $Item.Duration = [TimeSpan]::FromTicks(
            [Int64]$Item.Duration.Ticks
        )

    }

}

#
# Video Segments
#

if ($null -ne $InputObject.Analysis.Segments) {

    foreach ($Item in $InputObject.Analysis.Segments) {

        if ($Item.PSTypeNames -notcontains 'PCXLab.VideoSegment') {

            $Item.PSObject.TypeNames.Insert(
                0,
                'PCXLab.VideoSegment'
            )

        }

    }

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