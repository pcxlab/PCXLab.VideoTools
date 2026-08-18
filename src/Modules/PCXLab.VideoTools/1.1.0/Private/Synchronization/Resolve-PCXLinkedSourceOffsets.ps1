function Resolve-PCXLinkedSourceOffsets {

    <#
    .SYNOPSIS
        Creates SourceOffset entries for linked media sources.

    .DESCRIPTION
        After primary sources have been synchronized, this function resolves
        any linked sources (e.g., '.webcam.mp4' recordings) that inherit the
        offset of another source identified by LinkedSourceId.

        A linked source is not synchronized on its own. Instead, its offset is
        derived from the linked primary source's SourceOffset plus the linked
        source's own OffsetHint (default 0.0).

        The resulting SourceOffset is added to the provided collection so the
        linked source becomes a normal participant in the synchronized timeline.

        If a SourceOffset already exists for a linked source, no new offset is
        created, making this function idempotent.

    .PARAMETER ReferenceSource
        PCXLab.MediaSource used as the synchronization reference.

    .PARAMETER Sources
        All PCXLab.MediaSource objects participating in the recording session.

    .PARAMETER SourceOffsets
        Mutable collection of PCXLab.SourceOffset objects. New offsets for linked
        sources are appended in-place.
    #>

    [CmdletBinding()]
    [OutputType([void])]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ReferenceSource,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.Generic.IList[object]]$Sources,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.Generic.IList[object]]$SourceOffsets

    )

    if ($Sources.Count -eq 0) {
        return
    }

    $offsetBySourceId = @{}

    foreach ($offset in $SourceOffsets) {

        if ($offset.PSTypeNames -notcontains 'PCXLab.SourceOffset') {
            throw 'SourceOffsets must contain PCXLab.SourceOffset objects.'
        }

        $offsetBySourceId[$offset.SourceId] = $offset

    }

    foreach ($source in $Sources) {

        if ([string]::IsNullOrWhiteSpace($source.LinkedSourceId)) {
            continue
        }

        if ($offsetBySourceId.ContainsKey($source.Id)) {
            continue
        }

        if ($source.LinkedSourceId -eq $ReferenceSource.Id) {

            # Linked directly to the reference source.
            # The reference defines time zero, so the inherited offset is exact.
            
            $inheritedOffset = 0.0
            $confidence = 1.0

        }
        elseif ($offsetBySourceId.ContainsKey($source.LinkedSourceId)) {

            # Linked to another synchronized source.

            $linkedOffset = $offsetBySourceId[$source.LinkedSourceId]

            $inheritedOffset = [double]$linkedOffset.OffsetSeconds
            $confidence = $linkedOffset.Confidence

        }
        else {

            continue

        }

        if ($null -ne $source.OffsetHint) {
            $inheritedOffset += [double]$source.OffsetHint
        }

        $newOffset = New-PCXSourceOffsetObject `
            -SourceId $source.Id `
            -ReferenceId $ReferenceSource.Id `
            -SourcePath $source.Path `
            -ReferencePath $ReferenceSource.Path `
            -OffsetSeconds $inheritedOffset `
            -Confidence $confidence `
            -Method 'Linked'

        $SourceOffsets.Add($newOffset)
        $offsetBySourceId[$source.Id] = $newOffset

    }

}
