function rebuild_icon_cache {
    # may need to stop explorer first
    # stop-process -name explorer

    cd "$env:userprofile\AppData\Local\Microsoft\Windows\Explorer"
    attrib –h iconcache_*.db
    del iconcache_*.db
}

function unpin_taskbar_allapps {
    $ws = New-Object -Com Shell.Application
    $ns = $ws.NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
    $unpins = $ns.items().verbs() | Where-Object{ $_.Name.replace('&','') -match 'Unpin from taskbar' }
    $unpins | ForEach-Object{ $_.DoIt() }
}

function unpin_startmenu(
    [string] $name
) {
    $ws = New-Object -Com Shell.Application
    $ns = $ws.NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
    $unpins = $ns.items().verbs() | Where-Object{ $_.Name.replace('&','') -match 'Unpin from Start' }
    $unpins | ForEach-Object{ $_.DoIt() }
}

function unpin_taskbar_xml {
    [xml]$xmlDocument = '<?xml version="1.0" encoding="utf-8"?>
            <LayoutModificationTemplate
                xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
                xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
                xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
                xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
                Version="1">
                <CustomTaskbarLayoutCollection PinListPlacement="Replace">
                    <defaultlayout:TaskbarLayout>
                        <taskbar:TaskbarPinList>
                            <taskbar:DesktopApp DesktopApplicationLinkPath="#leaveempty"/>
                        </taskbar:TaskbarPinList>
                    </defaultlayout:TaskbarLayout>
                </CustomTaskbarLayoutCollection>
            </LayoutModificationTemplate>'

    $tgt = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
#    $tgt = "$env:localappdata\Microsoft\Windows\Shell\LayoutModification.xml"
    $xmlDocument.save($tgt)

    $dft = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml"
    setprop "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" 'LayoutXMLPath' 'String' $dft
    setprop "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" 'LayoutXMLPath' 'String' $tgt
}

function startmenu_pins {
    # copied from unattend
    if([System.Environment]::OSVersion.Version.Build -lt 20000) {
        return
    }
    $key = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start'
    setprop $key 'ConfigureStartPins' 'String' '{"pinnedList":[]}'
}

function color2int (
    [System.Drawing.Color] $color
) {
    [byte[]] $bytes = @($color.R, $color.G, $color.B, $color.A)
    return [System.BitConverter]::ToUInt32($bytes, 0)
}

function colorscheme {
    # copied from unattend. not sure if this is totally working in 25H2

    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    setprop $key 'SystemUsesLightTheme' 'DWORD' 0
    setprop $key 'AppsUseLightTheme' 'DWORD' 0
    setprop $key 'ColorPrevalence' 'DWORD' 0
    setprop $key 'EnableTransparency' 'DWORD' 0

    Add-Type -AssemblyName 'System.Drawing'
    $accentColor = [System.Drawing.ColorTranslator]::FromHtml('#613583')

    # unused?
    # $startColor = [System.Drawing.Color]::FromArgb(0xD2, $accentColor)

    setprop 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' 'StartColorMenu' 'DWORD' (color2int -Color $accentColor)
    setprop 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' 'AccentColorMenu' 'DWORD' (color2int -Color $accentColor)
    setprop 'HKCU:\Software\Microsoft\Windows\DWM' 'AccentColor' 'DWORD' (color2int -Color $accentColor)

    $params = @{
        LiteralPath = 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
        Name = 'AccentPalette'
    }
    $palette = Get-ItemPropertyValue @params
    $index = 20
    $palette[ $index++ ] = $accentColor.R
    $palette[ $index++ ] = $accentColor.G
    $palette[ $index++ ] = $accentColor.B
    $palette[ $index++ ] = $accentColor.A
    Set-ItemProperty @params -Value $palette -Type 'Binary' -Force
}

function debloat_packages {
    # copied from unattend
    $names = @(
        'Microsoft.Microsoft3DViewer'
        'Microsoft.BingSearch'
        'Microsoft.WindowsCalculator'
        'Microsoft.WindowsCamera'
        'Clipchamp.Clipchamp'
        'Microsoft.WindowsAlarms'
        'Microsoft.Copilot'
        'Microsoft.549981C3F5F10'
        'Microsoft.Windows.DevHome'
        'MicrosoftCorporationII.MicrosoftFamily'
        'Microsoft.WindowsFeedbackHub'
        'Microsoft.Edge.GameAssist'
        'Microsoft.GetHelp'
        'Microsoft.Getstarted'
        'microsoft.windowscommunicationsapps'
        'Microsoft.WindowsMaps'
        'Microsoft.MixedReality.Portal'
        'Microsoft.BingNews'
        'Microsoft.WindowsNotepad'
        'Microsoft.MicrosoftOfficeHub'
        'Microsoft.Office.OneNote'
        'Microsoft.OutlookForWindows'
        'Microsoft.Paint'
        'Microsoft.MSPaint'
        'Microsoft.People'
        'Microsoft.Windows.Photos'
        'Microsoft.PowerAutomateDesktop'
        'MicrosoftCorporationII.QuickAssist'
        'Microsoft.SkypeApp'
        'Microsoft.ScreenSketch'
        'Microsoft.MicrosoftSolitaireCollection'
        'Microsoft.MicrosoftStickyNotes'
        'MicrosoftTeams'
        'MSTeams'
        'Microsoft.Todos'
        'Microsoft.WindowsSoundRecorder'
        'Microsoft.Wallet'
        'Microsoft.BingWeather'
        'Microsoft.WindowsTerminal'
        'Microsoft.Xbox.TCUI'
        'Microsoft.XboxApp'
        'Microsoft.XboxGameOverlay'
        'Microsoft.XboxGamingOverlay'
        'Microsoft.XboxIdentityProvider'
        'Microsoft.XboxSpeechToTextOverlay'
        'Microsoft.GamingApp'
        'Microsoft.YourPhone'
        'Microsoft.ZuneMusic'
        'Microsoft.ZuneVideo'
    )
	$installed = Get-AppxProvisionedPackage -Online
	foreach ($name in $names) {
		if ($found = $installed | Where-Object {$_.DisplayName -eq $name}) {
			Remove-AppxProvisionedPackage $found -AllUsers -Online -ErrorAction 'Continue'
			if($?) {
				write-host "removed package: $found"
			} else {
				write-host "found package: $found but failed to remove"
			}
		} else {
            write-host "no package for: $name"
        }
	}
}

function deblot_capabilities {
    # copied from unattend
    $names = @(
        'Print.Fax.Scan'
        'Language.Handwriting'
        'Browser.InternetExplorer'
        'MathRecognizer'
        'OneCoreUAP.OneSync'
        'OpenSSH.Client'
        'Microsoft.Windows.MSPaint'
        'Microsoft.Windows.PowerShell.ISE'
        'App.Support.QuickAssist'
        'Microsoft.Windows.SnippingTool'
        'Language.Speech'
        'Language.TextToSpeech'
        'App.StepsRecorder'
        'Hello.Face.18967'
        'Hello.Face.Migration.18967'
        'Hello.Face.20134'
        'Media.WindowsMediaPlayer'
        'Microsoft.Windows.WordPad'
    )
    $installed = Get-WindowsCapability -Online | Where-Object -Property 'State' -NotIn -Value @('NotPresent', 'Removed')
    foreach ($name in $names) {
        if ($found = $installed | Where-Object {($_.Name -split '~')[0] -eq $name}) {
            Remove-WindowsCapability $found -Online -ErrorAction 'Continue'
            if($?) {
				write-host "removed capability: $found"
			} else {
				write-host "found capability: $found but failed to remove"
			}
		} else {
            write-host "no capability for: $name"
        }
    }
}

function debloat_features {
    # copied from unattend
    $names = @(
        'MediaPlayback'
        'MicrosoftWindowsPowerShellV2Root'
        'Microsoft-RemoteDesktopConnection'
        'Recall'
        'Microsoft-SnippingTool'
    )
    $installed = Get-WindowsOptionalFeature -Online | Where-Object -Property 'State' -NotIn -Value @('Disabled', 'DisabledWithPayloadRemoved')
    foreach( $name in $names ) {
        if ($found = $installed | Where-Object {$_.FeatureName -eq $name}) {
            Disable-WindowsOptionalFeature $found -Online -Remove -NoRestart -ErrorAction 'Continue'
            if($?) {
				write-host "removed feature: $found"
			} else {
				write-host "found feature: $found but failed to remove"
			}
		} else {
            write-host "no feature for: $name"
        }
    }
}

function debloat_contentdelivery {
    # copied from unattend
    $names = @(
        'ContentDeliveryAllowed'
        'FeatureManagementEnabled'
        'OEMPreInstalledAppsEnabled'
        'PreInstalledAppsEnabled'
        'PreInstalledAppsEverEnabled'
        'SilentInstalledAppsEnabled'
        'SoftLandingEnabled'
        'SubscribedContentEnabled'
        'SubscribedContent-310093Enabled'
        'SubscribedContent-338387Enabled'
        'SubscribedContent-338388Enabled'
        'SubscribedContent-338389Enabled'
        'SubscribedContent-338393Enabled'
        'SubscribedContent-353694Enabled'
        'SubscribedContent-353696Enabled'
        'SubscribedContent-353698Enabled'
        'SystemPaneSuggestionsEnabled'
    )
    # not sure about this defaultuser key
    $key = 'registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    foreach($name in $names) {
        setprop $key $name 'DWORD' 0
    }
}

function home_reparsepoints {
    # these are for backwards-compatibility with ancient programs
    # probably not a good idea to remove

    # C:\Users\chris
    # Application Data -> C:\Users\chris\AppData\Roaming
    # Local Settings -> C:\Users\chris\AppData\Local
    # My Documents -> C:\Users\chris\Documents
    # Start Menu -> C:\Users\chris\AppData\Roaming\Microsoft\Windows\Start Menu

    $paths = Get-ChildItem $HOME -force
    $rms = $paths | Where-Object {$_.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)}
}
