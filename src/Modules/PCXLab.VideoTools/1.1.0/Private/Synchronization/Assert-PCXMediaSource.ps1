function Assert-PCXMediaSource {

    <#
    .SYNOPSIS
        Validates that an object is a PCXLab.MediaSource with valid MediaInformation.

    .DESCRIPTION
        Internal helper used by capability-check and resolver functions to avoid
        duplicating MediaSource/MediaInformation validation.

        Throws if the input is not a PCXLab.MediaSource or if MediaInformation is
        present but not a PCXLab.MediaInformation object.

    .PARAMETER Source
        The object to validate.

    .OUTPUTS
        None
    #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Source

    )

    if ($Source.PSTypeNames -notcontains 'PCXLab.MediaSource') {
        throw 'Source must be a PCXLab.MediaSource object.'
    }

    if ($Source.MediaInformation -and
        ($Source.MediaInformation.PSTypeNames -notcontains 'PCXLab.MediaInformation')) {
        throw 'Source.MediaInformation must be a PCXLab.MediaInformation object.'
    }

}
