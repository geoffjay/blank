public interface Blank.Application : GLib.Object {

    /**
     * The commands that are recognized.
     */
    public enum Command {
        NONE,
        QUIT;

        public string to_string () {
            switch (this) {
                case NONE:    return "none";
                case QUIT:    return "quit";
                default: assert_not_reached ();
            }
        }

        public string description () {
            switch (this) {
                case NONE:    return "No operation";
                case QUIT:    return "Quit the command line interface";
                default: assert_not_reached ();
            }
        }

        public static Command[] all () {
            return {
                NONE,
                QUIT
            };
        }

        public static Command parse (string value) {
            try {
                var regex_none = new Regex ("none", RegexCompileFlags.CASELESS);
                var regex_quit = new Regex ("q|quit", RegexCompileFlags.CASELESS);

                /**
                 * It feels inefficient doing this one at a time, but I can't
                 * come up with a better idea.
                 */
                if (regex_none.match (value)) {
                    return NONE;
                } else if (regex_quit.match (value)) {
                    return QUIT;
                } else {
                    return NONE;
                }
            } catch (RegexError e) {
                GLib.message ("Command regex error: %s", e.message);
            }

            return NONE;
        }
    }

    /**
     * Model used to update the view.
     */
    public abstract Blank.ApplicationModel model { get; set; }

    /**
     * View to provide the user access to the data in the model.
     */
    public abstract Blank.ApplicationView view { get; set; }

    /**
     * Controller to update the model and perform any functionality requested
     * by the view.
     */
    public abstract Blank.ApplicationController controller { get; set; }

    /**
     * Emitted when the application has been stopped.
     */
    public abstract signal void closed ();

    public abstract void shutdown ();

    /**
     * The methods startup, activate, and command_line need to be overridden in
     * the application classes that derive this but it seemed pointless to force
     * it through this interface.
     */
/*
 *    protected abstract int _command_line (GLib.ApplicationCommandLine cmdline);
 *
 *    protected abstract void _startup ();
 *
 *    protected abstract void _activate ();
 */
}
