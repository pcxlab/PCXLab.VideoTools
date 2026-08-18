function Export-PCXRecordingSession {

    <#
    .SYNOPSIS
        Exports a PCXLab.MediaSynchronization object to a JSON file.

    .DESCRIPTION
        Saves the complete result of synchronizing multiple media sources so
        the expensive audio-correlation computation can be reused without
        running Sync-PCXMedia again.

        Evidence produced by the correlation algorithm is intentionally
        omitted from the persistent cache.

    .PARAMETER InputObject
        PCXLab.MediaSynchronization object.

    .PARAMETER Path
        Destination JSON file.

    .PARAMETER Force
        Overwrite an existing file.

    .EXAMPLE
        Sync-PCXMedia -Sources $Sources |
            Export-PCXRecordingSession

    .EXAMPLE
        Sync-PCXMedia -Sources $Sources |
            Export-PCXRecordingSession `
                -Path 'C:\Cache\RecordingSession.json'

    .OUTPUTS
        System.IO.FileInfo
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(

        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter()]
        [Alias('OutputPath')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Force

    )

    begin {

        $Sessions = [System.Collections.Generic.List[object]]::new()

    }

    process {

        if ($InputObject.PSTypeNames -notcontains 'PCXLab.MediaSynchronization') {
            throw 'InputObject must be a PCXLab.MediaSynchronization object.'
        }

        [void]$Sessions.Add($InputObject)

    }

    end {

        if ($Sessions.Count -eq 0) {
            throw 'No recording session objects were provided.'
        }

        $Session = $Sessions[0]

        #
        # Default output path
        #

        if ([string]::IsNullOrWhiteSpace($Path)) {

            $Path = Get-PCXRecordingSessionPath `
                -Sources $Session.Sources

        }

        #
        # Ensure output folder exists
        #

        $Parent = [System.IO.Path]::GetDirectoryName($Path)

        if ([string]::IsNullOrWhiteSpace($Parent)) {
            throw "Unable to determine parent folder from path '$Path'."
        }

        if (-not (Test-Path -LiteralPath $Parent)) {

            New-Item `
                -ItemType Directory `
                -Path $Parent `
                -Force | Out-Null

        }

        #
        # Build sanitized export items
        #

        $ExportItems = foreach ($Item in $Sessions) {

            $SanitizedOffsets = @()

            if ($null -ne $Item.Timeline.SourceOffsets) {

                foreach ($Offset in $Item.Timeline.SourceOffsets) {

                    $SanitizedOffsets += [PSCustomObject]@{

                        SourceId      = $Offset.SourceId
                        ReferenceId   = $Offset.ReferenceId
                        SourcePath    = $Offset.SourcePath
                        ReferencePath = $Offset.ReferencePath
                        OffsetSeconds = $Offset.OffsetSeconds
                        Confidence    = $Offset.Confidence
                        Method        = $Offset.Method

                    }

                }

            }

            [PSCustomObject]@{

                PSTypeName        = 'PCXLab.MediaSynchronization'

                Created           = $Item.Created
                ModuleVersion     = $Item.ModuleVersion

                Sources           = @(
                    foreach ($Source in $Item.Sources) {

                        $sanitizedSource = [PSCustomObject]@{

                            PSTypeName            = 'PCXLab.MediaSource'

                            Path                  = $Source.Path
                            Id                    = $Source.Id
                            Label                 = $Source.Label
                            Role                  = $Source.Role
                            SourceType            = $Source.SourceType
                            AudioStreamIndex      = $Source.AudioStreamIndex
                            OffsetHint            = $Source.OffsetHint

                            SynchronizationMethod = if ($Source.PSObject.Properties['SynchronizationMethod']) { $Source.SynchronizationMethod } else { 'Auto' }
                            AnalysisMode          = if ($Source.PSObject.Properties['AnalysisMode']) { $Source.AnalysisMode } else { 'Auto' }
                            RenderingMode         = if ($Source.PSObject.Properties['RenderingMode']) { $Source.RenderingMode } else { 'Auto' }

                            MediaInformation      = $Source.MediaInformation

                        }

                        $sanitizedSource

                    }
                )
                Timeline          = [PSCustomObject]@{

                    PSTypeName           = 'PCXLab.SynchronizationTimeline'

                    ReferenceId          = $Item.Timeline.ReferenceId
                    ReferencePath        = $Item.Timeline.ReferencePath
                    ReferenceDuration    = $Item.Timeline.ReferenceDuration

                    TotalDuration        = $Item.Timeline.TotalDuration
                    TotalDurationSeconds = $Item.Timeline.TotalDurationSeconds

                    SourceOffsets        = $SanitizedOffsets
                    Segments             = $Item.Timeline.Segments

                }

                Strategy          = $Item.Strategy
                MinimumConfidence = $Item.MinimumConfidence
                MaxOffsetSeconds  = $Item.MaxOffsetSeconds

            }

        }

        #
        # Build export document
        #

        $Document = New-PCXExportDocument `
            -CollectionName 'MediaSynchronization' `
            -Items $ExportItems

        #
        # Export
        #

        if ($PSCmdlet.ShouldProcess($Path, 'Export recording session')) {

            $Document |
                ConvertTo-Json -Depth 10 |
                Set-Content `
                    -LiteralPath $Path `
                    -Encoding UTF8 `
                    -Force:$Force

            Get-Item -LiteralPath $Path

        }

    }

}
