function Test-PCXSyntax {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $tokens = $null
    $errors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $Path,
        [ref]$tokens,
        [ref]$errors
    ) | Out-Null

    if ($errors.Count -eq 0) {
        Write-Host "✓ Syntax OK" -ForegroundColor Green
    }
    else {
        $errors
    }
}