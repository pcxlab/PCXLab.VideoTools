function Import-PCXVideoSegment {

    <#
    .SYNOPSIS
        Imports PCXLab.VideoSegment objects from a JSON file.

    .DESCRIPTION
        Imports a previously exported video segment document and restores
        all PCXLab custom types and TimeSpan properties.

    .PARAMETER Path
        Path to a VideoSegment JSON file.

    .EXAMPLE
        Import-PCXVideoSegment -Path 'C:\Videos\Test-VideoSegments.json'

    .OUTPUTS
        PCXLab.VideoSegment
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.VideoSegment')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path

    )

    process {

        foreach ($File in $Path) {

            if (-not (Test-Path -LiteralPath $File)) {
                throw "File not found: $File"
            }

            $Document = Get-Content `
                -LiteralPath $File `
                -Raw |
                ConvertFrom-Json

            if ($null -eq $Document.VideoSegments) {
                throw "File '$File' is not a PCXLab.VideoSegment export."
            }

            foreach ($Item in $Document.VideoSegments) {

                $Start = [TimeSpan]::FromTicks([Int64]$Item.Start.Ticks)
                $End = [TimeSpan]::FromTicks([Int64]$Item.End.Ticks)

                $AnalysisEvents = [System.Collections.Generic.List[object]]::new()
                $eventsProp = $Item.PSObject.Properties['AnalysisEvents']
                if ($null -ne $eventsProp -and $null -ne $eventsProp.Value) {
                    foreach ($Event in $eventsProp.Value) {
                        $startProp = $Event.PSObject.Properties['Start']
                        if ($null -ne $startProp -and $null -ne $startProp.Value -and $null -ne $startProp.Value.Ticks) {
                            $Event.Start = [TimeSpan]::FromTicks([Int64]$startProp.Value.Ticks)
                        }

                        $endProp = $Event.PSObject.Properties['End']
                        if ($null -ne $endProp -and $null -ne $endProp.Value -and $null -ne $endProp.Value.Ticks) {
                            $Event.End = [TimeSpan]::FromTicks([Int64]$endProp.Value.Ticks)
                        }

                        $durationProp = $Event.PSObject.Properties['Duration']
                        if ($null -ne $durationProp -and $null -ne $durationProp.Value -and $null -ne $durationProp.Value.Ticks) {
                            $Event.Duration = [TimeSpan]::FromTicks([Int64]$durationProp.Value.Ticks)
                        }

                        $eventTypeProp = $Event.PSObject.Properties['EventType']
                        $eventType = if ($null -ne $eventTypeProp) { $eventTypeProp.Value } else { $null }

                        if ($eventType -eq 'Silence' -and $Event.PSTypeNames -notcontains 'PCXLab.Silence') {
                            $Event.PSObject.TypeNames.Insert(0, 'PCXLab.Silence')
                        }
                        elseif ($eventType -eq 'BlackFrame' -and $Event.PSTypeNames -notcontains 'PCXLab.BlackFrame') {
                            $Event.PSObject.TypeNames.Insert(0, 'PCXLab.BlackFrame')
                        }

                        [void]$AnalysisEvents.Add($Event)
                    }
                }

                $horizontalFlip = if ($null -ne $Item.PSObject.Properties['HorizontalFlip'] -and $null -ne $Item.HorizontalFlip) {
                    [bool]$Item.HorizontalFlip
                }
                else {
                    $false
                }

                New-PCXVideoSegmentObject `
                    -SourcePath $Item.SourcePath `
                    -Start $Start `
                    -End $End `
                    -Action $Item.Action `
                    -AnalysisEvents $AnalysisEvents `
                    -HorizontalFlip $horizontalFlip

            }

        }

    }

}
