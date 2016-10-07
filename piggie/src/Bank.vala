namespace Bank {

/*
	To compile: valac --pkg gio-2.0 --pkg gtk+-3.0 Bank.vala && ./Bank
*/

public const string HIGH 	 = "#C8EFFC";
public const string MEDIUM   = "#8EFF99";
public const string LOW		 = "#FFF58C";
public const string WARNING  = "#FF727E";
public const string ALIVE	 = "#ffffff";
public const string DEAD	 = "#EEEEEE";
public const string RAW_CSS  = """
.level-bar {
	transition: all 300ms ease-in;
}
.level-bar.fill-block.level-high {
    background-image: linear-gradient(to bottom,
                                  shade (COLOR_HERE, 1.10),
                                  COLOR_HERE
                                  );
    transition: all 1000ms ease-in;
    border: 1px solid shade (COLOR_HERE, 0.90);
}
.level-bar.fill-block.empty-fill-block {
    background-color: shade (ALIVE_COLOR, 1);
    background-image: linear-gradient(to bottom,
                                  shade (ALIVE_COLOR, 1),
                                  shade (ALIVE_COLOR, .95)
                                  );
    border-color: alpha (#000, 0.25);
    box-shadow: inset 0 0 0 1px alpha (@bg_highlight_color, 0.05),
                inset 0 1px 0 0 alpha (@bg_highlight_color, 0.45),
                inset 0 -1px 0 0 alpha (@bg_highlight_color, 0.15),
                0 1px 0 0 alpha (@bg_highlight_color, 0.15);
}
""";

public class MyApp : Gtk.Window {
	public Counter counter;

	public int current;
	public int max;

	public MyApp () {
		var headerbar = new Gtk.HeaderBar ();
		var grid = new Gtk.Grid ();
		var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

		grid.orientation = Gtk.Orientation.HORIZONTAL;
		headerbar.show_close_button = true;

		var settings = new GLib.Settings ("org.piggie.bank");
		max = settings.get_int ("goal");

		current = settings.get_int ("cash");

		counter = new Counter (max, true);
		counter.change_points ("-10000000");
		counter.change_points (@"$current");

		grid.add (counter);

		this.set_titlebar (headerbar);
		this.add (grid);
		this.show_all ();
	}

	public static int main (string[] args) {
		Gtk.init(ref args);

		var app = new MyApp ();
		app.title = "Piggie";
		app.set_icon_name ("Piggie");
		app.set_startup_id ("Piggie");

		app.destroy.connect (() => {
			var settings = new GLib.Settings ("org.piggie.bank");

			app.current = int.parse (app.counter.points.label);

		    settings.set_int ("goal", app.current > app.max? app.current : app.max);
			settings.set_int ("cash", app.current);

			Gtk.main_quit ();
		});

		Gtk.main();
		return 0;
	}
}
}
