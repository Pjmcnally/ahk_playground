/*  Hotkeys, Hotstrings, Functions used at BHIP.

This module contains all of the Hotkeys, Hotstrings and functions I use at BHIP.
*/

; Functions used in this module
; ==============================================================================
fill_scrape_mail_date() {
        /*  Fill scrape start dates and mail start date into jobs screen.

        Args:
            None
        Return:
            None
    */
    InputBox, scrape_start, % "Scrape Start", % "Please enter scrape start date"
    if ErrorLevel
        Exit
    InputBox, mail_start, % "Mail Start", % "Please enter mail start date"
    if ErrorLevel
        Exit
    InputBox, num, % "Number?", % "Please enter the number of lines to fill"
    if ErrorLevel
        Exit
    i = 0
    box_height := 24

    While(i < num) {
        if (Mod(i, 20) = 0) {
            KeyWait, LButton, D
            MouseGetPos, x, y
        }

        Sleep, 200
        Send {Click, 2}
        Sleep, 200
        Send, % scrape_start
        Click, 325, 1225, 2  ; Magic number for location of mail date box
        Sleep, 200
        Send, % mail_start

        y += box_height
        MouseMove, x, y

        i += 1
    }
}

format_jira(str) {
    /*  Reformat text sent into JIRA from Outlook email.

        Outlook add extra line breaks to emails sent to JIRA.  Also, JETI tries
        to process colors and adds {color} tags around all text (even black).
        These "features" combine to make text very hard to read.

        This function cleans up the text and makes it much more human readable.

        Args:
            str (str): The text to be cleaned up.
        Return:
            str: The cleaned text.
    */
    res := ""
    CrLf := "`r`n"
    empty_count := 0

    Loop, parse, str, `n, `r
    {
        line := A_LoopField
        line := RegExReplace(line, "\xA0+")  ; Remove all Non-breaking spaces
        line := RegExReplace(line, "{color.*?}")  ; Remove all {color} tags
        line := RegexReplace(line, "\*\s*(.*?)\s*\*", "$1")  ; Remove all * tags leaving surrounded text
        line := RegexReplace(line, "\+\s*(.*?)\s*\+", "$1")  ; Remove all + tags leaving surrounded text
        line := RegExReplace(line, "\_\s*(.*?)\_\s*", "$1")  ; Remove all _ tags leaving surrounded text
        line := RegExReplace(line, "\[{2,}(.*?)\]{2,}", "[$1]")  ; Convert double brackets to single.
        line := RegExReplace(line, "(?:(\[)\s+|\s+(\]))", "$1$2")  ; Remove any spaces immediately inside of open bracket or before closing bracket
        line := RegExReplace(line, "\[(.*?)\|\]", "$1")  ; Remove any link tags with no link content



        line := Trim(line)  ; Trim whitespace


        if not (line) {  ; Some lines end up empty.  Consecutive empty lines are collapsed to 1.
            empty_count += 1
        } else if (line and empty_count > 1 ) {  ; If a line is preceded by multiple empty lines append it too string with preceding empty line
            res := res . CrLf . line . Crlf
            empty_count := 0
        } else {  ; Otherwise just add to string.
            res := res . line . CrLf
            empty_count := 0
        }
    }

    return res
}

format_db_for_jira() {
    /*  Format content copied out of MSSMS as a table for JIRA and paste results.
    */
    res := ""
    CrLf := "`r`n"
    str := Clipboard

    Loop, parse, str, `n, `r
    {
        div_char := (A_Index == 1) ? "||" : "|"  ; || in header. | elsewhere.
        Loop, Parse, A_LoopField, `t
        {
            If (A_Index == 1) {  ; If first elem precede with div char
                res := res . div_char
            }
            res := res . A_LoopField . div_char
        }
        res := res . CrLf
    }

    paste_contents(res)
    return
}

send_UPDB_email(option) {
    if (option = "start") {
        subject := "Importing UPDB Today"
        body := "I will be importing today, starting at 7:15 pm. Please be sure to exit the UPDB before then.{Enter 2}Thank you."
    } else if (option = "done") {
        subject := "Importing UPDB Today - Complete"
        body := "The import of the UPDB is now complete.{Enter 2}There were some import conflicts. I have added them to the spreadsheet."
    } else {
        MsgBox, % "No valid option specified"
    }

    recipients := get_updb_email_group()
    send_outlook_email(subject, body, get_updb_email_group())
}

; Hotstrings & Hotkeys in this module
; ==============================================================================
; Misc Hotstrings
:co:{f::From error log:{Enter}{{}code{}}{Enter}^v{Enter}{{}code{}}
:co:{c::{{}code{}}{Enter}^v{Enter}{{}code{}}
:co:{q::{{}quote{}}{Enter}^v{Enter}{{}quote{}}
:co:b1::BACKLOG 001!o

; Meeting hotkeys (for time entry)
:co:mdad::Task-78{Tab 3}* Getting raw data for auto-docket review{Enter}Parsing data and updating auto-docket review spreadsheet  ; *'s for all items after first are auto-filled by JIRA
:co:mdev::Task-80{Tab 3}* Weekly DevOps Meeting
:co:mwad::Task-82{Tab 3}* Weekly Auto-Docket Meeting
:co:mrel::Task-83{Tab 3}* Weekly Release Meeting
:co:mmbhip::Task-95{Tab 3}* Monthly BHIP Meeting

; Other billing hotkeys
:co:tupdb::Task-94{Tab 3}* Updating UPDB

; Signature/Ticket Hotstrings
:o:psig::Patrick McNally{Enter}DevOps Support{Enter}pmcnally@blackhillsip.com
:co:ifq::If there are any questions or there is anything more I can do to help please let me know.

; UPDB Import emails
#IfWinActive ahk_exe OUTLOOK.EXE
:co:eups::
    send_UPDB_email("start")
return

:co:eupd::
    send_UPDB_email("done")
return
#IfWinActive  ; End UPDB Import emails

#IfWinActive ahk_exe Ssms.exe  ; SQL HotStrings
:o:bt::{/}{*}{ENTER}BEGIN TRAN{Enter 2}--commit{ENTER}ROLLBACK{ENTER}{*}{/}
<<<<<<< HEAD
#IfWinActive ; End SQL Hotstrings
=======
#IfWinActive ; End SQL HotStrings
>>>>>>> e938b560b465906703ba347648e7876c9a89d4c4

; Complex Hotkeys
^!v::
    format_db_for_jira()  ; Run format_db_for_jira on contents on clipboard
return

^!f::
    clip_func("format_jira")  ; Run "format_jira" func on selected text
return

^!d::
    fill_scrape_mail_date()
return
