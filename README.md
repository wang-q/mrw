# Resize windows on macOS/Windows

## Usage

|        Symbol         |                       Key                        |
|:---------------------:|:------------------------------------------------:|
|   <kbd>hyper</kbd>    | <kbd>ctrl</kbd>+<kbd>opt</kbd>+<kbd>cmd</kbd> |
|                       | <kbd>ctrl</kbd>+<kbd>win</kbd>+<kbd>alt</kbd> |
| <kbd>hyperShift</kbd> |       <kbd>hyper</kbd>+<kbd>shift</kbd>        |

### Moving

* Center current window. <kbd>hyper</kbd>+<kbd>C</kbd>

* Move to edges
    * Left   - <kbd>hyper</kbd>+<kbd>Home</kbd>
    * Right  - <kbd>hyper</kbd>+<kbd>End</kbd>
    * Top    - <kbd>hyper</kbd>+<kbd>PgUp</kbd>
    * Bottom - <kbd>hyper</kbd>+<kbd>PgDn</kbd>

* Move current window to another monitor. <kbd>hyper</kbd>+<kbd>J</kbd>/<kbd>K</kbd>

### Resizing

* Fixed ratio window
    * Native ratio window (first maximize, then loop through ratios: 0.9, 0.7, 0.5). <kbd>hyperShift</kbd>+<kbd>M</kbd>
    * 4:3 ratio window (loop through ratios: 1.0, 0.9, 0.7, 0.5). <kbd>hyper</kbd>+<kbd>M</kbd>

* Width adjustments
    * Loop through screen width ratios: 3/4, 3/5, 1/2, 2/5, 1/4. <kbd>hyper</kbd>+<kbd>Left</kbd>/<kbd>Right</kbd>
    * Set to vertical half screen. <kbd>hyperShift</kbd>+<kbd>Left</kbd>/<kbd>Right</kbd>

* Height adjustments
    * Loop through screen height ratios: 3/4, 1/2, 1/4. <kbd>hyper</kbd>+<kbd>Up</kbd>/<kbd>Down</kbd>
    * Set to horizontal half screen. <kbd>hyperShift</kbd>+<kbd>Up</kbd>/<kbd>Down</kbd>

### Testing

* Alert. <kbd>hyper</kbd>+<kbd>W</kbd>
* Notify. <kbd>hyperShift</kbd>+<kbd>W</kbd>

## macOS - Hammerspoon

[Download here](https://www.hammerspoon.org) or `brew install hammerspoon`.

Then symlink the configuration file:

```shell
bash mac/install.sh

```

## Windows - AutoHotkey v2

[Download here](https://www.autohotkey.com/) or
`winget install --id AutoHotkey.AutoHotkey`.

If you want the program to start automatically at startup, run the following codes:

```powershell
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$ENV:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\rw.lnk")
$Shortcut.TargetPath = "$Home\Scripts\rw\win\init.ahk"
$Shortcut.Save()

# start "$ENV:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

```

[officekey](https://superuser.com/questions/1455857/how-to-disable-office-key-keyboard-shortcut-opening-office-app)
[ahk forum](https://www.autohotkey.com/boards/viewtopic.php?t=65573)

```cmd
REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32

:: REG DELETE HKCU\Software\Classes\ms-officeapp\Shell

```

## Ideas

Hammerspoon section comes
from [this post](http://songchenwen.com/tech/2015/04/02/hammerspoon-mac-window-manager/).

Size looping like [spectacle](https://www.spectacleapp.com).

AHK section comes from [here](https://github.com/justcla/WindowHotKeys).
