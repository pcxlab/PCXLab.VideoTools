function New-PCXMediaSourceObject {

    <#
    .SYNOPSIS
        Creates a PCXLab.MediaSource object.

    .DESCRIPTION
        Represents an input media source for the synchronization engine.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Label,

        [Parameter()]
        [ValidateSet(
            'Auto',
            'Primary',
            'Video',
            'Audio'
        )]
        [string]$Role = 'Auto',

        [Parameter()]
        [ValidateSet(
            'Auto',
            'Video',
            'Audio'
        )]
        [string]$SourceType = 'Auto',

        [Parameter()]
        [int]$AudioStreamIndex = -1,

        [Parameter()]
        [Nullable[double]]$OffsetHint,

        [Parameter()]
        [object]$MediaInformation

    )

    if ($Role -eq 'Auto') {

        $hasVideo = $false
        $hasAudio = $false

        if ($MediaInformation -and ($MediaInformation.PSTypeNames -contains 'PCXLab.MediaInformation')) {
            $hasVideo = $MediaInformation.HasVideo
            $hasAudio = $MediaInformation.HasAudio
        }

        if ($hasVideo -and $hasAudio) {
            $Role = 'Primary'
        }
        elseif ($hasAudio) {
            $Role = 'Audio'
        }
        elseif ($hasVideo) {
            $Role = 'Video'
        }
        else {
            $Role = 'Primary'
        }

    }

    if ($SourceType -eq 'Auto') {

        if ($Role -eq 'Audio') {
            $SourceType = 'Audio'
        }
        elseif ($Role -eq 'Video') {
            $SourceType = 'Video'
        }
        else {
            $SourceType = 'Video'
        }

    }

    [PSCustomObject]@{

        PSTypeName = 'PCXLab.MediaSource'

        Path       = $Path
        Id         = $Id
        Label      = $Label
        Role       = $Role
        SourceType = $SourceType

        AudioStreamIndex = $AudioStreamIndex

        OffsetHint = $OffsetHint

        MediaInformation = $MediaInformation

    }

}
