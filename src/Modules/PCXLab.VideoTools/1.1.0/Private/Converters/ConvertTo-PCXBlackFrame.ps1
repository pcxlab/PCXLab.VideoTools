function ConvertTo-PCXBlackFrame {

    <#
    .SYNOPSIS
        Converts FFmpeg blackdetect output into PCXLab.BlackFrame objects.

    .DESCRIPTION
        Parses the log lines produced by FFmpeg's blackdetect filter and
        emits strongly typed PCXLab.BlackFrame objects.
    #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$InputObject,

        [Parameter(Mandatory)]
        [string]$SourcePath

    )

    begin {

        $startRegex = [regex]'black_start:\s*(?<Start>[0-9]+(?:\.[0-9]+)?)'
        #$endRegex = [regex]'black_end:\s*(?<End>[0-9]+(?:\.[0-9]+)?)\s*\|\s*black_duration:\s*(?<Duration>[0-9]+(?:\.[0-9]+)?)'
        $endRegex = [regex]'black_end:\s*(?<End>[0-9]+(?:\.[0-9]+)?)\s*(?:\|\s*)?black_duration:\s*(?<Duration>[0-9]+(?:\.[0-9]+)?)'
        $currentStart = $null

    }

    process {

        if ([string]::IsNullOrWhiteSpace($InputObject)) { return }

        $startMatch = $startRegex.Match($InputObject)

        if ($startMatch.Success) {
            $currentStart = [double]$startMatch.Groups['Start'].Value
        }

        $endMatch = $endRegex.Match($InputObject)

        if ($endMatch.Success -and $null -ne $currentStart) {

            $end = [double]$endMatch.Groups['End'].Value
            $duration = [double]$endMatch.Groups['Duration'].Value

            New-PCXBlackFrameObject `
                -SourcePath $SourcePath `
                -Start ([TimeSpan]::FromSeconds($currentStart)) `
                -End ([TimeSpan]::FromSeconds($end)) `
                -DurationSeconds $duration

            $currentStart = $null

        }

    }

}
