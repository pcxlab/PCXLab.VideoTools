function Import-PCXEditPoint {

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(

        [Parameter(Mandatory)]
        [ValidateScript({
                Test-Path $_ -PathType Leaf
            })]
        [string]$Path

    )

    $Document = Read-PCXImportDocument `
        -Path $Path `
        -CollectionName 'EditPoints'

    foreach ($Item in $Document.EditPoints) {

        New-PCXEditPointObject `
            -SourcePath $Item.SourcePath `
            -Start (ConvertTo-PCXTimeSpan $Item.Start) `
            -End (ConvertTo-PCXTimeSpan $Item.End) `
            -Duration (ConvertTo-PCXTimeSpan $Item.Duration) `
            -Classification $Item.Classification `
            -Reason $Item.Reason `
            -Confidence $Item.Confidence

    }

}