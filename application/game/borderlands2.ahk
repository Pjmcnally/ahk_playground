/*  This is my script for auto run in borderlands 2.  Honestly, I just got tired
    of holding down Shift all the time to run so I made this.
*/

;#IfWinActive ahk_class BigHugeClass
;#IfWinActive ahk_class Borderlands 2 (32-bit`, DX9)
#IfWinActive ahk_exe Borderlands2.exe  ; Only run in Borderlands 2

~$w::  ; Start running.
    varInt = 0
    Send {shift up}
    Send {shift down}
    Send {shift up}
Return


~$s::  ; Stop running.
    if varInt {
        varInt = 0
        Send {w up}
        Send {shift up}
    }
Return


; ~$a::
; if varInt {
;     varInt = 0
;     Send {w up}
;     Send {shift up}
; }
; Return


; ~$d::
; if varInt {
;     varInt = 0
;     Send {w up}
;     Send {shift up}
; }
; Return


t::  ; Stop running.
    if varInt {
        varInt = 0
        Send {w up}
        Send {shift up}
    } else {
        varInt = 1
        Send {w down}
        Send {shift down}
    }
Return

; This should always be at the bottom
#IfWinActive ; End #IfWinActive for Borderlands
