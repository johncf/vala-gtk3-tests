using Gtk;
using Gdk;
using Cairo;

public class AnimationExample : Gtk.Window {
    private Cairo.Surface? surface = null;

    private int draw_width;
    private int draw_height;
    private int step;

    public AnimationExample () {
        // constructor chain up
        GLib.Object (type: Gtk.WindowType.TOPLEVEL);

        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.set_size_request (500, 500);
        this.add (drawing_area);

        drawing_area.configure_event.connect (this.on_configure_event);
        drawing_area.draw.connect (this.on_draw);

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
        // create our new surface with the correct size.
        var widget_window = sender.get_window();
        var tmpsurface = widget_window.create_similar_surface (Cairo.Content.COLOR,
                                                               event.width,
                                                               event.height);
        var ctx = new Cairo.Context (tmpsurface);
        ctx.set_source_rgb (0.9, 0.9, 0.9);
        ctx.paint ();
        // set up our surface so it is ready for drawing
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

    // do_draw will be executed whenever we would like to update our animation
    private void do_draw () {
        if (this.surface == null) return;

        this.step += 4; // give movement to our animation
        this.step %= this.draw_width;

        var ctx = new Cairo.Context (this.surface);
        ctx.set_source_rgb((double) this.step / this.draw_width,
                           (double) this.step / this.draw_width,
                           1.0 - (double) this.step / this.draw_width);
        ctx.rectangle((double) this.step, (double) this.draw_height / 2.0, 100, 100); 
        ctx.stroke();

        // tell our window it is time to draw our animation.
        this.queue_draw();
    }

    static int main (string[] args){
        Gtk.init (ref args);

        var window = new AnimationExample ();
        window.show_all ();

        // Just a timeout to update once a second.
        Timeout.add(60, ()=>{window.do_draw();return true;});

        Gtk.main ();

        return 0;
    }
}
