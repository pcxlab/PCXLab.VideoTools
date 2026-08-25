function Import-PCXSilence {

    <#
    .SYNOPSIS
        Imports previously exported silence analysis.
    
    .PARAMETER Path
        JSON file created by Export-PCXSilence.
    
    .EXAMPLE
        Import-PCXSilence Test.silence.json
    #>
    
    [CmdletBinding()]
    param(
    
        [Parameter(Mandatory)]
        [ValidateScript({
    
                Test-Path $_ -PathType Leaf
    
            })]
        [string]$Path
    
    )
    
    $document =
    Get-Content `
        -LiteralPath $Path `
        -Raw |
    ConvertFrom-Json
    
    foreach ($item in $document.Silence) {

        New-PCXSilenceObject `
            -SourcePath $item.SourcePath `
            -Start (ConvertTo-PCXTimeSpan $item.Start) `
            -End (ConvertTo-PCXTimeSpan $item.End) `
            -DurationSeconds $item.DurationSeconds
    
    }
    
}