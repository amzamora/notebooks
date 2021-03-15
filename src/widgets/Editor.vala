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

public class Editor : Gtk.Box {
    public Editor () {
        this.orientation = Gtk.Orientation.VERTICAL;
        this.spacing = 10;
        this.add (new Gtk.Label ("Paragraph 1"));
        this.add (new Gtk.Label ("Paragraph 2"));
        this.add (new Gtk.Label ("Paragraph 3"));
    }

    public void set_markdown (string markdown) {
        // Remove all children
        this.remove_all_children();

        // Put elements
        int pos = 0;
        while (pos < markdown.length) {
            var elem = this.get_next_element(markdown, ref pos);
            this.add (elem);
        }

        // Show
        this.show_all();
    }

    private void remove_all_children() {
        var children = this.get_children();
        foreach (var child in children) {
            this.remove(child);
        }
    }

    private Gtk.Widget get_next_element(string markdown, ref int pos) {
        if (this.is_header(markdown, pos)) {
            return this.get_header(markdown, ref pos);
        }
        else {
            return this.get_paragraph(markdown, ref pos);
        }
    }

    private Gtk.Widget get_paragraph(string markdown, ref int pos) {
        var content = new StringBuilder();

        // Get paragraph
        while (pos < markdown.length) {
            if (markdown[pos] == '\n') {
                if (this.is_new_element(markdown, pos)) {
                    break;
                }
                content.append_c(' ');
                pos += 1;
            }

            content.append_c(markdown[pos]);
            pos += 1;
        }

        // Move until next element
        while (markdown[pos] == '\n') {
            pos += 1;
        }

        // Make paragraph
        var paragraph = new Gtk.Label(content.str);
        paragraph.halign = Gtk.Align.START;
        paragraph.wrap = true;
        paragraph.xalign = 0;

        return paragraph;
    }

    private Gtk.Widget get_header(string markdown, ref int pos) {
        // Determine type of header
        int i = 0;
        while (markdown[i] == '#') {
            i += 1;
        }

        // Get header content
        var content = new StringBuilder();
        while (markdown[pos] != '\n' && pos < markdown.length) {
            content.append_c(markdown[pos]);
            pos += 1;
        }

        // Move until next element
        while (markdown[pos] == '\n') {
            pos += 1;
        }

        // Make header
        var header = new Gtk.Label(content.str);
        header.halign = Gtk.Align.START;
        header.wrap = true;
        header.xalign = 0;

        if      (i == 1) header.get_style_context().add_class(Granite.STYLE_CLASS_H1_LABEL);
        else if (i == 2) header.get_style_context().add_class(Granite.STYLE_CLASS_H2_LABEL);
        else if (i == 3) header.get_style_context().add_class(Granite.STYLE_CLASS_H3_LABEL);
        else if (i == 4) header.get_style_context().add_class(Granite.STYLE_CLASS_H4_LABEL);
        return header;
    }

    private bool is_new_element(string markdown, int pos) {
        if (markdown[pos + 1] == '\n') {
            return true;
        }
        else {
            return false;
        }
    }

    private bool is_header(string markdown, int pos) {
        if (pos == 0 || markdown[pos - 1] == '\n') {
            int i = 0;
            while (markdown[pos + i] == '#') {
                i += 1;
            }

            if (i != 0 && markdown[i] == ' ' && i <= 4) {
                return true;
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }
}
