Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

$Videos = Get-ChildItem "F:\Recordings" -Recurse -File |
Where-Object {
    $_.Name -match '^bandicam \d{4}-\d{2}-\d{2} \d{2}-\d{2}-\d{2}-\d+\.mp4$'
}

Write-Host ""
Write-Host "Videos found : $($Videos.Count)"
Write-Host ""

foreach ($Video in $Videos) {

    Write-Host "==================================================="
    Write-Host "Processing:"
    Write-Host $Video.FullName
    Write-Host "==================================================="

    try {

        $Analysis = Analyze-PCXVideo `
            -Path $Video.FullName

        #
        # Cache
        #

        $Analysis |
            Export-PCXVideoAnalysis -Force | Out-Null

        #
        # Silence
        #

        $Silence = $Analysis |
            Get-PCXSilence

        $Silence |
            Export-PCXSilence | Out-Null

        #
        # Edit Points
        #

        $Silence |
            Get-PCXEditPoint |
            Export-PCXEditPoint  | Out-Null

        #
        # Video Segments
        #

        $Segments = $Silence |
            Get-PCXVideoSegments

        #
        # Premiere Markers
        #

        $Segments |
            Export-PCXPremiereMarkers | Out-Null

        #
        # Premiere Razor Script
        #

        $Segments |
            Export-PCXPremiereEditPoints | Out-Null

        Write-Host "[SUCCESS] $($Video.Name)" -ForegroundColor Green

    }
    catch {

        Write-Host "[FAILED ] $($Video.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow

    }

}

Write-Host ""
Write-Host "======================================="
Write-Host "Finished processing all recordings."
Write-Host "======================================="