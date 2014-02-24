SUBDIRS = \
	ui

desktopdir = $(datadir)/applications
desktop_in_files = blank.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

gresource_file = blank.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))

CLEANFILES = \
	$(desktop_DATA)

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	$(desktop_in_files)

install-data-hook:
	chmod +x $(desktopdir)/@PACKAGE@.desktop
