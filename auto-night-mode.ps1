param (
    [string] $mode
)
# Establishes and enforces coding rules in expressions, scripts, and script blocks.
Set-StrictMode -Version Latest

# hardcode $mode (no argument needed to run in automatic mode)
$mode = 'auto'

<#
# begin editing
#>
$morning_hour = 8
$morning_minute = 0
$morning_second = 0

$evening_hour = 20
$evening_minute = 0
$evening_second = 0
<#
# end editing
#>

# create some strings (path to registry keys of the windows theme)
$path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$name_system = 'SystemUsesLightTheme'
$name_apps = 'AppsUseLightTheme'

function main {
    # run automatic (scheduled) or normal (toggle) function
    if ($mode -eq 'auto') {
        # call auto funktion & set dark/light theme
        $night_mode = auto_night_mode
        set_registry_keys($night_mode)
    }
    else {
        # call toggle funktion & set dark/light theme
        $night_mode = toggle_night_mode
        set_registry_keys(!$night_mode)
    }
}

function set_registry_keys {
    param([int] $value)
    # set some registry entries (set registry keys to change windows theme)
    New-ItemProperty -Path $path -Name $name_system -Type Dword -Force -Value $value
    New-ItemProperty -Path $path -Name $name_apps -Type Dword -Force -Value $value
}

function auto_night_mode {
    # write output of commands (not the strings) in variable
    #$current_time = Invoke-Expression 'Get-Date -DisplayHint Time'
    $current_time = Invoke-Expression 'Get-Date -DisplayHint Time -Hour 8 -Minute 00 -Second 00'
    $morning = Invoke-Expression ('Get-Date -DisplayHint Time -Hour ' + $morning_hour + ' -Minute ' + $morning_minute + ' -Second ' + $morning_second)
    $evening = Invoke-Expression ('Get-Date -DisplayHint Time -Hour ' + $evening_hour + ' -Minute ' + $evening_minute + ' -Second ' + $evening_second)

    $laterThanEqual8 = $current_time -ge $morning
    $earlierThan20 = $current_time -lt $evening
    $earlierThan8 = $current_time -lt $morning
    $laterThanEqual20 = $current_time -ge $evening
    
    # check for day or night time
    $day = $laterThanEqual8 -and $earlierThan20
    $night = $earlierThan8 -or $laterThanEqual20

    if ($night) {
        return 0
    }
    elseif ($day) {
        return 1
    }
}

function toggle_night_mode {
    # return value of registry key (only for system theme)
    return (Get-ItemProperty -Path $path).$name_system
}

function clock_calculation {
    $bspStr = "Ich-bin-ein-String-mit-Trennzeichen."
    $bspStr = $bspStr.Split("-")
    $bspStr
    $bspStr[3]
}

main