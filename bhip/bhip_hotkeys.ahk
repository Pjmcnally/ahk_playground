; This ahk file contains the scripts that I use at BHIP.


; Functions used in this module
; ------------------------------------------------------------------------------
format_jira(str){
    ; This function formats text in JIRA recieved through email
    ; It's main purpose is to remove extra lines and {color} tags
    e_count := 0                                                        ; Count of consecutive empty lines
    Loop, parse, str, `n, `r                                            ; Loop over lines of input str
    {
        string := A_LoopField                                           ; Assign current line to string variable
        string := RegExReplace(string, "[\s_]*{color.*?}[\s_]*")        ; Remove all {color} tags and ajoining spaces and underscores
        string := RegExReplace(string, "\xA0+")                         ; Remove all Non-breaking spaces
        string := RegexReplace(string, "\s*\*\s*")                      ; Remove all * and adjoining whitespace
        string := Trim(string)                                          ; Trim whitespace

        if (string) {                                                   ; If there is a string
            if (e_count > 1){                                           ; That was preceeded by more than 1 empty line
                send {Enter}                                            ; Add an empty line
            }
            Send {Raw}%string%                                          ; Send line (Raw to preserve special chars)
            Send {Enter}                                                ; Send newline
            e_count := 0                                                ; Set empty line count to 0
        } else {
            e_count += 1                                                ; Increment empty line count
        }
    }
    Return True
}

format_db_for_jira(){
    ; This function formats content copied out of MSSMS as a table for JIRA
    str := Clipboard                        ; Content needs to already be on the clipboard
    Loop, parse, str, `n, `r                ; Loop over each line on the clipboard
    {
        if (A_Index == 1) {                 ; If this is the first line
                char := "||"                ; use || as divider for header
            } else {
                char := "|"                 ; Otherwise use |
            }
        Loop, Parse, A_LoopField, `t        ; Loop over each element (tab delineated)
        {
            If (A_Index == 1) {
                Send, % char                ; Send first dividing char if first elem in line
            }
            Send, % A_LoopField             ; Send contents of element
            Send, % char                    ; Send closing dividing char
        }
        Send {Enter}                        ; Send newline to end line
    }
}


; Hotstrings in this module
; ------------------------------------------------------------------------------
; Misc Hotstrings
:co:pinfo::Patrick{Tab}McNally{Tab}Pmcnally@blackhillsip.com{Tab}{Down}{Tab}{Tab}{Space}
:o:{c::{{}code{}}{Enter}^v{Enter}{{}code{}}
:co:b1::BACKLOG 001!o
:co:fd::For documentation please see: ^v

; Signature/Ticket Hotstrings
:o:-p::--Patrick
:o:psig::Patrick McNally{Enter}DevOps Support{Enter}pmcnally@blackhillsip.com
:co:ifq::If there are any questions or there is anything more I can do to help please let me know.

; Daily auto-docket review Hotstrings
:co:crule::=AND(A2 <> "", B2 <> "")
:co:abanf::US-90{tab}Application status does not contain "To Be Abandoned"{tab}There are notes that this is to be abandoned but the status wasn't updated.  Nothing we can do.
:co:acmd::Bug with AppColl docketing - Not an issue with Auto-docket{tab}Manual finish docketing{tab}
:co:noarf::US-22, US-251{tab}System tried two p-codes (US-22, US-251).  Both had text rules that failed.{tab}Both rules seem overly specific for this doc.  I am not sure how to fix this.{tab}
:co:attrf::Required attributes not extracted from doc and entered into right side of screen{tab}Not sure why this didn't work (I don't understand this part well yet){tab}
:co:miscf::Many codes{tab}Misc Doc code.  Several rules tried.  All rules failed.{tab}We probably need to make a rule for this specific doc.{tab}
:co:eadr::
    recipients := "Jill{tab}Milena{tab}Leonie{tab}"  ; I don't use full emails here to protect from spam.  Autofill will complete them in my Outlook.
    subject := "Daily Auto-Docket Report"
    body := "All,{Enter}{Tab}I have attached the Daily Auto-Docket Report for " . f_date() . ".{Enter 2}{Tab}If there are any questions or there is anything more I can do to help please let me know."
    send_outlook_email(subject, body, recipients)
Return

; Complex Hotstrings
^!v::
    KeyWait Ctrl    ; Wait for control and alt to be released If not released they
    KeyWait Alt     ; can cause the sent text to issue commands (alt-tab for example)

    format_db_for_jira()  ; Run format_db_for_jira on contents on clipboard
Return

^!f::
    KeyWait Ctrl    ; Wait for control and alt to be released If not released they
    KeyWait Alt     ; can cause the sent text to issue commands (alt-tab for example)

    clip_func("format_jira")    ; Run "format_jira" func on selected text
Return

; SQL Hostrings
:o:bt::{/}{*}{ENTER}BEGIN TRAN{Enter 2}--commit{ENTER}ROLLBACK{ENTER}{*}{/}
