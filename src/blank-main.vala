using Config;

private static bool cli = false;
private static bool verbose = false;
private static bool version = false;

private const GLib.OptionEntry[] local_options = {{
    "cli", 'c', 0, OptionArg.NONE, ref cli,
    "Start the application with a command line interface", null
},{
    "verbose", 'v', 0, OptionArg.NONE, ref verbose,
    "Provide verbose debugging output.", null
},{
    "version", 'V', 0, OptionArg.NONE, ref version,
    "Display version number.", null
},{
    null
}};

private static void parse_local_args (ref unowned string[] args) {
    var opt_context = new OptionContext (PACKAGE_NAME);
    opt_context.set_ignore_unknown_options (true);
    opt_context.set_help_enabled (false);
    opt_context.add_main_entries (local_options, null);

    try {
        opt_context.parse (ref args);
    } catch (OptionError e) {
    }

    if (version) {
        stdout.printf ("%s - version %s\n", args[0], PACKAGE_VERSION);
        Posix.exit (0);
    }
}

public int main (string[] args) {

    Blank.Application app;
    int status = 0;

    GLib.Environment.set_application_name ("Blank");

    parse_local_args (ref args);

    /* Setup the application view */
    if (cli) {
        app = new Blank.CLI.Application ();
    } else {
        app = new Blank.UI.Application ();
    }

    app.closed.connect (() => {
        app = null;
    });

    /* Launch the application */
    try {
        status = (app as GLib.Application).run (args);
    } catch (GLib.Error e) {
        stdout.printf ("Error: %s\n", e.message);
        return 0;
    }

    app.shutdown ();

    return status;
}
