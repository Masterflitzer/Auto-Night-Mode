param([string] $mode)

Set-StrictMode -Version Latest

[string] $path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
[string] $name_system = 'SystemUsesLightTheme'
[string] $name_apps = 'AppsUseLightTheme'

function night_mode {
    param([int] $value)
    New-ItemProperty -Path $path -Name $name_system -Type Dword -Force -Value $value
    New-ItemProperty -Path $path -Name $name_apps -Type Dword -Force -Value $value
}

function toggle_night_mode {
    [bool] $night_mode = (Get-ItemProperty -Path $path).$name_system
    
    if (!$night_mode) {
        # enable light theme
        night_mode(1)
    }
    elseif ($night_mode) {
        # enable dark theme
        night_mode(0)
    }
}

function auto_night_mode {
    [string] $current_time = Get-Date -DisplayHint Time
    [string] $morning = 'Get-Date -DisplayHint Time -Hour 8 -Minute 0 -Second 0'
    [string] $evening = 'Get-Date -DisplayHint Time -Hour 20 -Minute 0 -Second 0'

    if ($current_time -le $morning -OR $current_time -ge $evening) {
        # enable light theme
        night_mode(1)
    }
    elseif ($current_time -ge $morning -OR $current_time -le $evening) {
        # enable dark theme
        night_mode(0)
    }
}

if ($mode -eq 'auto') {
    auto_night_mode
}
else {
    toggle_night_mode
}
exit