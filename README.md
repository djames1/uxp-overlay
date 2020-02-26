# uxp-overlay
Gentoo overlay for UXP based browsers such as iceweasel-uxp and Basilisk

## Installing Overlay
To install this overlay, please run the following:
`layman -o https://raw.githubusercontent.com/djames1/uxp-overlay/master/repository.xml -L -a uxp`

## List of packages
www-client/iceweasel-uxp - Fork of Basilisk with freedom respecting branding and additional privacy flags at compilation
www-client/iceape-uxp - Fork of Seamonkey with freedom respecting branding and additional privacy flags at compilation

## TODO
Improve iceweasel-uxp ebuild - very poorly written at the moment

Make a Basilisk ebuild based on the iceweasel-uxp ebuild

Potentially create a binary package that pulls basilisk upstream binaries

Determine if we can extract the pre-compiled binaries from Hyperbola Linux packages

Create an icedove-uxp ebuild

(Maybe) Create a New Moon ebuild with the option to compile with WebRTC 

## Credits
iceweasel-uxp overlay taken from https://github.com/g4jc/iceweasel-uxp-overlay
