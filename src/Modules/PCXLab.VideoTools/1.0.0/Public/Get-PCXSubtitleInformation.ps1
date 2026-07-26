function Get-PCXSubtitleInformation {

    <#
    .SYNOPSIS
        Gets subtitle information from one or more media files.
    
    .DESCRIPTION
        Retrieves subtitle information using FFprobe and returns a
        standardized PCXLab.SubtitleInformation object.
    
    .PARAMETER Path
        One or more media file paths.
    
    .EXAMPLE
        Get-PCXSubtitleInformation -Path "C:\Videos\Test.mp4"
    
    .OUTPUTS
        PCXLab.SubtitleInformation
    #>
    
        [CmdletBinding()]
        [OutputType('PCXLab.SubtitleInformation')]
        param(
    
            [Parameter(
                Mandatory,
                Position = 0,
                ValueFromPipeline,
                ValueFromPipelineByPropertyName
            )]
            [Alias('FullName')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Path
    
        )
    
        process {
    
            foreach ($MediaFile in $Path) {
    
                $Media = Invoke-PCXFFprobe -Path $MediaFile
    
                if ($null -eq $Media) {
                    continue
                }
    
                ConvertTo-PCXSubtitleInformation -InputObject $Media
    
            }
    
        }
    
    }