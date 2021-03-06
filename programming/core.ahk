/*  Programming related functions, hotstrings, and hotkeys.
*/

#IfWinActive, ahk_group consoles ; Only run in consoles (specified in core.ahk)


; Hotstrings
; ==============================================================================
; Git
:*:gs::git status
:*:gd::git diff
:*:gfa::git fetch --all --prune


; Django
:*:drun::python manage.py runserver
:*:dmm::python manage.py makemigrations
:*:dmig::python manage.py migrate
:*:dcol::python manage.py collectstatic --noinput --clear

; PowerShell
:*c:gctail::Get-Content -Path ^v -tail 1 -wait
:*c:gctailsel::Get-Content -Path ^v -tail 1 -wait | Select-String


; Hotkeys || ^ = Ctrl, ! = Alt, + = Shift
; ==============================================================================
+Space::Send {Space}  ; Fix Shift + Space not working in PowerShell terminal.

#IfWinActive ; Clear IfWinActive
