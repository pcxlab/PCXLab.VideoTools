function Get-PCXToolPath {

    <#
    .SYNOPSIS
        Returns the full path to an external tool.

    .DESCRIPTION
        Attempts to locate an external tool by searching in the
        following order:

            1. Settings.json
            2. Project Tools folder
            3. System PATH

    .PARAMETER Tool
        Logical tool name.

    .EXAMPLE
        Get-PCXToolPath -Tool FFprobe

    .EXAMPLE
        Get-PCXToolPath -Tool FFmpeg

    .OUTPUTS
        System.String

    .NOTES
        Internal function.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(

        [Parameter(Mandatory)]
        [ValidateSet(
            'FFmpeg',
            'FFprobe',
            'MediaInfo',
            'Whisper'
        )]
        [string]$Tool

    )

    $Context = Get-PCXContext

    # -----------------------------------------------------------------
    # Tool definitions
    # -----------------------------------------------------------------

    $ToolMap = @{
        FFmpeg = @{
            Executable = 'ffmpeg.exe'
            ProjectPath = 'Tools\FFmpeg\bin\ffmpeg.exe'
        }

        FFprobe = @{
            Executable = 'ffprobe.exe'
            ProjectPath = 'Tools\FFmpeg\bin\ffprobe.exe'
        }

        MediaInfo = @{
            Executable = 'MediaInfo.exe'
            ProjectPath = 'Tools\MediaInfo\MediaInfo.exe'
        }

        Whisper = @{
            Executable = 'whisper.exe'
            ProjectPath = 'Tools\Whisper\whisper.exe'
        }
    }

    $Definition = $ToolMap[$Tool]

    # -----------------------------------------------------------------
    # 1. Settings.json
    # -----------------------------------------------------------------

    $ConfiguredPath = Get-PCXSetting -Name "Tools.$Tool"

    if (-not [string]::IsNullOrWhiteSpace($ConfiguredPath)) {

        if (Test-Path -LiteralPath $ConfiguredPath) {

            return (Resolve-Path -LiteralPath $ConfiguredPath).Path

        }

    }

    # -----------------------------------------------------------------
    # 2. Project Tools Folder
    # -----------------------------------------------------------------

    $ProjectTool = Join-Path `
        -Path $Context.ProjectRoot `
        -ChildPath $Definition.ProjectPath

    if (Test-Path -LiteralPath $ProjectTool) {

        return (Resolve-Path -LiteralPath $ProjectTool).Path

    }

    # -----------------------------------------------------------------
    # 3. System PATH
    # -----------------------------------------------------------------

    $Command = Get-Command `
        -Name $Definition.Executable `
        -CommandType Application `
        -ErrorAction SilentlyContinue

    if ($null -ne $Command) {

        return $Command.Source

    }

    return $null
}