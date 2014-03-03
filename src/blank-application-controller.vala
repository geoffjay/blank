/**
 * The application controller in a MVC design is responsible for responding to
 * events from the view and updating the model.
 */
public class Blank.ApplicationController : GLib.Object {

    /**
     * Application model to use.
     */
    private Blank.ApplicationModel model;

    /**
     * Application view to use.
     */
    private Blank.ApplicationView view;

    /* Control administrative functionality */
    private bool _admin = false;
    public bool admin {
        get { return _admin; }
        set {
            /* XXX Ideally this would allow for both views simultaneously but
             *     for now assuming that just one is active is fine */
            _admin = value;
            model.admin = _admin;
            if (ui_enabled)
                (view as Blank.UI.Application).admin = _admin;
            else if (cli_enabled)
                (view as Blank.CLI.Application).admin = _admin;
        }
    }

    /* Flag to set if user requested a command line interface. */
    private bool _cli_enabled = false;
    public bool cli_enabled {
        get { return _cli_enabled; }
        set {
            _cli_enabled = value;
            if (_cli_enabled) {
                (view as Blank.CLI.Application).closed.connect (() => {
                    (view as GLib.Application).quit ();
                });
            } else {
                /* XXX not sure, might need to disconnect in future if this is
                 *     meant to keep the view open */
                //(view as GLib.Application).quit ();
            }
        }
    }

    /* Flag to set if user requested a graphical interface. */
    private bool _ui_enabled = false;
    public bool ui_enabled {
        get { return _ui_enabled; }
        set {
            _ui_enabled = value;
            if (_ui_enabled) {
               /*
                 *_ui.admin = admin;
                 *_ui.closed.connect ();
                 */
                /*
                 *(view as Blank.UI.Application).save_requested.connect (save_requested_cb);
                 *(view as Blank.UI.Application).closed.connect (() => {
                 *    (view as GLib.Application).quit ();
                 *});
                 */
            } else {
                /* XXX should perform a clean shutdown of the interface - fix */
                //(view as GLib.Application).quit ();
            }
        }
    }

    /**
     * Default construction.
     */
    public ApplicationController () {
        /* Nothing for now but could imagine creating blank model and view if
         * dactl is extended to construct application configurations as well. */
    }

    /**
     * Alternative construction with model and view as parameters.
     */
    public ApplicationController.with_data (ApplicationModel model, Blank.ApplicationView view) {
        this.model = model;
        this.view = view;

        if (view is Blank.CLI.ApplicationView)
            cli_enabled = true;
        else if (view is Blank.UI.ApplicationView)
            ui_enabled = true;
    }

    /**
     * Callbacks common to all view types.
     * XXX the intention is to use a common interface later on
     */
    public void save_requested_cb () {
        stdout.printf ("Saving the configuration.\n");
    }
}
