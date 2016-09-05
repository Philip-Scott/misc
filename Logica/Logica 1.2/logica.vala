using GLib;
using Gtk;

//valac-0.26 --pkg gtk+-3.0 logica.vala && ./logica
//	sudo cp org.felipe.logic*.xml /usr/share/glib-2.0/schemas/
//	sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
//
//TODO:	
//		Separate error theme
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
	const unichar letter[] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q'};
	Letters A; Letters B; Letters C; Letters D; Letters E; Letters F; Letters G; Letters H; Letters I; Letters J; 
	Letters K; Letters L; Letters M; Letters N; Letters O; Letters P; Letters Q; Letters R; Letters S; Letters T; 
	Letters U; Letters V; Letters W; Letters X; Letters Y; Letters Z;
	
public class Resolution : Object {
	private StringBuilder fi_right[20];
	private StringBuilder fi_left[20];
	private StringBuilder fi_checked;
	private unichar valid_letters[20];
	private unichar c;
	private int l;
	private int r;
	private int n;

	
	public int print_formulas () {
		int x;
		for (x = 1; x <= l; x++) {
			stdout.printf (@"$(fi_left[x].str)\n");
		}
		for (x = 1; x <= r; x++) {
			stdout.printf (@"$(fi_right[x].str)\n");
		}
		return 0;
	}
	
	//Set solver;
	public string separate_formulas (string fi) {
		string nfi = null;
		foreach (unichar a in valid_letters) {
			foreach (unichar b in valid_letters) {
				//And
				if (fi.contains (@"!($a&$b)")) 			 nfi = @"(!$a&!$b)";
				else if (fi.contains (@"!(!$a&$b)"))	 nfi = @"($a&!$b)";
				else if (fi.contains (@"!($a&!$b)")) 	 nfi = @"(!$a&$b)";
				else if (fi.contains (@"!(!$a&!$b)")) 	 nfi = @"($a&$b)";
				else if (fi.contains (@"($a&$b)")) 		 nfi = @"$a, $b";
				else if (fi.contains (@"(!$a&$b)"))	 	 nfi = @"!$a, $b";
				else if (fi.contains (@"($a&!$b)")) 	 nfi = @"$a, !$b";
				else if (fi.contains (@"(!$a&!$b)")) 	 nfi = @"!$a, !$b";
				
				//Or
				
				//If
				
				//If and only if
				
				if (nfi != null) break;
			}
		if (nfi != null) break;
		}
				
		if (nfi == null) return fi;
		else return separate_formulas (nfi);
	}
	
	
	public Resolution (string fi_l = "", string fi_r = "(G|F)") { 
		l = 0;
		string fi_L = "," + fi_l.replace(" ",""); //Remove spaces
		string fi_R = "," + fi_r.replace(" ",""); //Remove spaces
		fi_right[0] = new StringBuilder ();
		
		
		foreach (unichar a in letter) {    //set valid letters
			if (fi_L.contains (@"$a")) {
				valid_letters[l] = a;
				l++;
			}
		}
				
		l = 0; //Separate formulas
		fi_left[l] = new StringBuilder ();
		for (int i = 0; fi_L.get_next_char (ref i, out c);) { //left
			if (c == ',') {				
				l++;
				fi_left[l] = new StringBuilder ();
			} 
			else fi_left[l].append_unichar (c);
		}
		r = 0;
		fi_right[r] = new StringBuilder ();
		for (int i = 0; fi_R.get_next_char (ref i, out c);) { //right
			if (c == ',') {				
				r++;
				fi_right[r] = new StringBuilder ();
			} 
			else fi_right[r].append_unichar (c);
		}
	} 
}

	
public class Letters : Gtk.ToggleButton {
	bool init = false;
	
	public int update () {	
		if (init) {
			if (this.active) formula_label.set_label (formula_label.label.replace (this.label,"1"));
			else formula_label.set_label (formula_label.label.replace (this.label,"0"));
			
			if (override_label.label != "") { 
				if (this.active) override_label.set_label (override_label.label.replace (this.label,"1"));
				else override_label.set_label (override_label.label.replace (this.label,"0"));	
			}
		}
		return 1;
	}
	
	public int reset () {
		if (init) { 
			this.active = false;
			this.set_sensitive (true);
		}
	
		return 0;
	}
	
	public int letter_sensitive (bool state = false) {
		if (init) { 
			this.active = state;
			this.set_sensitive (state);
		}
		return 0;
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
			override_label.set_label (originaloverride);
			solver_box.update ();
		});
	}
}

public class Solver : Gtk.VBox {
	ToolButton refresh_button;
	
	public signal void update ();
	
	public string? advanced_calculate (string fi) {
		string nfi = fi;
		if 	(fi.contains ("1,1")) nfi = fi.replace ("1,1","1");
		else if (fi.contains ("1,0")) nfi = fi.replace ("1,0","0");
		else if (fi.contains ("0,1")) nfi = fi.replace ("0,1","0");
		else if (fi.contains ("0,0")) nfi = fi.replace ("0,0","0");
		else if (fi.contains ("!(0)")) nfi = fi.replace ("!(0)","1");
		else if (fi.contains ("!(1)")) nfi = fi.replace ("!(1)","0");
		else nfi = fi;
		
		if (nfi == fi) return fi;
		else return advanced_calculate (nfi);
	}
	
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
		
		//nand
		else if (fi.contains ("(1⇑1)")) nfi = fi.replace ("(1⇑1)","0");
		else if (fi.contains ("(1⇑0)")) nfi = fi.replace ("(1⇑0)","1");
		else if (fi.contains ("(0⇑1)")) nfi = fi.replace ("(0⇑1)","1");
		else if (fi.contains ("(0⇑0)")) nfi = fi.replace ("(0⇑0)","1");
		
		//nor
		else if (fi.contains ("(1⇓1)")) nfi = fi.replace ("(1⇓1)","0");
		else if (fi.contains ("(1⇓0)")) nfi = fi.replace ("(1⇓0)","0");
		else if (fi.contains ("(0⇓1)")) nfi = fi.replace ("(0⇓1)","0");
		else if (fi.contains ("(0⇓0)")) nfi = fi.replace ("(0⇓0)","1");
		
		else if (fi.contains ("(0)")) nfi = fi.replace ("(0)","0");
		else if (fi.contains ("(1)")) nfi = fi.replace ("(1)","1");
		else if (fi.contains ("{")) nfi = fi.replace ("{","(");
		else if (fi.contains ("}")) nfi = fi.replace ("}",")");
		else if (fi.contains ("[")) nfi = fi.replace ("[","(");
		else if (fi.contains ("]")) nfi = fi.replace ("]",")");
		else if (fi.contains (" ")) nfi = fi.replace (" ","");
				
		else nfi = fi;
		
		if (nfi == fi) {
			if (formula_toggle.state == false) return fi;
			else return advanced_calculate (nfi); 
		}
		else return Calculate (nfi);
				
	}	
	public Solver () {
		headerbar.title = "Logic Solver";
		headerbar.subtitle = "By: Felipe Escoto";
 		headerbar.show_close_button = true;
		var step_solve_button = new ToolButton.from_stock (Gtk.Stock.GO_FORWARD);
		var solve_button = new ToolButton.from_stock (Gtk.Stock.JUMP_TO);
		
		refresh_button = new ToolButton.from_stock (Gtk.Stock.REFRESH);
		refresh_button.set_tooltip_text ("Restore formula");
		refresh_button.set_sensitive (false);
		refresh_button.clicked.connect (() => {
			formula_label.set_label (originalfi);
			override_label.set_label (originaloverride);
   			headerbar.subtitle = "By: Felipe Escoto";
   			refresh_button.set_sensitive (false);
   			solve_button.set_sensitive (true);
   			step_solve_button.set_sensitive (true);
   			reset_letters ();
		});
		
		solve_button.set_tooltip_text ("Auto-solve");
		solve_button.clicked.connect (() => {
			reset_letters ();
			solve_button.set_sensitive (false);
			letters_sensitive ();
			while (auto_solver () != 1) { 	//Solve
				letter_states ();
				stderr.printf (@" :: $(headerbar.subtitle)\n");
				if (formula_toggle.state == true && headerbar.subtitle == "1") {
					//reset_letters ();
					formula_label.set_label (originalfi);
					override_label.set_label (originaloverride);
					headerbar.subtitle = "Invalid Formula";
					return;
				}
			}
			letters_sensitive (true);
			if (formula_toggle.state == true) {
				headerbar.subtitle = "Valid Formula";
			}
			formula_label.set_label (originalfi);
			override_label.set_label (originaloverride);
			
		});
		
		step_solve_button.set_tooltip_text ("Step by step");
		step_solve_button.clicked.connect (() => {
			solve_button.set_sensitive (true);
			auto_solver ();
		});
		
		var return_button = new ToolButton.from_stock (Gtk.Stock.GO_BACK);
		return_button.set_tooltip_text ("Formula editor");
		return_button.clicked.connect (() => {
			app.remove (solver_box);
			app.add (mainbox);
			app.resize (1,1);
			headerbar.remove (return_button);
			headerbar.remove (step_solve_button);
			headerbar.remove (solve_button);
			headerbar.remove (refresh_button);
			headerbar.pack_end (formula_toggle);
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
	
	public int reset_letters () { 
		A.reset ();	B.reset ();	C.reset (); 
		D.reset ();	E.reset ();	F.reset ();
		G.reset ();	H.reset ();	I.reset ();
		J.reset ();	K.reset ();	L.reset ();
		M.reset ();	N.reset ();	O.reset ();
		P.reset ();	Q.reset ();	R.reset ();
		S.reset ();	T.reset ();	U.reset ();
		V.reset ();	W.reset ();	X.reset ();
		Y.reset ();	Z.reset ();
		return 1;
	}
	
	public int	letters_sensitive (bool state = false) {
		A.letter_sensitive (state);	B.letter_sensitive (state);	C.letter_sensitive (state); 
		D.letter_sensitive (state);	E.letter_sensitive (state);	F.letter_sensitive (state);
		G.letter_sensitive (state);	H.letter_sensitive (state);	I.letter_sensitive (state);
		J.letter_sensitive (state);	K.letter_sensitive (state);	L.letter_sensitive (state);
		M.letter_sensitive (state);	N.letter_sensitive (state);	O.letter_sensitive (state);
		P.letter_sensitive (state);	Q.letter_sensitive (state);	R.letter_sensitive (state);
		S.letter_sensitive (state);	T.letter_sensitive (state);	U.letter_sensitive (state);
		V.letter_sensitive (state);	W.letter_sensitive (state);	X.letter_sensitive (state);
		Y.letter_sensitive (state);	Z.letter_sensitive (state);
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
	
	public void populate (string formula_, string formula_override = "") {	
		originalfi = formula_;
		originaloverride = formula_override;
		formula_label = new Label (formula_);
		override_label = new Label (formula_override);	
		formula_label.get_style_context ().add_class ("h2");
		override_label.get_style_context ().add_class ("h2");
		if (formula_override == "") this.add (formula_label);
		else this.add (override_label);
		
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
			Y.update (); Z.update (); refresh_button.set_sensitive (true);
			headerbar.subtitle = Calculate (formula_label.label);
		});
	}
}
	
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
/*
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
		}*/
		
		//string formula_new = remove_extrapars (formula_back + "X" + formula_front);
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
				case 'I': case 'J': case 'K': case 'L':	case 'M':	case 'N':	case 'O':	case 'P':
				case 'Q': case 'R': case 'S': case 'T': 	case 'U':  	case 'V':
				case 'W': case 'X': case 'Y': case 'Z': 
					c = 'X';
					break;
				case '|':	case '⇒':	case '⇔':	case '⇓':	case '⇑': 
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
		string builded = builder.str;
		
	
		if (fi == builded) return remove_extrapars (builded);
		else return simplify_formula(builded);
		//return remove_extrapars (builder_final.str.reverse());
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
	/*	int pars = 0;
		unichar c;
		for (int i = 0; fi.get_next_char (ref i, out c);) {
			if (c == '(') pars = pars + 1;
			else if (c == ')') pars = pars - 1;
			if (pars == -1) return false;
		}
		
		if (pars == 0 && check_pars(fi)) return true;
		else return false; */return true;
	}
		
	public bool check_pars (string fi) {
	/*	int atoms = 0;
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
		else return true; */return true;
	}
	private string easy_build (string fi) {
		string nfi;
		
		if (fi.contains ("<->")) nfi = fi.replace ("<->","⇔");
		else if (fi.contains ("<=>")) nfi = fi.replace ("<=>","⇔");
		else if (fi.contains ("->")) nfi = fi.replace ("->","⇒ ");
		else if (fi.contains ("=>")) nfi = fi.replace ("=>","⇒ ");
		else if (fi.contains ("⟷")) nfi = fi.replace ("⟷","⇔");
		else if (fi.contains ("→")) nfi = fi.replace ("→","⇒");
		else if (fi.contains ("∧")) nfi = fi.replace ("∧","&");
		else if (fi.contains ("∨")) nfi = fi.replace ("∨","|");
		else if (fi.contains ("¬")) nfi = fi.replace ("¬","!");

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
		headerbar.subtitle = "By: Felipe Escoto";
		headerbar.set_decoration_layout ("close");
 		headerbar.show_close_button = true;
		
		mainbox = new Box (Gtk.Orientation.VERTICAL, 0);
		this.add (mainbox);
		
		formula 		= new Entry ();
		formula2		= new Entry ();
		var entails		= new Label ("0");
		var Cancel 		= new Button.with_label ("Clear");
		var Calculate 	= new Button.with_label ("Check");	
		var button_and 	=  LogicButton (" & ");
		var button_or 	=  LogicButton (" | ");
		var button_not 	=  LogicButton (" ! ");
		var button_pars	=  LogicButton ("( )");
		var button_ifif	=  LogicButton ("⇔");
		var button_if 	=  LogicButton ("⇒");
		var button_nand	=  LogicButton ("⇑");
		var button_nor 	=  LogicButton ("⇓");
		
		
		button_and.set_tooltip_text ("And");
		button_or.set_tooltip_text	("Or");
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
		Cancel.get_style_context ().add_class ("h3");
		formula.get_style_context ().add_class ("h2");
		formula2.get_style_context ().add_class ("h2");
		entails.get_style_context ().add_class ("h2");
				
		Calculate.set_focus_on_click (false);
		Cancel.set_focus_on_click (false);
		
		grid = new Grid ();
		
		grid.attach (formula,		0,	0,	15,	1);//
		grid.attach (button_and,	0,	3,	3,	1);
		grid.attach (button_or,		3,	3,	3,	1);
		grid.attach (button_not,	6,	3,	3,	1);
		grid.attach (button_pars,	9,	3,	3,	1);
		grid.attach (Cancel,		12,	3,	3,	1);	//	
		grid.attach (button_if,		0,	6,	3,	1);
		grid.attach (button_ifif,	3,	6,	3,	1);
		grid.attach (button_nand,	6,	6,	3,	1);
		grid.attach (button_nor,	9,	6,	3,	1);
		grid.attach (Calculate,		12,	6,	3,	1);
		
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
				grid.attach (formula,		0,	0,	7,	1);
				grid.attach (entails,		7,	0,	1,	1);
				grid.attach (formula2,		8,	0,	7,	1);
				entails.set_label ("⊨");
				this.show_all ();
			} else { //default
				formula.has_focus = true;
				entails.set_label ("0");
				grid.remove (formula);
				grid.remove (formula2);
				grid.remove (entails);
				grid.attach (formula,		0,	0,	15,	1);
				if (remove_spaces(formula.text) == "") {
					Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
					Calculate.get_style_context ().remove_class(Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
					Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), error_css);			
				}
			}
			formula.text = formula.text + "~";
			formula.text = formula.text.replace ("~","");
			Check ();
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
		button_not.clicked.connect (() => {button_clicked ("!()");});		
		button_pars.clicked.connect (() => {button_clicked ("( )");});		
		button_if.clicked.connect (() => {button_clicked ("( ⇒ )");});		
		button_ifif.clicked.connect (() => {button_clicked ("( ⇔ )");});		
		button_nand.clicked.connect (() => {button_clicked ("( ⇑ )");});		
		button_nor.clicked.connect (() => {button_clicked ("( ⇓ )");});		
						
		formula.changed.connect (() => {
			Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), error_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);
			formula.text = formula.text.up ();
			formula.text = easy_build (formula.text);
			formula.set_tooltip_text (@"$(add_spaces(remove_spaces(formula.text)).replace (" , ", "\n"))");
			if (entails.label ==  "0" && (formula.text == "" || remove_spaces(formula.text) == "")) 
				Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), error_css);
			//if (formula_toggle.state == true) check_formula (simplify_formula (remove_spaces (formula2.text)));
			//check_formula (simplify_formula (remove_spaces (formula.text)));
			Check ();	
		});
		
		formula2.changed.connect (() => {
			Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), error_css, Gtk.STYLE_PROVIDER_PRIORITY_USER);			
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
				if (remove_spaces (formula.text) == "") return;
				if (simplify_formula (remove_spaces (formula2.text)) == "") return;
				check_formula (simplify_formula (remove_spaces (formula.text)));
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
			if (entails.label == "0") formula_valid = formula_valid + 1;
			if (formula_valid == 2) {
				Calculate.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
				Calculate.get_style_context ().remove_class(Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
				Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), error_css);
			}		
		 });
		
		Calculate.clicked.connect (() => {//Solver button!
			if (formula_valid == 2) {
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
		
		Cancel.clicked.connect (() => {
			if (formula.has_focus) formula.text = "";
			if (formula2.has_focus) formula2.text = "";
		});
		
		formula.set_text (settings.get_string ("formula0"));
		formula2.set_text (settings.get_string ("formula1"));
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
}
}
