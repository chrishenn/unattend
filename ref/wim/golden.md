to create a golden image that can be "sysprep generalize" and then "dism capture"d,

- boot into "audit mode" (ctrl+shift+F3)
- apply all edits, installs, and changes to defualt user account
    - schneegans.de could automate this (?) by running my scripts against the DefaultUser (would require script mods probably)
- run sysprep
    - sysprep /generalize /oobe /shutdown
    - sysprep /generalize ... /unattend:answer_file.xml (build answer_file.xml into wim)
- boot to windows installer / WinPE
    - open terminal (shift+F10)
    - dispart -> list volume -> here "E" is an external disk, "C" is the installed golden system partition
    - dism /capture-image /compress:maximum /checkintegrity /verify /bootable /imagefile:E:\install.wim /capturedir:C:\ /name:"Golden Image"

ref

- https://theitbros.com/sysprep-windows-machine/
- https://www.youtube.com/watch?v=HTPjMs4K2uY
