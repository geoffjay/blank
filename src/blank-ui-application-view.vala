/**
 * The Gtk.Application class expects an ApplicationWindow so a lot is being
 * moved here from outside of the actual view class.
 */
public class Blank.UI.ApplicationView : Gtk.ApplicationWindow, Blank.ApplicationView {

    /* Model used to update the view */
    private Blank.ApplicationModel model;

    /* Widgets and data needed for interface */
    private Gtk.Widget stack;

    /**
     * Default construction.
     */
    internal ApplicationView (Blank.ApplicationModel model) {
        GLib.Object (title: "Data Acquisition and Control",
                     window_position: WindowPosition.CENTER);

        this.model = model;

        load_widgets ();
        load_style ();

        /* Load the layout from either the configuration or use the default */
        add_layout ();

        initialize_display ();
        connect_signals ();
    }

    private void load_widgets () {
        /* Load anything that's needed from the toolbar */
        path = GLib.Path.build_filename (Config.UI_DIR, "toolbar.ui");
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
        stack = new Gtk.Stack ();
        stack.expand = true;

        grid.attach (tb_builder.get_object ("toolbar") as Gtk.Widget, 0, 0, 1, 1);
        grid.attach (stack, 0, 1, 1, 1);
    }

    private void load_style () {

        /* XXX use resource instead - see gtk3-demo for example */

        /* Apply stylings from CSS resource */
        var provider = Blank.load_css ("gtk-style.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                  provider,
                                                  600);
    }

    private void add_layout () {
        /* If no pages were defined load the default layout */
        if (model.page_map.size == 0) {
            using_default = true;

            var path = GLib.Path.build_filename (Config.UI_DIR, "default_layout.ui");
            GLib.message ("Loading interface file: %s", path);

            /* Add the main content from a Glade interface file */
            var builder = new Gtk.Builder ();
            try {
                builder.add_from_file (path);
            } catch (GLib.Error e) {
                GLib.error ("Unable to load file: %s", e.message);
            }

            /* These are all of the widgets that are needed without using builder */
            frame_channels = builder.get_object ("frame_channels") as Widget;
            frame_charts = builder.get_object ("frame_charts") as Widget;
            frame_controls = builder.get_object ("frame_controls") as Widget;
            frame_modules = builder.get_object ("frame_modules") as Widget;

            Gtk.Label title = new Gtk.Label ("Default Layout");
            Gtk.Box content = builder.get_object ("default_layout") as Gtk.Box;
            (notebook as Gtk.Notebook).append_page (content, title);

            /* Get content box and fill */
            var channel_scroll = builder.get_object ("scrolledwindow_channels");
            add_channel_treeview_content (channel_scroll as Gtk.Widget);

            var chart_scroll = builder.get_object ("scrolledwindow_charts");
            add_chart_content (chart_scroll as Gtk.Widget);

            var control_scroll = builder.get_object ("scrolledwindow_controls");
            add_control_content (control_scroll as Gtk.Widget);

            var module_scroll = builder.get_object ("scrolledwindow_modules");
            add_module_content (module_scroll as Gtk.Widget);
        } else {
            /* Currently only pages can be added to the notebook */
            foreach (var page in model.page_map.values) {
                GLib.message ("Adding page: %s", page.id);
                var title = new Gtk.Label ((page as Blank.Page).model.title);
                (notebook as Gtk.Notebook).append_page ((page as Blank.Page).view,
                                                        title);
            }

            /* Currently only grids can be added to pages */
            foreach (var grid in model.grid_map.values) {
                var page = model.app_builder.get_object ((grid as Blank.Grid).model.page_ref);

                GLib.message ("Adding grid: %s to page %s", grid.id, page.id);

                /*
                 *(page as Gtk.Widget).expand = true;
                 */
                var stage = (page as Blank.Page).view.get_stage ();
                stage.add ((grid as Blank.Grid).view);

                /* XXX GridCell needs to be changed to have a model and view
                 *     to be able to populate it outside of this loop */
                foreach (var cell in ((grid as Blank.Grid).model as Blank.Container).objects.values) {
                    if (cell is Blank.GridCell) {
                        var cell_actor = new Clutter.Actor ();
                        cell_actor.x_align = Clutter.ActorAlign.FILL;
                        cell_actor.y_align = Clutter.ActorAlign.FILL;
                        cell_actor.x_expand = true;
                        cell_actor.y_expand = true;
                        (grid as Blank.Grid).view.add_child_using_cell (cell_actor, cell as Blank.GridCell);

                        /* Just for now populate here using this ugly way */
                        foreach (var tree in model.tree_map.values) {
                            var tree_model = (tree as Blank.ChannelTree).model;
                            var tree_view = (tree as Blank.ChannelTree).view;

                            if (tree_model.cell_ref == cell.id) {
                                GLib.message ("Adding channel tree: %s to %s", tree_model.id, cell.id);
                                tree_model.channel_request.connect ((id) => {
                                    var channel = model.builder.get_object (id);
                                    GLib.message ("Adding channel %s to %s", channel.id, tree_model.id);
                                    tree_model.channels.set (channel.id, channel);
                                });

                                /* XXX this wasn't exactly as intended */
                                tree_model.add_channels ();
                                //var actor = new GtkClutter.Actor.with_contents ((tree as Blank.ChannelTree).view);
                                //actor.x_align = Clutter.ActorAlign.FILL;
                                //actor.y_align = Clutter.ActorAlign.FILL;
                                //actor.x_expand = true;
                                //actor.y_expand = true;
                                cell_actor.add_child ((tree_view as GtkClutter.Embed).get_stage ());
                            }
                        }

                        foreach (var chart in model.chart_map.values) {
                            var chart_model = (chart as Blank.Chart).model;
                            if (chart_model.cell_ref == cell.id) {
                                GLib.message ("Adding chart: %s to %s", chart_model.id, cell.id);
                                cell_actor.add_child ((chart as Blank.Chart).view);
                                ((chart as Blank.Chart).view).set_size (200, 200);
                                /*
                                 *((chart as Blank.Chart).view).x_align = Clutter.ActorAlign.FILL;
                                 *((chart as Blank.Chart).view).y_align = Clutter.ActorAlign.FILL;
                                 *((chart as Blank.Chart).view).x_expand = true;
                                 *((chart as Blank.Chart).view).y_expand = true;
                                 */
                                var color = Clutter.Color.from_hls ((float)Random.double_range (0.0, 360.0), 0.5f, 0.5f);
                                color.alpha = 255;
                                ((chart as Blank.Chart).view).background_color = color;
                            }
                        }

                        GLib.message ("HxW: %f, %f", cell_actor.height, cell_actor.width);
                    }
                }
            }
        }

        /* No point taking up space unnecessarily */
        if ((notebook as Gtk.Notebook).get_n_pages () == 1) {
            (notebook as Gtk.Notebook).show_tabs = false;
        }
    }

    private void initialize_display () {
    }

    private void connect_signals () {
        /* Signals from the application data model */

        /* Callbacks with functions */
        //channel_treeview.cursor_changed.connect (channel_cursor_changed_cb);

/*
 *        foreach (var tree in model.tree_map) {
 *            (tree as Blank.ChannelTree).view.channel_selected.connect ((id) => {
 *                GLib.debug ("Selected: %s", id);
 *                var channel = model.builder.get_object (id);
 *
 *                [> This is an ugly way of doing this but it shouldn't matter <]
 *                foreach (var chart in model.chart_map) {
 *                    //(chart as Blank.Chart).select_series (id);
 *                }
 *            });
 *        }
 */
    }

    private void add_module_content (Gtk.Widget scrolled_window) {
    }
}
