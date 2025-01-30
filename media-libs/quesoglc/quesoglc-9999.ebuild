# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit flag-o-matic python-any-r1 multilib-minimal

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="git://git.code.sf.net/p/quesoglc/code"
	inherit autotools git-r3
else
	KEYWORDS="amd64 ppc sparc x86"
	SRC_URI="https://downloads.sourceforge.net/${PN}/${P}-free.tar.bz2"
fi

DESCRIPTION="Free implementation of the OpenGL Character Renderer (GLC)"
HOMEPAGE="https://quesoglc.sourceforge.net/"

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="static-libs doc"
RESTRICT="network-sandbox"

RDEPEND="
	dev-db/sqlite[${MULTILIB_USEDEP}]
	media-libs/fontconfig[${MULTILIB_USEDEP}]
	media-libs/freetype:2[${MULTILIB_USEDEP}]
	media-libs/freeglut[${MULTILIB_USEDEP}]
	dev-libs/fribidi[${MULTILIB_USEDEP}]
	media-libs/glew[${MULTILIB_USEDEP}]
	"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-text/doxygen
		dev-texlive/texlive-latexextra
		virtual/latex-base
	)"

PATCHES=(
	"${FILESDIR}"/${P}-python3.patch
)

src_prepare() {
	default

	[[ ${PV} == *9999 ]] &&  eautoreconf -f -i -s -W all
	multilib_copy_sources
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-executables
		$(use_enable static-libs static)
		--with-fribidi
		--with-glew
		--with-sqlite3
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake all
	if multilib_is_native_abi; then
		use doc && cd docs && doxygen -u && cd .. && emake doc
	fi
}

multilib_src_install() {
	default

	if multilib_is_native_abi; then
		use doc && dodoc -r docs/html
	fi

}

multilib_src_install_all() {
	einstalldocs

	find "${ED}" -name '*.la' -delete || die
}
