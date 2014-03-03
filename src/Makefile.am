NULL =
BUILT_SOURCES =
EXTRA_DIST =

gresource_file = $(top_srcdir)/data/blank.gresource.xml

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

BUILT_SOURCES += resources.c

EXTRA_DIST += $(gresource_file)

bin_PROGRAMS = blank

# There should be an option to --enable-ui during configuration to allow for
# building only the cli.
#
# This is going to be confusing for a while because plugins have ui components,
# and so do several of the configurable objects that use views like the chart
# and grid. These will likely be broken out into multiple files later on.
UI_SOURCES = \
	$(NULL)

# For some totally bizarre reason this doesn't always work if it's included in
# the VALAFLAGS section, just add in as needed until a solution is found.
#	--gresources $(gresource_file)

blank_VALAFLAGS = \
	$(VALAFLAGS) \
	--enable-experimental \
	-H $(srcdir)/libblank.h -C -c --thread \
	--vapidir=$(top_srcdir)/vapi \
	-X -g -X -pg \
	@VALAPACKAGES@ \
	--pkg config \
	--pkg posix \
	--pkg linux \
	$(BLANK_COMMON_VALAFLAGS) \
	$(NULL)

blank_CFLAGS = \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@ \
	$(GLIB_CFLAGS) \
	$(GTK_CFLAGS) \
	$(CLUTTER_CFLAGS) \
	$(GEE_CFLAGS) \
	$(GIO_CFLAGS)

blank_LDADD = \
	@PACKAGE_LIBS@ \
	$(GLIB_LIBS) \
	$(GTK_LIBS) \
	$(CLUTTER_LIBS) \
	$(GEE_LIBS) \
	$(GIO_LIBS)

blank_headers = \
	common.h \
	blank.h \
	libblank.h

blank_SOURCES = \
	$(BUILT_SOURCES) \
	blank-main.vala \
	blank-application.vala \
	blank-application-model.vala \
	blank-application-controller.vala \
	blank-application-view.vala \
	blank-cli-application.vala \
	blank-cli-application-view.vala \
	blank-ui-application.vala \
	blank-ui-application-view.vala \
	blank-utility.vala \
	$(UI_SOURCES) \
	$(NULL)

CLEANFILES = \
	*.stamp \
	stamp-h1 \
	$(srcdir)/libblank.h
