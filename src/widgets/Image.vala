/*
* Copyright (c) 2021 Alonso Zamorano (https://github.com/amzamora)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class Image : Gtk.Grid {
    private Gdk.PixbufAnimation animated_image;
    private Gdk.PixbufAnimationIter iter;
    private Gtk.DrawingArea drawing_area;

    public Image(string file) {
        this.animated_image = new Gdk.PixbufAnimation.from_file(file);
        TimeVal time = TimeVal();
        time.get_current_time();
        this.iter = this.animated_image.get_iter(time);

        this.drawing_area = new Gtk.DrawingArea();
        this.drawing_area.hexpand = true;
        this.drawing_area.vexpand = true;
        this.drawing_area.draw.connect (draw_image);

        this.attach(drawing_area, 0, 0, 1, 1);
        this.vexpand = false;
        this.height_request = this.iter.get_pixbuf().height;
    }

    private bool draw_image(Cairo.Context cr) {
        var image = this.iter.get_pixbuf();
        var width = this.drawing_area.get_allocated_width();
        var height = (int) (width * (((double) image.height) / image.width));
        this.height_request = height;
        var x = 0;
        var y = 0;
        var temp_image = image.scale_simple(width, height, Gdk.InterpType.BILINEAR);
        this.draw_rounded_path(cr, x, y, width, height, 5);
        Gdk.cairo_set_source_pixbuf(cr, temp_image, x, y);
        cr.clip();
        cr.paint();

        Timeout.add(this.iter.get_delay_time(), () => {
            TimeVal time = TimeVal();
            time.get_current_time();
            this.iter.advance(time);
            this.drawing_area.queue_draw_area(x, y, width, height);
            return false;
        });

        return false;
    }

    // From: https://stackoverflow.com/a/4231963
    private void draw_rounded_path(Cairo.Context ctx, double x, double y, double width, double height, double radius) {
        double degrees = 3.14 / 180.0;

        ctx.new_sub_path();
        ctx.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
        ctx.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
        ctx.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
        ctx.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
        ctx.close_path();
    }
}
