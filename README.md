# uxp-overlay
Gentoo overlay for UXP based browsers such as Iceweasel-UXP

## Installing Overlay
To install this overlay, please run the following:
`layman -o https://raw.githubusercontent.com/djames1/uxp-overlay/master/repository.xml -L -a uxp`

## List of packages
- www-client/iceweasel-uxp
    - Fork of Basilisk browser with open source branding and with additional privacy flags at compilation
- www-client/iceape-uxp
    - Fork of SeaMonkey suite with open source branding and additional privacy flags at compilation
        - This has a different GUID than SeaMonkey so most addons will not work without, at minimum, adding the GUID to `install.rdf` in the downloaded addon .xpi file

## TODO
- Improve Iceweasel-UXP and Iceape-UXP ebuilds - both are missing some options, such as the ability to choose between GTK2 or GTK3
- Determine if we can extract the pre-compiled binaries from Hyperbola Linux packages in order to create bin packages
- Create an Icedove-UXP ebuild - this is low priority as I don't use Icedove-UXP

## WON'T DO
- Basilisk ebuild
    - This won't happen as Basilisk has a restrictive branding policy and we already have Iceweasel-UXP
- basilisk-bin ebuild
    - See above
- Create an unbranded Pale Moon (New Moon) ebuild with compile flags not present in the official Pale Moon ebuild
    - I have no interest in this as I don't use Pale Moon, but I would accept a pull request for this.
- Any Binary Outcast (Interlink Mail, Borealis Navigator) packages.
    - Tobin expressly told me that I was not allowed to package these, so I will not package them.

## Credits
Initial iceweasel-uxp package taken from https://github.com/g4jc/iceweasel-uxp-overlay
