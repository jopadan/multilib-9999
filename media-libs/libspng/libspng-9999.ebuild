# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib toolchain-funcs multilib

DESCRIPTION="Simple, modern libpng alternative"
HOMEPAGE="https://github.com/randy408/libspng"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/randy408/${PN}"
	inherit git-r3
else
SRC_URI="https://github.com/randy408/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	sys-libs/zlib[${MULTILIB_USEDEP}]
"
DEPEND="
	${RDEPEND}
	test? (
		>=media-libs/libpng-1.6.0
	)
"

multilib_src_configure() {
	local emesonargs=(
		$(meson_use test dev_build)
	)

	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	einstalldocs
}
