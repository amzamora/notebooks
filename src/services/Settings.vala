class Settings : Granite.Services.Settings {
	public int pos_x { get; set; }
	public int pos_y { get; set; }
	public int window_width { get; set; }
	public int window_height { get; set; }
	public int last_note_selected { get; set; }

	private static Settings? instance;
	public static unowned Settings get_default () {
		if (instance == null) {
			instance = new Settings ();
		}

		return instance;
	}

	private Settings () {
		base ("com.github.amzamora.notebooks");
	}
}
