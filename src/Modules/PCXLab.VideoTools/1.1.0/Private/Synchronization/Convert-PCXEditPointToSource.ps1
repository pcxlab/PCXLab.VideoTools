function Convert-PCXEditPointToSource {

    <#
    .SYNOPSIS
        Translates a reference edit point to a synchronized source.

    .DESCRIPTION
        Applies a source offset to a PCXLab.EditPoint so the same edit
        decision can be made on the target recording.

    .PARAMETER EditPoint
        PCXLab.EditPoint expressed in reference time.

    .PARAMETER SourceOffset
        PCXLab.SourceOffset describing the target source's offset relative
        to the reference.

    .OUTPUTS
        PCXLab.EditPoint
    #>

    [CmdletBinding()]
    [OutputType('PCXLab.EditPoint')]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$EditPoint,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$SourceOffset

    )

    if ($EditPoint.PSTypeNames -notcontains 'PCXLab.EditPoint') {
        throw 'EditPoint must be a PCXLab.EditPoint object.'
    }

    if ($SourceOffset.PSTypeNames -notcontains 'PCXLab.SourceOffset') {
        throw 'SourceOffset must be a PCXLab.SourceOffset object.'
    }

    $offset = $SourceOffset.OffsetSeconds

    $startSeconds = $EditPoint.StartSeconds - $offset
    $endSeconds   = $EditPoint.EndSeconds - $offset

    if ($endSeconds -le 0) {
        return
    }

    if ($startSeconds -lt 0) {
        $startSeconds = 0
    }

    $durationSeconds = $endSeconds - $startSeconds

    if ($durationSeconds -le 0) {
        return
    }

    $start    = [TimeSpan]::FromSeconds($startSeconds)
    $end      = [TimeSpan]::FromSeconds($endSeconds)
    $duration = [TimeSpan]::FromSeconds($durationSeconds)

    New-PCXEditPointObject `
        -SourcePath $SourceOffset.SourcePath `
        -Start $start `
        -End $end `
        -Duration $duration `
        -Classification $EditPoint.Classification `
        -Reason $EditPoint.Reason `
        -Confidence $EditPoint.Confidence

}
