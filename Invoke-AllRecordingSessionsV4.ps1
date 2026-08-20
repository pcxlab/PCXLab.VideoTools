Import-Module "C:\Projects\PCXLab.VideoTools\src\Modules\PCXLab.VideoTools" -Force

#----------------------------------------------------------
# Configuration
#----------------------------------------------------------

$Root = "F:\Recordings"
# $Root = "C:\Recording seg TestONLOY"

#
# Supported values:
#
#   BlackFrames
#   Silence
#
$Analyzer = 'BlackFrames'

$Success = 0
$Failed  = 0
$Skipped = 0

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " PCXLab Standalone Video Batch Processor"
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Root Folder : $Root"
Write-Host "Analyzer    : $Analyzer"
Write-Host ""

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Folder not found: $Root"
}

#
# Discover supported video files.
#

$Videos = Get-ChildItem `
    -LiteralPath $Root `
    -Recurse `
    -File |

Where-Object {

    $_.Extension -match '^\.(mp4|mov|mkv|avi|m4v)$' -and
    $_.BaseName -notmatch '-Edited$'

} |

Sort-Object FullName

Write-Host "Videos Found : $($Videos.Count)" -ForegroundColor Green
Write-Host ""

$Index = 0

foreach ($Video in $Videos) {

    $Index++

    $VideoTimer = [System.Diagnostics.Stopwatch]::StartNew()

    Write-Host ""
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "Video [$Index / $($Videos.Count)]"
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host $Video.FullName
    Write-Host ""

    #
    # Skip videos already edited.
    #

    $EditedVideo = Join-Path `
        $Video.DirectoryName `
        ($Video.BaseName + "-Edited" + $Video.Extension)

    if (Test-Path -LiteralPath $EditedVideo) {

        Write-Host "[SKIPPED] Edited video already exists." -ForegroundColor Yellow
        Write-Host $EditedVideo

        $Skipped++
        continue

    }

    Write-Host "Analyzer : $Analyzer" -ForegroundColor Cyan
    Write-Host ""

    try {

        #
        # Run analyzer
        #

        $Detection = switch ($Analyzer) {

            'BlackFrames' {

                Find-PCXBlackFrames `
                    -Path $Video.FullName

            }

            'Silence' {

                Find-PCXSilence `
                    -Path $Video.FullName

            }

            default {

                throw "Unknown analyzer '$Analyzer'."

            }

        }

        if (@($Detection).Count -eq 0) {

            Write-Warning "No edit regions detected."

            $Skipped++
            continue

        }

        #
        # Convert detection objects into VideoSegments.
        #

        $Segments = @(
            $Detection |
            Get-PCXVideoSegments
        )

        if ($Segments.Count -eq 0) {

            Write-Warning "No VideoSegments were generated."

            $Skipped++
            continue

        }

                #
        # Export VideoSegments JSON
        #

        Write-Host "Exporting VideoSegments..." -ForegroundColor DarkCyan

        $Segments |
            Export-PCXVideoSegment |
            Out-Null

        #
        # Export Premiere Markers
        #

        Write-Host "Exporting Premiere Markers..." -ForegroundColor DarkCyan

        $Segments |
            Export-PCXPremiereMarkers |
            Out-Null

        #
        # Export Premiere Edit Points
        #

        Write-Host "Exporting Premiere Edit Points..." -ForegroundColor DarkCyan

        $Segments |
            Export-PCXPremiereEditPoints |
            Out-Null

        #
        # Render edited video
        #

        Write-Host "Rendering Edited Video..." -ForegroundColor DarkCyan

        $Segments |
            Edit-PCXVideoSegments |
            Out-Null

        $VideoTimer.Stop()

        Write-Host ""
        Write-Host "[SUCCESS]" -ForegroundColor Green
        Write-Host ("Elapsed : {0}" -f $VideoTimer.Elapsed)

        $Success++

    }
    catch {

        $VideoTimer.Stop()

        Write-Host ""
        Write-Host "[FAILED]" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host ("Elapsed : {0}" -f $VideoTimer.Elapsed)

        $Failed++

    }

}

$Stopwatch.Stop()

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host " Standalone Video Batch Complete"
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host ("Processed    : {0}" -f $Videos.Count)
Write-Host ("Success      : {0}" -f $Success) -ForegroundColor Green
Write-Host ("Failed       : {0}" -f $Failed) -ForegroundColor Red
Write-Host ("Skipped      : {0}" -f $Skipped) -ForegroundColor Yellow

if ($Videos.Count -gt 0) {

    $Rate = [math]::Round(
        ($Success / $Videos.Count) * 100,
        2
    )

    Write-Host ("Success Rate : {0} %" -f $Rate)

}

Write-Host ("Elapsed      : {0}" -f $Stopwatch.Elapsed)

Write-Host ""