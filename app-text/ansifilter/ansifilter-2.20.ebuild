# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop toolchain-funcs qmake-utils xdg-utils

DESCRIPTION="Handles text files containing ANSI terminal escape codes"
HOMEPAGE="http://www.andre-simon.de/"
SRC_URI="http://www.andre-simon.de/zip/${P}.tar.bz2
	gui? ( https://gitlab.com/uploads/-/system/project/avatar/6678914/ansifilter2_logo_256.png )"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~x64-macos"
IUSE="gui"

RDEPEND="
	gui? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"
DEPEND="${RDEPEND}"

DOCS=( ChangeLog.adoc README.adoc  )

src_prepare() {
	default

	# bug 431452
	rm src/qt-gui/moc_mydialog.cpp || die

	sed \
		-e "/GZIP/d" \
		-e "/COPYING/d" \
		-i makefile || die

	sed \
		-e "s/-O2//" \
		-i src/makefile || die
}

src_configure() {
	if use gui ; then
		pushd src/qt-gui > /dev/null || die
		eqmake5
		popd > /dev/null || die
	fi
}

src_compile() {
	emake -f makefile CXX="$(tc-getCXX)"

	if use gui ; then
		emake -C src/qt-gui
	fi
}

src_install() {
	emake -f makefile \
		DESTDIR="${D}" \
		doc_dir="/usr/share/doc/${PF}" \
		-j1 \
		install $(usev gui install-gui)

	einstalldocs
	if use gui; then
		newicon -s 256 "${DISTDIR}"/ansifilter2_logo_256.png "${PN}".png
	fi
}

pkg_preinst() {
	if use gui; then
		xdg_desktop_database_update
		xdg_icon_cache_update
	fi
}

pkg_postrm() {
	if use gui; then
		xdg_desktop_database_update
		xdg_icon_cache_update
	fi
}

pkg_postinst() {
	if use gui; then
		xdg_desktop_database_update
		xdg_icon_cache_update
	fi
}
