ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
	data \
	src \
	vapi

EXTRA_DIST = \
	$(noinst_DATA) \
	autogen.sh

DISTCHECK_CONFIGURE_FLAGS =

# Extra clean files so that maintainer-clean removes *everything*
MAINTAINERCLEANFILES = \
	aclocal.m4 \
	compile \
	config.guess \
	config.sub \
	configure \
	depcomp \
	install-sh \
	ltmain.sh \
	Makefile.in \
	missing \
	config.h.in

vala-clean:
	rm -f `find . -name "*.stamp"`
