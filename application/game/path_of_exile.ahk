; All of the items below are now obsolete due to PoE Trade Macro
; getItemName(str) {
;     /*  Items can be copied in PoE by mousing over and pressing ctrl-c. The
;         items name is always on the second line.

;         This function extracts the items name to be used in certain websites.
;     */

;     Array := StrSplit(str, "`r", "`n")
;     Return Array[2]
; }

; checkPoePrice() {
;     name := getItemName(clipboard)

;     Send, ^a
;     Send, % name
;     Send, {Enter}
; }

; #IfWinExist, ahk_exe PathOfExile_x64Steam.exe
; ^v::
;     if (WinActive("poe.ninja - Mozilla Firefox")
;         or WinActive("PoE Goods - Mozilla Firefox")
;         or WinActive("Trade - Path of Exile - Mozilla Firefox"))
;     {
;         checkPoePrice()
;     } else {
;         Send ^v
;     }
; #IfWinActive

#IfWinActive, ahk_exe PathOfExile_x64Steam.exe
^+r::  ; Ctrl-Shift-R
    run "Z:\Documents\Path of Building\POE-TradeMacro-2.16.0\Run_TradeMacro.ahk"
    run "Z:\Documents\Path of Building\POE-Trades-Companion-AHK-v-1-15-BETA_9991\POE Trades Companion.ahk"
Return

^h::
    Send {Enter}/hideout{Enter}
Return
#IfWinActive
