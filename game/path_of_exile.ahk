getItemName(str) {
    /*  Items can be copied in PoE by mousing over and pressing ctrl-c. The
        items name is alwasy on the second line.

        This function extracts the items name to be used in certain websites.
    */

    Array := StrSplit(str, "`r", "`n")
    return Array[2]
}

checkPoePrice() {
    name := getItemName(clipboard)
    ; link := buildPoeNinjaLink(name)

    Send, ^a
    Send, % name
    Send, {Enter}
}

checkPoeMap() {
    item := get_highlighted()
    map_properties := StrSplit(item, "`r", "`n")

    bad_statuses := ["Players are Cursed with Temporal Chains", "Players cannot Regenerate Life, Mana or Energy Shield"]
    results := ""

    for index, elem in map_properties {
        if (HasVal(bad_statuses, elem)) {
            MsgBox, % "Re-Roll map:`r`n" . elem
            Break
        }
    }

    MsgBox, , % "Run", % "Good to run", .3
}

#IfWinActive, ahk_exe PathOfExile_x64Steam.exe
^+c::  ; Ctrl-Alt-C Check Map statuses
    checkPoeMap()
return
#IfWinActive

#IfWinActive, poe.ninja - Google Chrome
^v::  ; Override ctrl-v for just this website only in Chrome
    checkPoePrice()
return
#IfWinActive

#IfWinActive, PoE Goods - Google Chrome
^v::  ; Override ctrl-v for just this website only in Chrome
    checkPoePrice()
return
#IfWinActive
