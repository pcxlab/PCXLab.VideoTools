function Get-PCXContext {

    <#
    .SYNOPSIS
        Returns the current PCXLab.VideoTools runtime context.

    .DESCRIPTION
        Retrieves the internal runtime context for the current
        module session. The context contains information used
        internally by the module, including important paths and
        runtime state.

    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return $script:PCXContext
}