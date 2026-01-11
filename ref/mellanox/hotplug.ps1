# Paths
$bootscripts_tgt =  "C:\BOOT\"
$bootscripts_src = ".\scripts"

$bootscript_batfile = "hotplug.bat"
$bootscript_bat_tgt = "$bootscripts_tgt$bootscript_batfile"


# Make C:\BOOT if not exist; copy scripts to run on boot
if (-not(test-path $bootscripts_tgt)) {
    New-Item -Path "$bootscripts_tgt" -ItemType Directory
}
copy-item -Path "$bootscripts_src\*" -Destination $bootscripts_tgt -Force


# make scheduled task that runs script.bat on login
$action = New-ScheduledTaskAction -Execute "$bootscript_bat_tgt"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$task_principle = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DisableMlxHotplug" -Description "Disable Hotplug Descriptor for Mlx NIC" -Principal $task_principle -Settings $settings -Force

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