using GLib;
using Gtk;

//  valac --pkg gtk+-3.0 logica.vala resolution.vala solver.vala && ./logica
//	sudo cp org.felipe.logic*.xml /usr/share/glib-2.0/schemas/
//	sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
//
//TODO:
//		Alternate solver
namespace ProyectoDeLogica {
	public GLib.Settings settings;
	Switch formula_toggle;
	Entry formula;
	Entry formula2;
	string originalfi;
	string originaloverride;
	Label formula_label;
	Label override_label;
	Box box;
	Box mainbox;
	Window app;
	Solver solver_box;
	HeaderBar headerbar;
	Grid grid;
	const unichar letter[] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z', '1','0'};
	Letters A; Letters B; Letters C; Letters D; Letters E; Letters F; Letters G; Letters H; Letters I; Letters J;
	Letters K; Letters L; Letters M; Letters N; Letters O; Letters P; Letters Q; Letters R; Letters S; Letters T;
	Letters U; Letters V; Letters W; Letters X; Letters Y; Letters Z;

public class Logic : Gtk.Window {
	public bool formula_focus = false;
	public int formula_valid = 0;
	public bool simplify_type = false;
	public bool dont_exit = true;

	public signal void Check ();
	public signal void GoodFormula ();

	public override bool delete_event (Gdk.EventAny event) {
		//TODO Save state on exit
		settings.set_string (@"formula0", @"$(formula.text)");
		settings.set_string (@"formula1", @"$(formula2.text)");
		this.destroy ();
		return dont_exit;
	}

	public string? final_check (string fi) {
		string test;
		if (fi.contains ("X,X")) test = fi.replace ("X,X", "X");
		else test = fi;

		if (test == "X") {GoodFormula (); return test;}
		if (fi == test) return test;
		else return final_check(test);
	}

	public string? check_formula (string fi) {
		if (fi == "T" || fi == "" || fi == "&" || fi == "X)" || fi == "(X" ) return null;
		if (fi.contains ("(&") || fi.contains ("&)")) return null;

		string formula_new = remove_extrapars (fi.replace ("(X&X)", "X"));
		if (formula_new != fi) check_formula (formula_new);
		return final_check(fi);
	}

	public string simplify_formula (string fi) { //Used to simplify the formula checks
		unichar c;
		bool modified = false;
		var builder 	  =	new StringBuilder ();
		var builder_final =	new StringBuilder ();
		for (int i = 0; fi.get_next_char (ref i, out c);) { //Replace formula with Xs and &s
			switch (c) {
				case 'A': case 'B': case 'C': case 'D':	case 'E':	case 'F':	case 'G':	case 'H':
				case 'I': case 'J': case 'K': case 'L':
				case 'M': case 'N': case 'O': case 'P':	case 'Q':
				case 'R': case 'S': case 'T': case 'U': case 'V':
				case 'W': case 'X':
				case 'Y': case 'Z': case '1': case '0':
				case '◻':
					c = 'X';
					break;
				case '|': case '⇒': case '⇔': case '⇓': case '⇑': case '^':
					c = '&';
					break;
				case '[': case '{':
					c = '(';
					break;
				case ']': case '}':
					c = ')';
					break;
			}
			builder.append_unichar (c);
		}
		if  (builder.str.contains (")!")) return builder.str;
		string builded = builder.str;


		if (fi == builded) return remove_extrapars (builded);
		else return simplify_formula(builded);
	}

	public string remove_extrapars (string fi) {
		string test;

		if (fi.contains ("!(X)")) test = fi.replace ("!(X)", "X");
		else if (fi.contains ("!X")) test = fi.replace ("!X", "X");
		else if (fi.contains ("(X)")) test = fi.replace ("(X)", "X");
		else if (fi.contains ("((X&X))")) test = fi.replace ("((X&X))", "(X&X)");

		//else if (fi.contains ("!")) test = fi.replace ("!", "");
	 	else test = fi;
		//stdout.printf (@"$test\n"); // DEBUG Code

		if (test == fi)  return test;
		else return remove_extrapars (test);
	}

	public string remove_spaces (string fi) {
		unichar c;
		var builder = new StringBuilder ();

		for (int i = 0; fi.get_next_char (ref i, out c);) {
			if (c != ' ') builder.append_unichar (c);
		}

		return builder.str;
	}
	public string add_spaces (string fi, int a = 0) {
		string nfi;
		
		if (fi.contains ("&") && a == 0) nfi = fi.replace ("&"," & ");
		else if  (fi.contains ("|") && a == 1) nfi = fi.replace ("|"," | ");
		else if (fi.contains ("⇒") && a == 2) nfi = fi.replace ("⇒"," ⇒ ");
		else if (fi.contains ("⇔") && a == 3) nfi = fi.replace ("⇔"," ⇔ ");
		else if (fi.contains (",") && a == 4) nfi = fi.replace (","," , ");
		else nfi = fi;
		a++;

		if (a == 5) return nfi;
		else return add_spaces (nfi, a);
	}


	public bool count_pars (string fi) { //Quick check of pars
	    return true;
	}

	public bool check_pars (string fi) {
		return true;
	}

	private string easy_build (string fi) {
		string nfi;

		if (fi.contains ("<->")) nfi = fi.replace ("<->","⇔");
		else if (fi.contains ("<=>")) nfi = fi.replace ("<=>","⇔");
		else if (fi.contains ("->")) nfi = fi.replace ("->","⇒ ");
		else if (fi.contains ("=>")) nfi = fi.replace ("=>","⇒ ");
		else if (fi.contains ("⟷")) nfi = fi.replace ("⟷","⇔");
		else if (fi.contains ("→")) nfi = fi.replace ("→","⇒");
		else if (fi.contains ("∨")) nfi = fi.replace ("∨","|");
		else if (fi.contains ("¬")) nfi = fi.replace ("¬","!");
		else if (fi.contains ("[]")) nfi = fi.replace ("[]","◻");
		else nfi = fi;

		if (nfi == fi) return nfi;
		else return easy_build (nfi);
	}

	private void button_clicked (string label) {
		if (formula.has_focus) {
			formula.delete_selection ();
			int new_position = formula.get_position ();

			formula.insert_at_cursor (label);
			new_position += label.length > 4 ? label.length - 4 : label.length - 1 ;
			formula.grab_focus ();
			formula.set_position (new_position);
		} else if (formula2.has_focus) {
			formula2.delete_selection ();
			int new_position = formula2.get_position ();

			formula2.insert_at_cursor (label);
			new_position += label.length > 4 ? label.length - 4 : label.length - 1 ;
			formula2.grab_focus ();
			formula2.set_position (new_position);
		}
	}

	public Button LogicButton (string text) {
		var temp = new Gtk.Button.with_label (text);
		temp.get_style_context ().add_class ("h3");
		temp.set_size_request (60,45); //w,h
		temp.can_focus = false;
		return temp;
	}

	public Logic () {
		this.destroy.connect (Gtk.main_quit);
		this.set_border_width (12);
		var error_css = new CssProvider ();
		var css_file = "/home/felipe/Code/vala/Logica/custom.css";
		//this.resizable = false;
 		//Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true; //Dark theme?

 		headerbar = new Gtk.HeaderBar ();
		this.set_titlebar (headerbar);
		headerbar.title = "Logic Calculator";
		headerbar.subtitle = "";
		headerbar.set_decoration_layout ("close");
 		headerbar.show_close_button = true;

		mainbox = new Box (Gtk.Orientation.VERTICAL, 0);
		this.add (mainbox);

		formula 		= new Entry ();
		formula2		= new Entry ();
		var entails		= new Label ("0");
		var clear 		= new Button.with_label ("Clear");
		var Calculate 	= new Button.with_label ("Check");
		var button_and 	=  LogicButton (" & ");
		var button_or 	=  LogicButton (" | ");
		var button_not 	=  LogicButton (" ! ");
		var button_pars	=  LogicButton ("( )");
		var button_ifif	=  LogicButton ("⇔");
		var button_if 	=  LogicButton ("⇒");
		var button_nand	=  LogicButton ("⇑");
		var button_nor 	=  LogicButton ("⇓");
		var button_xor 	=  LogicButton ("^");


		button_and.set_tooltip_text ("AND");
		button_or.set_tooltip_text ("OR");
		button_xor.set_tooltip_text ("XOR");
		button_not.set_tooltip_text ("Not");
		button_if.set_tooltip_text ("If");
		button_ifif.set_tooltip_text ("If and ONLY IF");
		button_nor.set_tooltip_text ("NOR");
		button_nand.set_tooltip_text ("NAND");
		formula.margin_bottom = 10;
		formula2.margin_bottom = 10;
		formula_toggle.can_focus = false;

		Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		Calculate.get_style_context ().add_class ("h3");
		clear.get_style_context ().add_class ("h3");
		formula.get_style_context ().add_class ("h2");
		formula2.get_style_context ().add_class ("h2");
		entails.get_style_context ().add_class ("h2");

		Calculate.set_focus_on_click (false);
		clear.set_focus_on_click (false);

		grid = new Grid ();

		grid.attach (formula,		0,	0,	18,	1);
		grid.attach (button_and,	0,	3,	3,	1);
		grid.attach (button_or,		3,	3,	3,	1);
		grid.attach (button_xor,	6,	3,	3,	1);
		grid.attach (button_not,	9,	3,	3,	1);
		grid.attach (button_pars,	12,	3,	3,	1);
		grid.attach (clear,		15,	3,	3,	1);
		grid.attach (button_if,		0,	6,	3,	1);
		grid.attach (button_ifif,	3,	6,	3,	1);
		grid.attach (button_nand,	6,	6,	3,	1);
		grid.attach (button_nor,	9,	6,	3,	1);
		grid.attach (Calculate,		12,	6,	6,	1);

		grid.set_column_homogeneous (true);
		//grid.set_row_homogeneous (true);
		grid.row_spacing = 4;
		grid.column_spacing = 4;

		formula_toggle = new Switch ();
		formula_toggle.set_tooltip_text ("Advanced mode");
		headerbar.pack_end (formula_toggle);
		formula_toggle.state_set.connect ((state) => {
			if (state) { //advanced
				grid.remove (formula);
				grid.attach (formula,		0,	0,	8,	1);
				grid.attach (entails,		8,	0,	2,	1);
				grid.attach (formula2,		10,	0,	8,	1);
				entails.set_label ("⊨");
				this.show_all ();
			} else { //default
				formula.has_focus = true;
				entails.set_label ("0");
				grid.remove (formula);
				grid.remove (formula2);
				grid.remove (entails);
				grid.attach (formula,		0,	0,	18,	1);
				if (remove_spaces(formula.text) == "") {
					Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
					Calculate.get_style_context ().remove_class(Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
					Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), error_css);
				}
			}
			formula.text = formula.text + "~";
			formula.text = formula.text.replace ("~","");
			formula2.text = formula2.text + "~";
			formula2.text = formula2.text.replace ("~","");

			return false;
		});

		formula.focus_in_event.connect (() => {
			if (formula_focus == false) {
				//formula.text = "";
				formula_focus = true;
			}
			return false;
		});

		error_css.load_from_path (css_file);
		//Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), error_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);

		mainbox.add (grid);
		mainbox.spacing = 12;

		//Connections
		button_and.clicked.connect (() => {button_clicked ("( & )");});
		button_or.clicked.connect (() => {button_clicked ("( | )");});
		button_xor.clicked.connect (() => {button_clicked ("( ^ )");});
		button_not.clicked.connect (() => {button_clicked ("!()");});
		button_pars.clicked.connect (() => {button_clicked ("( )");});
		button_if.clicked.connect (() => {button_clicked ("( ⇒ )");});
		button_ifif.clicked.connect (() => {button_clicked ("( ⇔ )");});
		button_nand.clicked.connect (() => {button_clicked ("( ⇑ )");});
		button_nor.clicked.connect (() => {button_clicked ("( ⇓ )");});

		formula.changed.connect (() => {
			if (formula.text.contains ("◻") ) formula.text = "◻";
			formula.get_style_context ().add_provider (error_css, STYLE_PROVIDER_PRIORITY_USER);
			formula.text = formula.text.up ();
			formula.text = easy_build (formula.text);
			formula.set_tooltip_text (@"$(add_spaces(remove_spaces(formula.text)).replace (" , ", "\n"))");
			if (entails.label ==  "0" && (remove_spaces(formula.text) == ""))
				formula.get_style_context ().remove_provider (error_css);
			//if (formula_toggle.state == true) check_formula (simplify_formula (remove_spaces (formula2.text)));
			//check_formula (simplify_formula (remove_spaces (formula.text)));
			Check ();
		});

		formula2.changed.connect (() => {
			if (formula2.text.contains ("◻") ) formula2.text = "◻";
			formula2.get_style_context ().add_provider (error_css, STYLE_PROVIDER_PRIORITY_USER);
			formula2.text = formula2.text.up ();
			formula2.text = easy_build (formula2.text);
			formula2.set_tooltip_text  (@"$(add_spaces(remove_spaces(formula2.text)).replace (" , ", "\n"))");
			Check ();
		});

		Check.connect (() => {
			Calculate.label = "Check";
			Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
			formula_valid = 0;
			//headerbar.subtitle = @"Valid formulas ???, State: $(entails.label)";
			if (entails.label != "0") { //Advanced mode
				//if (remove_spaces (formula.text) == "") return;
				//if (simplify_formula (remove_spaces (formula2.text)) == "") return;
				check_formula (simplify_formula (remove_spaces (formula.text)));
				check_formula (simplify_formula (remove_spaces (formula2.text)));
				check_formula (simplify_formula (remove_spaces (formula2.text)));
			} else { //Single formula mode
				check_formula (simplify_formula (remove_spaces (formula.text)));
			}
			//headerbar.subtitle = @"Valid formulas $formula_valid, State: $(entails.label)";
		});

		formula.activate.connect (() => {
			Calculate.clicked ();
		});

		formula2.activate.connect (() => {formula.activate ();});

		GoodFormula.connect (() => {
			formula_valid = formula_valid + 1;
			if (entails.label == "0" && formula_valid == 1) {
				Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
				Calculate.get_style_context ().remove_class(Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
				formula.get_style_context ().remove_provider (error_css);
			}
			else if (formula_valid == 1) {
				formula.get_style_context ().remove_provider (error_css);
				formula2.get_style_context ().add_provider (error_css, STYLE_PROVIDER_PRIORITY_USER);
			}
			else if (formula_valid == 2) {
				formula2.get_style_context ().remove_provider (error_css);
				formula.get_style_context ().add_provider (error_css, STYLE_PROVIDER_PRIORITY_USER);
			}
			else if (formula_valid == 3) {
				Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
				Calculate.get_style_context ().remove_class(Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
				formula.get_style_context ().remove_provider (error_css);
				formula2.get_style_context ().remove_provider (error_css);
			}
			//headerbar.subtitle = @"$formula_valid";
		 });

		Calculate.clicked.connect (() => {//Solver button!
			if (formula_valid == 3 || (entails.label == "0" && formula_valid == 1)) {
				this.remove (mainbox);
				headerbar.remove (formula_toggle);
				formula.text = remove_spaces (formula.text);
				formula.text = add_spaces (formula.text);
				solver_box = new Solver ();
				if (formula_toggle.state == true) {
					formula2.text = remove_spaces (formula2.text);
					formula2.text = add_spaces (formula2.text);
					solver_box.populate (@"$(formula.text) , !($(formula2.text))", @"$(formula.text) ⊨  $(formula2.text)");
				} else solver_box.populate (formula.text);
				this.add (solver_box);
				solver_box.show_all ();
			}
		});

		clear.clicked.connect (() => {
			if (formula.has_focus) formula.text = "";
			if (formula2.has_focus) formula2.text = "";
		});

		if (settings.get_string ("formula0") != "") formula.set_text (settings.get_string ("formula0"));
		if (settings.get_string ("formula1") != "") formula2.set_text (settings.get_string ("formula1"));
	}

}

public static int main (string[] args) {
	Gtk.init(ref args);
	settings = new GLib.Settings ("org.felipe.logic");
	app = new Logic ();
	app.show_all ();
	//var test = new Resolution ("(D&E), (L|K)", "G");
	//test.print_formulas ();
	//stdout.printf (test.separate_formulas ("(K&!K)") );
	Gtk.main();

	return 0;
}}
