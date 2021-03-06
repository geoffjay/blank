/**
 * Various helper utilities copied from Boxes.
 */
namespace Blank {

    public Gee.List<double?> hex_to_rgb (string hex) {
        Gee.ArrayList<double?> rgb = new Gee.ArrayList<double?> ();

        Gdk.Color color = Gdk.Color ();
        Gdk.Color.parse (hex, out color);
        rgb.add (color.red / 65535.0);
        rgb.add (color.green / 65535.0);
        rgb.add (color.blue / 65535.0);

        return rgb;
    }

    public Gtk.CssProvider load_css (string css) {
        var provider = new Gtk.CssProvider ();
        try {
            var file = File.new_for_uri("resource:///org/example/blank/" + css);
            provider.load_from_file (file);
        } catch (GLib.Error e) {
            warning ("loading css: %s", e.message);
        }
        return provider;
    }

    public Gdk.Pixbuf load_asset (string asset) throws GLib.Error {
        return new Gdk.Pixbuf.from_resource ("/org/example/blank/icons/" + asset);
    }

    public Gtk.Builder load_ui (string ui) {
        var builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/example/blank/ui/".concat (ui, null));
        } catch (GLib.Error e) {
            error ("Failed to load UI file '%s': %s", ui, e.message);
        }
        return builder;
    }

    public Clutter.Color gdk_rgba_to_clutter_color (Gdk.RGBA gdk_rgba) {
        Clutter.Color color = {
            (uint8) (gdk_rgba.red * 255).clamp (0, 255),
            (uint8) (gdk_rgba.green * 255).clamp (0, 255),
            (uint8) (gdk_rgba.blue * 255).clamp (0, 255),
            (uint8) (gdk_rgba.alpha * 255).clamp (0, 255)
        };

        return color;
    }

    public Gdk.RGBA get_blank_bg_color () {
        var style = new Gtk.StyleContext ();
        var path = new Gtk.WidgetPath ();
        path.append_type (typeof (Gtk.Window));
        style.set_path (path);
        style.add_class ("blank-bg");
        return style.get_background_color (0);
    }

    public Gdk.RGBA get_color (string desc) {
        Gdk.RGBA color =  Gdk.RGBA ();
        color.parse (desc);
        return color;
    }
}
