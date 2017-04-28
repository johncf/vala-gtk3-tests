using Gtk;
using Gdk;
using Cairo;
using Pango;

public class Texter : Gtk.Window {
    private Cairo.Surface? surface = null;
    private Pango.Layout? layout = null;

    private int padding = 10;
    private string text;

    public Texter (string text) {
        // constructor chain up
        GLib.Object (type: Gtk.WindowType.TOPLEVEL);

        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.set_size_request (500, 500);
        drawing_area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK);

        drawing_area.configure_event.connect (this.on_configure_event);
        drawing_area.draw.connect (this.on_draw);
        drawing_area.button_press_event.connect (this.on_press);

        this.text = text;
        this.add (drawing_area);
        this.destroy.connect (Gtk.main_quit);
    }

    private bool on_draw (Gtk.Widget sender, Cairo.Context ctx) {
        if (this.surface != null) {
            ctx.set_source_surface(this.surface, 0, 0);
            ctx.paint();
        }
        return false;
    }

    private bool on_configure_event (Gtk.Widget sender, Gdk.EventConfigure event) {
        var widget_window = sender.get_window();
        // create our new surface with the correct size.
        var tmpsurface = widget_window.create_similar_surface (Cairo.Content.COLOR,
                                                               event.width,
                                                               event.height);
        var ctx = new Cairo.Context (tmpsurface);
        ctx.set_source_rgb (0.9, 0.9, 0.9);
        ctx.paint (); // bg fill
        var layout = Pango.cairo_create_layout(ctx);
        layout.set_font_description(Pango.FontDescription.from_string("Sans 24"));
        layout.set_width(Pango.units_from_double(event.width - 2 * this.padding));
        layout.set_text(this.text, this.text.length);
        ctx.move_to(this.padding, this.padding);
        ctx.set_source_rgb (0.25, 0.25, 0.25);
        Pango.cairo_show_layout(ctx, layout);
        this.layout = layout;
        this.surface = tmpsurface;
        return true;
    }

    private bool on_press (Gtk.Widget sender, Gdk.EventButton event) {
        if (this.layout == null) return false;
        var m_x = Pango.units_from_double(event.x - this.padding);
        var m_y = Pango.units_from_double(event.y - this.padding);
        int index, _trail;
        this.layout.xy_to_index(m_x, m_y, out index, out _trail);
        var rect = this.layout.index_to_pos(index);
        var ctx = new Cairo.Context (this.surface);
        ctx.rectangle(Pango.units_to_double(rect.x) + this.padding,
                      Pango.units_to_double(rect.y) + this.padding,
                      Pango.units_to_double(rect.width),
                      Pango.units_to_double(rect.height));
        ctx.set_line_width(1);
        ctx.set_source_rgb (0.1, 0.2, 0.6);
        ctx.stroke();
        sender.queue_draw();
        return false;
    }

    static int main (string[] args) {
        Gtk.init (ref args);

        var window = new Texter ("Hello, world!\nThis must be read from a file.\nRight?");
        window.show_all ();

        Gtk.main ();

        return 0;
    }
}
