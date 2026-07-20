function Invoke-PCXFFprobe {

    <#
    .SYNOPSIS
        Executes FFprobe and returns its JSON output.
    
    .DESCRIPTION
        Invokes FFprobe against a media file and converts the JSON
        response into a PowerShell object.
    
    .PARAMETER Path
        Media file to analyse.
    
    .OUTPUTS
        PSCustomObject
    
    .NOTES
        Internal function.
    #>
    
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Path
        )
    
        if (-not (Test-Path -LiteralPath $Path))
        {
            throw "Video file not found: $Path"
        }
    
        $FFprobe = Get-PCXToolPath -Tool FFprobe
        
    
        if (-not $FFprobe)
        {
            throw "Unable to locate ffprobe.exe."
        }
    
        $Arguments = @(
            '-v','quiet'
            '-print_format','json'
            '-show_format'
            '-show_streams'
            $Path
        )
    
        $Json = & $FFprobe @Arguments
    
        if ($LASTEXITCODE -ne 0)
        {
            throw "FFprobe failed with exit code $LASTEXITCODE."
        }
    
        return ($Json | ConvertFrom-Json)
    }