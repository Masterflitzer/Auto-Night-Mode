# Auto Night Mode

Download:
* [Auto Night Mode](https://github.com/masterflitzer/auto-night-mode/archive/main.zip)
* [Powershell](https://github.com/PowerShell/PowerShell.git)

Usage: `.\auto-night-mode.ps1 [[-mode] auto] [[-morning] 08:00:00] [[-evening] 20:00:00]`

This script toggles the Windows 10 dark or light mode if it is executed without arguments.

When executed with the `auto` argument, it acts as an automatic night mode. This means that the dark or light mode is activated within a certain period of time.

If you do not want to use arguments, you can hardcode the variables in the script (look for the comment where it says `# hardcode variables`).

With the Windows Task Scheduler, this script can be run automatically every 15 minutes, for example.

Example Task:
* **Program/script:** `"C:\Program Files\PowerShell\7\pwsh.exe"`
* **Add arguments** `-windowstyle hidden -executionpolicy bypass "%userprofile%\scripts\auto-night-mode.ps1" -mode auto -morning 08:00:00 -evening 18:00:00`
