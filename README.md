# uxp-overlay
Gentoo overlay for UXP based browsers such as Iceweasel-UXP

## Installing Overlay
To install this overlay, please run the following:
`layman -o https://raw.githubusercontent.com/djames1/uxp-overlay/master/repository.xml -L -a uxp`

## List of packages
- www-client/iceweasel-uxp
    - Fork of Basilisk browser with open source branding and with additional
      privacy flags at compilation
- www-client/iceape-uxp
    - Fork of SeaMonkey suite with open source branding and additional privacy
      flags at compilation
        - This has a different GUID than SeaMonkey so most addons will not work
          without, at minimum, adding the GUID to `install.rdf` in the
          downloaded addon .xpi file
- www-client/bluegorilla
    - My fork of Iceape-UXP
- mail-client/icedove-uxp
    - Fork of Thunderbird 52 with open source branding and additional privacy
      flags at compilation
- www-client/serpent
    - Unbranded Basilisk ebuild (Serpent browser)

## WON'T DO
- Branded Basilisk ebuild
    - Reason: Retarded branding policies.
- Pale Moon ebuild
    - Reason: Pale Moon ebuilds that are allowed to use the official branding
      already exist [here](https://github.com/deu/palemoon-overlay).
- Branded Binary Outcast (Interlink Mail, Borealis Navigator) ebuilds.
    - Reason: Retarded EULA

## Credits
Initial iceweasel-uxp package taken from https://github.com/g4jc/iceweasel-uxp-overlay
