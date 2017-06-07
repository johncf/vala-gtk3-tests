using Cairo;
using Gdk;
using Gtk;
using Pango;

public class Texter : Gtk.Window {
    private Gtk.DrawingArea darea; // for queue_draw
    private Gtk.Scrollbar scroll; // for set_adjustment, get_value
    private Pango.Context pctx;

    private Pango.Layout? layout = null;

    private string text;

    public Texter (string text) {
        // constructor chain up
        GLib.Object (type: Gtk.WindowType.TOPLEVEL);

        Gtk.Grid grid = new Gtk.Grid();
        this.add (grid);

        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.expand = true;
        drawing_area.configure_event.connect (this.on_configure_event);
        drawing_area.draw.connect (this.on_draw);

        grid.attach (drawing_area, 0, 0);

        var pctx = drawing_area.create_pango_context();

        var scrollbar = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL,
                                           new Adjustment (0, 0, 100, 10, 90, 100));
        scrollbar.value_changed.connect (() => {
            drawing_area.queue_draw ();
        });

        grid.attach (scrollbar, 1, 0);

        this.darea = drawing_area;
        this.scroll = scrollbar;
        this.pctx = pctx;
        this.text = text;

        this.destroy.connect (Gtk.main_quit);
    }

    public override void get_preferred_height (out int min_height, out int nat_height) {
        min_height = 300;
        nat_height = 300;
    }

    public override void get_preferred_width (out int min_width, out int nat_width) {
        min_width = 400;
        nat_width = 400;
    }

    private bool on_draw (Gtk.Widget sender, Cairo.Context ctx) {
        double clip_l, _t, clip_r, _b;
        ctx.clip_extents(out clip_l, out _t, out clip_r, out _b);
        if (clip_r - clip_l < 3) { return false; }

        ctx.set_source_rgb (0.9, 0.9, 0.9);
        ctx.paint (); // bg fill

        ctx.set_source_rgb (0.25, 0.25, 0.25);
        var y_offset = this.scroll.get_value();
        ctx.move_to(0, -y_offset);
        Pango.cairo_show_layout(ctx, this.layout);

        return false;
    }

    private bool on_configure_event (Gtk.Widget sender, Gdk.EventConfigure event) {
        if (this.layout == null) {
            var layout = new Pango.Layout(this.pctx);
            layout.set_font_description(Pango.FontDescription.from_string("Sans 12"));
            layout.set_wrap(Pango.WrapMode.WORD_CHAR);
            layout.set_auto_dir(false);
            layout.set_text(this.text, this.text.length);
            this.layout = layout;
        }
        this.layout.set_width(Pango.units_from_double(event.width));

        //var height = layout.get_line_count ();
        int width, height;
        layout.get_pixel_size (out width, out height);
        var adjustment = this.scroll.get_adjustment ();
        adjustment.set_page_size (event.height);
        adjustment.set_page_increment (event.height * 0.9);
        this.scroll.set_range (0, height);

        return false;
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
                break;
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
