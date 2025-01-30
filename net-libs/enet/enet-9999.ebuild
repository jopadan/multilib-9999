# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal autotools libtool

DESCRIPTION="Relatively thin, simple and robust network communication layer on top of UDP"
HOMEPAGE="http://enet.bespin.org/ https://github.com/lsalzman/enet/"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/lsalzman/${PN}"
	inherit git-r3
else
SRC_URI="http://enet.bespin.org/download/${P}.tar.gz"
fi

LICENSE="MIT"
SLOT="1.3/8"
KEYWORDS="amd64 ~arm64 ~loong ppc ppc64 ~riscv x86"
IUSE="static-libs"

RDEPEND="!${CATEGORY}/${PN}:0"

src_prepare() {
	default
	eautoreconf -i -s
}

multilib_src_configure() {
	local myconf=(
		--enable-shared
		$(use_enable static-libs static)
	)

	ECONF_SOURCE=${S} econf "${myconf[@]}"
}

multilib_src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}

