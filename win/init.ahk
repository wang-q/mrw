#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Notes:
; WinGetPos, X, Y, W, H, A  ; "A" to get the active window's pos.
; MsgBox, The active window is at %X%`,%Y% with width and height [%W%, %H%]

; Hoy Key Symbols
; Symbol # = Win (Windows logo key)
; Symbol ! = Alt
; Symbol ^ = Control
; Symbol + = Shift
; Symbol & = An ampersand may be used between any two keys or mouse buttons to
;            combine them into a custom hotkey.

; ----------------------------
; Icon
; ----------------------------
InitializeIcon()

InitializeIcon() {
    ; Set the System tray icon (should sit next to the AHK file)
    if FileExist("icon.ico") {
        Menu, Tray, Icon, icon.ico
    }
}

; ----------------------------
; Actions
; ----------------------------

; Hello world
#!^W::
    MsgBox % GetDebugInfo()
return

#!^+W::
    TrayTip, AHK, Hello World!
return

; Center window
#!^+C::
    MoveToCenter()
return

#!^C::
    MoveToCenter()
return

; Move
#!^Home::
    MoveToEdge("Left")
return

#!^End::
    MoveToEdge("Right")
return

#!^PgUp::
    MoveToEdge("Top")
return

#!^PgDn::
    MoveToEdge("Bottom")
return

; Half screen
#!^+Left::
    ToHalfScreen("Left")
return

#!^+Right::
    ToHalfScreen("Right")
return

#!^+Up::
    ToHalfScreen("Top")
return

#!^+Down::
    ToHalfScreen("Bottom")
return

; Loop 3/4, 3/5, 1/2, 2/5, 1/4 screen width
#!^Left::
    LoopWidth("Left")
return

#!^Right::
    LoopWidth("Right")
return

; Loop 3/4, 1/2, 1/4 screen height
#!^Up::
    LoopHeight("Top")
return

#!^Down::
    LoopHeight("Bottom")
return

; Maximize window
#!^+M::
    info := GetWindowFrame()
    max := info[3]
    LoopFixedRatio(max.w / max.h)
return

#!^M::
    LoopFixedRatio(4/3)
return

; ----------------------------
; Functions
; ----------------------------

GetMonitorNumber() {
    ; Get the Active window
    WinGetPos, WinX, WinY, WinW, WinH, A  ; "A" to get the active window's pos.
    SysGet, numMonitors, MonitorCount
    Loop %numMonitors% {
        SysGet, monitor, MonitorWorkArea, %A_Index%
        if (monitorLeft <= WinX && WinX < monitorRight && monitorTop <= WinY && WinY <= monitorBottom){
            ; We have found the monitor that this window sits inside (at least the top-left corner)
            return %A_Index%
        }
    }
    return 1    ; If we can't find a matching window, just return 1 (Primary)
}

GetWindowFrame() {
    ; Get the Active window
    WinGet, win, ID, A
    WinGetPos, WinX, WinY, WinW, WinH, A

    ; Get monitor info
    MonNum := GetMonitorNumber()
    SysGet, Mon, MonitorWorkArea, %MonNum%

    ; Create frame object
    f := { x: WinX
        , y: WinY
        , w: WinW
        , h: WinH }

    ; Create screen object
    max := { x: MonLeft
           , y: MonTop
           , w: MonRight - MonLeft
           , h: MonBottom - MonTop }

    return [win, f, max]
}

GetDebugInfo() {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]
    MonNum := GetMonitorNumber()
    return "Monitor: " . MonNum
        . "`nWindow ID: " . win
        . "`nWindow Frame: [" . f.x . ", " . f.y . ", " . f.w . ", " . f.h . "]"
        . "`nScreen Frame: [" . max.x . ", " . max.y . ", " . max.w . ", " . max.h . "]"
}

EnsureWindowIsRestored() {
    WinGet, ActiveWinState, MinMax, A
    if (ActiveWinState != 0)
        WinRestore, A
}

SetWindowFrame(win, f) {
    if (win) {
        EnsureWindowIsRestored() ; Always ensure the window is restored before any move or resize operation
        ;    MsgBox Move to: (X/Y) %NewX%, %NewY%; (W/H) %NewW%, %NewH%
        WinMove, A, , f.x, f.y, f.w, f.h
    }
}

MoveToCenter() {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Calculate center position directly
    f.x := max.x + (max.w - f.w) / 2
    f.y := max.y + (max.h - f.h) / 2

    SetWindowFrame(win, f)
}

MoveToEdge(Edge) {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Set window coordinates
    if InStr(Edge, "Left")
        f.x := max.x
    if InStr(Edge, "Right")
        f.x := max.x + (max.w - f.w)
    if InStr(Edge, "Top")
        f.y := max.y
    if InStr(Edge, "Bottom")
        f.y := max.y + (max.h - f.h)

    SetWindowFrame(win, f)
}

ToHalfScreen(Edge) {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Set window coordinates
    if InStr(Edge, "Left") {
        f.w := Floor(max.w / 2)
        f.h := max.h
        f.x := max.x
        f.y := max.y
    }
    if InStr(Edge, "Right") {
        f.w := Floor(max.w / 2)
        f.h := max.h
        f.x := max.x + (max.w - f.w)
        f.y := max.y
    }
    if InStr(Edge, "Top") {
        f.w := max.w
        f.h := Floor(max.h / 2)
        f.x := max.x
        f.y := max.y
    }
    if InStr(Edge, "Bottom") {
        f.w := max.w
        f.h := Floor(max.h / 2)
        f.x := max.x
        f.y := max.y + (max.h - f.h)
    }

    SetWindowFrame(win, f)
}

LoopWidth(Edge) {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Only change width
    serials := [ 0.75, 0.6, 0.5, 0.4, 0.25 ]

    if ( f.w = Floor(max.w * serials[1]) ) {
        f.w := Floor(max.w * serials[2])
    } else if ( f.w = Floor(max.w * serials[2]) ) {
        f.w := Floor(max.w * serials[3])
    } else if ( f.w = Floor(max.w * serials[3]) ) {
        f.w := Floor(max.w * serials[4])
    } else if ( f.w = Floor(max.w * serials[4]) ) {
        f.w := Floor(max.w * serials[5])
    } else if ( f.w = Floor(max.w * serials[5]) ) {
        f.w := Floor(max.w * serials[1])
    } else {
        f.w := Floor(max.w * serials[1])
    }

    if InStr(Edge, "Left")
        f.x := max.x
    if InStr(Edge, "Right")
        f.x := max.x + (max.w - f.w)

    SetWindowFrame(win, f)
}

LoopHeight(Edge) {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Only change height
    serials := [ 0.75, 0.5, 0.25 ]

    if ( f.h = Floor(max.h * serials[1]) ) {
        f.h := Floor(max.h * serials[2])
    } else if ( f.h = Floor(max.h * serials[2]) ) {
        f.h := Floor(max.h * serials[3])
    } else if ( f.h = Floor(max.h * serials[3]) ) {
        f.h := Floor(max.h * serials[1])
    } else {
        f.h := Floor(max.h * serials[1])
    }

    if InStr(Edge, "Top")
        f.y := max.y
    if InStr(Edge, "Bottom")
        f.y := max.y + (max.h - f.h)

    SetWindowFrame(win, f)
}

LoopFixedRatio(ratio) {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Fixed ratio window
    ScreenM := Min(max.w, max.h)
    BaseW := Floor(ScreenM * ratio)
    BaseH := ScreenM
    serials := [ 1, 0.9, 0.7, 0.5 ]

    ; Calculate current window relative to base size
    current := f.w / BaseW

    ; Find next serial
    nextSerial := serials[1]
    for i, r in serials {
        if (abs(current - r) < 0.01) {
            nextSerial := serials[i + 1]
            if (!nextSerial)
                nextSerial := serials[1]
            break
        }
    }

    ; Apply new size
    f.w := Floor(BaseW * nextSerial)
    f.h := Floor(BaseH * nextSerial)

    ; centering
    f.x := max.x + (max.w - f.w) / 2
    f.y := max.y + (max.h - f.h) / 2

    SetWindowFrame(win, f)
}
