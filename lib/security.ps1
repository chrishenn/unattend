function admin {
    $id = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $id.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
}

function allow_scripts {
    Set-ExecutionPolicy -force -scope LocalMachine -ExecutionPolicy Bypass
    Set-ExecutionPolicy -force -scope CurrentUser -ExecutionPolicy Bypass
}

function uac_disable {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    SetProp $key 'ConsentPromptBehaviorAdmin' 'DWORD' 0
    SetProp $key 'EnableLUA' 'DWORD' 0
}

function run_sys (
    [Parameter(Mandatory)][string] $Command,
    [Parameter(Mandatory)][AllowEmptyString()][string] $Arguments
) {
    # run a command as 'NT AUTHORITY\SYSTEM' by scheduling a task to run it
    Import-Module ScheduledTasks
    $name = "RunAs_LocalSystem_$(New-Guid)"

    $actionArguments = @{'-Execute' = $Command}
    if (-not [string]::IsNullOrEmpty($Arguments)) {
        $actionArguments['-Argument'] = $Arguments
    }
    $action = New-ScheduledTaskAction @actionArguments
    $principal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -LogonType Interactive
    Register-ScheduledTask -TaskName $name -Action $action -Principal $principal | Start-ScheduledTask
    Unregister-ScheduledTask $name -Confirm:$false
}

function run_sess {
    # trying to launch autohotkey binaries in "interactive" shell sesson: this didn't work
    $guis = ((qwinsta console).split('`n').trim()[1] -replace '\s+', ' ').split(' ')[2]
    psexec -i $guis pwsh -c '& C:\users\chris\scoop\apps\hotkey\current\AHhotkey.exe'
}

function get_user {
    $user = Get-LocalUser | where-object {$_.name -notmatch '(administrator|default|guest|utility)'}
    return $user.name
}
