# dism offline

## Missing Drivers

#note This likely won't work, because the iso needs to be mounted on a network share in order to boot to this screen - so the online driver inject probably can't modify the base image that will be redownloaded on next boot attempt

### Online Driver Inject

- extract all the drivers to a USB thumb drive (D: in this example)
- boot with the Windows CD
- go to the recovery console ( Shift + F10 )
- find out what drive letter your windows installation is in (probably C:) and what drive letter drivers are in

```
DISM /Image:C:\ /Add-Driver /driver:D:\ /recurse
```

- wait until the process completes. You should see lines indicating what driver is being injected
- reboot

After rebooting, you should be able to boot into windows (if the boot menu for start-up repair shows,
just select the option to boot Windows normally).

This appears to be modifying the installer's image, while mounted in the installer runtime. I'm thinking this would not work when the storage driver is missing for the driver itself.

---

## Offline Driver Inject

https://woshub.com/integrate-drivers-to-windows-install-media/

```
OWCINJECT
	- drivers
	- ISO
	- mount
```

extract installer contents into ISO folder

get the index of the version of Windows you want to inject drivers into

```
Dism /Get-WimInfo /WimFile:E:\OWCINJECT\ISO\sources\install.wim
```

Do the same with `boot.wim` as we will have to modify that as well

```
Dism /Get-WimInfo /WimFile:E:\OWCINJECT\ISO\sources\boot.wim
```

Now mount the edition of Windows you want. Preferably you should do it with every index/version

```
Dism /Mount-Image /ImageFile:E:\OWCINJECT\ISO\sources\install.wim /Index:4 /MountDir:E:\OWCINJECT\MOUNT
```

Then inject the drivers into the image. This command will recursively install all files in the folder

```
Dism /Image:E:\OWCINJECT\MOUNT /Add-Driver /Driver:E:\OWCINJECT\Driver_Win10 /Recurse
```

Once the driver installation is done, unmount the image and commit changes

```
Dism /Unmount-Image /MountDir:E:\OWCINJECT\MOUNT /Commit
```

then use imgBurn to burn the modified .wim files and the extracted ISO folder into an .iso installer file.

or

```
oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,bc:\iso\boot\etfsboot.com#pEF,e,bc:\iso\efi\microsoft\boot\efisys.bin c:\iso c:\Win.iso
```

---

you can also use oscdimg from the windows ADK "deployment tools" instead of imgburn to do the iso packing
https://w365.dk/index.php/2022/03/19/how-to-add-drivers-to-windows-installation-iso-windows-10-11/

for install.wim, boot.wim
for each index in the .wim
install the drivers

- install.wim might be install.esd
- mount wim on linux
    - https://manpages.ubuntu.com/manpages/xenial/man1/wimlib-imagex-mount.1.html
    - https://unix.stackexchange.com/questions/283446/how-to-create-bootable-windows-8-iso-image-in-linux
    - https://adminthing.blogspot.com/2020/06/modify-windows-ISO.html

---
