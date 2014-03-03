/**
 * The Gtk.Application class expects an ApplicationWindow so a lot is being
 * moved here from outside of the actual view class.
 */
public class Blank.UI.ApplicationView : Gtk.ApplicationWindow, Blank.ApplicationView {

    /* Model used to update the view */
    private Blank.ApplicationModel model;

    /* Widgets and data needed for interface */
    private Gtk.Widget notebook;

    /**
     * Default construction.
     */
    internal ApplicationView (Blank.ApplicationModel model) {
        GLib.Object (title: "Blank Application",
                     window_position: Gtk.WindowPosition.CENTER);

        this.model = model;

/*
 *        this.show_menubar = false;
 *        this.maximize ();
 *        this.show_all ();
 *
 *        this.model = model;
 *
 *        load_widgets ();
 *        load_style ();
 *
 *        [> Load the layout from either the configuration or use the default <]
 *        add_layout ();
 *
 *        initialize_display ();
 *        connect_signals ();
 */
    }

    public void load_widgets () {
        /* Load anything that's needed from the toolbar */
        var path = GLib.Path.build_filename (Config.UI_DIR, "toolbar.ui");
        GLib.message ("Loading interface file: %s", path);

        var tb_builder = new Gtk.Builder ();
        try {
            tb_builder.add_from_file (path);
        } catch (GLib.Error e) {
            GLib.error ("Unable to load file: %s", e.message);
        }

        /* Load what's needed into the top-level grid */
        var grid = new Gtk.Grid ();
        (grid as Gtk.Widget).expand = true;
        this.add (grid);
        grid.show ();

        /* All layout panels will be placed inside of a notebook to allow for
         * multiple buildable pages */
        notebook = new Gtk.Notebook ();
        notebook.expand = true;

        grid.attach (tb_builder.get_object ("toolbar") as Gtk.Widget, 0, 0, 1, 1);
        grid.attach (notebook, 0, 1, 1, 1);
    }

    public void load_style () {

        /* XXX use resource instead - see gtk3-demo for example */

        /* Apply stylings from CSS resource */
        var provider = Blank.load_css ("gtk-style.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                  provider,
                                                  600);
    }

    public void add_layout () {

        if ((notebook as Gtk.Notebook).get_n_pages () == 1) {
            (notebook as Gtk.Notebook).show_tabs = false;
        }
    }

    public void initialize_display () {
    }

    public void connect_signals () {
        /* Signals from the application data model */
    }

    /*
     *private void add_module_content (Gtk.Widget scrolled_window) {
     *}
     */
}
