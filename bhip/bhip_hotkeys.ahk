; Misc Hotstrings
:co:ifq::If there are any questions or there is anything more I can do to help please let me know.
:o:{c::{{}code{}}^v{{}code{}}
:co:b1::BACKLOG 001!o

; Signature Hotstrings
:o:-p::--Patrick
:o:psig::Patrick McNally{Enter}DevOps Support{Enter}pmcnally@blackhillsip.com

; Hostrings for various hosts
:co:pinfo::Patrick{Tab}McNally{Tab}Pmcnally@blackhillsip.com{Tab}{Down}{Tab}{Tab}{Space}

; SQL Hostrings
:o:bt::{/}{*}{ENTER}BEGIN TRAN{Enter 2}--commit{ENTER}ROLLBACK{ENTER}{*}{/}

; Ticket Hotstrings
:o:ppdone::This is resolved.{Enter 2}The database was updated to move the documents into "L" status.{Enter 2}The placeholder file was swapped in, xod files were created for each PDF in the JDS and the original file was restored.
:o:deacli::
    str =
(
We have deactivated CLIENT NAME as of DATE.

To do so we did the following:

+*In Appcoll:*+
* Disabled all IP Tools reports for client's instance.

+*In IP Tools:*+
* Disabled workflow triggers for this client.
* Ended all client's tasks
* Ended the client's daily docketing job
* Disabled the client's host credential (HOSTNAME).

 We informed BlackHillsIP that this was completed.
)
    clip_swap(str)
return
