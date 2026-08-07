Describe 'Get-PCXEditPoint' {

    BeforeAll {

        $EditPoints = Find-PCXSilence 'C:\Videos\Test.mp4' |
            Get-PCXEditPoint

    }

    It 'Returns edit point objects' {

        $EditPoints |
            Should -Not -BeNullOrEmpty

        $EditPoints[0].PSTypeNames |
            Should -Contain 'PCXLab.EditPoint'

    }

    It 'Contains reason' {

        $EditPoints[0].Reason |
            Should -Not -BeNullOrEmpty

    }

    It 'Contains confidence' {

        $EditPoints[0].Confidence |
            Should -BeGreaterThan 0

    }

}