public class Bank.Counter : Gtk.Overlay {
	public Gtk.Label points;
	public Gtk.Entry entry;
	public Gtk.Button plus;
	public Gtk.Button minus;
	public Gtk.LevelBar bar;

	private Gtk.CssProvider custom_css;

	public Counter (int lp, bool player1 = false) {
		bar = new Gtk.LevelBar.for_interval (0,lp);

		custom_css = new Gtk.CssProvider ();
		custom_css.load_from_data (RAW_CSS.replace ("COLOR_HERE", HIGH).replace ("ALIVE_COLOR", ALIVE), -1);
		bar.get_style_context ().add_provider (custom_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);

		bar.get_style_context ().remove_class ("level-high");
		bar.get_style_context ().add_class ("counter");

		points = new Gtk.Label (@"$lp");
		points.get_style_context ().add_class ("h1");
		points.expand = true;

		entry = new Gtk.Entry ();
		entry.get_style_context ().add_class ("h2");
		entry.activate.connect (() => {
			if (entry.get_text().contains ("@")) {
				reset (entry.get_text().replace ("@", "").to_int ());
				entry.text = "";
			} else if (entry.get_text().contains ("+")) {
				change_points (entry.get_text().replace ("+", ""));
				entry.text = "";
			} else {
				entry.text = entry.text.replace ("-", "");
				change_points("-" + entry.get_text ());
				entry.text = "";
			}
		});

		var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		hbox.get_style_context ().add_class ("linked");
		hbox.halign = Gtk.Align.CENTER;
		hbox.margin = 6;


		bar.orientation = Gtk.Orientation.VERTICAL;
		bar.set_inverted (true);
		bar.set_size_request (300,550);
		bar.set_value (lp);

		plus = new Gtk.Button.with_label (" + ");
		minus = new Gtk.Button.with_label (" - ");
		plus.get_style_context ().add_class ("h2");
		minus.get_style_context ().add_class ("h2");
		plus.can_focus = false;
		minus.can_focus = false;

		plus.clicked.connect (() => {
			change_points ("100");

		});

		minus.clicked.connect (() => {
			change_points ("-100");
		});

		if (!player1) {
			hbox.add (minus);
			hbox.add (entry);
			hbox.add (plus);
			add (bar);
		} else {
			hbox.add (plus);
			hbox.add (entry);
			hbox.add (minus);
			add (bar);
		}

		var grid = new Gtk.Grid ();
		add_overlay (grid);
		grid.show_all ();

		grid.orientation = Gtk.Orientation.VERTICAL;
		grid.add (hbox);
		grid.add (points);
		hexpand = true;
		vexpand = true;

		this.show_all ();
	}

	private string get_level (int persent) {

		persent = 100 - persent;
		if (persent >= 85) {
			return HIGH;
		} else if (persent >= 50) {
			return MEDIUM;
		} else if (persent >= 15) {
			return LOW;
		}

		else {
			return WARNING;
		}
	}

	private int get_persentage () {
		int current = int.parse (points.label);
		int persent = (int)(current * 100 / bar.max_value);

		if (persent > 100) persent = 100;
		if (persent < 0) persent = 0;

		return 100 - persent;
	}

	public void reset (int points) {
		bar.max_value = points;
		change_points ("-10000000");
		change_points (@"$points");
	}

	public void change_points (string change) {
		int delta = int.parse (change);
		int lp = int.parse (points.label);
		lp = lp + delta;

		points.label = lp.to_string ();

		string state = ALIVE;
		if (lp <= 0) {
			lp = 0;
			state = DEAD;
			points.label = lp.to_string ();
		}

		var persent = get_persentage ();
		string level = get_level (persent);
		bar.set_value (lp);

		custom_css = new Gtk.CssProvider ();
		custom_css.load_from_data (RAW_CSS.replace ("COLOR_HERE", level).replace ("ALIVE_COLOR", state), -1);
		bar.get_style_context ().add_provider (custom_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);
	}
}
