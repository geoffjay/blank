dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.64])
AC_INIT([blank], [0.1])

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_SRCDIR([src/blank-main.vala])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AC_PROG_CC
AM_PROG_CC_STDC
AM_PROG_VALAC([0.20.0])
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_HEADER_STDC

AC_SUBST(abs_top_builddir)
AC_SUBST(VERSION)

# Initialize automake
AM_INIT_AUTOMAKE([1.11.1 foreign no-dist-gzip dist-xz -Wno-portability])
AM_MAINTAINER_MODE([enable])

dnl Initialize libtool
dnl Disable the generation of static libraries
LT_PREREQ([2.2.6])
LT_INIT([dlopen disable-static])

dnl Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

dnl Support GSettings
GLIB_GSETTINGS

AC_DEFINE(VERSION, "0.1", "blank")

dnl Declare Variables
AC_SUBST(PACKAGE_CFLAGS)
AC_SUBST(PACKAGE_LIBS)
PACKAGE_CFLAGS=""
PACKAGE_LIBS=""

AC_SET_DEFAULT_PATHS_SYSTEM

PREFIX=$prefix
AC_SUBST(PREFIX)

SYSCONFDIR="$ac_default_prefix/etc"
AC_SUBST(SYSCONFDIR)

dnl Add setup for installation directories
AC_DEFINE_UNQUOTED(DATADIR, "$SYSCONFDIR/$PACKAGE",
                   [Define the architecture-independent data directory.])

AC_DEFINE_UNQUOTED(UI_DIR, "$ac_default_prefix/share/$PACKAGE/ui",
                   [Define the read-only user interface files directory.])

dnl Library checks
VALAFLAGS="--target-glib=2.32 $VALAFLAGS"
VALAPACKAGES=""

PKG_CHECK_MODULES([GLIB], [glib-2.0 gthread-2.0 gmodule-2.0 gobject-2.0],,
	[AC_MSG_ERROR([glib2 is required])])

PKG_CHECK_MODULES([GTK], [gtk+-3.0],
	[VALAPACKAGES="$VALAPACKAGES --pkg gtk+-3.0"],
	[AC_MSG_ERROR([gtk3 is required])])

PKG_CHECK_MODULES([CLUTTER], [clutter-1.0 clutter-gtk-1.0],
	[VALAPACKAGES="$VALAPACKAGES --pkg clutter-1.0 --pkg clutter-gtk-1.0"],
	[AC_MSG_ERROR([clutter and clutter-gtk are required])])

PKG_CHECK_MODULES([GEE], [gee-1.0],
	[VALAPACKAGES="$VALAPACKAGES --pkg gee-1.0"],
	[AC_MSG_ERROR([gee is required])])

dnl Package setup for Vala files
AC_SUBST(VALAPACKAGES)

dnl Header checks
AC_CHECK_HEADERS(stdlib.h)
AC_CHECK_LIB(m, floor, PACKAGE_LIBS="$PACKAGE_LIBS -lm",)

dnl Build Options
AC_ARG_ENABLE(debug,
    AS_HELP_STRING([--enable-debug],[Enable debugging (default: disabled)]),,
        [enable_debug=no])
AS_IF([test "x$enable_debug" != "xno"],
      [AC_DEFINE(DEBUG, [1], ["Enable debugging support"])]
      [CFLAGS="$CFLAGS -O0 -g"]
      [BLANK_DEBUG_VALAFLAGS="-g -DDEBUG"]
      [AS_IF([test "x$GCC" = xyes],
             [CC_CHECK_FLAG([-g])])])

AC_SUBST(BLANK_DEBUG_VALAFLAGS)

dnl Build flags
AS_IF([test "x$GCC" != "xno"],
      [CC_CHECK_FLAG([-Wall])]
      [CC_CHECK_FLAG([-Wextra])]
      [CC_CHECK_FLAG([-Wno-deprecated-declarations])]
      [CC_CHECK_FLAG([-Wmissing-prototypes])]
      [CC_CHECK_FLAG([-Wshadow])]
      [CC_CHECK_FLAG([-Wpointer-arith])]
      [CC_CHECK_FLAG([-Wstrict-prototypes])]
      [CC_CHECK_FLAG([-Wcast-qual])]
      [CC_CHECK_FLAG([-Wwrite-strings])]
      [CC_CHECK_FLAG([-pedantic])])

dnl GOptions requires gettext for i18n
ALL_LINGUAS=""
GETTEXT_PACKAGE=blank
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", [Gettext package.])
AM_GLIB_GNU_GETTEXT
dnl IT_PROG_INTLTOOL([0.40.0])

AC_SUBST([BLANK_PLUGIN_LINKER_FLAGS],["-module -avoid-version -Wl,-z,defs"])

dnl Configuration
AC_SUBST([pkgconfigdir])

AC_CONFIG_FILES([
	Makefile
	data/blank.desktop
	data/Makefile
	data/ui/Makefile
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT

dnl Generate build report
AC_MSG_NOTICE([

    $PACKAGE $VERSION
    ==============

    Prefix:                         ${ac_default_prefix}
    System configuration:           ${sysconfdir}
    Data directory:                 ${datadir}
    UI directory:                   ${ui_dir}
    Package directory:              ${pkgconfigdir}
    Compiler:                       ${CC}
    CFLAGS:                         ${CFLAGS}
    VALAFLAGS:                      ${VALAFLAGS}

    Plugins:

    Placeholder

    $PACKAGE will be installed in $bindir
])
