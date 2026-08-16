function Resolve-PCXSourceRenderingMode {

    <#
    .SYNOPSIS
        Resolves a MediaSource's RenderingMode to a concrete value.

    .DESCRIPTION
        Pure resolver that inspects a PCXLab.MediaSource and returns whether
        this source should be rendered as an edited output.

        If the source has an explicit non-Auto mode, that value is returned.
        If the mode is Auto, the resolver selects a default based on the
        source's Role and video capabilities:

        - Enabled when the source has video and is not an Audio-only source.
        - Disabled for Audio-only sources or sources without video.

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

    if ($Source.RenderingMode -and $Source.RenderingMode -ne 'Auto') {
        return $Source.RenderingMode
    }

    if (-not $Source.MediaInformation) {
        return 'Disabled'
    }

    if ($Source.Role -eq 'Audio') {
        return 'Disabled'
    }

    if ($Source.MediaInformation.HasVideo) {
        return 'Enabled'
    }

    return 'Disabled'

}
