$SourceRoot = "C:\Recording"
$ArchiveRoot = "C:\Recording2"

$Files = Get-ChildItem $SourceRoot -Recurse -File | Where-Object {

    $_.Name -match '-Edited\.mp4$' -or
    $_.Name -match '-Analysis\.json$' -or
    $_.Name -match '-Silence\.json$' -or
    $_.Name -match '-EditPoints\.json$' -or
    $_.Name -match '-PremiereMarkers\.jsx$' -or
    $_.Name -match '-PremiereEditPoints\.jsx$'

}

Write-Host ""
Write-Host "Files to move : $($Files.Count)"
Write-Host ""

foreach ($File in $Files) {

    # Relative path from C:\Recording
    $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\')

    # Destination path
    $Destination = Join-Path $ArchiveRoot $RelativePath

    # Create destination folder if needed
    $DestinationFolder = Split-Path $Destination -Parent

    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null
    }

    # Move the file
    Move-Item -Path $File.FullName -Destination $Destination -Force

    Write-Host "Moved: $RelativePath"
}

Write-Host ""
Write-Host "===================================="
Write-Host "Archive completed successfully."
Write-Host "===================================="