# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

inherit toolchain-funcs cmake autotools

DESCRIPTION="FTE QuakeWorld (Quake 1) client & server"
HOMEPAGE="http://www.fteqw.com/"
# mirror://sourceforge/${PN}/ftesrc${PV}-all.zip
SRC_URI=""

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/fte-team/${PN}"
	inherit git-r3
else
SRC_URI="https://github.com/fte-team/fteqw/archive/refs/heads/master.zip"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="debug dedicated opengl X"

dir=${GAMES_DATADIR}/quake1

RDEPEND="media-libs/alsa-lib
	media-libs/openjpeg
	media-libs/libogg
	media-libs/libpng
	media-libs/libvorbis
	media-libs/openxr-loader
	dev-games/ode
	net-libs/gnutls
	virtual/opengl
	media-libs/libsdl
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXxf86vm"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto
	x11-base/xcb-proto"

PATCHES=( "${FILESDIR}"/${PN}-ode.patch )

src_prepare()
{
	cmake_src_prepare
}

src_configure()
{
	local CMAKE_BUILD_TYPE=$(usex debug Debug Release)
	local mycmakeargs=(
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	# No icon
	make_desktop_entry ${PN} "FTE QuakeWorld"
}
