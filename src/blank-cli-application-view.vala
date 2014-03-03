public class Blank.CLI.ApplicationView : GLib.Object, Blank.ApplicationView {

    /* Model used to update the view */
    private Blank.ApplicationModel model;

    /* A queued list of results to a read signal */
    private GLib.Queue<string> results_queue = new GLib.Queue<string> ();

    /**
     * Default construction.
     */
    internal ApplicationView (Blank.ApplicationModel model) {
        this.model = model;
    }

    public void queue_result (string result) {
        results_queue.push_tail (result);
    }

    public void print_queued_results () {
        string item = null;
        while ((item = results_queue.pop_head ()) != null) {
            stdout.printf ("%s\n", item);
        }
    }

    public async void run_cli () {
        string? args = "dummy";
        Blank.Application.Command cmd = Blank.Application.Command.NONE;

        do {
            stdout.printf (">>> ");
            args = stdin.read_line ();
            var tokens = args.split (" ");
            cmd = Blank.Application.Command.parse (tokens[0]);

            switch (cmd) {
                case Blank.Application.Command.NONE:
                    stdout.printf ("received: %s\n", cmd.to_string ());
                    break;
                case Blank.Application.Command.QUIT:
                    stdout.printf ("shutting down\n");
                    break;
                default:
                    assert_not_reached ();
            }

        } while (cmd != Blank.Application.Command.QUIT);
    }
}
