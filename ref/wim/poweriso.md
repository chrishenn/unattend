# poweriso

The second attempt. Instead of scripting, use PowerIso to automatically mount each wim file and add drivers.
This attempt was ultimately untested, since I stopped the setup before getting to the "driver missing" phase.

NOTE: I stopped the test because the unattend file did not work (crashed with err).

---

## add drivers into boot.wim and install.wim

use poweriso -> tools -> dism tool

mounts each "image" inside each wim and adds the drivers
I tried to boot from netboot with these, and it ran into the same "needs a driver" issue - no idea if this worked or if I even added the correct drivers.

---

## create windows winpe

download windows adk and adk_winpe (diff installers)
go to program files -> windows kits -> windows adk -> launch the deployment and imaging tools env

run the commands from learn.microsoft.com to create winpe iso
you can also customize the drivers? updates? in there while it's mounted, but I dunno
https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-usb-bootable-drive?view=windows-11

```cmd
copype amd64 C:\WinPE_amd64
MakeWinPEMedia /ISO C:\WinPE_amd64 C:\WinPE_amd64\WinPE_amd64.iso /bootex
```

---

## boot into windows using netbootxyz

extract the winpe.iso into netboot/assets/winpe/x64
extract the install_windows.iso into H:\testiso

in the netboot.xyz web gui:
go to menus -> create new menu
This url is case-sensitive!!!? Nginx rejects a url win lowercase "winpe" on it. dunno.

```ipxe
# local-vars.ipxe

set win_base_url https://netboot-assets.henn.dev/WinPE
```

boot target machine to netboot.xyz. go to windows -> load installer.
It verifies various files it expects to be present in the extracted winpe folder, then boots to shell.

```cmd
# the shell already ran wpeinit to initialize networking
wpeinit

# didn't work
net use H: \\192.168.1.142\h /user:192.168.1.142\chris <pass>

# worked!
net use H: \\192.168.1.142\H
interactive user/pass

# launched setup. not sure if it got to the copy files phase
H:
cd H:\testiso
.\setup.exe

# immediately ran into unknown exception
.\setup.exe /unattend:H:\testiso\autounattend.xml
```
