BeforeAll {

    . "$PSScriptRoot\..\TestHelper.ps1"

    $script:Module = Get-Module PCXLab.VideoTools

}

Describe 'Search-PCXNormalizedCorrelation' {

    It 'Finds zero lag for identical signals' {

        $result = & $script:Module {

            $signal = @(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)

            Search-PCXNormalizedCorrelation `
                -Reference $signal `
                -Target $signal `
                -MinLag -2 `
                -MaxLag 2 `
                -TopCount 1

        }

        $result | Should -Not -BeNullOrEmpty
        $result[0].Lag | Should -Be 0
        $result[0].Correlation | Should -BeGreaterThan 0.99

    }

    It 'Finds positive lag when target is shifted right' {

        $result = & $script:Module {

            $reference = @(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)
            $target = @(0.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)

            Search-PCXNormalizedCorrelation `
                -Reference $reference `
                -Target $target `
                -MinLag 0 `
                -MaxLag 4 `
                -TopCount 1

        }

        $result[0].Lag | Should -Be 2

    }

    It 'Finds negative lag when target is shifted left' {

        $result = & $script:Module {

            $reference = @(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)
            $target = @(3.0, 4.0, 5.0, 6.0, 7.0, 8.0)

            Search-PCXNormalizedCorrelation `
                -Reference $reference `
                -Target $target `
                -MinLag -4 `
                -MaxLag 0 `
                -TopCount 1

        }

        $result[0].Lag | Should -Be -2

    }

    It 'Returns up to TopCount candidates' {

        $result = & $script:Module {

            $signal = @(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)

            Search-PCXNormalizedCorrelation `
                -Reference $signal `
                -Target $signal `
                -MinLag -1 `
                -MaxLag 1 `
                -TopCount 3

        }

        $result.Count | Should -Be 3

    }

    It 'Skips candidates with zero variance' {

        { & $script:Module {

            $reference = @(1.0, 1.0, 1.0, 1.0)
            $target = @(1.0, 2.0, 3.0, 4.0)

            Search-PCXNormalizedCorrelation `
                -Reference $reference `
                -Target $target `
                -MinLag 0 `
                -MaxLag 2 `
                -TopCount 1

        } } | Should -Throw

    }

}
