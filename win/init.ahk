#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Notes:
; WinGetPos, X, Y, W, H, A  ; "A" to get the active window's pos.
; MsgBox, The active window is at %X%`,%Y% with width and height [%W%, %H%]

; Hoy Key Symbols
; Symbol	#	= Win (Windows logo key)
; Symbol	!	= Alt
; Symbol	^	= Control
; Symbol	+	= Shift
; Symbol	& = An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.

; Watch out for the Microsoft Office Apps Pop-up!
; Pops up whhen user presses various combinations of Windows key with Alt and Shift and Home.
; To disable the Microsoft Office 360 pop-up, add this registry ket to your system:
; Note: Solution taken from AHK Forum: https://www.autohotkey.com/boards/viewtopic.php?t=65573
; ----
; Run: REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32
; This will add a registry key that will make the Office key run a useless command, effectively disabling it.
; It does not block the individual hot keys - it only removes the loading of the Office app.
; To reverse it, just delete the key (the Shell folder did not previously exist, so it can be completely removed)
; Run: REG DELETE HKCU\Software\Classes\ms-officeapp\Shell

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
    MsgBox, Hello World!
return

#!^+W::
    TrayTip, AHK, Hello World!
return

; Loop 3/4, 3/5, 1/2, 2/5, 1/4 screen width
#!^Left::
    LoopW("Left")
return

#!^Right::
    LoopW("Right")
return

; Loop 3/4, 1/2, 1/4 screen height
#!^Up::
    LoopH("Top")
return

#!^Down::
    LoopH("Bottom")
return

; Half screen
#!^+Left::
    ToHS("Left")
return

#!^+Right::
    ToHS("Right")
return

#!^+Up::
    ToHS("Top")
return

#!^+Down::
    ToHS("Bottom")
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

; Center window
#!^+C::
    MoveWindowToCenter()
return

#!^C::
    MoveWindowToCenter()
return

; Maximize window
#!^+M::
    ResizeAndCenter(1)
return

#!^M::
    LoopM()
return

; ----------------------------
; Functions
; ----------------------------

GetWindowNumber() {
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

EnsureWindowIsRestored() {
    WinGet, ActiveWinState, MinMax, A
    if (ActiveWinState != 0)
        WinRestore, A
}

RestoreMoveAndResize(A, NewX, NewY, NewW, NewH) {
    EnsureWindowIsRestored() ; Always ensure the window is restored before any move or resize operation
;    MsgBox Move to: (X/Y) %NewX%, %NewY%; (W/H) %NewW%, %NewH%
    WinMove, A, , NewX, NewY, NewW, NewH
}

ToHS(Edge) {
    WinNum := GetWindowNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %WinNum%
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

    RestoreMoveAndResize(A, NewX, NewY, NewW, NewH)
}

LoopW(Edge) {
    WinNum := GetWindowNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %WinNum%
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

    RestoreMoveAndResize(A, NewX, NewY, NewW, NewH)
}

LoopH(Edge) {
    WinNum := GetWindowNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %WinNum%
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

    RestoreMoveAndResize(A, NewX, NewY, NewW, NewH)
}

GetCenterCoordinates(ByRef A, WinNum, ByRef NewX, ByRef NewY, WinW, WinH) {
    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %WinNum%
    ScreenW := MonRight - MonLeft
    ScreenH := MonBottom - MonTop

    ; Calculate the position based on the given dimensions [W|H]
    NewX := (ScreenW-WinW)/2 + MonLeft ; Adjust for monitor offset
    NewY := (ScreenH-WinH)/2 + MonTop ; Adjust for monitor offset
}

DoResizeAndCenter(WinNum, NewW, NewH) {
    GetCenterCoordinates(A, WinNum, NewX, NewY, NewW, NewH)
    RestoreMoveAndResize(A, NewX, NewY, NewW, NewH)
}

LoopM() {
    WinNum := GetWindowNumber()

    ; Set the screen variables
    SysGet, Mon, MonitorWorkArea, %WinNum%
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

    DoResizeAndCenter(WinNum, NewW, NewH)
}

MoveWindowToCenter() {
    WinGetPos, WinX, WinY, WinW, WinH, A  ; "A" to get the active window's pos.
    WinNum := GetWindowNumber()
    DoResizeAndCenter(WinNum, WinW, WinH)
    return
}

MoveToEdge(Edge) {
    ; Get monitor and window dimensions
    WinNum := GetWindowNumber()
    SysGet, Mon, MonitorWorkArea, %WinNum%
    WinGetPos, WinX, WinY, WinW, WinH, A  ; "A" to get the active window's pos.

    ; Set window coordinates
    if InStr(Edge, "Left")
        NewX := MonLeft
    if InStr(Edge, "Right")
        NewX := MonRight - WinW
    if InStr(Edge, "Top")
        NewY := MonTop
    if InStr(Edge, "Bottom")
        NewY := MonBottom - WinH

    ; MsgBox NewX/NewY = %NewX%,%NewY%
    RestoreMoveAndResize(A, NewX, NewY, NewW, NewH)
    return
}

CalculateSizeByWinRatio(ByRef NewW, ByRef NewH, WinNum, Ratio) {
    WinNum := GetWindowNumber()
    SysGet, Mon, MonitorWorkArea, %WinNum%
    NewW := (MonRight - MonLeft) * Ratio
    NewH := (MonBottom - MonTop) * Ratio
}

ResizeAndCenter(Ratio) {
    WinNum := GetWindowNumber()
    CalculateSizeByWinRatio(NewW, NewH, WinNum, Ratio)
    DoResizeAndCenter(WinNum, NewW, NewH)
}
