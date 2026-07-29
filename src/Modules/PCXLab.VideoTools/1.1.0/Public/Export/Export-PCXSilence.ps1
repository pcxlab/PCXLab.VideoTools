function Export-PCXSilence {

    <#
    .SYNOPSIS
        Exports PCXLab.Silence objects to a JSON file.
    
    .DESCRIPTION
        Saves the output of Find-PCXSilence so it can later be imported
        without running FFmpeg again.
    
    .PARAMETER InputObject
        PCXLab.Silence objects.
    
    .PARAMETER OutputPath
        Destination JSON file.
    
    .EXAMPLE
        Find-PCXSilence -Path Test.mp4 |
            Export-PCXSilence -OutputPath Test.silence.json
    
    .OUTPUTS
        System.IO.FileInfo
    #>
    
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([System.IO.FileInfo])]
        param(
    
            [Parameter(Mandatory, ValueFromPipeline)]
            [ValidateNotNull()]
            [object]$InputObject,
    
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$OutputPath
    
        )
    
        begin {
    
            $silence = [System.Collections.Generic.List[object]]::new()
    
        }
    
        process {
    
            if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
                throw 'InputObject must be a PCXLab.Silence object.'
            }
    
            [void]$silence.Add($InputObject)
    
        }
    
        end {
    
            $resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
    
            $document = [ordered]@{
    
                SchemaVersion = '1.0'
    
                ModuleVersion = '1.1.0'
    
                GeneratedOn = Get-Date
    
                Silence = $silence
    
            }
    
            if ($PSCmdlet.ShouldProcess($resolvedOutputPath, 'Export silence analysis')) {
    
                $document |
                    ConvertTo-Json -Depth 5 |
                    Set-Content `
                        -LiteralPath $resolvedOutputPath `
                        -Encoding utf8
    
                Get-Item $resolvedOutputPath
    
            }
    
        }
    
    }