function Resolve-PCXSourceAnalysisMode {

    <#
    .SYNOPSIS
        Resolves a MediaSource's AnalysisMode to a concrete value.

    .DESCRIPTION
        Pure resolver that inspects a PCXLab.MediaSource and returns whether
        silence analysis should be performed on this source.

        If the source has an explicit non-Auto mode, that value is returned.
        If the mode is Auto, the resolver selects a default based on the
        source's audio capabilities, with the legacy Role property used only
        as a backward-compatibility fallback:

        - Disabled when the source has no audio suitable for analysis.
        - Enabled when the source has audio suitable for analysis and is not
          explicitly a Video-only source.
        - Disabled for Video sources.

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

    if ($Source.AnalysisMode -and $Source.AnalysisMode -ne 'Auto') {
        return $Source.AnalysisMode
    }

    if (-not (Test-PCXSourceAudioSuitableForAnalysis -Source $Source)) {
        return 'Disabled'
    }

    if ($Source.Role -eq 'Video') {
        return 'Disabled'
    }

    return 'Enabled'

}
