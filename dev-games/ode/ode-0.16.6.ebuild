# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal autotools libtool

DESCRIPTION="Open Dynamics Engine SDK"
HOMEPAGE="http://ode.org/"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://bitbucket.org/odedevs/${PN}"
	inherit git-r3
else
SRC_URI="https://bitbucket.org/odedevs/${PN}/downloads/${P}.tar.gz"
fi

LICENSE="|| ( LGPL-2.1+ BSD )"
SLOT="0/6"
KEYWORDS="amd64 ~arm64 x86 ~amd64-linux ~x86-linux"
IUSE="debug doc double-precision examples gyroscopic static-libs"

RDEPEND="
	examples? (
		virtual/glu
		virtual/opengl
	)
"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/doxygen )"

MY_EXAMPLES_DIR=/usr/share/doc/${PF}/examples

DOCS=( CHANGELOG.txt README.md )

PATCHES=(
)

src_prepare() {
	default

	sed -i \
		-e "s:\$.*/drawstuff/textures:${MY_EXAMPLES_DIR}:" \
		drawstuff/src/Makefile.am \
		ode/demo/Makefile.am || die
	[[ ${PV} == *9999 ]] &&  eautoreconf -f -i -s -W all
	multilib_copy_sources
}

multilib_src_configure() {
	default
	local myconf=(
		--enable-shared
		$(use_enable static-libs static)
		$(use_enable debug asserts)
		$(use_enable double-precision)
		$(use_enable examples demos)
		$(use_enable gyroscopic)
		$(use_with examples drawstuff X11)
	)

	ECONF_SOURCE=${S} econf "${myconf[@]}"
}

multilib_src_compile() {
	emake all
	if multilib_is_native_abi; then
		use doc && cd ode/doc && doxygen Doxyfile && cd .. && emake doc
	fi
}

multilib_src_install() {
	default

	find "${ED}" -name '*.la' -delete || die

	if multilib_is_native_abi; then
		use doc && cd ode/doc && docinto html && dodoc -r * && cd ../../ || die
		if use examples ; then
			docompress -x ${MY_EXAMPLES_DIR}

			insinto ${MY_EXAMPLES_DIR}
			exeinto ${MY_EXAMPLES_DIR}

			doexe drawstuff/dstest/dstest
			doins ode/demo/*.{c,cpp,h} \
			      drawstuff/textures/*.ppm \
			      drawstuff/dstest/dstest.cpp \
			      drawstuff/src/{drawstuff.cpp,internal.h,x11.cpp}

			cd ode/demo || die

			local f
			for f in *.c* ; do
				doexe .libs/${f%.*}
			done
		fi
	fi
}

