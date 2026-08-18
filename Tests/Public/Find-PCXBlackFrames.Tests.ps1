Describe 'Find-PCXBlackFrames' {

    BeforeAll {

        . "$PSScriptRoot\..\TestHelper.ps1"

        $script:Module = Get-Module PCXLab.VideoTools

    }

    It 'Returns one or more black frame regions for the test media' {

        $blackFrames = @(
            Find-PCXBlackFrames -Path $script:TestVideo
        )

        $blackFrames.Count | Should -BeGreaterThan 0

    }

    It 'Returns PCXLab.BlackFrame objects' {

        $blackFrames = @(
            Find-PCXBlackFrames -Path $script:TestVideo
        )

        $blackFrames[0].PSTypeNames[0] | Should -Be 'PCXLab.BlackFrame'

    }

    It 'Honours the requested minimum duration' {

        # The test video contains no black regions longer than 20 seconds.
        $shortBlackFrames = @(
            Find-PCXBlackFrames `
                -Path $script:TestVideo `
                -MinimumDuration 20
        )

        $shortBlackFrames.Count | Should -Be 0

    }

    It 'Returns ordered boundaries for every black frame region' {

        $blackFrames = @(
            Find-PCXBlackFrames -Path $script:TestVideo
        )

        foreach ($blackFrame in $blackFrames) {

            $blackFrame.EndSeconds | Should -BeGreaterThan $blackFrame.StartSeconds
            $blackFrame.DurationSeconds | Should -BeGreaterThan 0

        }

    }

    It 'Produces VideoSegments that can be exported through the Premiere pipeline' {

        $segments = @(
            Find-PCXBlackFrames -Path $script:TestVideo |
            Get-PCXVideoSegments
        )

        $result = $segments |
            Export-PCXPremiereMarkers -Path "$TestDrive\Test-Markers.jsx"

        $result | Should -Not -BeNullOrEmpty
        $result.FullName | Should -Exist

    }

}