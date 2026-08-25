function ConvertTo-PCXPremiereTimecode {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [double]$Seconds,

        [Parameter()]
        [ValidateRange(1,240)]
        [int]$FrameRate = 30
    )

    $hours = [math]::Floor($Seconds / 3600)
    $Seconds -= $hours * 3600

    $minutes = [math]::Floor($Seconds / 60)
    $Seconds -= $minutes * 60

    $wholeSeconds = [math]::Floor($Seconds)

    $frames = [math]::Floor(($Seconds - $wholeSeconds) * $FrameRate)

    if ($frames -ge $FrameRate) {
        $frames = 0
        $wholeSeconds++

        if ($wholeSeconds -ge 60) {
            $wholeSeconds = 0
            $minutes++

            if ($minutes -ge 60) {
                $minutes = 0
                $hours++
            }
        }
    }

    '{0:00}:{1:00}:{2:00}:{3:00}' -f `
        $hours,
        $minutes,
        $wholeSeconds,
        $frames
}