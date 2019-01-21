/*  DevOps functions, hotstrings, and hotkeys used at BHIP.
*/

; Functions
; ==============================================================================
; Run on local system after merging a branch into master to other branches.
get_dep_remote() {
    str =
    ( LTrim
        workon devops_live
        write-host "``r``nUpdating Live deploy`r`n===================="
        git checkout deploy
        git fetch --all --prune
        git pull
        workon devops_test;
        write-host "``r``nUpdating Test master`r`n===================="
        git checkout master
        git fetch --all --prune
        git pull
        write-host "``r``nUpdating Test test`r`n===================="
        git checkout test
        git fetch --all --prune
        git pull
        write-host "``r``nUpdating Test deploy`r`n===================="
        git checkout deploy
        git fetch --all --prune
        git pull
        Write-Host "`r`nReturning to Master`r`n===================="
        git checkout master
    )
    Return str
}

get_dep_local() {
    str =
    ( LTrim
        workon DevOps
        write-host "``r``nPulling changes to master`r`n===================="
        git checkout master
        git fetch --all --prune
        git pull
        write-host "``r``nMerging master into test`r`n===================="
        git checkout test
        git fetch --all --prune
        git merge master
        git push
        write-host "``r``nMerging master into deploy`r`n===================="
        git checkout deploy
        git fetch --all --prune
        git merge master
        git push
        Write-Host "`r`nReturning to Master`r`n===================="
        git checkout master
    )
    Return str
}

; Hotstrings
; ==============================================================================
; Run on local system after merging a branch into master to other branches.
:*:depLocal::
    paste_contents(get_dep_local())
Return

; Run on remote system after updating all branches to pull down changes.
:*:depRemote::
    paste_contents(get_dep_remote())
Return
