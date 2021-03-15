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

public class MainWindow : Gtk.Window {
    public MainWindow () {
        // Headerbar
        var headerbar = new Gtk.HeaderBar();
        headerbar.title = "Notebooks";
        headerbar.set_decoration_layout("close:maximize");
        headerbar.show_close_button = true;

        var button = new Gtk.Button.from_icon_name("document-open", Gtk.IconSize.LARGE_TOOLBAR);
        headerbar.pack_end(button);
        this.set_titlebar(headerbar);

        // Main
        var editor = new Editor();

        var scrolled_window = new Gtk.ScrolledWindow(null, null);
        scrolled_window.expand = true;
        scrolled_window.add(editor);

        this.add(scrolled_window);

        // Actions
        button.clicked.connect (() => {
            var file_chooser = new Gtk.FileChooserNative (
               "Open some files",
               this,
               Gtk.FileChooserAction.OPEN,
               "Open",
               "Cancel"
           );
           var response = file_chooser.run ();
           file_chooser.destroy ();

           if (response == Gtk.ResponseType.ACCEPT) {
               string contents;
               GLib.FileUtils.get_contents (file_chooser.get_filename (), out contents);
               editor.set_markdown(contents);
           }
        });
    }
}
