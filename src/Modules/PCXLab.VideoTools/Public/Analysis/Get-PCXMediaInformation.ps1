function Get-PCXMediaInformation {

    <#
    .SYNOPSIS
        Gets comprehensive media information for one or more media files.
    
    .DESCRIPTION
        Combines video and audio information into a single object.
    
    .PARAMETER Path
        One or more media files.
    
    .OUTPUTS
        PCXLab.MediaInformation
    #>
    
    [CmdletBinding()]
    [OutputType('PCXLab.MediaInformation')]
    param(
    
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path
    
    )
    
    process {
    
        foreach ($MediaFile in $Path) {
    
            $Video = Get-PCXVideoInformation -Path $MediaFile
            $Audio = Get-PCXAudioInformation -Path $MediaFile
    
            New-PCXMediaInformationObject `
                -Video $Video `
                -Audio $Audio
    
        }
    
    }
    
}