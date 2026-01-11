. $psscriptroot\hotkey_lib.ps1

function hotkey {
    ah_kill
    start-sleep -s 2
    ah_copy "$psscriptroot\compiled"
    ah_start
}

hotkey
