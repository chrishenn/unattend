(get-childitem "$psscriptroot/../lib/*.ps1").foreach({. $_.FullName})

function hotkey {
    ah_kill
    start-sleep -s 2
    ah_copy "$psscriptroot\compiled"
    ah_start
}

hotkey
