$WshShell = New-Object -comObject WScript.Shell
$ScriptDir = $PSScriptRoot
$Shortcut = $WshShell.CreateShortcut("$ENV:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\mrw.lnk")
$Shortcut.TargetPath = Join-Path $ScriptDir "init.ahk"
$Shortcut.Save()
