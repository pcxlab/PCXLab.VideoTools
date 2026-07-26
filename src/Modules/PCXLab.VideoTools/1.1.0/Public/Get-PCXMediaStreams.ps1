function Get-PCXMediaStreams {

    <#
    .SYNOPSIS
        Gets all media streams from one or more media files.
    
    .DESCRIPTION
        Retrieves all streams (Video, Audio, Subtitle, Data, Attachment, etc.)
        from a media file and returns standardized PCXLab.MediaStream objects.
    
    .PARAMETER Path
        One or more media file paths.
    
    .EXAMPLE
        Get-PCXMediaStreams -Path "C:\Videos\Test.mp4"
    
    .OUTPUTS
        PCXLab.MediaStream
    #>
    
        [CmdletBinding()]
        [OutputType('PCXLab.MediaStream')]
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
    
                ConvertTo-PCXMediaStreams -InputObject $Media
    
            }
    
        }
    
    }