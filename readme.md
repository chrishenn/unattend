# unattend

Install Windows 11 and apply customizations automatically

These three repos are meant to be used together:

- https://github.com/chrishenn/unattend
- https://github.com/chrishenn/chplib
- https://github.com/chrishenn/scoops

## features

The goal is to have the windows installer do a fresh install of windows, and automatically kick off a full set of
customizations, such that there is no manual installation or configuration required to go from blank disk to a working
installation of windows 11.

This noninteractive flow is a WIP; right now, a single manual step is required.

I've been testing with windows 11 client (LTSC 2024 25H2) and these scripts may not work well on other images.

- Automate the windows 11 OOBE with an autounattend.xml file
    - https://schneegans.de/windows/unattend-generator/
- Automate windows tweaks, software installaion, software config
    - apply settings, tweaks, debloat, and install software
        - using https://github.com/chrishenn/chplib
        - using https://github.com/chrishenn/scoops
    - apply dotfiles
- Automate the application of modified "privacy+" ameliorations via "windows ameliorated"
    - https://amelabs.net/
    - https://github.com/Ameliorated-LLC/trusted-uninstaller-cli
    - https://github.com/Ameliorated-LLC/privacy_plus

## usage

```powershell
# (bash) unpack your windows installer iso into ./iso
./iso.sh unpack <file.iso>

# customize your {unattend, scripts, playbook} to your liking

# (bash) package a bootable iso image, including scripts and configs from the local repo
./iso.sh pkg

# disable secure boot on the target system
# remove drives that you do not want wiped, leaving just the target drive for the windows install
# boot from iso

# manual step:
# log into the windows gui after the machine reboots itself
# connect over ssh (or locally) and run:

$env:OP_SERVICE_ACCOUNT_TOKEN = '<token>'
& "$HOME\unattend\setup2.ps1" 'username' 'password'
```

## dev

debug env

```powershell
. "$HOME\unattend\setup_init.ps1"
```

NOTE: if you replace line separators 'CRLF' with 'LF' in autounattend.xml, it will not run

## todo

- [ ] drivers
    - [x] detect cpu, install matching chipset drivers
    - [x] detect igpu, install matching driver
    - [ ] mount sdio driver pack over network
    - [ ] motherboard-specific driver packages from vendor site
        - [ ] handle hardware quirks (eg latest realtek 5gbe lan driver is terribly buggy)
- [ ] software
    - [ ] obsidian vault sync
- [ ] tweak
    - [ ] set: default browser
    - [ ] set: default image viewer
    - [ ] set: file explorer sorting, columns
    - [x] disable: audio ducking
    - [ ] disable: audio enhancements
    - [ ] disable: audio exclusive mode
    - [ ] disable: file contents indexing
    - [ ] disable: "allow windows to turn this device off to save power" for all devices
- [x] AME
    - [x] script: windows updates
    - [x] script: windows activate
    - [x] script: security deps
    - [x] script: system deps
    - [x] script: launch AME cli
- [x] driver bloat
    - [x] remove: waves maxxaudio
    - [x] remove: killer wifi suite
    - [x] remove: edge update service
    - [x] remove: logitech lamparray service
    - [x] remove: alienware control center
- [x] windows bloat
    - [x] remove: mobsync / microsoft sync center / offline files
    - [x] remove: windows settings sync
    - [x] remove: random cruft folders from $HOME
- [x] power
    - [x] unhide: all power settings
    - [x] set: "ultimate" power profile
    - [x] set: custom power and sleep button controls
    - [x] disable: screen off
    - [x] disable: usb power save
    - [x] disable: dpst
- [x] custom tweaks
    - [x] quick access: unpin default folders from explorer
    - [x] quick access: pin my custom "home" folders
    - [x] set: key hold time, repeat interval
    - [x] set: desktop graphics settings
- [x] settings tweaks
    - [x] disable: autoplay
    - [x] disable: "when I snap a thing show what I can snap next to it"
    - [x] disable: "show window handle at top screen when dragging"
    - [x] disable: auto lock
    - [x] disable: require login after wake
    - [x] disable: mouse accel
    - [x] notification tray: hide bluetooth
    - [x] notification tray: hide securityhelath
    - [x] notification tray: always show all icons

stretching:

- [ ] programmatically launch tasks after reboot
    - [ ] enable autologin for next boot
    - [ ] store secrets in env
    - [ ] schedule subsequent script setup2.ps1 to launch with secrets after reboot
- [ ] automate golden image creation
    - [ ] boot a new base image and apply our mods as default user, then bake into golden image
- [ ] network boot support
    - [ ] package the iso such that windows will use unattend.xml when pxe booting
    - [ ] package drivers into install environment + booted windows

out of scope, but would be nice:

- [ ] modify epatcher src
    - [ ] add: scripted application of settings
    - [ ] add: silent uninstall
- [ ] modify powertoys src
    - [ ] add: scripted application of settings

ideal flow:

- unattend
    - setup.ps1
    - enable auto login for next boot (how?)
    - inject op/gh secrets into environment durably across reboot (disk, probably)
    - schedule setup2 to run on next login
    - reboot
- run setup2.ps1 from scheduled task on login
    - cleanup
        - file cruft
        - driver bloat
        - stored secrets
    - chezmoi
    - run ame
    - reboot
