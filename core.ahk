/*  Core settings, hotstrings, and functions.

This module contains three parts: Auto-Execute, Universal Functions, and
Universal hotstrings.

It is key to note that autohotkey_main.ahk is system specific where core.ahk is
universal. Core.ahk contains settings, hotstrings, and functions that are
desired across all other modules and used across all systems.

The Auto-Execute section sets global parameters across all other modules
imported by autohotkey_main. These settings are essentially universal. If
there are system specific Auto-Execute commands those should be added to
the Auto-Execute section of autohotkey_main.ahk.

The other sections are Universal Functions and Universal Hotstrings. These are
core hotstrings and functions that are needed on all systems. These functions
are sometimes required by other modules/functions. It is assumed by other
modules that this module is imported.
*/

; Auto-Execute Section (All core Auto-Execute commands should go here)
; ==============================================================================
#SingleInstance, Force          ; Automatically replaces old script with new if the same script file is rune twice
#NoEnv                          ; Avoids checking empty variables to see if they are environment variables (recommended for all new scripts).
#Warn                           ; Enable warnings to assist with detecting common errors. (More explicit)
#Hotstring EndChars `n `t       ; Limits hotstring ending characters to {Enter}{Tab}{Space}
SendMode Input                  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir%    ; Ensures a consistent starting directory.
SetTitleMatchMode, 2            ; 2: A window's title can contain WinTitle anywhere inside it to be a match.

; Create group of consoles for git commands
GroupAdd, consoles, ahk_exe pwsh.exe
GroupAdd, consoles, ahk_exe powershell.exe
GroupAdd, consoles, ahk_exe powershell_ise.exe
GroupAdd, consoles, ahk_exe RDCMan.exe
GroupAdd, consoles, ahk_exe Code.exe

return  ; End of Auto-Execute Section

; Universal Functions:
; ==============================================================================
get_highlighted(persist=TRUE, e=TRUE) {
    /*  Return whatever text is currently highlighted in the active window.

        Args:
            None
        Returns:
            str: Highlighted text
    */

    if (persist) {
        ClipSaved := ClipboardAll
    }
    Clipboard =
    Sleep, 100

    Send ^c
    ClipWait, 2, 1
    if (ErrorLevel and e) {
        MsgBox, % "No text selected.`r`n`r`nPlease select text and try again."
        return
    } else if (ErrorLevel and not e) {
        res :=
    } else {
        res := Clipboard
    }

    if (persist) {
        Clipboard := ClipSaved
        ClipSaved =
    }

    return res
}

paste_contents(str) {
    /*  Paste a string without disturbing contents of clipboard.

    Args:
        str (str): The text to be pasted
    Returns:
        None
    */
    ClipSaved := ClipboardAll
    Clipboard := str
    Send, ^v

    ; This sleep is a bit weird. Without it, AutoHotkey will send a paste
    ; command to the OS and then immediately restore the clipboard.
    ; This happens so fast that the old contents get pasted instead of new.
    Sleep, 100

    Clipboard := ClipSaved
    ClipSaved =

    return
}

clip_func(func) {
    /*  Run func on highlighted text and replace text.

        This function takes in a func name. That function is run on whatever
        text is currently highlighted. The results are pasted over the
        highlighted text.

        Args:
            func (str): Name of function to be run on highlighted text
        Returns:
            None
    */
    str := get_highlighted()
    if (str) {
        res := %func%(str)
        paste_contents(res)
    }

    return
}

timer_wrapper(func, args:="") {
    /*  A wrapper function to time the wrapped function

        This function takes in a func name and list of arguments (optional).
        That provided function is run with the provided arguments. That
        process is timed which is displayed at the end.

        Args:
            func (str): Name of function to be run on highlighted text
            args (str): Optional. Args for internal function
        Returns:
            None
    */
    start_time := A_TickCount

    %func%(%args%)

    end_time := A_TickCount
    t_diff := end_time - start_time
    MsgBox, % milli_to_hhmmss(t_diff)
}

milli_to_hhmmss(milli) {
    /*  A function to convert milliseconds to readable time.

        Args:
            milli (int): number of milliseconds
        Returns:
            Str: The formatted string in hh:mm:ss.mil
    */
    mil := mod(milli, 1000)
    sec := mod(milli //= 1000, 60)
    min := mod(milli //= 60, 60)
    hou := milli // 60
    return Format("{1:02d}:{2:02d}:{3:02d}.{4:03d}", hou, min, sec, mil)
}

string_upper(string) {
    /*  Call stringUpper as a function (not command)
    */
    StringUpper, res, string
    return res
}

string_lower(string) {
    /*  Call stringLower as a function (not command)
    */
    StringLower, res, string
    return res
}

string_hyphenate(string) {
    /*  Function to replace all spaces with hyphens '-'
    */
    res := StrReplace(string, " ", "-")
    return res
}

string_underscore(string) {
    /*  Function to replace all spaces with underscore '_'
    */
    res := StrReplace(string, " ", "_")
    return res
}

f_date(date:="", format:="MM-dd-yyyy") {
    /*  Function to return formatted date.

        Args:
            date (str): Optional. If not provided will default to current date & time. Otherwise, specify all or the leading part of a timestamp in the YYYYMMDDHH24MISS format
            format (str): Optional. If not provided will default to MM-dd-yyyy. Provide any format (as string)  https://autohotkey.com/docs/commands/FormatTime.html
        Returns:
            str: Date in specified format
    */
    FormatTime, res, %date%, %format%
    return res
}

send_outlook_email(subject, body, recipients := "") {
    /*  Fill content into Outlook email.

        Args:
            subject (str): The subject of the email
            body (str): The body of the email
            recipients (str): Optional. Recipients of email.
        Return:
            None
    */
    if (recipients) {
        Send, %recipients%{Tab 2}
    }
    Send, %subject%{Tab}
    Send, % body

    return
}

click_and_return(x_dest, y_dest, speed:=0) {
    /*  Click a specified location and returns pointer to original location.
    */
    MouseGetPos,  x_orig, y_orig
    MouseMove, % x_dest, y_dest, 0
    Click Down
    Sleep 10  ; For stability and consistent results, increase if issues occur.
    Click Up
    MouseMove, % x_orig, y_orig, 0
    return
}

HasVal(haystack, needle) {
    if !(IsObject(haystack)) || (haystack.Length() = 0)
        return 0
    for index, value in haystack
        if (value = needle)
            return index
    return 0
}

SendWait(msg, wait:=0) {
    Send % msg
    if (wait) {
        Sleep % wait
    }
}

SendLines(iter, wait:=0) {
    For index, value in iter {
        SendWait(value, wait)
        SendWait("{Enter}", wait)
    }
}

; Universal Hotstrings:
; ==============================================================================
^Space::  ; Assign Ctrl-Spacebar as a hotkey to pause all active ahk processes
    ; I cant KeyWait here or it won't work. Also it is unnecessary.
    Pause, Toggle
return

^!Space::  ; Assign Ctrl-Alt-Spacebar to suspend all hotkeys
    ; I cant KeyWait here or it won't work. Also it is unnecessary.
    Suspend, Toggle
return

^!r::  ; Assign Ctrl-Alt-R as a hotkey to reload active script.
    KeyWait ctrl
    KeyWait alt
    Reload
return

^!u::  ; Ctrl-Alt-U to uppercase any highlighted text
    KeyWait ctrl
    KeyWait alt
    clip_func("string_upper")
return

^!l::  ; Ctrl-Alt-L to lowercase all highlighted text
    KeyWait ctrl
    KeyWait alt
    clip_func("string_lower")
return

^!-:: ; Ctrl-Alt-Hyphen to Hyphenate all text
    KeyWait ctrl
    KeyWait alt
    clip_func("string_hyphenate")
return

^!+_:: ; Ctrl-Alt-Shift-Underscore to underscore all text
    KeyWait ctrl
    KeyWait alt
    KeyWait shift
    clip_func("string_underscore")
return

:?*:!  ::  ; I am trying to break the habit of double spacing after a sentence.
:?*:?  ::
:?*:.  ::
    ; A_ThisLabel = ":?*:!  " or whichever hotstring was invoked.
    ; SubString(..., 5, 2) Extracts the punctuation mark and 1 space
    str := SubStr(A_ThisLabel, 5, 2)
    SendRaw, % str  ; SendRaw so "!" isn't interpreted as "alt"
    SoundBeep, 750, 500
return

^!t::  ; Ctrl-Alt-T for temp function/hotkeys (one-offs uses or testing)
    KeyWait ctrl
    KeyWait alt
return
