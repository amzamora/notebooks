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
