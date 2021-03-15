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

public class Notebooks : Gtk.Application {
    public Notebooks () {
        Object (
            application_id: "com.github.amzamora.notebooks",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        // Start app and restore
        var main_window = new MainWindow ();
        restore (main_window);

        // Save state when app closed
        main_window.delete_event.connect (() => {
            save (main_window);
            return false;
        });

        // Provide custom css
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/amzamora/notebooks/custom.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        main_window.show_all ();
        this.add_window (main_window);
    }

    public void restore (MainWindow window) {
        // Restore position
        var pos_x = Settings.get_instance().pos_x;
        var pos_y = Settings.get_instance().pos_y;

        if (pos_x != -1 || pos_y != -1) {
            window.move (pos_x, pos_y);
        }

        // Restore size
        window.resize (Settings.get_instance().window_width, Settings.get_instance().window_height);
    }

    public void save (MainWindow window) {
        // Save position
        int x, y;
        window.get_position (out x, out y);
        Settings.get_instance().pos_x = x;
        Settings.get_instance().pos_y = y;

        // Save size
        int width, height;
        window.get_size (out width, out height);
        Settings.get_instance().window_width = width;
        Settings.get_instance().window_height = height;

        // Save las note selected
        //window.save_current_note ();
        //settings.last_note_selected = window.get_note_id ();
    }

    public static int main(string[] args) {
        return new Notebooks().run (args);
    }
}
