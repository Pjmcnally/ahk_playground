/*  Create module to allow media keys to control Pandora

    NOTE ABOUT SOURCE
    -----------------
    Because Pandora is now a Windows 10 App it cannot be run by just accessing the exe.
    To resolve this issue create a shortcut and add that shortcut to the start menu
    using the path below. To create the shortcut do the following:
        1. Windows + R
        2. Enter: shell:AppsFolder
        3. Right click Pandora and click Create Shortcut
        4. Create folder and copy shortcut to folder
*/

; Classes
; ==============================================================================
class PandoraInterface {

    ; Set general attributes
    static Version := "winApp"
    static Source := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Pandora\Pandora.lnk"
    static Window := "ahk_exe Pandora.exe"
    static TempFile := A_WorkingDir . "\application\pandora\local.txt"
    static PsFile := A_WorkingDir . "\application\pandora\IsWindowsPlayingSound.ps1"

    ; Set wait times
    static SmallWait := 100

    ; Set time for idle checker
    static IdleCheckFreq := 300000 ; 5 minutes
    static IdlePeriod := 1800000  ; 30 minutes

    __New() {
        if (!(FileExist(this.Source))) {
            Throw "Pandora not found"  ; See NOTE ABOUT SOURCE in docstrings.
        }

        ; Set positions and size attributes
        This.x := This.getSysTopLeft() - 8  ; -8 makes it position flush against the edge. Not sure why.
        This.y := 0
        This.Height := 655
        This.Width := 860

        ; Set timer attribute / Start timer
        This.Timer := ObjBindMethod(this, "CheckIdle")
        timer := this.Timer  ; Not sure why this line is necessary but it is.
        SetTimer, % timer, % this.IdleCheckFrequency,
    }

    getSysTopLeft() {
        ; Get count of monitors
        SysGet, num_mons, MonitorCount

        ; Loop over monitors. Find left most monitor.
        x_coords := Array()
        Loop, % num_mons {
            SysGet, coords, MonitorWorkArea, % A_Index
            x_coords.push(coordsLeft)
        }

        Return Min(x_coords*)
    }

    playPause() {
        /*  Play or Pause current song.
        */
        if WinExist(This.Window) {
            Send, {Media_Play_Pause}
        } else {
            This.runMin()
        }

        ; Set/Update timer
        timer := this.Timer
        SetTimer, % timer, % this.IdleCheckFrequency,
    }

    next() {
        /*  Skip current song.
        */
        if WinExist(This.Window) {
            Send, {Media_Next}
        } else {
            This.runMin()
        }
    }

    runMin() {
        /*  Run then minimize Pandora.
        */
        WinGetActiveTitle, previouslyActive
        Run, % This.Source
        This.SetPos()
        WinActivate, % previouslyActive

        ; Check if Pandora is Logged in and ready to go
        if (This.CheckLoggedIn()) {
            startTime := A_TickCount
            maxRetryDur = 10000  ; Try for 10 seconds then give up
            while ((A_TickCount - startTime < maxRetryDur) and (not This.IsPlaying())) {
                This.playPause()
                sleep, 500
            }

            if (This.IsPlaying()) {
                WinMinimize, % This.Window
            }
        }
    }

    setPos() {
        ; Get original position
        WinGetPos, tempX, tempY, tempW, tempH, % This.Window

        ; Loop until position fixed
        while (tempX != This.x or tempY != this.y or tempW != this.Width or tempH != This.Height) {
            WinMove, % This.Window, , % This.x, This.y, This.Width, This.Height
            Sleep, % This.SmallWait
            WinGetPos, tempX, tempY, tempW, tempH, % This.Window
        }
    }

    kill() {
        /*  Kill the active Pandora window
        */
        if WinExist(This.Window) {
            WinClose, % This.Window
        }
    }

    minMax() {
        /*  Maximize or minimize the active Pandora window
        */
        if (WinExist(This.Window) and WinActive(This.Window)) {
            This.minimize()
        } else if (WinExist(This.Window) and (!WinActive(This.Window))) {
            This.maximize()
        } else {
            This.runMin()
        }
    }

    minimize() {
        This.setPos()
        WinGet, state, MinMax, % This.Window
        while (state != -1) {
            WinMinimize, % This.Window
            Sleep, % This.SmallWait
            WinGet, state, MinMax, % This.Window
        }
    }

    maximize() {
        while (not WinActive(This.Window)) {
            WinActivate, % This.Window
            This.setPos()
            Sleep, % This.SmallWait
        }
    }

    reset() {
        /*  Kill and then restart the active Pandora window
        */
        if WinExist(This.Window) {
            WinClose, % This.Window
            WinWaitClose, % This.Window
        }

        This.runMin()
    }

    CheckIdle() {
        ; Check if idle period longer than desired. If yes kill Pandora
        if (A_TimeIdlePhysical > This.IdlePeriod) {
            this.kill()
            Sleep, % 10000 ; Wait 10 seconds
        }

        ; Check if Pandora not running. If yes, kill timer.
        if (!(WinExist(this.Window))) {
            timer := this.Timer
            setTimer, % timer, OFF  ; Turn off timer
        }
    }

    IsPlaying() {
        ; 0x994022 ; Color when playing
        ; 0xFFFFFF ; Color when paused

        prevCoordMode := A_CoordModePixel
        CoordMode Pixel, Screen

        WinGetPos, X, Y, Width, Height, % This.Window
        button_x := (Width // 2) + X
        button_y := (Height - 40) + Y
        PixelGetColor, OutputVar, button_x, button_y

        CoordMode Pixel, % prevCoordMode
        return (OutputVar = 0x994022)
    }

    CheckLoggedIn() {
        ; Check if Pandora is already logged in.
        StartTime := A_TickCount
        MaxWaitTime := 3000
        loggedIn := False
        While (A_TickCount - StartTime < MaxWaitTime) {
            WinGetTitle, title, % This.Window
            if (InStr(title, "Now Playing")) {
                loggedIn := True
                break
            }
            Sleep, % This.SmallWait
        }

        return loggedIn
    }
}

; Hotkeys || ^ = Ctrl, ! = Alt, + = Shift
; ==============================================================================
; The Pandora object is instantiated in the Auto-Execution section of Core.ahk
  F7::pandora.playPause()   ; Plays/Pause the current song in the Pandora client
  F8::pandora.next()        ; Skip to current song in the Pandora Client
 ^F7::pandora.minMax()      ; Maximize or Minimize the Pandora Client
 +F7::pandora.setPos()      ; Resets position of the Pandora Client
^!F7::pandora.kill()        ; Close the Pandora Client
