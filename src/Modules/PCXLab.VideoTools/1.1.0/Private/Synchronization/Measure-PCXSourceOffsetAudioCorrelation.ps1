function Measure-PCXSourceOffsetAudioCorrelation {

    <#
    .SYNOPSIS
        Measures the audio-correlation offset of a target source relative
        to a reference source.

    .DESCRIPTION
        Extracts temporary correlation WAV files for the reference and
        target media sources, runs the multi-stage audio correlation
        algorithm, and returns a PCXLab.SourceOffset object.

    .PARAMETER ReferenceSource
        PCXLab.MediaSource object used as the timing reference.

    .PARAMETER TargetSource
        PCXLab.MediaSource object to measure.

    .PARAMETER MinimumConfidence
        Minimum correlation confidence required (0.0 - 1.0).

    .PARAMETER MaxOffsetSeconds
        Maximum absolute offset to search.

    .PARAMETER TempPath
        Directory for temporary WAV files.

    .OUTPUTS
        PCXLab.SourceOffset
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.SourceOffset')]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ReferenceSource,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$TargetSource,

        [Parameter(Mandatory)]
        [ValidateRange(0.0, 1.0)]
        [double]$MinimumConfidence,

        [Parameter()]
        [ValidateRange(0, 300)]
        [Nullable[double]]$MaxOffsetSeconds,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TempPath

    )

    if ($ReferenceSource.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'ReferenceSource must be a PCXLab.MediaSource object.'
    }

    if ($TargetSource.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'TargetSource must be a PCXLab.MediaSource object.'
    }

    $maxOffset = 60.0
    if ($null -ne $MaxOffsetSeconds) {
        $maxOffset = [double]$MaxOffsetSeconds
    }
    $correlationDurationSeconds = [math]::Ceiling((3 * $maxOffset) + 10)

    $referenceWav = Export-PCXAudioCorrelationWav `
        -Source $ReferenceSource `
        -OutputDirectory $TempPath `
        -DurationSeconds $correlationDurationSeconds

    $targetWav = Export-PCXAudioCorrelationWav `
        -Source $TargetSource `
        -OutputDirectory $TempPath `
        -DurationSeconds $correlationDurationSeconds

    try {

        $correlationArguments = @{
            ReferencePath = $referenceWav.FullName
            TargetPath    = $targetWav.FullName
        }

        if ($null -ne $MaxOffsetSeconds) {
            $correlationArguments['MaxOffsetSeconds'] = $MaxOffsetSeconds
        }

        $evidence = Measure-PCXAudioCorrelation @correlationArguments

        if ($evidence.Correlation -lt $MinimumConfidence) {
            throw (
                "Correlation confidence {0:F4} is below the minimum threshold {1:F4} for '{2}'." -f
                $evidence.Correlation,
                $MinimumConfidence,
                $TargetSource.Path
            )
        }

        New-PCXSourceOffsetObject `
            -SourceId $TargetSource.Id `
            -ReferenceId $ReferenceSource.Id `
            -SourcePath $TargetSource.Path `
            -ReferencePath $ReferenceSource.Path `
            -OffsetSeconds ($evidence.PeakSample / $evidence.SampleRate) `
            -Confidence $evidence.Correlation `
            -Method 'AudioCorrelation' `
            -Evidence $evidence

    }
    finally {

        if ($referenceWav -and (Test-Path -LiteralPath $referenceWav.FullName)) {
            Remove-Item -LiteralPath $referenceWav.FullName -Force
        }

        if ($targetWav -and (Test-Path -LiteralPath $targetWav.FullName)) {
            Remove-Item -LiteralPath $targetWav.FullName -Force
        }

    }

}
