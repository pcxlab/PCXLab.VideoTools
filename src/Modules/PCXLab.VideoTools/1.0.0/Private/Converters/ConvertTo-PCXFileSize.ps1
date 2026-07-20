function ConvertTo-PCXFileSize {

    <#
    .SYNOPSIS
        Converts a file size in bytes to a readable string.

    .PARAMETER Bytes
        File size in bytes.

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [Int64]$Bytes

    )

    switch ($Bytes) {

        {$_ -ge 1TB} { return "{0:N2} TB" -f ($Bytes / 1TB) }
        {$_ -ge 1GB} { return "{0:N2} GB" -f ($Bytes / 1GB) }
        {$_ -ge 1MB} { return "{0:N2} MB" -f ($Bytes / 1MB) }
        {$_ -ge 1KB} { return "{0:N2} KB" -f ($Bytes / 1KB) }

        default { return "$Bytes Bytes" }

    }

}