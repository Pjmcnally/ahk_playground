#IfWinExist, ahk_exe PathOfExile_x64Steam.exe

attack_in_place() {
    keybind := get_aip_keybind()
    gui_name := "AipGui"
    word_status := {0: "Off", 1: "On"}
    game := "ahk_exe PathOfExile_x64Steam.exe"

    if GetKeyState(keybind) {
        Send {%keybind% up}
    } else {
        Send {%keybind% down}
    }

    gui_id := get_gui_id(gui_name)
    if (gui_id = "0x0") {  ; "0x0" is returned if gui doesn't exist
        build_aip_gui(word_status[GetKeyState(keybind)])
    } else {
        update_gui(gui_name, word_status[GetKeyState(keybind)])
    }

    winActivate, % game
}

get_aip_keybind() {
    return "F10"
}

build_aip_gui(state) {
    Gui, AipGui:New, ,
    Gui, AipGui:Color, green
    Gui, AipGui:+AlwaysOnTop
    Gui, AipGui:+Border
    Gui, AipGui:-SysMenu
    Gui, AipGui:+ToolWindow
    Gui, AipGui:Show, h0 w25 NoActivate, % state
}

$F10::
    attack_in_place()
return

#IfWinExist
