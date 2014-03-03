using Config;

/**
 * The view class in an MVC design is responsible for updating the display based
 * on the changes made to the model.
 *
 * XXX should consider adding signals where necessary in the model and only
 *     update the view when it fires a signal to improve performance.
 */
public class Blank.UI.Application : Gtk.Application, Blank.Application {

    /* Allow administrative functionality */
    private bool _admin = false;
    public bool admin {
        get { return _admin; }
        set { _admin = value; }
    }

    /**
     * {@inheritDoc}
     */
    public virtual Blank.ApplicationModel model { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Blank.ApplicationView view { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Blank.ApplicationController controller { get; set; }

    /**
     * Signals used to inform the controller that a request was made of
     * the model.
     */

    /**
     * Used when the user requests to quit.
     */
    public signal void save_requested ();

    /**
     * Default construction.
     */
    public Application () {
        string[] args1 = {};
        unowned string[] args2 = args1;
        GtkClutter.init (ref args2);

        message ("Application construction starting");

        GLib.Object (application_id: "org.example.blank",
                     flags: ApplicationFlags.HANDLES_COMMAND_LINE);

        message ("Creating model");
        model = new Blank.ApplicationModel ();
        assert (model != null);

        message ("Creating view");
        view = new Blank.UI.ApplicationView (model);
        //(view as Gtk.Window).application = this;
        assert (view != null);

        message ("Creating controller");
        controller = new Blank.ApplicationController.with_data (model, view);
        assert (controller != null);
        //controller.admin = admin;
    }

    private void add_actions () {
        var theme_action = new SimpleAction.stateful ("wintheme", null, new Variant.boolean (false));
        theme_action.activate.connect (theme_activated_cb);
        this.add_action (theme_action);
        theme_action.activate (true);

        var tb_max_action = new SimpleAction.stateful ("wintbmax", null, new Variant.boolean (false));
        tb_max_action.activate.connect (tb_max_activated_cb);
        this.add_action (tb_max_action);

        var save_action = new SimpleAction ("save", null);
        save_action.activate.connect (save_activated_cb);
        this.add_action (save_action);

        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (quit_activated_cb);
        this.add_action (quit_action);

        /* Add some actions to the app menu */
        var menu = new GLib.Menu ();
        menu.append ("Quit", "app.quit");
        this.app_menu = menu;

        message ("Application construction complete");
    }

    /**
     * Load and launch the application window.
     */
    protected override void activate () {
        base.activate ();
        message ("Blank.UI: activate ()");

        Gtk.Window.set_default_icon_name ("blank");
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

        /* Moved view stuff here to test something */
        (view as Gtk.ApplicationWindow).show_menubar = false;
        (view as Gtk.ApplicationWindow).maximize ();
        (view as Gtk.ApplicationWindow).show_all ();

        (view as Blank.UI.ApplicationView).load_widgets ();
        (view as Blank.UI.ApplicationView).load_style ();

        /* Load the layout from either the configuration or use the default */
        (view as Blank.UI.ApplicationView).add_layout ();

        (view as Blank.UI.ApplicationView).initialize_display ();
        (view as Blank.UI.ApplicationView).connect_signals ();

        (view as Gtk.ApplicationWindow).present ();

        add_actions ();
    }

    /**
     * Perform the application setup including connecting interface callbacks
     * to the various actions.
     */
    protected override void startup () {
        base.startup ();
        message ("Started");
    }

    public override void shutdown () {
        base.shutdown ();
        message ("Closing");
        /* Let someone else deal with shutting down. */
        closed ();
    }

    public virtual int launch (string[] args) {
        return (this as Gtk.Application).run (args);
    }

    /**
     * XXX should test moving this into the Utility file so that it doesn't
     *     need to be created in every application class
     */
    static bool opt_admin;
    static bool opt_help;
    static const OptionEntry[] options = {{
        "admin", 'a', 0, OptionArg.NONE, ref opt_admin,
        "Allow administrative functionality.", null
    },{
        "cli", 'c', 0, OptionArg.NONE, null,
        "Start the application with a command line interface", null
    },{
        "help", 'h', 0, OptionArg.NONE, ref opt_help,
        null, null
    },{
        "verbose", 'v', 0, OptionArg.NONE, null,
        "Provide verbose debugging output.", null
    },{
        "version", 'V', 0, OptionArg.NONE, null,
        "Display version number.", null
    },{
        null
    }};

    public override int command_line (GLib.ApplicationCommandLine cmdline) {
        opt_admin = false;
        opt_help = false;

        var opt_context = new OptionContext (PACKAGE_NAME);
        opt_context.add_main_entries (options, null);
        opt_context.set_help_enabled (false);

        message ("Processing command line arguments");

        try {
            string[] args1 = cmdline.get_arguments ();
            unowned string[] args2 = args1;
            opt_context.parse (ref args2);
        } catch (OptionError e) {
           cmdline.printerr ("error: %s\n", e.message);
           cmdline.printerr (opt_context.get_help (true, null));
           return 1;
        }

        if (opt_help) {
            cmdline.printerr (opt_context.get_help (true, null));
            return 1;
        }

        admin = opt_admin;

        /* XXX not sure if this is the correct way to use this yet */
        activate ();

        return 0;
    }

    /**
     * Action callback for quit.
     */
    private void quit_activated_cb (SimpleAction action, Variant? parameter) {
        var dialog = new Gtk.MessageDialog (null,
                                            Gtk.DialogFlags.MODAL,
                                            Gtk.MessageType.QUESTION,
                                            Gtk.ButtonsType.YES_NO,
                                            "Are you sure you want to quit?");

        (dialog as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.NO:
                    (dialog as Gtk.Dialog).destroy ();
                    break;
                case Gtk.ResponseType.YES:
                    (dialog as Gtk.Dialog).destroy ();
                    this.quit ();
                    break;
            }
        });

        (dialog as Gtk.Dialog).run ();
    }

    /**
     * Action callback for changing the window theme.
     */
    private void theme_activated_cb (SimpleAction action, Variant? parameter) {
        this.hold ();
        Variant state = action.get_state ();
        bool active = state.get_boolean ();
        var settings = Gtk.Settings.get_default ();
        (settings as GLib.Object).set ("gtk-application-prefer-dark-theme", !active);
        action.set_state (new Variant.boolean (!active));
        this.release ();
    }

    /**
     * Action callback for changing the window toolbar behaviour on maximized.
     */
    private void tb_max_activated_cb (SimpleAction action, Variant? parameter) {
        this.hold ();
        Variant state = action.get_state ();
        bool active = state.get_boolean ();
        action.set_state (new Variant.boolean (!active));
        (view as Gtk.Window).hide_titlebar_when_maximized = !active;
        this.release ();
    }

    /**
     * Action callback for saving the configuration file.
     */
    private void save_activated_cb (SimpleAction action, Variant? parameter) {
        var dialog = new Gtk.MessageDialog (null,
                                            Gtk.DialogFlags.MODAL,
                                            Gtk.MessageType.QUESTION,
                                            Gtk.ButtonsType.YES_NO,
                                            "Overwrite %s with application preferences?",
                                            "dummy");

        (dialog as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.YES:
                    /* Signal the controller if the user selected yes */
                    (dialog as Gtk.Dialog).destroy ();
                    save_requested ();
                    break;
                case Gtk.ResponseType.NO:
                    (dialog as Gtk.Dialog).destroy ();
                    return;
                default:
                    break;
            }
        });

        (dialog as Gtk.Dialog).run ();
    }
}
