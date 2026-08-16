function Get-PCXEditPoint {

    <#
    .SYNOPSIS
        Converts silence analysis into recommended edit points.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject

    )
  
    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.Silence') {
            throw 'InputObject must be a PCXLab.Silence object.'
        }
    
        $Rule = Get-PCXEditPointRule `
            -Classification $InputObject.Classification

        if ($null -eq $Rule) {
            return
        }

        if (-not $Rule.Enabled) {

            Write-Verbose "Skipping '$($InputObject.Classification)' edit point: rule is disabled."

            return

        }
    
        New-PCXEditPointObject `
            -SourcePath $InputObject.SourcePath `
            -Start $InputObject.Start `
            -End $InputObject.End `
            -Duration $InputObject.Duration `
            -Classification $InputObject.Classification `
            -Reason $Rule.Reason `
            -Confidence $Rule.Confidence
    
    }

}