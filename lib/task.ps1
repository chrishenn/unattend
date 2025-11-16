function new_task {
    # make scheduled task that runs script.bat on login
    $act = New-ScheduledTaskAction -Execute "$bootscript_bat_tgt"
    $trig = New-ScheduledTaskTrigger -AtLogOn
    $prin = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8
    $tname = 'DisableMlxHotplug'
    $desc = 'do thing'

    Register-ScheduledTask -Action $act -Trigger $trig -TaskName $tname -Description $desc `
        -Principal $prin -Settings $settings -Force
}
