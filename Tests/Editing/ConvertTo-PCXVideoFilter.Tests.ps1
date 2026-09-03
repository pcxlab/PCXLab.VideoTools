Describe 'ConvertTo-PCXVideoFilter' {

    BeforeAll {
        . "$PSScriptRoot\..\TestHelper.ps1"
        $script:Module = Get-Module PCXLab.VideoTools
    }

    It 'Returns empty string when settings object has no filters enabled' {
        $filter = & $script:Module {
            param($settings)
            ConvertTo-PCXVideoFilter -Settings $settings
        } ([PSCustomObject]@{})

        $filter | Should -Be ''
    }

    It 'Returns hflip when HorizontalFlip is True' {
        $filter = & $script:Module {
            param($settings)
            ConvertTo-PCXVideoFilter -Settings $settings
        } ([PSCustomObject]@{ HorizontalFlip = $true })

        $filter | Should -Be 'hflip'
    }

    It 'Returns empty string when HorizontalFlip is False' {
        $filter = & $script:Module {
            param($settings)
            ConvertTo-PCXVideoFilter -Settings $settings
        } ([PSCustomObject]@{ HorizontalFlip = $false })

        $filter | Should -Be ''
    }

    It 'Silently ignores unknown properties and is forward-compatible' {
        $filter = & $script:Module {
            param($settings)
            ConvertTo-PCXVideoFilter -Settings $settings
        } ([PSCustomObject]@{ UnknownSetting = 'abc'; AnotherUnknown = 123; HorizontalFlip = $true })

        $filter | Should -Be 'hflip'
    }

}
