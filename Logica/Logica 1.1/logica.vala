using GLib;
using Gtk;

//valac-0.26 --pkg gtk+-3.0 logica.vala && ./logica
namespace ProyectoDeLogica {
	Entry formula;
	string originalfi;
	Label formula_label;
	Box box;
	Box mainbox;
	Window app;
	Solver solver_box;
	HeaderBar headerbar;
	Grid grid;
	Letters A; Letters B; Letters C; Letters D; Letters E; Letters F; Letters G; Letters H; Letters I; Letters J; 
	Letters K; Letters L; Letters M; Letters N; Letters O; Letters P; Letters Q; Letters R; Letters S; Letters T; 
	Letters U; Letters V; Letters W; Letters X; Letters Y; Letters Z;
	
	
public class Letters : Gtk.ToggleButton {
	bool init = false;
	
	public int update () {	
		if (init) {
			if (this.active) formula_label.set_label (formula_label.label.replace (this.label,"1"));
			else formula_label.set_label (formula_label.label.replace (this.label,"0"));	
		}
		return 1;
	}
	public int state () {
		if (init) {
			if (this.active) {
				stderr.printf (" V ");
				return 1;
			} else { 
				stderr.printf (" F ");
				return 0;
			}
		}
		return -1;
	}
	
	public int toggle () {
		if (init) {
			this.active = !(this.active);
			if (this.active) return 1;
			else return 0;
			
		}
		else return -1;
	}
	
	public Letters (string letter) {
		
		this.can_focus = false;
		this.set_label (@"$letter");
		if (originalfi.contains (letter)) {
			solver_box.add (this);
			this.init = true;
			this.get_style_context ().add_class ("h3");
		}
		
		this.toggled.connect (() => {
			formula_label.set_label (originalfi);
			solver_box.update ();
		});
	}
}

public class Solver : Gtk.VBox {
	public signal void update ();
	public string? Calculate (string fi) {
		string nfi = fi;
		
		//And
		if 	(fi.contains ("(1&1)")) nfi = fi.replace ("(1&1)","1");
		else if (fi.contains ("(1&0)")) nfi = fi.replace ("(1&0)","0");
		else if (fi.contains ("(0&1)")) nfi = fi.replace ("(0&1)","0");
		else if (fi.contains ("(0&0)")) nfi = fi.replace ("(0&0)","0");
		
		//or
		else if (fi.contains ("(1|1)")) nfi = fi.replace ("(1|1)","1");
		else if (fi.contains ("(1|0)")) nfi = fi.replace ("(1|0)","1");
		else if (fi.contains ("(0|1)")) nfi = fi.replace ("(0|1)","1");
		else if (fi.contains ("(0|0)")) nfi = fi.replace ("(0|0)","0");
		
		//if
		else if (fi.contains ("(1⇒1)")) nfi = fi.replace ("(1⇒1)","1");
		else if (fi.contains ("(1⇒0)")) nfi = fi.replace ("(1⇒0)","0");
		else if (fi.contains ("(0⇒1)")) nfi = fi.replace ("(0⇒1)","1");
		else if (fi.contains ("(0⇒0)")) nfi = fi.replace ("(0⇒0)","1");
		
		//only if
		else if (fi.contains ("(1⇔1)")) nfi = fi.replace ("(1⇔1)","1");
		else if (fi.contains ("(1⇔0)")) nfi = fi.replace ("(1⇔0)","0");
		else if (fi.contains ("(0⇔1)")) nfi = fi.replace ("(0⇔1)","0");
		else if (fi.contains ("(0⇔0)")) nfi = fi.replace ("(0⇔0)","1");
		
		//not
		else if (fi.contains ("!0")) nfi = fi.replace ("!0","1");
		else if (fi.contains ("!1")) nfi = fi.replace ("!1","0");
		else if (fi.contains ("!(0)")) nfi = fi.replace ("!(0)","1");
		else if (fi.contains ("!(1)")) nfi = fi.replace ("!(1)","0");
		
		else if (fi.contains ("{")) nfi = fi.replace ("{","(");
		else if (fi.contains ("}")) nfi = fi.replace ("}",")");
		else if (fi.contains ("[")) nfi = fi.replace ("[","(");
		else if (fi.contains ("]")) nfi = fi.replace ("]",")");
		else if (fi.contains (" ")) nfi = fi.replace (" ","");
		else nfi = fi;
		
		if (nfi == fi) return fi;
		else return Calculate (nfi);
	}	
	public Solver () {
		headerbar.title = "Logic Solver";
		headerbar.subtitle = "By: Felipe Escoto";
 		headerbar.show_close_button = true;
		
		var refresh_button = new ToolButton.from_stock (Gtk.Stock.REFRESH);
		refresh_button.clicked.connect (() => {
			formula_label.set_label (originalfi);
   			headerbar.subtitle = "By: Felipe Escoto";
		});
		
		var solve_button = new ToolButton.from_stock (Gtk.Stock.JUMP_TO);
		solve_button.clicked.connect (() => {
			stderr.printf ("\n************************\n");
			while (auto_solver () != 1); 	//Reset
				letter_states ();
				stderr.printf (@" :: $(headerbar.subtitle)\n");
			while (auto_solver () != 1) { 	//Solve
				letter_states ();
				stderr.printf (@" :: $(headerbar.subtitle)\n");
			}
		});
		
		var step_solve_button = new ToolButton.from_stock (Gtk.Stock.GO_FORWARD);
		step_solve_button.clicked.connect (() => {
			auto_solver ();
		});
		
		var return_button = new ToolButton.from_stock (Gtk.Stock.GO_BACK);
		return_button.clicked.connect (() => {
			app.remove (solver_box);
			app.add (mainbox);
			headerbar.remove (return_button);
			headerbar.remove (step_solve_button);
			headerbar.remove (solve_button);
			headerbar.remove (refresh_button);
			headerbar.title = "Logic Calculator";
			headerbar.subtitle = "By: Felipe Escoto";
		});
		
		solve_button.set_tooltip_text ("Terminal Needed to\ndisplay automatic answers");
		refresh_button.can_focus = false;
		solve_button.can_focus = false;
		headerbar.pack_start (return_button);
		headerbar.pack_end (solve_button);
		headerbar.pack_end (step_solve_button);
		headerbar.pack_end (refresh_button);
 		app.show_all ();
	}
	public int letter_states () { 
		A.state ();	B.state ();	C.state (); 
		D.state ();	E.state ();	F.state ();
		G.state ();	H.state ();	I.state ();
		J.state ();	K.state ();	L.state ();
		M.state ();	N.state ();	O.state ();
		P.state ();	Q.state ();	R.state ();
		S.state ();	T.state ();	U.state ();
		V.state ();	W.state ();	X.state ();
		Y.state ();	Z.state ();
		return 1;
	}
	
	public int auto_solver () { 
		if (A.toggle () == 1) return 0; if (B.toggle () == 1) return 0; if (C.toggle () == 1) return 0; 
		if (D.toggle () == 1) return 0; if (E.toggle () == 1) return 0; if (F.toggle () == 1) return 0;
		if (G.toggle () == 1) return 0; if (H.toggle () == 1) return 0; if (I.toggle () == 1) return 0;
		if (J.toggle () == 1) return 0; if (K.toggle () == 1) return 0; if (L.toggle () == 1) return 0;
		if (M.toggle () == 1) return 0; if (N.toggle () == 1) return 0; if (O.toggle () == 1) return 0;
		if (P.toggle () == 1) return 0; if (Q.toggle () == 1) return 0; if (R.toggle () == 1) return 0;
		if (S.toggle () == 1) return 0; if (T.toggle () == 1) return 0; if (U.toggle () == 1) return 0;
		if (V.toggle () == 1) return 0; if (W.toggle () == 1) return 0; if (X.toggle () == 1) return 0;
		if (Y.toggle () == 1) return 0; if (Z.toggle () == 1) return 0;
		return 1;
	}
	
	public void populate (string formula_) {	
		originalfi = formula_;
		
		//TODO Use the entry instead
		formula_label = new Label (formula_);	
		formula_label.get_style_context ().add_class ("h2");
		this.add (formula_label);
		this.set_spacing (4);
		
		A =	new Letters ("A");	B =	new Letters ("B"); 	C =	new Letters ("C"); 	D =	new Letters ("D");
		E =	new Letters ("E"); 	F =	new Letters ("F");	G =	new Letters ("G");	H =	new Letters ("H");
		I =	new Letters ("I"); 	J =	new Letters ("J");	K =	new Letters ("K"); 	L =	new Letters ("L");
		M =	new Letters ("M"); 	N =	new Letters ("N"); 	O =	new Letters ("O");	P =	new Letters ("P");
		Q =	new Letters ("Q"); 	R =	new Letters ("R"); 	S =	new Letters ("S"); 	T =	new Letters ("T");
		U =	new Letters ("U"); 	V =	new Letters ("V"); 	W =	new Letters ("W"); 	X =	new Letters ("X");
		Y =	new Letters ("Y"); 	Z =	new Letters ("Z"); 
		
		this.update.connect (() => {
			A.update (); B.update (); C.update (); D.update (); E.update (); F.update (); G.update (); H.update ();
			I.update (); J.update (); K.update (); L.update (); M.update (); N.update (); O.update (); P.update ();
			Q.update (); R.update (); S.update (); T.update (); U.update (); V.update (); W.update (); X.update ();
			Y.update (); Z.update ();
			headerbar.subtitle = Calculate (formula_label.label);
		});
	}
}
	
public class Logic : Gtk.Window {
	public bool formula_focus = false;
	public bool formula_valid = false;
	public bool simplify_type = false; 
	
	public signal void GoodFormula ();
	
	public string? check_formula (string fi) {
		
		if (fi == "T" || fi == "" || fi == "&" || fi == "X)" || fi == "(X" ) return null;
		if (fi == "X" || fi == "(X)") {
			GoodFormula ();
			return null;
		}

		if (fi.contains ("(&") || fi.contains ("&)")) return null;
		
		unichar c;
		int conectors = 0;
		int conectors_max = 0;
		
		for (int i = 0; fi.get_next_char (ref i, out c);) {
			if (c == '&' || c == '|') conectors++;
			if (conectors > conectors_max) conectors_max = conectors;
			//if (c == ')') conectors--;
		}
		
		int i;
		for (i = 0; fi.get_next_char (ref i, out c);) {
			if (c == '(') {
				conectors_max--;
				if (conectors_max == 0) break;
			};
		}
		/*
			string formula_back;
			string formula_check;
			string formula_front;
		
			formula_back 	= fi[0:i-1];
			formula_check	= fi[i-1:i+4];
			formula_front 	= fi[i+4:fi.length];
		
		stdout.printf (@"Back: $formula_back\n");
		stdout.printf (@"Check: $formula_check\n");
		stdout.printf (@"front: $formula_front\n");
		
		if (formula_check != "(X&X)") return null;
		*/
		//string formula_new = remove_extrapars (formula_back + "X" + formula_front);
		string formula_new = remove_extrapars (fi.replace ("(X&X)", "X"));
		
		//stdout.printf (@"$formula_new\n");
		
		if (formula_new != fi) check_formula (formula_new);
		if (formula_new == "X") GoodFormula ();
		return null;
	}
/*	public string replace_formula (string fi) {
		unichar c;
		bool modified = false;
		var builder = new StringBuilder ();
		for (int i = 0; fi.get_next_char (ref i, out c);) {
		switch (c) {
			case '!':
				c = '¬';
				break;
			case '&':
				c = '∧';
				break;
			case '|':
				c = '∨';
				break;			
			}
			builder.append_unichar (c);
		}
		return builder.str;
	}*/
	
	public string simplify_formula (string fi) { //Used to simplify the formula checks 
		unichar c;
		bool modified = false;
		var builder 	  =	new StringBuilder ();
		var builder_final =	new StringBuilder ();
		for (int i = 0; fi.get_next_char (ref i, out c);) { //Replace formula with Xs and &s
			switch (c) {
				case 'A': case 'B': case 'C': case 'D':	case 'E':	case 'F':	case 'G':	case 'H':
				case 'I': case 'J': case 'K': case 'L':	case 'M':	case 'N':	case 'O':	case 'P':
				case 'Q': case 'R': case 'S': case 'T': 	case 'U':  	case 'V':
				case 'W': case 'X': case 'Y': case 'Z': 
					c = 'X';
					break;
				case '|':
				case '⇒':
				case '⇔':				
					c = '&';
					break;
				case '[':
				case '{':
					c = '(';
					break;
				case ']':
				case '}':
					c = ')';
					break;
			}
			builder.append_unichar (c);
		} 
		if  (builder.str.contains (")!")) return builder.str;
		
		string test;
		string builded = builder.str;
		
		test = builded;
		
		if (fi == builded) return remove_extrapars (test);
		else return simplify_formula(test);
		//return remove_extrapars (builder_final.str.reverse());
	}
	
	public string remove_extrapars (string fi) {
		string test;
	
		if (fi.contains ("(X)")) test = fi.replace ("(X)", "X");
		else if (fi.contains ("((X&X))")) test = fi.replace ("((X&X))", "(X&X)");
	 	else if (fi.contains ("!(X)")) test = fi.replace ("!(X)", "X");
		else if (fi.contains ("!")) test = fi.replace ("!", "");
		else if (fi.contains ("X,X")) test = fi.replace ("X,X", "X"); //TODO FIX [X,(X&X)] 
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
		int pars = 0;
		unichar c;
		for (int i = 0; fi.get_next_char (ref i, out c);) {
			if (c == '(') pars = pars + 1;
			else if (c == ')') pars = pars - 1;
			if (pars == -1) return false;
		}
		
		if (pars == 0 && check_pars(fi)) return true;
		else return false;
	}
		
	public bool check_pars (string fi) {
		int atoms = 0;
		int and_or_count = 0;
		int not_count = 0;
		//int pars_open = 0;
		//int pars_closed = 0;
		//int pars = 0;
		unichar c,p;
		int i = 0;
		fi.get_next_char (ref i, out p);
		for (i = 1; fi.get_next_char (ref i, out c);) {
			if (p == '&') {
				if (c ==')' || c == '&') return false;
			}
			if (p == ')') {
				if (c =='(') return false;
			}
			if (p == '(') {
				if (c ==')') return false;
			}  
			if (p == '!') {
				if (c != '(') return false;
			}	
			p = c; 
		}
		
		return true;
		for (i = 0; fi.get_next_char (ref i, out c);) {
			switch (c) {
				case '(':
				case ')': 
					break;
				case '&': 
				case '|': 
				case '!': 
					not_count++;
					break;
				default:
					atoms++;
					break;
			}
		}
		if (atoms != and_or_count * 2 + not_count) return false;
		else return true;
	}
	private string easy_build (string fi) {
		string nfi;
		
		if (fi.contains ("<->")) nfi = fi.replace ("<->","⇔");
		else if (fi.contains ("<=>")) nfi = fi.replace ("<=>","⇔");
		else if (fi.contains ("->")) nfi = fi.replace ("->","⇒ ");
		else if (fi.contains ("=>")) nfi = fi.replace ("=>","⇒ ");
		else nfi = fi;
		
		if (nfi == fi) return nfi;
		else return easy_build (nfi);
	}
	 
	private void button_clicked (string label) {
		
		formula.delete_selection ();
		int new_position = formula.get_position ();

		formula.insert_at_cursor (label);
		new_position += label.length > 4 ? label.length - 4 : label.length - 1 ;		
		formula.grab_focus ();
		formula.set_position (new_position);
	}
	
	public Logic () {
		this.destroy.connect (Gtk.main_quit);
		this.set_border_width (12);
		//this.resizable = false;
 		//Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true; //Dark theme?
 
 		headerbar = new Gtk.HeaderBar ();
		this.set_titlebar (headerbar);
		headerbar.title = "Logic Calculator";
		headerbar.subtitle = "By: Felipe Escoto";
 		headerbar.show_close_button = true;
		
		mainbox = new Box (Gtk.Orientation.VERTICAL, 0);
		this.add (mainbox);
		
		formula 	= new Entry ();
		var Cancel 		= new Button.with_label ("Clear");
		var Calculate 	= new Button.with_label ("Check");	
		var button_and 	= new Gtk.Button.with_label (" & ");
		var button_or 	= new Gtk.Button.with_label (" | ");
		var button_not = new Gtk.Button.with_label (" ! ");
		var button_pars = new Gtk.Button.with_label ("( )");
		var button_ifif = new Gtk.Button.with_label ("⇔");
		var button_if = new Gtk.Button.with_label ("⇒");
		
		button_and.set_tooltip_text ("And");
		button_or.set_tooltip_text	("Or");
		button_not.set_tooltip_text ("Not");
		button_if.set_tooltip_text ("If");
		button_ifif.set_tooltip_text ("If and ONLY IF");
		
		Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		Calculate.get_style_context ().add_class ("h3");
		Cancel.get_style_context ().add_class ("h3");
		formula.get_style_context ().add_class ("h2");
		button_and.get_style_context ().add_class ("h3");
		button_or.get_style_context ().add_class ("h3");
		button_not.get_style_context ().add_class ("h3");
		button_not.get_style_context ().add_class ("h3");
		button_if.get_style_context ().add_class ("h3");
		button_ifif.get_style_context ().add_class ("h3");
		
		Calculate.set_focus_on_click (false);
		Cancel.set_focus_on_click (false);
		
		grid = new Grid ();
		
		grid.attach (formula,		0,	0,	4,	1);
		grid.attach (button_and,	0,	1,	1,	1);
		grid.attach (button_or,		1,	1,	1,	1);
		grid.attach (button_not,	2,	1,	1,	1);
		grid.attach (button_pars,	3,	1,	1,	1);
		grid.attach (button_if,		0,	2,	1,	1);
		grid.attach (button_ifif,	1,	2,	1,	1);
		grid.attach (Calculate,		3,	2,	1,	1);
		grid.attach (Cancel,		2,	2,	1,	1);
		
		grid.set_column_homogeneous (true);
		grid.set_row_homogeneous (true);
		grid.row_spacing = 12;
		grid.column_spacing = 4;
	
		formula.focus_in_event.connect (() => {
			if (formula_focus == false) {
				formula.text = "";
				formula_focus = true; 
			}
			return false;
		});
		
		
		var error_css = new CssProvider ();
		var css_file = "/home/felipe/Code/vala/Logica/custom.css";
		
	
		error_css.load_from_path (css_file);
		//Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), error_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);
	

		mainbox.add (grid);
		mainbox.spacing = 12;
		
		//Connections
		button_and.clicked.connect (() => {button_clicked ("( & )");});
		button_or.clicked.connect (() => {button_clicked ("( | )");});
		button_not.clicked.connect (() => {button_clicked ("!()");});
		button_pars.clicked.connect (() => {button_clicked ("( )");});
		button_if.clicked.connect (() => {button_clicked ("( ⇒ )");});
		button_ifif.clicked.connect (() => {button_clicked ("( ⇔ )");});
				
		formula.changed.connect (() => {
			//stdout.printf ("**********************************\n");
			if (formula.text != "") 
				Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), error_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);
			else Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), error_css);
			formula_valid = false;
			formula.text = formula.text.up ();
			formula.text = easy_build (formula.text);
			Calculate.label = "Check";
			Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
			if (formula.text == "" || remove_spaces(formula.text) == "") return;
			if ( (count_pars (remove_spaces(formula.text))) == true) {
				check_formula (simplify_formula (remove_spaces (formula.text)));
			}	
		});
		
		formula.activate.connect (() => {
			Calculate.clicked ();
		});
		
		GoodFormula.connect (() => {
			Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
			Calculate.get_style_context ().remove_class(Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
			Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), error_css);
			formula_valid = true;
		 });
		
		Calculate.clicked.connect (() => {//Solver button!
			if (formula_valid == true) {
				this.remove (mainbox);
				formula.text = remove_spaces (formula.text);
				formula.text = add_spaces (formula.text);
				solver_box = new Solver ();
				solver_box.populate (formula.text);
				this.add (solver_box);
				solver_box.show_all ();
			}
		});
		
		Cancel.clicked.connect (() => {
			formula.text = "";
		});
	}
}

public static int main (string[] args) {
	Gtk.init(ref args);
	
	app = new Logic ();
	app.show_all ();
	//app.simplify_formula ("!(!(X)&!(X))");
	Gtk.main();
	
	
	return 0;
}}
