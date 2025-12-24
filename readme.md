# unattend

Install Windows 11 and apply customizations automatically

---

## features

The goal is to have the windows installer do a fresh install of windows, and automatically kick off a full set of
customizations, such that there is no manual installation or configuration required to go from blank disk to a working
installation of windows 11.

The "fully automatic" flow is a WIP - but with a single manual step, the scripts and configs included here
can be used to provide a fresh windows 11 (client) installation with customizations, amelioration, and opinionated
defaults.

The resulting image will not have access to windows update, and is highly customized. It should never be used in places
where stability is needed.

I've been testing with windows 11 client (LTSC 2024 25H2) and these scripts may not work well on other images.

- Automate the windows 11 OOBE with an autounattend.xml file
    - https://schneegans.de/windows/unattend-generator/
    - debloat
- Automate application of configurations and tweaks via script launched by the unattend file
    - apply custom settings
    - apply tweaks + debloat
    - apply chezmoi dotfiles
- Automate the application of modified "privacy+" ameliorations via "windows ameliorated"
    - https://amelabs.net/
    - https://github.com/Ameliorated-LLC/trusted-uninstaller-cli
    - https://github.com/Ameliorated-LLC/privacy_plus
- Automate the installation, and customization, of some software via custom scoop manifests
    - https://github.com/chrishenn/scoops

---

## usage

```powershell
# (bash) unpack your windows installer iso into ./iso
./iso.sh unpack <file.iso>

# customize your {unattend, playbook, scripts} to your liking

# (bash) package a bootable iso image, including scripts and configs from the local repo
./iso.sh pkg

# disable secure boot on the target system
# boot from iso
# NOTE: this will wipe drive 0. I suggest removing all disks other than the one you intend to install windows onto
# NOTE: windows installs the bootloader onto a random non-target-os drive. Recommended to remove other disks anyway

# NOTE: REQUIRED TO LOG INTO THE GUI DESKTOP? AME FAILS TO RUN AS ADMIN WHEN CONNECT OVER SSH W/O LOGGING INTO GUI FIRST
# NOTE: I've been running these over ssh after logging into the gui session. YMMV
# NOTE: putting these mise/chezmoi steps into setup2.ps1 script causes mise to spazz out, so do them here
$env:Path += ";$env:USERPROFILE\AppData\Local\mise\shims"
mise use -g chezmoi op
$env:OP_SERVICE_ACCOUNT_TOKEN = '<token>'
& "$HOME\unattend\setup2.ps1" 'user' 'pass'
```

---

## dev

debug env

```powershell
$repo = "$HOME\unattend"
(get-childitem "$repo/lib/*.ps1").foreach({. $_.FullName})
```

---

## todo

- [ ] programmatically launch tasks after reboot
    - [ ] enable autologin for next boot
    - [ ] store secrets in env
    - [ ] schedule subsequent script setup2.ps1 to launch with secrets after reboot
- [ ] automate golden image creation
    - [ ] boot a new base image and apply our mods as default user, then bake into golden image
- [ ] network boot support
    - [ ] package the iso such that windows will use unattend.xml when pxe booting
    - [ ] package drivers into install environment + booted windows
        - [ ] dell xps laptop wifi
        - [ ] gigabyte, msi, asus mobo builtin ethernet
        - [ ] intel wifi
- [ ] drivers    
    - [x] detect cpu, install matching chipset drivers
    - [x] detect igpu, install matching driver
    - [ ] motherboard-specific driver packages from vendor site
        - handle hardware quirks (eg latest realtek 5gbe lan driver is terribly buggy)
    - [ ] mount sdio driver pack over network
        - ideally, this could replace other driver installers
- [ ] software
    - [ ] obsidian
        - [ ] vault sync
    - [ ] scoop pwsh module to take a scoops subtree from my cfg.yml and install packages from it
        - pkg install behavior switchable to: {best-effort, all-or-nothing}
    - [ ] scoop pwsh module to run svc, software de-bloat (in case they re-appear)
        - edgeupdate, svc bloat like to re-install sometimes
        - dpst likes to re-enable itself at random
- [ ] default apps
    - [ ] browser: zen
    - [ ] media player: mpv
    - [ ] image viewer: imageglass
- [ ] audio
    - [x] disable: audio ducking
    - [ ] disable: audio enhancements
    - [ ] disable: exclusive mode
- [ ] tweak
    - [ ] set: file explorer sorting, columns
    - [ ] disable: file contents indexing
        - is this covered by disabling wsearch?
    - [ ] default to "no" for all devices: "allow windows to turn this device off to save power"
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
    - [x] notification tray: hide nvidia
    - [x] notification tray: hide securityhelath
    - [x] notification tray: always show all icons

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
    - chezmoi
    - cleanup
        - file cruft
        - driver bloat
        - stored secrets
    - run ame
    - reboot
