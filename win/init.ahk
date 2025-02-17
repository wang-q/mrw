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
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]
    MonNum := GetMonitorNumber()
    msg := "Monitor: " . MonNum
        . "`nWindow ID: " . win
        . "`nWindow Frame: [" . f.x . ", " . f.y . ", " . f.w . ", " . f.h . "]"
        . "`nScreen Frame: [" . max.x . ", " . max.y . ", " . max.w . ", " . max.h . "]"
    MsgBox % msg
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
    ResizeAndCenter(1)
return

#!^M::
    LoopFixedRatio()
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

EnsureWindowIsRestored() {
    WinGet, ActiveWinState, MinMax, A
    if (ActiveWinState != 0)
        WinRestore, A
}

SetWindowFrame(A, NewX, NewY, NewW, NewH) {
    EnsureWindowIsRestored() ; Always ensure the window is restored before any move or resize operation
;    MsgBox Move to: (X/Y) %NewX%, %NewY%; (W/H) %NewW%, %NewH%
    WinMove, A, , NewX, NewY, NewW, NewH
}

SetWindowFrame2(win, f) {
    if (win) {
        EnsureWindowIsRestored()
        WinMove, A, , f.x, f.y, f.w, f.h
    }
}

GetCenterCoordinates(ByRef A, MonNum, ByRef NewX, ByRef NewY, WinW, WinH) {
    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %MonNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; Calculate the position based on the given dimensions [W|H]
    NewX := (ScreenW-WinW)/2 + MonLeft ; Adjust for monitor offset
    NewY := (ScreenH-WinH)/2 + MonTop ; Adjust for monitor offset
}

ResizeAndCenterWindow(MonNum, NewW, NewH) {
    GetCenterCoordinates(A, MonNum, NewX, NewY, NewW, NewH)
    SetWindowFrame(A, NewX, NewY, NewW, NewH)
}

MoveToCenter() {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    ; Calculate center position directly
    f.x := max.x + (max.w - f.w) / 2
    f.y := max.y + (max.h - f.h) / 2

    SetWindowFrame2(win, f)
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

    SetWindowFrame2(win, f)
}

ToHalfScreen(Edge) {
    MonNum := GetMonitorNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %MonNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; Set window coordinates
    if InStr(Edge, "Left") {
        NewW := Floor(ScreenW / 2)
        NewH := ScreenH
        NewX := MonLeft
        NewY := MonTop
    }
    if InStr(Edge, "Right") {
        NewW := Floor(ScreenW / 2)
        NewH := ScreenH
        NewX := MonRight - NewW
        NewY := MonTop
    }
    if InStr(Edge, "Top") {
        NewW := ScreenW
        NewH := Floor(ScreenH / 2)
        NewX := MonLeft
        NewY := MonTop
    }
    if InStr(Edge, "Bottom") {
        NewW := ScreenW
        NewH := Floor(ScreenH / 2)
        NewX := MonLeft
        NewY := MonBottom - NewH
    }

    SetWindowFrame(A, NewX, NewY, NewW, NewH)
}

LoopWidth(Edge) {
    MonNum := GetMonitorNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %MonNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; "A" to get the active window's pos
    WinGetPos, WinX, WinY, WinW, WinH, A

    ; Only change width
    serials := [ 0.75, 0.6, 0.5, 0.4, 0.25 ]

    if ( WinW = Floor(ScreenW * serials[1]) ) {
        NewW := Floor(ScreenW * serials[2])
    } else if ( WinW = Floor(ScreenW * serials[2]) ) {
        NewW := Floor(ScreenW * serials[3])
    } else if ( WinW = Floor(ScreenW * serials[3]) ) {
        NewW := Floor(ScreenW * serials[4])
    } else if ( WinW = Floor(ScreenW * serials[4]) ) {
        NewW := Floor(ScreenW * serials[5])
    } else if ( WinW = Floor(ScreenW * serials[5]) ) {
        NewW := Floor(ScreenW * serials[1])
    } else {
        NewW := Floor(ScreenW * serials[1])
    }

    if InStr(Edge, "Left")
        NewX := MonLeft
    if InStr(Edge, "Right")
        NewX := MonRight - NewW

    SetWindowFrame(A, NewX, NewY, NewW, NewH)
}

LoopHeight(Edge) {
    MonNum := GetMonitorNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %MonNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; "A" to get the active window's pos
    WinGetPos, WinX, WinY, WinW, WinH, A

    ; Only change width
    serials := [ 0.75, 0.5, 0.25 ]

    if ( WinH = Floor(ScreenH * serials[1]) ) {
        NewH := Floor(ScreenH * serials[2])
    } else if ( WinH = Floor(ScreenH * serials[2]) ) {
        NewH := Floor(ScreenH * serials[3])
    } else if ( WinH = Floor(ScreenH * serials[3]) ) {
        NewH := Floor(ScreenH * serials[1])
    } else {
        NewH := Floor(ScreenH * serials[1])
    }

    if InStr(Edge, "Top")
        NewY := MonTop
    if InStr(Edge, "Bottom")
        NewY := MonBottom - NewH

    SetWindowFrame(A, NewX, NewY, NewW, NewH)
}

LoopFixedRatio() {
    MonNum := GetMonitorNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %MonNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; "A" to get the active window's pos
    WinGetPos, WinX, WinY, WinW, WinH, A

    ; 4:3 window
    ScreenM := Min(ScreenW, ScreenH)
    BaseW := Floor(ScreenM * 4 / 3)
    BaseH := ScreenM
    serials := [ 1, 0.9, 0.7, 0.5 ]

    if ( WinW = Floor(BaseW * serials[1]) ) {
        NewW := Floor(BaseW * serials[2])
        NewH := Floor(BaseH * serials[2])
    } else if ( WinW = Floor(BaseW * serials[2]) ) {
        NewW := Floor(BaseW * serials[3])
        NewH := Floor(BaseH * serials[3])
    } else if ( WinW = Floor(BaseW * serials[3]) ) {
        NewW := Floor(BaseW * serials[4])
        NewH := Floor(BaseH * serials[4])
    } else if ( WinW = Floor(BaseW * serials[4]) ) {
        NewW := Floor(BaseW * serials[1])
        NewH := Floor(BaseH * serials[1])
    } else {
        NewW := Floor(BaseW * serials[1])
        NewH := Floor(BaseH * serials[1])
    }

    ResizeAndCenterWindow(MonNum, NewW, NewH)
}

CalculateSizeByWinRatio(ByRef NewW, ByRef NewH, MonNum, Ratio) {
    MonNum := GetMonitorNumber()
    SysGet, Mon, MonitorWorkArea, %MonNum%
    NewW := (MonRight - MonLeft) * Ratio
    NewH := (MonBottom - MonTop) * Ratio
}

ResizeAndCenter(Ratio) {
    MonNum := GetMonitorNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %MonNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; Get current window size
    WinGetPos, WinX, WinY, WinW, WinH, A

    ; Define ratios for cycling
    serials := [ 1.0, 0.9, 0.7, 0.5 ]

    ; Calculate current ratio
    currentRatio := WinW / ScreenW

    ; Find next ratio
    nextRatio := serials[1]
    for i, ratio in serials {
        if (abs(currentRatio - ratio) < 0.01) {
            nextRatio := serials[i + 1]
            if (!nextRatio)
                nextRatio := serials[1]
            break
        }
    }

    ; Calculate new dimensions
    NewW := Floor(ScreenW * nextRatio)
    NewH := Floor(ScreenH * nextRatio)

    ResizeAndCenterWindow(MonNum, NewW, NewH)
}

