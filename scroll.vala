using Cairo;
using Gdk;
using Gtk;
using Pango;

public class Texter : Gtk.Window {
    private Gtk.DrawingArea darea; // for queue_draw
    private Gtk.Scrollbar scroll; // for set_adjustment, get_value
    private Pango.Context pctx;

    private Pango.Layout? layout = null;

    private int padding = 10;
    private string text;

    public Texter (string text) {
        // constructor chain up
        GLib.Object (type: Gtk.WindowType.TOPLEVEL);

        Gtk.Grid grid = new Gtk.Grid();
        this.add (grid);

        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.expand = true;
        //drawing_area.set_size_request (500, 500);

        drawing_area.configure_event.connect (this.on_configure_event);
        drawing_area.draw.connect (this.on_draw);

        grid.attach (drawing_area, 0, 0);

        var pctx = drawing_area.create_pango_context();

        var scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL,
                                           new Gtk.Adjustment(0, 0, 1, 0, 0, 1));

        grid.attach (scrollbar, 1, 0);

        this.darea = drawing_area;
        this.scroll = scrollbar;
        this.pctx = pctx;
        this.text = text;

        this.destroy.connect (Gtk.main_quit);
    }

    private bool on_draw (Gtk.Widget sender, Cairo.Context ctx) {
        ctx.set_source_rgb (0.9, 0.9, 0.9);
        ctx.paint (); // bg fill

        ctx.move_to(this.padding, this.padding);
        ctx.set_source_rgb (0.25, 0.25, 0.25);
        Pango.cairo_show_layout(ctx, this.layout);

        return false;
    }

    private bool on_configure_event (Gtk.Widget sender, Gdk.EventConfigure event) {
        var layout = new Pango.Layout(this.pctx);
        layout.set_font_description(Pango.FontDescription.from_string("Sans 24"));
        layout.set_width(Pango.units_from_double(event.width - 2 * this.padding));
        layout.set_text(this.text, this.text.length);

        this.layout = layout;
        return true;
    }

    static int main (string[] args) {
        if (args.length != 2) {
            stderr.printf ("Usage: %s [FILE]\n", args[0]);
            return 0;
        }

        // Create a file that can only be accessed by the current user:
        File file = File.new_for_commandline_arg (args[1]);
        //Gee.ArrayList<string> lines = new Gee.ArrayList<string> ();
        string text = "";
        try {
            FileInputStream istream = file.read();
            DataInputStream dis = new DataInputStream (istream);
            string? line;
            while ((line = dis.read_line (null)) != null) {
                //lines.add (line);
                text += line + "\n";
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            return 0;
        }

        Gtk.init (ref args);

        var window = new Texter (text);
        window.show_all ();

        Gtk.main ();

        return 0;
    }
}
