# unattend

Install Windows 11 and apply customizations automatically

These repos are meant to be used together:

- https://github.com/chrishenn/unattend
- https://github.com/chrishenn/chplib
- https://github.com/chrishenn/scoops
- https://github.com/chrishenn/drivers

## features

The goal is to have the following be carried out with no interaction when installing windows 11:

- an autounattend.xml installs the base windows os
- on first login, autounattend.xml launches customization scripts
- after one or two reboots and subsequent scripts, I have a usable installation of windows 11

## usage

This noninteractive flow is a WIP; right now, manual steps are required.

- Automate the windows 11 OOBE with an autounattend.xml file
    - https://schneegans.de/windows/unattend-generator/
- Apply settings, tweaks, debloat, dotfiles, and install software, drivers
    - ./unattend.ps1
    - using https://github.com/chrishenn/chplib
    - using https://github.com/chrishenn/scoops
    - using https://github.com/chrishenn/drivers
- Apply modified "privacy+" ameliorations via "windows ameliorated"
    - ./playbook
    - https://amelabs.net/
    - https://github.com/Ameliorated-LLC/trusted-uninstaller-cli
    - https://github.com/Ameliorated-LLC/privacy_plus

I've been testing with windows 11 client (LTSC 2024 25H2) and these scripts may not work well on other images.

```powershell
# (bash) unpack your windows installer iso into ./iso
./iso.sh unpack <file.iso>

# customize your {unattend, scripts, playbook} to your liking

# (bash) package a bootable iso image, including scripts and configs from the local repo
./iso.sh pkg

# disable secure boot on the target system
# remove drives that you do not want wiped
# boot from iso
# the unattend.xml should launch this on first login:
# & "C:\users\chris\unattend\setup.ps1"

# manual step:
# log into the windows gui after the machine reboots itself
# connect over ssh (or locally) and run:

$env:OP_SERVICE_ACCOUNT_TOKEN = '<token>'
. C:\users\chris\unattend\unattend.ps1; unattend 2

# manual step: drivers
# see ref/sdio for issues. interactive shell only
scoop install snappy-driver-installer-origin
sdio -script:$glob.sdio

# interactive shell only
scoop install chris/Z790_gigabyte_udac
scoop install chris/X870E_gigabyte_master
scoop install chris/XPS9320
```

## dev

NOTE: if you replace line separators 'CRLF' with 'LF' in autounattend.xml, it will not run !!

debug env

```powershell
$repo = 'C:\users\chris\unattend'
$lib = "$repo\lib"
. C:\users\chris\unattend\unattend.ps1
. ${function:glob_src} $lib
$opt = glob_opt $repo $lib
```

## todo

- [ ] drivers
    - [x] detect cpu, install matching chipset drivers
    - [x] detect igpu, install matching driver
    - [ ] install: drivers
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
    - `unattend.ps1 1`
        - install drivers
    - enable auto login for next boot (how?)
    - inject op/gh secrets into environment durably across reboot (disk, probably)
    - schedule setup2 to run on next login
    - reboot
- run `unattend.ps1 2` from scheduled task on login
    - cleanup
        - file cruft
        - driver bloat
        - stored secrets
    - chezmoi
    - run ame
    - reboot
