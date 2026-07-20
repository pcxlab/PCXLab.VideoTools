function Get-PCXVideoInformation {

    <#
    .SYNOPSIS
        Gets information about one or more video files.
    
    .DESCRIPTION
        Uses FFprobe to analyse one or more media files and returns a
        standardized PCXLab video information object.
    
    .PARAMETER Path
        One or more video files.
    
    .EXAMPLE
        Get-PCXVideoInformation -Path "C:\Videos\Lesson01.mp4"
    
    .EXAMPLE
        Get-ChildItem C:\Videos *.mp4 |
            Get-PCXVideoInformation
    
    .OUTPUTS
        PCXLab.VideoInformation
    #>
    
    [CmdletBinding()]
    [OutputType('PCXLab.VideoInformation')]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path
    )
    
    process {
    
        foreach ($Video in $Path) {

            $RawVideoInformation = Invoke-PCXFFprobe -Path $Video
        
            ConvertTo-PCXVideoInformation -InputObject $RawVideoInformation
        
        }
    
    }
    
}