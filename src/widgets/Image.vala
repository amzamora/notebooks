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

public class Image : WebKit.WebView {
    private int width = 0;
    private int height = 0;

    private const int IMAGE_LOADER_BUFFER_SIZE = 8192;
    private bool image_size_loaded = false;

    public Image(string path) {
        this.halign = Gtk.Align.CENTER;

        // Set image uri and html
        var before = """
            <!doctype html>
            <html>
            <head>
            <meta charset='UTF-8'><meta name='viewport' content='width=device-width initial-scale=1'>
            <style>
                html,
                body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                }

                img {
                    display: block;
                    /* width: 100%; */
                }
            </style>
            </head>
            <body>
        """;
        var middle = @"<img async src=\"$path\" referrerpolicy=\"no-referrer\">";
        var after = """
            </body>
            </html>
        """;
        this.load_html(before + middle + after, "file:///");

        // Get image resolution
        this.load_resolution.begin(path);
    }

    // from: https://github.com/elementary/files/blob/615b76d9ba8414f5c108057e1c7cdd70e243c130/src/View/Widgets/OverlayBar.vala
    private async void load_resolution (string path) {
        var file = File.new_for_path(path);

        try {
            Cancellable? cancellable = null;
            var stream = yield file.read_async (0, cancellable);
            if (stream == null) {
                error ("Could not read image file's size data");
            }
            var loader = new Gdk.PixbufLoader.with_mime_type(file.query_info ("*", 0).get_content_type ().to_string ());
            loader.size_prepared.connect ((width, height) => {
                this.image_size_loaded = true;
                this.height_request = height;
                this.width_request = width;
            });

            cancellable.cancel ();
            cancellable = new Cancellable ();

            yield read_image_stream (loader, stream, cancellable);

            // Gdk wants us to always close the loader, so we are nice to it
            try {
                stream.close ();
            } catch (GLib.Error e) {
                debug ("Error closing stream in load resolution: %s", e.message);
            }
            try {
                loader.close ();
            } catch (GLib.Error e) { /* Errors expected because may not load whole image */
                debug ("Error closing loader in load resolution: %s", e.message);
            }

        } catch (Error e) {
            warning ("Error loading image resolution in OverlayBar: %s", e.message);
        }
    }

    private async void read_image_stream (Gdk.PixbufLoader loader, FileInputStream stream, Cancellable cancellable) {
        uint8 [] buffer = new uint8[IMAGE_LOADER_BUFFER_SIZE];
        ssize_t read = 1;
        uint count = 0;
        while (!image_size_loaded && read > 0 && !cancellable.is_cancelled ()) {
            try {
                read = yield stream.read_async (buffer, 0, cancellable);
                count++;
                if (count > 100) {
                    this.width = -1;
                    this.height = -1;
                    break;
                }

                loader.write (buffer);

            } catch (IOError e) {
                if (!(e is IOError.CANCELLED)) {
                    warning (e.message);
                }
            } catch (Gdk.PixbufError e) {
                /* errors while loading are expected, we only need to know the size */
            } catch (FileError e) {
                warning (e.message);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}
