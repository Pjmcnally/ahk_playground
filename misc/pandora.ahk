; I run pandora on all of my computers. However, I run differnt
; versions depending on the computer. This set of hotkeys allows
; me to use a standard interface regardless of app or computer.

class PandoraInterface {
    SetVersion() {
        ; Test for Legacy version of Pandora Client and set config
        if (fileExist("C:\Program Files (x86)\Pandora\pandora.exe")) {
            This.Version := "Legacy"
            This.Source := "C:\Program Files (x86)\Pandora\pandora.exe"
            This.Window := "ahk_exe Pandora.exe"
            This.Wait := 3000
        ; Test for WinApp version of Pandora Client and set config
        } else if (FileExist("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Pandora\pandora.lnk")) {
            This.Version := "WinApp"
            This.Source := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Pandora\pandora.lnk"
            This.Window := "Pandora ahk_exe ApplicationFrameHost.exe"
            This.Wait := 5000
        } else {
            MsgBox, % "Pandora not found. Unable to proceed."
        }
    }

    playPause() {
        if WinExist(This.Window) {
            if (This.Version = "Legacy") {
                ControlSend, , {Space}, % This.Window
            } else if This.Version = "WinApp" {
                Send, {Media_Play_Pause}
            }
        } else {
            This.runMin()
        }
    }

    next() {
        if WinExist(This.Window) {
            if (This.Version = "Legacy") {
                ControlSend, , {Right}, % This.Window
            } else if This.Version = "WinApp" {
                Send, {Media_Next}
            }
        } else {
            This.runMin()
        }
    }

    runMin() {
        ; Function to run then minimize Pandora.
        Run, % This.Source
        Sleep, % This.Wait
        WinMinimize, % This.Window
    }

    kill() {
        if WinExist(This.Window) {
            WinClose, % This.Window
        }
    }

    minMax() {
        if (WinExist(This.Window) and WinActive(This.Window)) {
            WinMinimize, % This.Window
        } else if (WinExist(This.Window) and (!WinActive(This.Window))) {
            WinActivate, % This.Window
        } else {
            This.runMin()
        }
    }

    reset() {
        if WinExist(This.Window) {
            WinClose, % This.Window
            WinWaitClose, % This.Window
        }

        This.runMin()
    }
}

; Hotstrings in this module
; ------------------------------------------------------------------------------
; This hotkey plays/pauses the Windows Pandora client
F11::  ; F11
    pandora := new PandoraInterface
    pandora.SetVersion()
    pandora.playPause()
return


; This hotkey skips to the next song on the Windows Pandora Client
F12::  ; F12
    pandora := new PandoraInterface
    pandora.SetVersion()
    pandora.Next()
return


; This hotkey Maximizes or Minimize the Windows Pandora Client
^F11::  ; CTRL-F11
    pandora := new PandoraInterface
    pandora.SetVersion()
    pandora.minMax()
return


; This hotkey Maximizes or Minimize the Windows Pandora Client
+F11::  ; Shift-F11
    pandora := new PandoraInterface
    pandora.SetVersion()
    pandora.Reset()
return


; This hotkey closes the Windows Pandora Client
^!F11::  ; CTRL-ALT-F11
    pandora := new PandoraInterface
    pandora.SetVersion()
    pandora.kill()
return
