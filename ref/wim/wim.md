# wim customization

do not disable these services (notifications); they are required for the nvidia app.

```powershell
'WpnService'
'WpnUserService'
```

firewall

```powershell
# AME expects windows firewall to be present, and uses the firewall to block certain services from phoning home
# Block Certain Services (amehost.exe) Outbound UDP/TCP Traffic
# Block Cortana Outbound UDP/TCP Traffic
# Block Cortana Outbound UDP/TCP Traffic
# Block StartMenuExperienceHost|Desc=Block Cortana Outbound UDP/TCP Traffic
# Block Windows Settings Outbound UDP/TCP Traffic
# Block Explorer Outbound UDP/TCP Traffic

# amehost.exe is being used as a proxy for svchost.exe, used by these services:
# CryptSvc
# lfsvc
```

---

## wimtools: linux

https://github.com/lostindark/DriverStoreExplorer
https://www.tenforums.com/tutorials/95008-dism-add-remove-drivers-offline-image.html

```bash
# i can just use the image at index 1 inside the wimfile, for this iso
wiminfo iso/sources/install.wim

> index 1
> Windows 11 IoT Enterprise LTSC 2024
```

set up the autounattend.xml

```bash
# MAKE SURE THE PLACEHOLDER KMS LICENSE KEY MATCHES THE EDITION
# no images found: the placeholder KMS license key in unattend file didn't match the edition of the image in there.
# https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys

# "set your time zone explicitly"
# may be necessary. I had "can't read locale" errors

# "let windows setup (setup.exe) handle the windows pe stage as usual"
# was needed. else I had errors
```

note: the unattend generator renders an unattend.xml into the Panther folder at boot time. So manually packing the
unattend into Panther ahead of time does not seem to work

```bash
sudo apt install -y wimtools

# modify install.wim
mkdir -p wim
wimmountrw iso/sources/install.wim wim

# add the unattend
mkdir -p wim/Windows/Panther
nano wim/Windows/Panther/unattend.xml
# copy-paste contents of file. touch and shell redirect don't work

# save wim changes
wimunmount wim --commit
```

---

## refs

- debloaters
    - https://github.com/Mr1Stark/win11debloat
- tiny11, tiny11 core
    - powershell script that totally uninstalls winsxs from win11 iso (non-active win image)
    - https://github.com/ntdevlabs/tiny11builder
- oscdimg
    - the windows-native tool to pack windows iso's.
    - There's a choco package so that you don't have to install the windows ADK
    - `choco install windows-adk-oscdimg`
- tutorial for using built in windows tools
    - https://www.tenforums.com/tutorials/133098-dism-create-bootable-iso-multiple-windows-10-images.html
- imgburn
    - was mentioned to pack iso's but I haven't done it
- NTLite
    - mentioned in the win11 AME docs
- WinReducer
    - https://www.winreducer.net/wros.html
- MSMG Toolkit
    - mainly just a wrapper for some of the powershell commands
    - https://msmgtoolkit.in/
- UI
    - https://github.com/Open-Shell/Open-Shell-Menu
    - https://github.com/valinet/ExplorerPatcher
    - note: DO NOT USE startallback (does not seem to work on newer builds)
        - https://github.com/Aetherinox/startallback-utility
    - https://github.com/eythaann/Seelen-UI/
