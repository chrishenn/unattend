

function find_svcnames_from_stems
{
    # pass array of strings, where service name starts with stem and ends in random string of chars
    # passed array is modified in-place with full service names
    param (
        [Parameter(Mandatory=$true)]
        $stems
    )

    for ($i = 0; $i -lt $stems.count; $i++)
    {
        $stem = $stems[$i]
        $svc_obj = get-service -Name "$stem*"
        $stems[$i] = $svc_obj.Name
    }
}


function set_svc_start_values
{

    param (
        [Parameter(Mandatory=$true)]
        $svc_names,

        [Parameter(Mandatory=$true)]
        $start_value
    )

    if ($start_value -lt 2) {
        " Invalid start_value: must be 2 (automatic), 3 (manual), or 4 (disabled) "
        return
    }

    $svc_start_desc = @(
      "boot",
      "system",
      "automatic",
      "manual",
      "disabled"
    )

    $start_setting_name = $svc_start_desc[$start_value]

    for ($i = 0; $i -lt $svc_names.count; $i++)
    {

       $svc_name = $svc_names[$i]

       "   Setting $svc_name to: $start_setting_name ($start_value)"

       try {
         $svc_path = "HKLM:\SYSTEM\CurrentControlSet\Services\" + "$svc_name"
         Set-ItemProperty -Path $svc_path -Name "Start" -Value $start_value -ErrorAction Stop
       } catch {

          try {
            $svc_path001 = "HKLM:\SYSTEM\ControlSet001\Services\" + "$svc_name"
            Set-ItemProperty -Path $svc_path001 -Name "Start" -Value $start_value -ErrorAction Stop
          } catch {

           try {
             $svc_path002 = "HKLM:\SYSTEM\ControlSet002\Services\" + "$svc_name"
             Set-ItemProperty -Path $svc_path002 -Name "Start" -Value $start_value -ErrorAction Stop
           } catch {
             "      Couldn't write to Start key value for $svc_name "
         }
        }
       }

    }
}


function start_svc_list
{
    param (
        [Parameter(Mandatory=$true)]
        $svc_names
    )

    $svc_names | ForEach-Object {
        "   Starting: $_ "
        Start-Service -Name $_
    }
}


function stop_svc_list
{
    param (
        [Parameter(Mandatory=$true)]
        $svc_names
    )

    $svc_names | ForEach-Object {
        "   Stopping: $_ "
        Stop-Service -Name $_ -Force
    }
}

function create_ps1_shortcut
{
    param ( [Parameter(Mandatory=$true)][string]$SourcePs1Path, [Parameter(Mandatory=$true)][string]$DestinationPath )

    " Creating ps1 shortcut for script at: $SourcePs1Path"

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-noexit -ExecutionPolicy Bypass -File " + $SourcePs1Path
    $Shortcut.Save()
}



Export-ModuleMember -Function find_svcnames_from_stems, set_svc_start_values, start_svc_list, stop_svc_list, create_ps1_shortcut
