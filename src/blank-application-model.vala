/**
 * Main application class responsible for interfacing with data and different
 * interface types.
 */
public class Blank.ApplicationModel : GLib.Object {

    /* Allow administrative functionality */
    public bool admin { get; set; default = false; }

    /* Basic output verbosity, should use an integer to allow for -vvv */
    public bool verbose { get; set; default = false; }

    /**
     * Signals used primarily to inform the view that something in the
     * model was changed.
     */

    //public signal void something_changed ();

    /**
     * Default construction.
     */
    public ApplicationModel () {
    }
}
