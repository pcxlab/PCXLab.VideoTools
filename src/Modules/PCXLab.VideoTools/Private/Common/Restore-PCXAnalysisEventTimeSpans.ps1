function Restore-PCXAnalysisEventTimeSpans {

    <#
    .SYNOPSIS
        Restores type names and TimeSpan properties on deserialized analysis events.

    .DESCRIPTION
        After JSON round-tripping, TimeSpan values are deserialized as plain objects
        with a Ticks property. This helper restores the custom PSTypeName and
        reconstructs the Start, End, and Duration TimeSpan properties for each
        analysis event in the collection.

    .PARAMETER Items
        Collection of deserialized analysis event objects.

    .PARAMETER TypeName
        The PCXLab type name to insert (e.g. 'PCXLab.Silence', 'PCXLab.BlackFrame').
    #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$Items,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TypeName

    )

    if ($null -eq $Items) { return }

    foreach ($Item in $Items) {

        if ($Item.PSTypeNames -notcontains $TypeName) {

            $Item.PSObject.TypeNames.Insert(
                0,
                $TypeName
            )

        }

        #
        # Restore TimeSpan properties
        #

        $Item.Start = [TimeSpan]::FromTicks(
            [Int64]$Item.Start.Ticks
        )

        $Item.End = [TimeSpan]::FromTicks(
            [Int64]$Item.End.Ticks
        )

        $Item.Duration = [TimeSpan]::FromTicks(
            [Int64]$Item.Duration.Ticks
        )

    }

}
