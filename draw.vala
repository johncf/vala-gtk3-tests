using Gtk;
using Gdk;
using Cairo;

struct Point {
    double x;
    double y;
}

public class Scribble : Gtk.Window {
    private Cairo.Surface? surface = null;

    private int draw_width;
    private int draw_height;

    private Point? prev_pos;

    public Scribble () {
        // constructor chain up
        GLib.Object (type: Gtk.WindowType.TOPLEVEL);

        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.set_size_request (500, 500);
        drawing_area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK |
                              //Gdk.EventMask.BUTTON_RELEASE_MASK |
                                Gdk.EventMask.POINTER_MOTION_MASK);

        drawing_area.configure_event.connect (this.on_configure_event);
        drawing_area.draw.connect (this.on_draw);
        drawing_area.button_press_event.connect (this.on_press);
        //drawing_area.button_release_event.connect (this.on_release);
        drawing_area.motion_notify_event.connect (this.on_move);

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
        if (this.surface != null) {
            // copy the contents of the old surface to the new surface.
            ctx.set_source_surface(this.surface, 0, 0);
            ctx.paint();
        }
        this.surface = tmpsurface;
        this.draw_width = event.width;
        this.draw_height = event.height;
        return true;
    }

    private bool on_press (Gtk.Widget sender, Gdk.EventButton event) {
        if (event.button == Gdk.BUTTON_PRIMARY) {
            this.prev_pos = Point() { x = event.x, y = event.y };
        } else if (event.button == Gdk.BUTTON_SECONDARY) { // clear
            var ctx = new Cairo.Context (this.surface);
            ctx.set_source_rgb(0.9, 0.9, 0.9);
            ctx.paint();
            sender.queue_draw();
        }
        return false;
    }

    private bool on_move (Gtk.Widget sender, Gdk.EventMotion event) {
        if ((event.state & Gdk.ModifierType.BUTTON1_MASK) != 0) {
            var ctx = new Cairo.Context (this.surface);
            ctx.set_source_rgb (0.3, 0.3, 0.3);
            ctx.move_to(this.prev_pos.x, this.prev_pos.y);
            ctx.line_to(event.x, event.y);
            ctx.stroke();
            sender.queue_draw();
            this.prev_pos = Point() { x = event.x, y = event.y };
        }
        return false;
    }

    static int main (string[] args) {
        Gtk.init (ref args);

        var window = new Scribble ();
        window.show_all ();

        Gtk.main ();

        return 0;
    }
}
