# sdio

The latest realtek lan driver is so bad that installing it PERMANENTLY REMOVES WINDOWS ABILITY TO FIND IT
Some driver that sdio installed has made the machine no longer reboot.
I think sdio is installing all the right stuff, but these drivers and the MS driver subsystem are so cooked that doing
a complete and correct installation COOKS THE ENTIRE MACHINE.

I CANNOT OVERSTATE HOW FRUSTRATING, SLOW, AND DIFFICULT THIS SITUATION IS

---

todo: disable these drivers that sdio installs when `select missing newer better`

```bash
Installing $0276
  Pack:     \\192.168.1.142\h\windows\drivers\sdio\drivers\DP_LAN_Realtek-NT_25094.7z
  Name:     Realtek Gaming 2.5GbE Family Controller
  Provider: Realtek
  Date:     08/07/2025
  Version:  10.77.50.807
  HWID:     PCI\VEN_10EC&DEV_8125&SUBSYS_E0001458&REV_05
  inf:      Realtek\matchver\FORCED\10x64\PCIe_10.077.0727.2025\rt640x64.inf,realtek.ntamd64.10.0
  Score:    00FF0000

Installing $0246
  Pack:     \\192.168.1.142\h\windows\drivers\sdio\drivers\DP_Chipset_25111.7z
  Name:     Intel(R) Precise Touch and Stylus (Intel(R) PTS) - Base Driver - Port #1
  Provider: (Standard system devices)
  Date:     09/02/2020
  Version:  3.0.100.222
  HWID:     PCI\VEN_8086&DEV_7A50
  inf:      Intel\FORCED\PreciseTouch\10x64\3.0.100.222\IntelTHCBase.inf,standard.ntamd64.10.0...18327
  Score:    00FF2001
ERROR: installation failed
```

---

install

```pwsh
scoop install snappy-driver-installer-origin
```

To launch the gui with settings applied:

```pwsh
sdio -cfg:'C:\users\chris\unattend\ref\sdio\sdio.cfg'
```

These formats in the cfg file both work:

```cfg
# network reference to the smbshare location
"-drp_dir:\\192.168.1.142\h\windows\drivers\sdio\drivers"

# where H:\ is the same smbshare as above, but I've mapped it to H: with new-smbmapping
"-drp_dir:H:\windows\drivers\sdio\drivers"
```

To launch a script headless:

```pwsh
sdio -script:'C:\users\chris\unattend\ref\sdio\sdio.txt'
```

Note that cli args to sdio are ignored, and args passed with -script are passed through to the scripting ctx

```pwsh
# NOTE that quotes will cause the drive config to be ignored!!
drpdir \\192.168.1.142\h\windows\drivers\sdio\drivers

# DO NOT DO THIS
drpdir '\\192.168.1.142\h\windows\drivers\sdio\drivers'
```

Note that the cli will torrent all driver packs (many gig) before copying them to the drivers folder.
Verify that the network share config has been read correctly by making sure a log file is created at the start of the
run.
