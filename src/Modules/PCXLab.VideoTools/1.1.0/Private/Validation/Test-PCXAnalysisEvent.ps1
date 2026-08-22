function Test-PCXAnalysisEvent {

    <#
    .SYNOPSIS
        Validates whether an object conforms to the PCXLab analysis event contract.

    .DESCRIPTION
        Inspects an input object to verify the required temporal event properties exist,
        contain valid non-empty values, have correct data types, and satisfy logical timing constraints.

        Required contract properties:
          - SourcePath  [string]
          - Start       [TimeSpan]
          - End         [TimeSpan]
          - Duration    [TimeSpan]
          - EventType   [string]

        Optional convenience properties:
          - Source           [string]
          - StartSeconds     [double]
          - EndSeconds       [double]
          - DurationSeconds  [double]

    .PARAMETER InputObject
        The object to validate.

    .OUTPUTS
        System.Boolean
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(

        [Parameter(Mandatory = $false)]
        [object]$InputObject

    )

    if ($null -eq $InputObject) {
        return $false
    }

    $properties = $InputObject.PSObject.Properties

    #
    # Required Contract Properties
    #
    $requiredProperties = @(
        'SourcePath'
        'Start'
        'End'
        'Duration'
        'EventType'
    )

    foreach ($prop in $requiredProperties) {
        if ($null -eq $properties[$prop]) {
            return $false
        }
    }

    #
    # Type & Value Validation for Required Properties
    #
    if ([string]::IsNullOrWhiteSpace($InputObject.SourcePath) -or
        [string]::IsNullOrWhiteSpace($InputObject.EventType)) {
        return $false
    }

    if ($InputObject.Start -isnot [TimeSpan] -or
        $InputObject.End -isnot [TimeSpan] -or
        $InputObject.Duration -isnot [TimeSpan]) {
        return $false
    }

    #
    # Logical Timing Sanity Check
    #
    if ($InputObject.End -lt $InputObject.Start) {
        return $false
    }

    return $true

}
