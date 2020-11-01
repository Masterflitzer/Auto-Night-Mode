param (
    [string] $mode,
    [string] $morning,
    [string] $evening
)
# Establishes and enforces coding rules in expressions, scripts, and script blocks.
Set-StrictMode -Version Latest

$current_time = Invoke-Expression 'Get-Date -DisplayHint Time' | Out-String
$int_morning = 0
$int_evening = 0
$int_current_time = 0

# hardcode variables (no argument needed to run in automatic mode)
#$mode = 'auto'
#$morning = '08:00:00'
#$evening = '20:00:00'

# create some strings (path to registry keys of the windows theme) #S-1-5-21-843363826-3786156048-1633012339-1001
#$path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$name_system = 'SystemUsesLightTheme'
$name_apps = 'AppsUseLightTheme'

function main {
    # run automatic (scheduled) or normal (toggle) function
    if ($mode -eq 'auto') {
        # call auto function & set dark/light theme
        $night_mode = auto_night_mode
        set_registry_keys($night_mode)
    }
    else {
        # call toggle function & set dark/light theme
        $night_mode = toggle_night_mode
        set_registry_keys(!$night_mode)
    }
}

function split_string {
    param([string] $input_string)
    $string_array = $input_string.Split(":")
    return $string_array
}

function time_math {
    param ($array, [int] $result)
    $10_pow_0 = [Math]::Pow(10, 0) #10^0=1
    $10_pow_2 = [Math]::Pow(10, 2) #10^2=100
    $10_pow_4 = [Math]::Pow(10, 4) #10^4=10000
    [int] $hour = $array[0]
    [int] $minute = $array[1]
    [int] $second = $array[2]

    $result = $hour * $10_pow_4 + $minute * $10_pow_2 + $second * $10_pow_0
    return $result
}

function set_registry_keys {
    param([int] $value)
    # mount HKEY_Users
    $HKU = Get-PSDrive HKU -ea silentlycontinue
    if (!$HKU ) {
        New-PSDrive -Name HKU -PsProvider Registry HKEY_USERS | out-null
        Set-Location HKU:
    }
    # select all desired user profiles, exlude *_classes & .DEFAULT
    $regProfiles = Get-ChildItem -Path HKU: | Where-Object { ($_.PSChildName.Length -gt 8) -and ($_.PSChildName -notlike "*_class") -and ($_.PSChildName -notlike "*.DEFAULT") }
    # loop through all selected profiles & delete registry
    ForEach ($profile in $regProfiles ) {
        If (Test-Path -Path HKU:\$profile\$path) {
            # set some registry entries (set registry keys to change windows theme)
            New-ItemProperty -Path HKU:\$profile\$path -Name $name_system -Type Dword -Force -Value $value
            New-ItemProperty -Path HKU:\$profile\$path -Name $name_apps -Type Dword -Force -Value $value
        }
    }
}

function auto_night_mode {
    # check if variables exists
    if ($morning.Length -eq 0) { $morning = '08:00:00' }
    if ($evening.Length -eq 0) { $evening = '20:00:00' }
    # split the strings
    $morning = split_string($morning)
    $evening = split_string($evening)
    $current_time = split_string($current_time)
    [int] $int_morning = time_math($morning)
    [int] $int_evening = time_math($evening)
    [int] $int_current_time = time_math($current_time)

    [bool] $laterThanEqual8 = $int_current_time -ge $int_morning
    [bool] $earlierThan20 = $int_current_time -lt $int_evening
    [bool] $earlierThan8 = $int_current_time -lt $int_morning
    [bool] $laterThanEqual20 = $int_current_time -ge $int_evening
    
    # check for day or night time
    [bool] $day = $laterThanEqual8 -and $earlierThan20
    [bool] $night = $earlierThan8 -or $laterThanEqual20

    if ($night) {
        return 0
    }
    elseif ($day) {
        return 1
    }
}

function toggle_night_mode {
    # return value of registry key (only for system theme)
    return (Get-ItemProperty -Path HKCU:\$path).$name_system
}

# run the script
main
