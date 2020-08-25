# uxp-overlay
Gentoo overlay for UXP based browsers such as Iceweasel-UXP

## Installing Overlay
To install this overlay, please run the following:
`layman -o https://raw.githubusercontent.com/djames1/uxp-overlay/master/repository.xml -L -a uxp`

## List of packages
- www-client/bluegorilla
    - My fork of Iceape-UXP, which is a SeaMonkey like suite maintained by Hyperbola Linux
- www-client/serpent
    - Unbranded Basilisk ebuild (Serpent browser)

## WON'T DO
- Branded Basilisk ebuild
    - Reason: Branding policies.
- Pale Moon ebuild
    - Reason: Pale Moon ebuilds that are allowed to use the official branding
      already exist [here](https://github.com/deu/palemoon-overlay).
- Branded Binary Outcast (Interlink Mail, Borealis Navigator) ebuilds.
    - Reason: Due to EULA I need permission for this.
