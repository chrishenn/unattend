# dpst

- https://github.com/orev
- https://github.com/orev/dpst-control

# DPST-Control

Easily disable/enable Intel Display Power Saving Technology (DPST)

---

using intel gfx control panel, I turned the slider on and off for dpst. The slider was off but the feature was still
clearly dimming.
turn slider on -> reboot turn slider off -> reboot. Fixed!

problem: the dpst script is showing dpst enabled even though the screen is not dimming. So either the key has been
reset by uninstalling command center, and it hasn't taken effect yet, or that key wasn't
governing the disabling of the feature in the first place.

now, i've uninstalled intel graphics command center and expect the dpst to come back.
manually copied in the "driver key" from device manager for intel display adapter {4d36e968-e325-11ce-bfc1-08002be10318}
someone on reddit saw success deleting DisplayFeatureControl
there's also PowerDpstAggressivenessLevel set to 0
it looks like multiple displays would be found under /0000, /0001, /0002, etc. We could set each key for each to be
thurough, although I'll bet laptops have either /0000 or /0001 as the default screen

---

I think the best luck I've had was with installing intel gfx command center, turning adaptive brightness off, and
then running this dpst_disable.bat. I would uninstall intel gfx command center, and the dpst would re-enable itself.
