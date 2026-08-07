BeforeAll {

    Import-Module `
        "$PSScriptRoot\..\..\src\Modules\PCXLab.VideoTools" `
        -Force

}

Describe 'Get-PCXVideoDuration' {

    It 'Returns a TimeSpan' {

        $Duration = Get-PCXVideoDuration `
            -Path 'C:\Videos\Test.mp4'

        $Duration |
        Should -BeOfType TimeSpan

    }

    It 'Returns a positive duration' {

        $Duration = Get-PCXVideoDuration `
            -Path 'C:\Videos\Test.mp4'

        $Duration.TotalSeconds |
        Should -BeGreaterThan 0

    }

}