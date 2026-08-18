function Get-PCXArtifactDefinitions {

    <#
    .SYNOPSIS
        Returns the static artifact definition catalog.

    .DESCRIPTION
        Provides a single shared lookup of all artifact types, their
        suffixes, extensions, and separator rules used by
        Get-PCXArtifactPath.

        Configurable values (for example, the edited-video suffix) are
        described by metadata and resolved at lookup time, keeping the
        catalog itself static and immutable.

    .OUTPUTS
        System.Collections.Hashtable
    #>

    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return $script:PCXArtifactDefinitions

}

$script:PCXArtifactDefinitions = @{

    Analysis          = @{ Suffix = 'Analysis'; Extension = '.json'; Separator = '-' }
    Silence           = @{ Suffix = 'Silence'; Extension = '.json'; Separator = '-' }
    EditPoint         = @{ Suffix = 'EditPoints'; Extension = '.json'; Separator = '-' }
    VideoSegment      = @{ Suffix = 'VideoSegments'; Extension = '.json'; Separator = '-' }
    RecordingSession  = @{ Suffix = 'RecordingSession'; Extension = '.json'; Separator = '-'; PrefixSource = 'DirectoryName' }
    PremiereMarker    = @{ Suffix = 'PremiereMarkers'; Extension = '.jsx'; Separator = '-' }
    PremiereEditPoint = @{ Suffix = 'PremiereEditPoints'; Extension = '.jsx'; Separator = '-' }
    EditedVideo       = @{ ConfiguredSuffixSetting = 'Output.Suffix'; DefaultSuffix = '-Edited'; Extension = $null; Separator = '' }

}
