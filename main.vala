using Gtk;
using Gdk;
using Cairo;

public class AnimationExample : Gtk.Window {

    // the global surface that will serve as our buffer
    private Cairo.Surface? surface;

    private int oldw;
    private int oldh;

    private int i_draw;

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

    private bool on_draw (Gtk.Widget sender, Cairo.Context cr) {
        cr.set_source_surface(this.surface, 0, 0);
        cr.paint();
        return false;
    }

    private bool on_configure_event (Gtk.Widget sender, Gdk.EventConfigure event) {
        // create our new surface with the correct size.
        var tmpsurface = sender.get_window().create_similar_surface (Cairo.Content.COLOR,
                                                                     event.width,
                                                                     event.height);
        // set up our surface so it is ready for drawing
        if (this.surface != null && (this.oldw != event.width || this.oldh != event.height)) {
            // copy the contents of the old surface to the new surface.
            var cr = new Cairo.Context (tmpsurface);
            cr.set_source_surface (this.surface, 0, 0);
            cr.paint ();
        }
        this.surface = tmpsurface;
        this.oldw = event.width;
        this.oldh = event.height;
        return true;
    }

    // do_draw will be executed whenever we would like to update our animation
    private void do_draw () {
        //create a gtk-independant surface to draw on
        var cr = new Cairo.Context (this.surface);

        this.i_draw += 4;   // give movement to our animation
        this.i_draw %= this.oldw;
        cr.set_source_rgb (0.9, 0.9, 0.9);
        cr.paint ();
        cr.set_source_rgb ((double) this.i_draw / this.oldw,
                           (double) this.i_draw / this.oldw,
                           1.0 - (double) this.i_draw / this.oldw);
        cr.rectangle ((double) this.i_draw, (double) this.oldh / 2.0, 100, 100); 
        cr.stroke ();

        // tell our window it is time to draw our animation.
        this.queue_draw ();
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
