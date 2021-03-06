dnl blank.m4
dnl
dnl Copyright 2014 Geoff Johnson
dnl
dnl Useful macros borrowed from rygel.

AC_DEFUN([BLANK_ADD_STAMP], [
    blank_stamp_files="$blank_stamp_files $srcdir/$1"
])

AC_DEFUN([BLANK_ADD_VALAFLAGS], [
    VALAFLAGS="${VALAFLAGS:+$VALAFLAGS }$1"
])

dnl _BLANK_ADD_PLUGIN_INTERNAL(NAME-OF-PLUGIN,
dnl   NAME-OF-PLUGIN-WITH-UNDERSCORES,
dnl   NAME-OF-PLUGIN-FOR-HELP,
dnl   DEFAULT-FOR-ENABLE)
dnl --------------------------------------
dnl Add an --enable-plugin option, add its Makefile to AC_OUTPUT and set the
dnl conditional
AC_DEFUN([_BLANK_ADD_PLUGIN_INTERNAL], [
    AC_ARG_ENABLE([$1-plugin],
        AS_HELP_STRING([--enable-$1-plugin],[Enable the $3 plugin]),,
        enable_$2_plugin=$4)
    AC_CONFIG_FILES([src/plugins/$1/Makefile])
    AM_CONDITIONAL(m4_toupper(build_$2_plugin), test "x$[]enable_$2_plugin" = "xyes")
    BLANK_ADD_STAMP([src/plugins/$1/libblank_$2_la_vala.stamp])
    AC_CONFIG_FILES([src/plugins/$1/$1.plugin])
])

dnl BLANK_ADD_PLUGIN(NAME-OF-PLUGIN,
dnl   NAME-OF-PLUGIN-FOR-HELP,
dnl   DEFAULT-FOR-ENABLE)
dnl --------------------------------------
dnl Hands off to internal m4.
AC_DEFUN([BLANK_ADD_PLUGIN], [
    _BLANK_ADD_PLUGIN_INTERNAL([$1],
        m4_translit([$1],[-],[_]),
        [$2],
        [$3])
])

dnl _BLANK_DISABLE_PLUGIN_INTERNAL(NAME-OF-PLUGIN)
dnl --------------------------------------
dnl Unset the conditional for building the plugin.
AC_DEFUN([_BLANK_DISABLE_PLUGIN_INTERNAL], [
    AM_CONDITIONAL(m4_toupper(build_$1_plugin), false)
    enable_$1_plugin="n/a"
])

dnl BLANK_DISABLE_PLUGIN(NAME-OF-PLUGIN)
dnl --------------------------------------
dnl Hands off to internal m4.
AC_DEFUN([BLANK_DISABLE_PLUGIN], [
    _BLANK_DISABLE_PLUGIN_INTERNAL(m4_translit([$1],[-],[_]))
])
