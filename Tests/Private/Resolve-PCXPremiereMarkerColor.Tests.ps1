BeforeAll {
    . "$PSScriptRoot\..\TestHelper.ps1"
    $script:Module = Get-Module PCXLab.VideoTools

    function script:Resolve-MarkerColor($marker) {
        & $script:Module {
            param($m)
            Resolve-PCXPremiereMarkerColor -Marker $m
        } $marker
    }
}

Describe 'Resolve-PCXPremiereMarkerColor' {

    Context 'Editing Markers' {

        It 'Resolves Keep to 0 (Green)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Editing'
                MarkerSubKind = 'Keep'
                ColorIndex    = $null
                Name          = 'Keep'
            }
            Resolve-MarkerColor $marker | Should -Be 0
        }

        It 'Resolves Remove to 1 (Red)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Editing'
                MarkerSubKind = 'Remove'
                ColorIndex    = $null
                Name          = 'Remove'
            }
            Resolve-MarkerColor $marker | Should -Be 1
        }

        It 'Resolves unknown editing subkind to 5 (White)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Editing'
                MarkerSubKind = 'CustomDecision'
                ColorIndex    = $null
                Name          = 'CustomDecision'
            }
            Resolve-MarkerColor $marker | Should -Be 5
        }

    }

    Context 'Analysis Markers' {

        It 'Resolves Silence to 6 (Blue)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'Silence'
                ColorIndex    = $null
                Name          = 'Silence'
            }
            Resolve-MarkerColor $marker | Should -Be 6
        }

        It 'Resolves BlackFrame to 2 (Purple)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'BlackFrame'
                ColorIndex    = $null
                Name          = 'Black Frame'
            }
            Resolve-MarkerColor $marker | Should -Be 2
        }

        It 'Resolves Speech to 7 (Cyan)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'Speech'
                ColorIndex    = $null
                Name          = 'Speech'
            }
            Resolve-MarkerColor $marker | Should -Be 7
        }

        It 'Resolves SceneChange to 3 (Orange)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'SceneChange'
                ColorIndex    = $null
                Name          = 'Scene Change'
            }
            Resolve-MarkerColor $marker | Should -Be 3
        }

        It 'Resolves Chapter to 4 (Yellow)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'Chapter'
                ColorIndex    = $null
                Name          = 'Chapter'
            }
            Resolve-MarkerColor $marker | Should -Be 4
        }

        It 'Resolves AISuggestion to 2 (Purple)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'AISuggestion'
                ColorIndex    = $null
                Name          = 'AI Suggestion'
            }
            Resolve-MarkerColor $marker | Should -Be 2
        }

        It 'Resolves unknown analysis subkind to 6 (Blue default)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Analysis'
                MarkerSubKind = 'NewAnalysisType'
                ColorIndex    = $null
                Name          = 'New Analysis'
            }
            Resolve-MarkerColor $marker | Should -Be 6
        }

    }

    Context 'System Markers' {

        It 'Resolves Warning to 4 (Yellow)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'System'
                MarkerSubKind = 'Warning'
                ColorIndex    = $null
                Name          = 'Warning'
            }
            Resolve-MarkerColor $marker | Should -Be 4
        }

        It 'Resolves Error to 1 (Red)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'System'
                MarkerSubKind = 'Error'
                ColorIndex    = $null
                Name          = 'Error'
            }
            Resolve-MarkerColor $marker | Should -Be 1
        }

        It 'Resolves Information to 6 (Blue)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'System'
                MarkerSubKind = 'Information'
                ColorIndex    = $null
                Name          = 'Information'
            }
            Resolve-MarkerColor $marker | Should -Be 6
        }

        It 'Resolves unknown system subkind to 5 (White)' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'System'
                MarkerSubKind = 'Diagnostic'
                ColorIndex    = $null
                Name          = 'Diagnostic'
            }
            Resolve-MarkerColor $marker | Should -Be 5
        }

    }

    Context 'Explicit Color Override' {

        It 'Honours explicit ColorIndex override regardless of category' {
            $marker = [PSCustomObject]@{
                MarkerKind    = 'Editing'
                MarkerSubKind = 'Remove'
                ColorIndex    = 7 # Explicit Cyan overrides Red (1)
                Name          = 'Remove'
            }
            Resolve-MarkerColor $marker | Should -Be 7
        }

    }

    Context 'Legacy Fallback' {

        It 'Resolves Keep marker by Name when MarkerKind is missing' {
            $marker = [PSCustomObject]@{
                Name = 'Keep segment'
            }
            Resolve-MarkerColor $marker | Should -Be 0
        }

        It 'Resolves Remove marker by Name when MarkerKind is missing' {
            $marker = [PSCustomObject]@{
                Name = 'Remove segment'
            }
            Resolve-MarkerColor $marker | Should -Be 1
        }

        It 'Resolves Warning marker by Name when MarkerKind is missing' {
            $marker = [PSCustomObject]@{
                Name = 'Warning notice'
            }
            Resolve-MarkerColor $marker | Should -Be 4
        }

        It 'Resolves Error marker by Name when MarkerKind is missing' {
            $marker = [PSCustomObject]@{
                Name = 'Error report'
            }
            Resolve-MarkerColor $marker | Should -Be 1
        }

        It 'Defaults to 6 (Blue) when no pattern matches' {
            $marker = [PSCustomObject]@{
                Name = 'Custom marker title'
            }
            Resolve-MarkerColor $marker | Should -Be 6
        }

    }

}
