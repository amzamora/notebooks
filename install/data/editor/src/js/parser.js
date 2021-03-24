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
