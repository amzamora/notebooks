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

public class Editor : WebKit.WebView {
    public Editor () {
        this.get_style_context ().add_class ("editor");
        this.load_html(html, "file:///");
    }

    public void set_text(string text) {

    }
}

const string html = """<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<script>
class Parser {
	static parse(text, cursor) {
		let output = "";

		// Replace conflicting characters
		text = text.replace(/&/g, '&amp;');
		text = text.replace(/</g, '&lt;');
		text = text.replace(/>/g, '&gt;');

		// Put cursor
		if (cursor === -1) {
			cursor = text.length;
		}
	 	text = this._putCursor(text, cursor);

		// Parse to html
		let index = {pos: 0};
		while (index.pos < text.length) {
			output += this._next_element(text, index);
		}

		return output;
	}

	static _next_element(text, index) {
		if (this._isHeader(text, index.pos)) {
			return this._getHeader(text, index);

		} else if (this._isList(text, index.pos)) {
			return this._getList(text, index);

		} else {
			return this._getParagraph(text, index);
		}
	}

	static _getHeader(text, index) {
		// Determine what type of header it is
		let i = 0;
		while (text[index.pos + i] === '#') {
			i++;
		}
		let header = `<span class="h${i}">`;

		// Get header content
		while (text[index.pos] !== '\n' && index.pos < text.length) {
			header += text[index.pos];
			index.pos += 1;
		}

		// Move until next element
		while (text[index.pos] === '\n') {
			index.pos += 1;
		}

		header += '</span>';

		return header;
	}

	static _getParagraph(text, index) {
		let paragraph = '<span class="paragraph">';

		// Get content
		while (index.pos < text.length) {
			if (text[index.pos] === '\n') {
				if (this._isNewElement(text, index)) {
					break;
				}
				paragraph += " ";
				index.pos += 1;
			}

			paragraph += text[index.pos];
			index.pos += 1;
		}

		paragraph += '</span>';

		// Move until next element
		while (text[index.pos] === '\n') {
			index.pos += 1;
		}

		return paragraph;
	}


	static _getList(text, index) {
		let list = '<ul>';

		// Get items
		index.pos += 2;
		let item = "";
		while (true) {
			if (index.pos >= text.length) {
				list += "<li>" + item + "</li>";
				break;
			}

			if (text[index.pos] === '\n') {
				if (this._isNewElement(text, index)) {
					list += "<li>" + item + "</li>";
					if (this._isList(text, index.pos + 1)) {
						index.pos += 3;
						item = "";
						continue;
					}
					else {
						break;
					}
				}
				item += " ";
				index.pos += 1;
			}

			// Get item
			item += text[index.pos];

			// Advance until new sub item
			index.pos += 1;
		}

		// Move until next element
		while (text[index.pos] === '\n') {
			index.pos += 1;
		}

		list += '</ul>';

		return list;
	}

	static _isNewElement(text, index) {
		if (text[index.pos + 1] === '\n' || this._isHeader(text, index.pos + 1) || this._isBlockquote(text, index.pos + 1) || this._isList(text, index.pos + 1)) {
			return true;
		} else {
			return false;
		}
	}

	static _isHeader(text, index) {
		if (index === 0 || text[index - 1] === '\n') {
			let i = index;
			while (text[i] === '#') {
				i++;
			}

			if (i !== index && text[i] === ' ' && i - index <= 3) {
				return true;
			} else {
				return false;
			}
		}
		return false;
	}

	static _isBlockquote(text, index) {
		if (index === 0 || text[index - 1] === '\n') {
			if (text[index] === '>' && text[index + 1] === ' ') {
				return true;
			} else {
				return false;
			}
		}
		return false;
	}

	static _isList(text, index) {
		if (index === 0 || text[index - 1] === '\n') {
			if (text[index] === '-' && text[index + 1] === ' ') {
				return true;
			} else {
				return false;
			}
		}
		return false;
	}

	static moveCursorLeft(editor) {
		let cursor = document.getElementsByClassName("cursor")[0];
		console.dir(cursor);
	}

	static moveCursorRight() {

	}

	static delete() {

	}

	static insert(str) {

	}

	static _equivalentOffsetOnHtml(offset, html) {
		let state = {
			offset: 0,
			equivalent: 0,
			tagOpened: false,
			conflictingCharOpened: false
		}

		while (true) {
			// Check end conditions
			if (state.equivalent >= html.length) {
				break;
			}

			if (state.offset === offset && state.tagOpened !== true && state.conflictingCharOpened !== true && html[state.equivalent] !== '<') {
				break;
			}

			// Advance state
			if (html[state.equivalent] === '<') {
				state.tagOpened = true;
				state.equivalent += 1;

			} else if (html[state.equivalent] === '>') {
				state.tagOpened = false;
				state.equivalent += 1;

			} else if (html[state.equivalent] === '&') {
				state.conflictingCharOpened = true;
				state.equivalent += 1;

			} else if (state.conflictingCharOpened === true && html[state.equivalent] === ';') {
				state.conflictingCharOpened = false;
				state.equivalent += 1;
				state.offset += 1;

			} else if (state.tagOpened === true) {
				state.equivalent += 1;

			} else if (state.conflictingCharOpened === true) {
				state.equivalent += 1;

			} else {
				state.offset += 1;
				state.equivalent += 1;
			}
		}

		return state.equivalent;
	}

	static _putCursor(text, cursor) {
		function isWhiteSpace(char) {
			return char === ' ' || char === '\n' || char === '<' || char === '>'
		}

		let offset = this._equivalentOffsetOnHtml(cursor, text);

		let aux1 = offset - 1;
		while (!isWhiteSpace(text[aux1])) {
			if (aux1 < 1) {
				aux1 = 0;
				break;
			}
			aux1 -= 1;
		}
		if (aux1 !== 0) {aux1 += 1}

		let aux2 = offset;
		while (!isWhiteSpace(text[aux2]) && aux2 < text.length) {
			if (aux2 > text.length) {
				aux2 = text.ength;
				break;
			}
			aux2 += 1;
		}

		return text.substr(0, aux1) + '<nobr>' + text.substring(aux1, offset) + '<cursor class="cursor"></cursor>' + text.substring(offset, aux2) + '</nobr>' + text.substr(aux2);
	}
}
</script>
		<script>
class NotebooksEditor {
	constructor (anchor) {
		// Initialize editor
		this.editor = document.getElementById(anchor);
		this.editor.classList.add('NotebooksEditor');
		this.editor.innerHTML = '';

		// Attach callbacks to manage input
		this.input = Input(this.editor);
		let self = this;
		this.input.addEventListener('keyboard-input', function(e) {
			self._onKeyboardInput(e);
		});
		this.editor.addEventListener('click', function(e) {
			self._onClick(e);
		});
	}

	setText(text, cursor = -1) {
		this.editor.innerHTML = Parser.parse(text, cursor);
	}

	setFontSize(new_size) {

	}

	// Callbacks
	// =========

	_onKeyboardInput(e) {
		switch (e.value) {
			case 'left-key':
				Parser.moveCursorLeft(this.editor);
				break;

			case 'right-key':
				Parser.moveRight();
				break;

			case 'up-key':
				break;

			case 'down-key':
				break;

			case 'deletion':
				Parser.delete();
				break;

			default:
				// Insertion
				if (e.value.length === 1) {
					Parser.insert(e.value);
				}
				break;
		}
	}

	_onClick(e) {
		this.input.focus();
	}
}

// Generates an input box on the editor
function Input(editor) {
	let input = document.createElement('input');
	input.setAttribute('type', 'text');
	input.classList.add('notebooks-editor-input');
	editor.parentElement.appendChild (input);

	// Listen for keypresses
	document.addEventListener('keydown', function(e) {
		if (input === document.activeElement) {
			let aux = new CustomEvent('keyboard-input');

			if (e.keyCode == 37) {
				aux.value = 'left-key';
				input.dispatchEvent(aux);

			} else if (e.keyCode == 39) {
				aux.value = 'right-key';
				input.dispatchEvent(aux);

			} else if (e.keyCode == 38) {
				aux.value = 'up-key';
				input.dispatchEvent(aux);

			} else if (e.keyCode == 40) {
				aux.value = 'down-key';
				input.dispatchEvent(aux);

			} else if (e.keyCode == 8){
				aux.value = 'deletion';
				input.dispatchEvent(aux);

			} else if (e.keyCode == 13) {
				aux.value = '\n';
				input.dispatchEvent(aux);
			}
		}
	});

	// Listen for input
	input.addEventListener('input', function (e) {
			let aux = new CustomEvent('keyboard-input');
			aux.value = input.value;

			// Reset input box
			input.value = '';

			// Check for deleteContentBackward
			if (e.inputType !== 'deleteContentBackward') {
				input.dispatchEvent(aux);
			}
	});

	return input;
}
</script>
		<style>
/* Cursor
   ====== */

.NotebooksEditor {
	position: relative;
	overflow: auto;
	white-space: pre-wrap;
}

.cursor {
	height: 1.2em;
	border-left: 1px solid transparent; /* Why it does not work without it?*/
	position: absolute;
	animation: blink 0.6s step-start infinite alternate;
}

@keyframes blink {
	50% {border-left: 1px solid #333;}
	100% {border-left: 1px solid transparent;}
}
</style>
		<style>
/* Block elements */
.h1,
.h2,
.h3,
.paragraph,
.blockquote {
	display: block;
	white-space: pre-wrap;
	margin-bottom: 0.4em;
}

.h1 {
	font-weight: bold;
	font-size: x-large;
}

.h2 {
	font-weight: bold;
	font-size: large;
}

.h3 {
	font-weight: bold;
}

.blockquote {
	padding: 10px;
	border-left: 2px solid grey;
}

/* Inline elements */
.notation {
	color: gray;
}

bold {
	font-weight: bold;
}
</style>
		<style>
			* {
				box-sizing: border-box;
			}

			html, body {
				margin: 0;
				padding: 0;
				width: 100%;
				height: 100%;
				overflow: hidden;
			}

			#editor {
				padding-left: 15px;
				width: 100%;
				height: 100%;
				font-family: 'Inter var', sans-serif;
			}
		</style>
	</head>
	<body>
		<pre id="editor"></pre>
		<script>
			let editor = new NotebooksEditor('editor');
			editor.setText("# Hello editor!\nThis is a pragraph! And also is very very very very very very very very\n- very very\n- very long!\n\n- Yeah!\n- Yep\n- And yes");
			//editor.setText("# Header 1\nHello, world!");
		</script>
	</body>
</html>
""";
