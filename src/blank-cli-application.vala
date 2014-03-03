using Config;

/**
 * The view class in an MVC design is responsible for updating the display based
 * on the changes made to the model.
 *
 * XXX should consider adding signals where necessary in the model and only
 *     update the view when it fires a signal to improve performance.
 */
public class Blank.CLI.Application : GLib.Application, Blank.Application {

    /* Allow administrative functionality */
    public bool admin { get; set; default = false; }

    /**
     * Whether or not the cli is currently active.
     */
    private bool _active = false;
    public bool active {
        get { return _active; }
        set { _active = value; }
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
     * Default construction.
     */
    public Application () {
        application_id = "org.example.blank";
        flags |= ApplicationFlags.HANDLES_COMMAND_LINE;
    }

    public override void startup () {
        base.startup ();

        /* XXX add any startup steps here */
    }

    public override void activate () {
        base.activate ();

        message ("CLI: Activated");

        model = new Blank.ApplicationModel ();
        //model.verbose = opt_verbose;

        view = new Blank.CLI.ApplicationView (model);

        controller = new Blank.ApplicationController.with_data (model, view);
        controller.admin = admin;

        if (!active) {
            active = true;
            var loop = new GLib.MainLoop ();
            (view as Blank.CLI.ApplicationView).run_cli.begin ((obj, res) => {
                (view as Blank.CLI.ApplicationView).run_cli.end (res);
                loop.quit ();
            });
            loop.run ();
            /* ??? */
            shutdown ();
        }
    }

    public virtual int launch (string[] args) {
        return (this as GLib.Application).run (args);
    }

    public override void shutdown () {
        if (active) {
            active = false;
            /* Let someone else deal with shutting down. */
            closed ();
        }
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
}
