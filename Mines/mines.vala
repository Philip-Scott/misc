using Gtk;
using Math;
using Granite.Services;

namespace Mines {
public HeaderBar headerbar;
public ToolButton refresh_button; 
public Switch flag_mode;
public fint total_mines;
public fint total_flags;
public fint correct_flags;
public bool lost;

public class Mine : Button {
	public bool uncovered;
	public bool is_mine;
	public bool flaged;
	public int adjacent;
	public int posW;
	public int posH;
	public signal void im_zero (int a, int b);
	
	public void reset (bool mine) {
		this.label = @"    ";
		this.flaged = false;
		this.is_mine = mine;
		this.set_sensitive (true);
		this.get_style_context ().remove_class (@"flaged");
		this.get_style_context ().remove_class (@"mine");
		this.get_style_context ().remove_class (@"victory");
		this.get_style_context ().remove_class ("bomb");
		this.get_style_context ().add_class ("h2");
		this.get_style_context ().add_class ("no");
			
	}
	
	public Mine (bool mine, Field field, int posH_, int posW_) {
		flaged = false;
		is_mine = mine;
		posW = posW_;
		posH = posH_;
		can_focus = false;
		this.label = @"    ";
		this.get_style_context ().add_class ("h2");
		this.get_style_context ().add_class ("no");
		this.clicked.connect (() => {
			if (flag_mode.active && uncovered == false) { //FlagMode
				if (flaged) {
					flaged = false;
					this.get_style_context ().remove_class (@"flaged");
					if (is_mine) correct_flags.modify (-1);
					total_flags.modify (-1);
				} else {
					flaged = true;
					this.get_style_context ().add_class (@"flaged");
					if (is_mine) correct_flags.modify (1);
					total_flags.modify (1);
				}
			} else if (flaged == false) { //uncover mode
				if (is_mine) {
					this.get_style_context ().add_class (@"bomb");
					this.set_sensitive (false);
					lost = true;
					field.boom ();
					this.label = "☠";
				}
				else {
					this.uncovered = true;
					if (adjacent != 0) this.label = @"$adjacent";
					else {	
						im_zero (posH, posW);
						this.set_sensitive (false);
					}
					this.get_style_context ().add_class (@"m$adjacent");				
				}
			}
		});
		field.victory.connect (() => {
			if (is_mine) {
				this.label = "✓";
				this.uncovered = true;
				this.get_style_context ().add_class (@"mine");
				this.get_style_context ().add_class (@"victory");
			}
			else reveal ();
		});
		
		field.boom.connect (() => {
			if (is_mine) {
				this.get_style_context ().remove_class ("h2");
				this.get_style_context ().remove_class ("no");
				this.get_style_context ().add_class (@"bomb");
				this.set_sensitive (false);
				this.label = "💣";
			}
			else reveal (true);
		});
	}
	
	public void reveal (bool boom = false) {
		if (uncovered == false) {
			this.uncovered = true;
			if (boom == true) this.set_sensitive (false);
			else this.get_style_context ().add_class (@"m$adjacent");
			
			if (adjacent != 0) this.label = @"$adjacent";
			else {	
				im_zero (posH, posW);
				this.set_sensitive (false);
			}
			if (flaged) {
				flaged = false;
				this.get_style_context ().remove_class (@"flaged");
				total_flags.modify (-1);
			}
				
		}
	}
	
	public void set_adjacent (int a) {
		this.adjacent = a;
	} 
}

public class Field : Grid {
	public int width;
	public int height;
	public int i;
	public int j;
	public int adjacent;
	public 	bool is_mine;
	public int[,] mine_field;
	public Mine[,] mine;
	public signal void boom ();
	public signal void victory ();
	
	public Field (int h, int w) {
		width = w;
		height = h;
		set_row_spacing (0);
		set_column_spacing (0);
		set_row_homogeneous  (true);
		set_column_homogeneous (true);
		
		int i,j, adjacent;
		bool is_mine;
		lost = false;
		
		total_mines.val = 0;
		total_flags.val = 0;
		mine_field = new int[40,40];
		mine = new Mine[40,40];
		
		total_flags.changed.connect (() => {
			if (correct_flags.val == total_mines.val && total_flags.val == total_mines.val) this.victory ();
		});
		
		refresh_button.clicked.connect (() => {
			this.reset ();	
		});
	}	
	
	public void reset () {
		total_mines.val = 0;
		total_flags.val = 0;
		correct_flags.val = 0;
		lost = false;	
		for (i = 0; i < height; i++) { 
		for (j = 0; j < width; j++) {
			mine_field [i,j] = 0;
			this.remove (mine[i,j]);
			mine[i,j].destroy ();
		}}
		
		this.mine = new Mine[40,40];
		for (i = 0; i < height; i++) { 
		for (j = 0; j < width; j++) {
			is_mine = Random.boolean ();
			if (is_mine == true) is_mine = Random.boolean ();
			if (is_mine == true) is_mine = Random.boolean ();
			//if (is_mine == true) is_mine = Random.boolean (); 
						
			if (is_mine == true) total_mines.modify (1);
			mine[i,j] = new Mine (is_mine, this, i, j); 
			this.attach (mine[i,j], j, i, 1, 1);
			
			if (is_mine) mine_field [i,j] = 1;
			else mine_field [i,j] = 0;
		}}
		setup_mines ();
		show_all ();
		headerbar.subtitle = @"Mines Hidden: $(total_mines.val)    |     Flags Placed: $(total_flags.val)";
	}
	
	public void setup_mines () {
		//SetAdjacent value 
		for (i = 0; i < height; i++) { 
		for (j = 0; j < width; j++) {
			if (mine[i,j].is_mine) continue;
			adjacent = 0;
			if (i - 1 >= 0 && j - 1 >= 0) 			if (mine_field[i - 1,j - 1] == 1) 	adjacent++;	
			if (i - 1 >= 0) 						if (mine_field[i - 1,j] == 1) 		adjacent++; 		
			if (i - 1 >= 0 && j + 1 < width)		if (mine_field[i - 1,j + 1] == 1) 	adjacent++; 	
			if (j - 1 >= 0) 						if (mine_field[i,j - 1] == 1) 		adjacent++; 		
			if (j + 1 < width) 						if (mine_field[i,j + 1] == 1) 		adjacent++; 	
			if (i + 1 < height && j - 1 >= 0) 		if (mine_field[i + 1,j - 1] == 1) 	adjacent++; 	
			if (i + 1 < height) 					if (mine_field[i + 1,j] == 1) 		adjacent++; 
			if (i + 1 < height && j + 1 < width)	if (mine_field[i + 1,j + 1] == 1) 	adjacent++; 
			mine[i,j].set_adjacent (adjacent);
		}}
		
		for (i = 0; i < height; i++) { 
		for (j = 0; j < width; j++) {
			if (mine[i,j].adjacent == 0) { 
				mine[i,j].im_zero.connect ((a,b) => {
					if (a - 1 >= 0 && b - 1 >= 0 && lost == false) 			mine[a - 1,b - 1].reveal();
					if (a - 1 >= 0 && lost == false) 						mine [a - 1,b].reveal();
					if (a - 1 >= 0 && b + 1 < width && lost == false)		mine [a - 1,b + 1].reveal();
					if (b - 1 >= 0 && lost == false) 						mine [a,b - 1].reveal(); 
					if (b + 1 < width && lost == false) 					mine [a,b + 1].reveal(); 
					if (a + 1 < height && b - 1 >= 0 && lost == false) 		mine [a + 1,b - 1].reveal(); 	
					if (a + 1 < height && lost == false) 					mine [a + 1,b].reveal();  
					if (a + 1 < height && b + 1 < width && lost == false)	mine [a + 1,b + 1].reveal(); 
				});
			}
		}} 
	}
	
	public void populate () {		
		//Set mines
		for (i = 0; i < height; i++) { 
		for (j = 0; j < width; j++) {
			is_mine = Random.boolean ();
			if (is_mine == true) is_mine = Random.boolean ();
			if (is_mine == true) is_mine = Random.boolean ();
			if (is_mine == true) is_mine = Random.boolean ();
			
			
			if (is_mine == true) total_mines.modify (1);
			mine[i,j] = new Mine (is_mine, this, i, j); 
			this.attach (mine[i,j], j, i, 1, 1);
			
			if (is_mine) mine_field [i,j] = 1;
			else mine_field [i,j] = 0;
		}}
				
		setup_mines ();
		
		
	}
}
public class fint : Object {
	public int val;
	public void modify (int a) {
		val = val + a ;
		changed ();
	}		
	public signal void changed ();
	public fint () {
		
	}
	
}

public class App : Gtk.Window {
	int h;
	int w;
	public App () {
		correct_flags = new fint ();
		total_mines = new fint ();
		total_flags = new fint ();
		
		headerbar = new HeaderBar ();
		headerbar.title = "Minesweeper";
		headerbar.set_decoration_layout ("close");
 		headerbar.show_close_button = true;
		this.set_titlebar (headerbar);
		var variables = new Granite.Services.Paths ();
		variables.initialize ("Mines", "/dev/null");
		var new_mines = new SimpleCommand (@"/home/felipe/code/mines", "./mines");
		
		total_flags.changed.connect (() => {
			headerbar.subtitle = @"Mines Hidden: $(total_mines.val)    |     Flags Placed: $(total_flags.val)";
			if (correct_flags.val == total_mines.val && total_flags.val == total_mines.val) headerbar.subtitle = "Victory!!!";
		});

		flag_mode = new Switch ();
		flag_mode.set_can_focus (true);
		flag_mode.grab_focus ();
		flag_mode.set_tooltip_text ("Flag Mode");
		
		refresh_button = new ToolButton.from_stock (Gtk.Stock.REFRESH);
		
		
		
		var custom_css = new CssProvider ();
		var css_file = "/home/felipe/mines/custom.css";
		custom_css.load_from_path (css_file);
		Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), custom_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		this.destroy.connect(Gtk.main_quit);
		set_border_width (8);		
		
		this.add (new_game_box ());
	}
	public Grid new_game_box () {
 		var grid = new Grid ();
 		grid.set_orientation (Orientation.VERTICAL);
		grid.add (block_slider ("Rows", 8));
		grid.add (block_slider ("Columns", 13));
		grid.set_row_spacing (4);
		grid.set_column_spacing (4);
		grid.set_row_homogeneous  (true);
		grid.set_column_homogeneous (true);
		var start_button = new Button.with_label ("New Game");
		grid.add (start_button);
			
		start_button.clicked.connect (() => {
		 	new_game (w,h);
		});	
		
		return grid;
	}
	public HBox block_slider (string name, int start = 12) {
		int type;
		var box = new HBox (true, 8);
		var values = new Adjustment (start, 5, 40, 1, 1, 1);            
        var bar = new Scale (Orientation.HORIZONTAL, values);
        var label = new Label (@"$name: ");
       	label.xalign = 0;
		if (name == "Rows") type = 1;
		else type = 0;
		
		bar.value_changed.connect (() => {
			if (type == 1) w = (int) bar.get_value ();
			else h = (int) bar.get_value ();
			label.set_label (@"$name:  $((int) bar.get_value ())");
		});
		bar.value_changed ();
        bar.set_draw_value (false);
        bar.set_digits (0);
        box.add (label);
        box.add (bar);
        
        return box;
	}
	
	public Field new_game (int w, int h) {
		headerbar.pack_end (flag_mode);
		headerbar.pack_end (refresh_button);
		this.remove (this.get_child());
		
		headerbar.subtitle = @"Mines Hidden: $(w)    |     Flags Placed: $(h)";
		var field_ = new Field (w,h);		
		field_.populate ();
		this.add (field_);
		this.show_all ();
		return field_;
	}
}

public static int main(string[] args) {
    Gtk.init(ref args);
	var app = new App();
	
	app.show_all ();
	Gtk.main();
    return 0;
}

}
