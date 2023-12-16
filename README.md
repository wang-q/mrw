# Resize windows on macOS/Windows

|        Symbol         |                       Key                        |
|:---------------------:|:------------------------------------------------:|
|   <kbd>hyper</kbd>    | <kbd>ctrl</kbd> +<kbd>opt</kbd> + <kbd>cmd</kbd> |
|                       | <kbd>ctrl</kbd> +<kbd>win</kbd> + <kbd>alt</kbd> |
| <kbd>hyperShift</kbd> |       <kbd>hyper</kbd> + <kbd>shift</kbd>        |
|        &#9650;        |                        Up                        |
|        &#9660;        |                       Down                       |
|        &#9668;        |                       Left                       |
|        &#9658;        |                      Right                       |

* Center current window. <kbd>hyper</kbd> + <kbd>C</kbd>
* Base size is 1.33x1 screen height (4:3 window). Loop through 1, 0.9, 0.7, 0.5 and 0.3. <kbd>
  hyper</kbd> + <kbd>M</kbd>
* Maximize current window. <kbd>hyperShift</kbd> + <kbd>M</kbd>
* Vertical half screen size. <kbd>hyperShift</kbd> + &#9668; or &#9658;
* Horizontal half screen size. <kbd>hyperShift</kbd> + &#9650; or &#9660;
* Loop through 3/4, 3/5, 1/2, 2/5, 1/4 screen width. <kbd>hyper</kbd> + &#9668; or &#9658;
* Loop through 3/4, 1/2 and 1/4 screen height. <kbd>hyper</kbd> + &#9650; or &#9660;
* Move current window to another monitor. <kbd>hyper</kbd> + <kbd>J</kbd> or <kbd>K</kbd>

For testing:

* Alert. <kbd>hyper</kbd> + <kbd>W</kbd>
* Notify. <kbd>hyperShift</kbd> + <kbd>W</kbd>

## macOS - Hammerspoon

### Installation

[Download here](https://www.hammerspoon.org) or `brew install hammerspoon`.

Then symlink the configuration file:

```shell
bash mac/install.sh

```

## Windows - AutoHotkey v1

### Installation

[Download here](https://www.autohotkey.com/) or
`winget install -s msstore --accept-package-agreements "AutoHotkey Store Edition"`.

## Ideas

Hammerspoon section comes
from [this post](http://songchenwen.com/tech/2015/04/02/hammerspoon-mac-window-manager/).

Size looping like [spectacle](https://www.spectacleapp.com).

AHK section comes from [here](https://github.com/justcla/WindowHotKeys).
