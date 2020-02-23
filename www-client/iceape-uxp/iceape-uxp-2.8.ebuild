# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
WANT_AUTOCONF="2.1"
MOZ_ESR=""

MOZCONFIG_OPTIONAL_GTK2ONLY=1
MOZCONFIG_OPTIONAL_WIFI=0

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-v6.52 pax-utils xdg-utils autotools

UXP_VER="2020.02.18"
IA_VER="1.6"
ID_VER="2.3"
SRC_URI="https://github.com/MoonchildProductions/UXP/archive/v$UXP_VER.tar.gz
    https://repo.hyperbola.info:50000/other/icedove-uxp/icedove-uxp-$ID_VER.tar.gz
	https://repo.hyperbola.info:50000/other/iceape-uxp/iceape-uxp-$IA_VER.tar.gz"
IA_URI="https://repo.hyperbola.info:50000/other/iceape-uxp/iceape-uxp-$IA_VER.tar.gz"
ID_URI="https://repo.hyperbola.info:50000/other/icedove-uxp/icedove-uxp-$ID_VER.tar.gz"
KEYWORDS="~amd64 ~x86"
S="${WORKDIR}/icedove-uxp-$ID_VER"

DESCRIPTION="Mail and browser suite forked from Seamonkey and built on the the Unified XUL Platform."
HOMEPAGE="https://wiki.hyperbola.info/doku.php?id=en:project:iceape-uxp"

KEYWORDS="~amd64"

SLOT="0"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+calendar hardened +privacy hwaccel jack pulseaudio selinux test system-icu +system-zlib +system-bz2 +system-hunspell system-sqlite +system-ffi +system-pixman +system-jpeg"
RESTRICT="mirror"

ASM_DEPEND=">=dev-lang/yasm-1.1"

RDEPEND="
	dev-util/pkgconfig
	jack? ( virtual/jack )
	system-icu? ( dev-libs/icu )
	system-zlib? ( sys-libs/zlib )
	system-bz2? ( app-arch/bzip2 )
	system-hunspell? ( app-text/hunspell )
	system-sqlite? ( dev-db/sqlite )
	system-ffi? ( dev-libs/libffi )
	system-pixman? ( x11-libs/pixman )
	system-jpeg? ( media-libs/libjpeg-turbo )
	system-libevent? ( dev-libs/libevent )
	system-libvpx? ( media-libs/libvpx )
	selinux? ( sec-policy/selinux-mozilla )"

DEPEND="${RDEPEND}
	amd64? ( ${ASM_DEPEND} virtual/opengl )
	x86? ( ${ASM_DEPEND} virtual/opengl )"

QA_PRESTRIPPED="usr/lib*/${PN}/iceape-uxp"

BUILD_OBJ_DIR="${S}/mozilla/iceape"

src_unpack() {
	unpack icedove-uxp-$ID_VER.tar.gz
	cd "${S}" && tar -xzf $DISTDIR/iceape-uxp-$IA_VER.tar.gz || die "Failed to unpack application source"
	mv "iceape-uxp-$IA_VER" "suite" || die "Failed to remove version from application name (broken branding)"
	cd ${S} && tar -xzf $DISTDIR/v$UXP_VER.tar.gz
	mv UXP-$UXP_VER mozilla
	cd "${S}"
}

pkg_setup() {
	moz_pkgsetup

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XDG_SESSION_COOKIE \
		XAUTHORITY

}

pkg_pretend() {
	# Ensure we have enough disk space to compile
		CHECKREQS_DISK_BUILD="4G"
	check-reqs_pkg_setup
}

src_prepare() {
	# Drop -Wl,--as-needed related manipulation for ia64 as it causes ld sefgaults, bug #582432
	if use ia64 ; then
		sed -i \
		-e '/^OS_LIBS += no_as_needed/d' \
		-e '/^OS_LIBS += as_needed/d' \
		"${S}"/mozilla/widget/gtk/mozgtk/gtk2/moz.build \
		"${S}"/mozilla/widget/gtk/mozgtk/gtk3/moz.build \
		|| die "sed failed to drop --as-needed for ia64"
	fi

	#Fix Seamonkey leftovers missing from iceape build
	eapply $FILESDIR/0001-fix-package-manifest.patch
	eapply $FILESDIR/0001-icedove-uxp-toolkit-overrides.patch
	eapply $FILESDIR/0002-Disable-SSLKEYLOGFILE-in-NSS.patch
	eapply $FILESDIR/0002-fix-lightning.patch
	eapply $FILESDIR/0003-Hardcode-AppName-in-nsAppRunner.patch
	eapply $FILESDIR/0004-Fix-PGO-Build.patch
	eapply $FILESDIR/0007-gcc9_2_0-workaround.patch

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user
}

src_configure() {
	MEXTENSIONS="default"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# Add full relro support for hardened
	use hardened && append-ldflags "-Wl,-z,relro,-z,now"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig
	echo "mk_add_options XARGS=/usr/bin/xargs" >> "${S}"/.mozconfig

	echo "mk_add_options MOZ_MAKE_FLAGS='${MAKEOPTS}'" >> "${S}"/.mozconfig
	echo "ac_add_options --prefix='${EPREFIX}/usr'" >> "${S}"/.mozconfig
	echo "ac_add_options --libdir='${EPREFIX}/usr/$(get_libdir)'" >> "${S}"/.mozconfig

	if use jack ; then
		echo "ac_add_options --enable-jack" >> "${S}"/.mozconfig
	fi

	if use pulseaudio ; then
		echo "ac_add_options --enable-pulseaudio" >> "${S}"/.mozconfig
	else
		echo "ac_add_options --disable-pulseaudio" >> "${S}"/.mozconfig
	fi

	if use system-sqlite ; then
        echo "WARNING: Building with System SQLite is strongly discouraged and will likely break. See UXP bug #265"
        echo "ac_add_options --enable-system-sqlite" >> "${S}"/.mozconfig
    fi

	if use system-icu ; then
        echo "ac_add_options --with-system-icu" >> "${S}"/.mozconfig
    fi

	if use system-zlib ; then
        echo "ac_add_options --with-system-zlib" >> "${S}"/.mozconfig
        fi

	if use system-bz2 ; then
        echo "ac_add_options --with-system-bz2" >> "${S}"/.mozconfig
        fi

	if use system-hunspell ; then
        echo "ac_add_options --enable-system-hunspell" >> "${S}"/.mozconfig
    fi

	if use system-ffi ; then
		echo "ac_add_options --enable-system-ffi" >> "${S}"/.mozconfig
	fi

	if use system-pixman ; then
		echo "ac_add_options --enable-system-pixman" >> "${S}"/.mozconfig
	fi

	if use system-jpeg ; then
        echo "ac_add_options --with-system-jpeg" >> "${S}"/.mozconfig
    fi

	if use system-libvpx ; then
	echo "ac_add_options --with-system-libvpx" >> "${S}"/.mozconfig
	fi

	if use system-libevent ; then
	echo "ac_add_options --with-system-libevent" >> "${S}"/.mozconfig
	fi

	# Favor Privacy over features at compile time
	echo "ac_add_options --disable-userinfo" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-safe-browsing" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-url-classifier" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-eme" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-updater" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-crashreporter" >> "${S}"/.mozconfig
	if use privacy ; then
	echo "ac_add_options --disable-webrtc" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-webspeech" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-webspeechtestbackend" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-mozril-geoloc" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-nfc" >> "${S}"/.mozconfig
	fi
	echo "ac_add_options --disable-synth-pico" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-b2g-camera" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-b2g-ril" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-b2g-bt" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-gamepad" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-tests" >> "${S}"/.mozconfig
	echo "ac_add_options --disable-maintenance-service" >> "${S}"/.mozconfig

	#Build the iceape-uxp application with iceape branding
	echo "ac_add_options --disable-official-branding" >> "${S}"/.mozconfig
	echo "ac_add_options --enable-application=suite" >> "${S}"/.mozconfig
	echo "ac_add_options --with-branding=suite/branding/iceape" >> "${S}"/.mozconfig
	echo "export MOZILLA_OFFICIAL=1"
	echo "export MOZ_TELEMETRY_REPORTING="
	echo "export MOZ_ADDON_SIGNING="
	echo "export MOZ_REQUIRE_SIGNING="

	#Build lightning support
	if use calendar ; then
	echo "ac_add_options --enable-calendar" >> "${S}"/.mozconfig
	fi

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	# workaround for funky/broken upstream configure...
	SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
	#emake -f mozilla/client.mk configure
	mozilla/mach configure
}

src_compile() {
		MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
		mozilla/mach build

}

src_install() {
	cd "${BUILD_OBJ_DIR}" || die

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${BUILD_OBJ_DIR}"/dist/bin/xpcshell

	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
	#emake DESTDIR="${D}" INSTALL_SDK= install
	DESTDIR="${D}" ${S}/mozilla/mach install

	# Install language packs
	# mozlinguas_src_install

	local size sizes icon_path icon name
		sizes="16 32 48 128"
		icon_path="${S}/suite/branding/iceape/app-icons"
		icon="iceape"
		name="IceApe-UXP"

	# Install icons and .desktop for menu entry
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/iceape${size}.png" "${icon}.png"
	done
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${icon_path}/iceape48.png" "${icon}.png"
	newmenu "${FILESDIR}/icon/${PN}.desktop" "${PN}.desktop"
	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
		"${ED}/usr/share/applications/${PN}.desktop" || die

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true"\
			 >> "${ED}/usr/share/applications/${PN}.desktop" \
			|| die
	fi

	# Required in order to use plugins and even run firefox on hardened.
	pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{iceape,iceape-bin,plugin-container}

	# Apply privacy user.js
	if use privacy ; then
	insinto "/usr/lib/${PN}/browser/defaults/preferences"
	newins "${FILESDIR}/privacy.js-1" "iceape-branding.js"
	fi

}

pkg_preinst() {
	gnome2_icon_savelist

	# if the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# doesn't need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9" ; then
		einfo "APULSE found - Generating library symlinks for sound support"
		local lib
		pushd "${ED}"${MOZILLA_FIVE_HOME} &>/dev/null || die
		for lib in ../apulse/libpulse{.so{,.0},-simple.so{,.0}} ; do
			# a quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if ! [ -L ${lib##*/} ]; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	# Update mimedb for the new .desktop file
	xdg_desktop_database_update
	gnome2_icon_cache_update

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9" ; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
