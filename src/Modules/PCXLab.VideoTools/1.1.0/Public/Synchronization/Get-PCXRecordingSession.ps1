function Get-PCXRecordingSession {

    <#
    .SYNOPSIS
        Returns a PCXLab.MediaSynchronization result, using the cache when available.

    .DESCRIPTION
        Reuses a previously exported RecordingSession.json cache if one exists
        for the supplied media sources. If no cache exists, this command runs
        Sync-PCXMedia, exports the result to RecordingSession.json, and then
        returns the synchronization object directly.

        This wrapper preserves the public behavior of Sync-PCXMedia while
        avoiding repeated expensive audio-correlation computations.

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

    .PARAMETER CachePath
        Optional path to the RecordingSession.json cache file. If omitted,
        a cache named RecordingSession.json is written beside the first source.

    .EXAMPLE
        $Sources | Get-PCXRecordingSession

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
        [Nullable[double]]$MaxOffsetSeconds,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CachePath

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

        #
        # Resolve cache path
        #

        if ([string]::IsNullOrWhiteSpace($CachePath)) {

            $CachePath = Get-PCXRecordingSessionPath `
                -Sources $SourceList

        }

        #
        # Cache hit
        #

        if (Test-PCXRecordingSessionCache -Path $CachePath) {

            Write-Verbose "Returning cached recording session from '$CachePath'."
            return Import-PCXRecordingSession -Path $CachePath

        }

        #
        # Cache miss
        #

        Write-Verbose "No cache found at '$CachePath'. Running synchronization."

        $Synchronization = $SourceList |
            Sync-PCXMedia `
                -Strategy $Strategy `
                -ReferenceSourceId:$ReferenceSourceId `
                -MinimumConfidence $MinimumConfidence `
                -MaxOffsetSeconds $MaxOffsetSeconds

        $null = $Synchronization |
            Export-PCXRecordingSession `
                -Path $CachePath

        return $Synchronization

    }

}
