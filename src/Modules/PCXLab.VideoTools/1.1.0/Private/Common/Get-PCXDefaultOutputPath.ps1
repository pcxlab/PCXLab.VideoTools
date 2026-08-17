function Get-PCXDefaultOutputPath {

    <#
    .SYNOPSIS
        Generates a default output path for exported files.

    .DESCRIPTION
        This function is retained for backward compatibility. Where the
        requested suffix maps to a known artifact type, it delegates to
        Get-PCXArtifactPath. For all other suffixes and filenames, the
        original filename generation logic is preserved.

    .PARAMETER SourcePath
        Source media file.

    .PARAMETER Suffix
        Suffix appended to the source filename.

    .PARAMETER Extension
        Output file extension. May be specified with or without a leading '.'.

    .PARAMETER FileName
        Optional fixed filename. When specified, the source filename is not
        used and the output is placed in the same folder as the source with
        the given name.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(
            Mandatory,
            ParameterSetName = 'BySuffix'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Suffix,

        [Parameter(
            Mandatory,
            ParameterSetName = 'BySuffix'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Extension,

        [Parameter(
            Mandatory,
            ParameterSetName = 'ByFileName'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$FileName

    )

    if ($PSCmdlet.ParameterSetName -eq 'ByFileName') {

        $mappedArtifactType = switch ($FileName) {
            'RecordingSession.json' { 'RecordingSession' }
            default                 { $null }
        }

        if ($null -ne $mappedArtifactType) {
            return Get-PCXArtifactPath `
                -SourcePath $SourcePath `
                -ArtifactType $mappedArtifactType
        }

        $Directory = Split-Path $SourcePath -Parent
        return (Join-Path $Directory $FileName)

    }

    $mappedArtifactType = switch ($Suffix) {
        'Analysis'           { 'Analysis' }
        'Silence'            { 'Silence' }
        'EditPoints'         { 'EditPoint' }
        'VideoSegments'      { 'VideoSegment' }
        'PremiereMarkers'    { 'PremiereMarker' }
        'PremiereEditPoints' { 'PremiereEditPoint' }
        default              { $null }
    }

    if ($null -ne $mappedArtifactType) {
        return Get-PCXArtifactPath `
            -SourcePath $SourcePath `
            -ArtifactType $mappedArtifactType
    }

    if ($Extension[0] -ne '.') {
        $Extension = ".$Extension"
    }

    $FileName = "$([System.IO.Path]::GetFileNameWithoutExtension($SourcePath))-$Suffix$Extension"

    $Directory = Split-Path $SourcePath -Parent

    return (Join-Path $Directory $FileName)

}
