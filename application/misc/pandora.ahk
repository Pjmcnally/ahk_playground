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

    ; Set wait times
    static SmallWait := 100
    static BigWait := 8000

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
        This.Height := 585
        This.Width := 500

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
        Run, % This.Source

        ; Set window position and minimize
        This.SetPos()
        This.Minimize()

        ; Start music
        Sleep, % This.BigWait
        This.playPause()
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
        while (WinActive(This.Window)) {
            WinMinimize, % This.Window
            Sleep, % This.SmallWait
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
            Sleep, % this.BigWait
        }

        ; Check if Pandora not running. If yes, kill timer.
        if (!(WinExist(this.Window))) {
            timer := this.Timer
            setTimer, % timer, OFF  ; Turn off timer
        }
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
