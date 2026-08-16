function Sync-PCXMedia {

    <#
    .SYNOPSIS
        Synchronizes multiple media sources.

    .DESCRIPTION
        Determines relative timing offsets between two or more media
        sources and returns a PCXLab.MediaSynchronization result.

    .PARAMETER Sources
        PCXLab.MediaSource objects received from the pipeline.

    .PARAMETER Strategy
        Synchronization strategy to use. Default is AudioCorrelation.

    .PARAMETER ReferenceSourceId
        Optional identifier of the source to use as the timing reference.
        If omitted, the first source is used.

    .PARAMETER MinimumConfidence
        Minimum confidence threshold (0.0 - 1.0).

    .PARAMETER MaxOffsetSeconds
        Maximum absolute offset to search, in seconds.

    .OUTPUTS
        PCXLab.MediaSynchronization
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.MediaSynchronization')]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$Sources,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Strategy = 'AudioCorrelation',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ReferenceSourceId,

        [Parameter()]
        [ValidateRange(0.0, 1.0)]
        [double]$MinimumConfidence = 0.30,

        [Parameter()]
        [ValidateRange(0, 300)]
        [Nullable[double]]$MaxOffsetSeconds

    )

    begin {

        $SourceList = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($Sources.PSTypeNames -notcontains 'PCXLab.MediaSource') {
            throw 'Sources must be PCXLab.MediaSource objects.'
        }

        $SourceList.Add($Sources)

    }

    end {

        if ($SourceList.Count -lt 2) {
            throw 'At least two media sources are required for synchronization.'
        }

        # Resolve reference source
        $referenceSource = $SourceList[0]

        if (-not [string]::IsNullOrWhiteSpace($ReferenceSourceId)) {

            $resolved = @($SourceList | Where-Object { $_.Id -eq $ReferenceSourceId })

            if ($resolved.Count -eq 0) {
                throw "Reference source '$ReferenceSourceId' was not found."
            }

            if ($resolved.Count -gt 1) {
                throw "Multiple sources were found with Id '$ReferenceSourceId'."
            }

            $referenceSource = $resolved[0]

        }

        # Validate strategy
        if ($Strategy -ne 'AudioCorrelation') {
            throw "Synchronization strategy '$Strategy' is not supported."
        }

        # Validate reference source audio capability
        if (-not $referenceSource.MediaInformation.HasAudio) {
            throw "Reference source '$($referenceSource.Id)' must contain audio for the AudioCorrelation strategy."
        }

        $tempPath = Get-PCXSynchronizationTempPath

        try {

            $sourceOffsets = [System.Collections.Generic.List[object]]::new()

            foreach ($source in $SourceList) {

                if ($source.Id -eq $referenceSource.Id) { continue }

                $synchronizationMethod = Resolve-PCXSourceSynchronizationMethod -Source $source

                if ($synchronizationMethod -eq 'AudioCorrelation') {

                    $correlationArguments = @{
                        ReferenceSource  = $referenceSource
                        TargetSource     = $source
                        MinimumConfidence = $MinimumConfidence
                        TempPath         = $tempPath
                    }

                    if ($null -ne $MaxOffsetSeconds) {
                        $correlationArguments['MaxOffsetSeconds'] = $MaxOffsetSeconds
                    }

                    $offset = Measure-PCXSourceOffsetAudioCorrelation @correlationArguments

                }
                elseif ($synchronizationMethod -eq 'OffsetHint') {

                    $offset = New-PCXSourceOffsetObject `
                        -SourceId $source.Id `
                        -ReferenceId $referenceSource.Id `
                        -SourcePath $source.Path `
                        -ReferencePath $referenceSource.Path `
                        -OffsetSeconds $source.OffsetHint `
                        -Confidence 0 `
                        -Method 'OffsetHint'

                }
                elseif ($synchronizationMethod -eq 'None') {

                    continue

                }
                else {

                    throw "Synchronization method '$synchronizationMethod' is not supported for source '$($source.Id)'."

                }

                $sourceOffsets.Add($offset)

            }

            $timeline = Build-PCXSynchronizationTimeline `
                -ReferenceSource $referenceSource `
                -Sources $SourceList `
                -SourceOffsets $sourceOffsets

            $synchronizationArguments = @{
                Sources           = $SourceList
                Timeline          = $timeline
                Strategy          = $Strategy
                MinimumConfidence = $MinimumConfidence
            }

            if ($null -ne $MaxOffsetSeconds) {
                $synchronizationArguments['MaxOffsetSeconds'] = $MaxOffsetSeconds
            }

            New-PCXMediaSynchronizationObject @synchronizationArguments

        }
        finally {

            if (Test-Path -LiteralPath $tempPath) {
                Remove-Item -LiteralPath $tempPath -Recurse -Force
            }

        }

    }

}
