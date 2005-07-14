#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

ORIGDIR=`pwd`
cd $srcdir

PROJECT=pkg-config
TEST_TYPE=-f
FILE=pkg.m4

DIE=0

(autoconf --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "You must have autoconf installed to compile $PROJECT."
	echo "Download the appropriate package for your distribution,"
	echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
	DIE=1
}

AUTOMAKE=automake-1.4
ACLOCAL=aclocal-1.4

($AUTOMAKE --version) < /dev/null > /dev/null 2>&1 || {
        AUTOMAKE=automake
        ACLOCAL=aclocal
}

($AUTOMAKE --version) < /dev/null > /dev/null 2>&1 || {
	echo
	echo "You must have automake installed to compile $PROJECT."
	echo "Get ftp://ftp.cygnus.com/pub/home/tromey/automake-1.2d.tar.gz"
	echo "(or a newer version if it is available)"
	DIE=1
}

if test "$DIE" -eq 1; then
	exit 1
fi

test $TEST_TYPE $FILE || {
	echo "You must run this script in the top-level $PROJECT directory"
	exit 1
}

gunzip --stdout glib-1.2.8.tar.gz | tar xf - || { 
    echo "glib tarball not unpacked"
    exit 1
}

chmod +w `find glib-1.2.8 -name Makefile.am`
perl -p -i.bak -e "s/lib_LTLIBRARIES/noinst_LTLIBRARIES/g" `find glib-1.2.8 -name Makefile.am`
perl -p -i.bak -e "s/bin_SCRIPTS/noinst_SCRIPTS/g" `find glib-1.2.8 -name Makefile.am`
perl -p -i.bak -e "s/include_HEADERS/noinst_HEADERS/g" `find glib-1.2.8 -name Makefile.am`
perl -p -i.bak -e "s/[a-zA-Z0-9]+_DATA/noinst_DATA/g" `find glib-1.2.8 -name Makefile.am`
perl -p -i.bak -e "s/info_TEXINFOS/noinst_TEXINFOS/g" `find glib-1.2.8 -name Makefile.am`
perl -p -i.bak -e "s/man_MANS/noinst_MANS/g" `find glib-1.2.8 -name Makefile.am`

## patch gslist.c to have stable sort
perl -p -w -i.bak -e 's/if \(compare_func\(l1->data,l2->data\) < 0\)/if \(compare_func\(l1->data,l2->data\) <= 0\)/g' glib-1.2.8/gslist.c

(cd glib-1.2.8 && libtoolize --copy --force && $ACLOCAL $ACLOCAL_FLAGS && $AUTOMAKE && autoconf)

if test -z "$*"; then
	echo "I am going to run ./configure with no arguments - if you wish "
        echo "to pass any to it, please specify them on the $0 command line."
fi

libtoolize --copy --force

echo $ACLOCAL $ACLOCAL_FLAGS
$ACLOCAL $ACLOCAL_FLAGS

# optionally feature autoheader
(autoheader --version)  < /dev/null > /dev/null 2>&1 && autoheader

$AUTOMAKE -a $am_opt
autoconf

cd $ORIGDIR

$srcdir/configure --enable-maintainer-mode --disable-shared --disable-threads "$@"

echo 
echo "Now type 'make' to compile $PROJECT."
