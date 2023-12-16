# Resize windows on macOS/Windows

## macOS - Hammerspoon

### Installation

[Download here](https://www.hammerspoon.org) or `brew install hammerspoon`.

Then symlink the configuration file:

```shell
bash mac/install.sh

```

### Usage

| Symbol  |   Key   | Symbol  |  Key  |
|:-------:|:-------:|:-------:|:-----:|
| &#8984; | Command | &#9650; |  Up   |
| &#8963; | Control | &#9660; | Down  |
| &#8997; | Option  | &#9668; | Left  |
| &#8679; |  Shift  | &#9658; | Right |

`hyper`: &#8963; + &#8997; + &#8984; `hyperShift`: &#8963; + &#8997; + &#8984; + &#8679;

* Center current window. `hyper` + `C`
* Move current window to another monitor. `hyper` + `J` or `K`
* Base size is 1.33x1 screen height (4:3 window). Loop through 1, 0.9, 0.7, 0.5 and 0.3. `hyper` +
  `M`
* Maximize current window. `hyperShift` + `M`
* Loop through 3/4, 3/5, 1/2, 2/5, 1/4 screen width. `hyper` + &#9668; or &#9658;
* Vertical half screen size. `hyperShift` + &#9668; or &#9658;
* Loop through 3/4, 1/2 and 1/4 screen height. `hyper` + &#9650; or &#9660;
* Horizontal half screen size. `hyperShift` + &#9650; or &#9660;

For testing:

* Alert. `hyper` + `W`
* Notify. `hyperShift` + `W`

## Windows - AutoHotkey v1

### Installation

[Download here](https://www.autohotkey.com/) or
`winget install -s msstore --accept-package-agreements "AutoHotkey Store Edition"`.

## Ideas

Hammerspoon section comes from [this post](http://songchenwen.com/tech/2015/04/02/hammerspoon-mac-window-manager/).

Size looping like [spectacle](https://www.spectacleapp.com).

AHK section comes from [here](https://github.com/justcla/WindowHotKeys).
