#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

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
    if FileExist("icon.ico")
        TraySetIcon("icon.ico")
}

; ----------------------------
; Functions
; ----------------------------

GetMonitorNumber() {
    WinGetPos &WinX, &WinY,,, "A"  ; "A" to get the active window's pos.
    monitorCount := MonitorGetCount()
    
    Loop monitorCount {
        MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
        if (Left <= WinX && WinX < Right && Top <= WinY && WinY <= Bottom)
            return A_Index
    }
    return 1  ; If we can't find a matching window, just return 1 (Primary)
}

GetWindowFrame() {
    win := WinGetID("A")
    WinGetPos &WinX, &WinY, &WinW, &WinH, "A"

    MonNum := GetMonitorNumber()
    MonitorGet(MonNum, &Left, &Top, &Right, &Bottom)

    f := {
        x: WinX,
        y: WinY,
        w: WinW,
        h: WinH
    }

    max := {
        x: Left,
        y: Top,
        w: Right - Left,
        h: Bottom - Top
    }

    return [win, f, max]
}

GetDebugInfo() {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]
    MonNum := GetMonitorNumber()
    
    return Format(
        "Monitor: {}`nWindow ID: {}`nWindow Frame: [{}, {}, {}, {}]`nScreen Frame: [{}, {}, {}, {}]",
        MonNum, win, f.x, f.y, f.w, f.h, max.x, max.y, max.w, max.h
    )
}

EnsureWindowIsRestored() {
    if (WinGetMinMax("A") != 0)
        WinRestore("A")
}

SetWindowFrame(win, f) {
    if win {
        EnsureWindowIsRestored()
        WinMove(f.x, f.y, f.w, f.h, "ahk_id " win)
    }
}

MoveToCenter() {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

    f.x := max.x + (max.w - f.w) / 2
    f.y := max.y + (max.h - f.h) / 2

    SetWindowFrame(win, f)
}

MoveToEdge(Edge) {
    info := GetWindowFrame()
    win := info[1]
    f := info[2]
    max := info[3]

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

    serials := [0.75, 0.6, 0.5, 0.4, 0.25]
    current := f.w / max.w

    nextSerial := serials[1]
    for i, r in serials {
        if (Abs(current - r) < 0.01) {
            nextSerial := i = serials.Length ? serials[1] : serials[i + 1]
            break
        }
    }

    f.w := Floor(max.w * nextSerial)

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

    serials := [0.75, 0.5, 0.25]
    current := f.h / max.h

    nextSerial := serials[1]
    for i, r in serials {
        if (Abs(current - r) < 0.01) {
            nextSerial := i = serials.Length ? serials[1] : serials[i + 1]
            break
        }
    }

    f.h := Floor(max.h * nextSerial)

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

    ScreenM := Min(max.w, max.h)
    BaseW := Floor(ScreenM * ratio)
    BaseH := ScreenM
    serials := [1, 0.9, 0.7, 0.5]

    current := f.w / BaseW

    nextSerial := serials[1]
    for i, r in serials {
        if (Abs(current - r) < 0.01) {
            nextSerial := i = serials.Length ? serials[1] : serials[i + 1]
            break
        }
    }

    f.w := Floor(BaseW * nextSerial)
    f.h := Floor(BaseH * nextSerial)

    f.x := max.x + (max.w - f.w) / 2
    f.y := max.y + (max.h - f.h) / 2

    SetWindowFrame(win, f)
}

; ----------------------------
; Actions
; ----------------------------

; Hello world
#!^w:: MsgBox(GetDebugInfo())
#!^+w:: TrayTip("AHK", "Hello World!")

; Center window
#!^+c:: MoveToCenter()
#!^c:: MoveToCenter()

; Move to edges
#!^Home:: MoveToEdge("Left")
#!^End:: MoveToEdge("Right")
#!^PgUp:: MoveToEdge("Top")
#!^PgDn:: MoveToEdge("Bottom")

; Half screen
#!^+Left:: ToHalfScreen("Left")
#!^+Right:: ToHalfScreen("Right")
#!^+Up:: ToHalfScreen("Top")
#!^+Down:: ToHalfScreen("Bottom")

; Loop 3/4, 3/5, 1/2, 2/5, 1/4 screen width
#!^Left:: LoopWidth("Left")
#!^Right:: LoopWidth("Right")

; Loop 3/4, 1/2, 1/4 screen height
#!^Up:: LoopHeight("Top")
#!^Down:: LoopHeight("Bottom")

; Maximize window
#!^+m:: {
    info := GetWindowFrame()
    max := info[3]
    LoopFixedRatio(max.w / max.h)
}

#!^m:: LoopFixedRatio(4/3)
