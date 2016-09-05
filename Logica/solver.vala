using GLib;
using Gtk;

namespace ProyectoDeLogica {

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
	public string val () {
		if (init) {
			if (this.active) {
				return @" $(this.label)";
			} else {
				return @" !$(this.label)";
			}
		}
		return "";
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
		//xor
		else if (fi.contains ("(1^1)")) nfi = fi.replace ("(1^1)","0");
		else if (fi.contains ("(1^0)")) nfi = fi.replace ("(1^0)","1");
		else if (fi.contains ("(0^1)")) nfi = fi.replace ("(0^1)","1");
		else if (fi.contains ("(0^0)")) nfi = fi.replace ("(0^0)","0");
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

		//Extras
		else if (fi.contains ("(0)")) nfi = fi.replace ("(0)","0");
		else if (fi.contains ("(1)")) nfi = fi.replace ("(1)","1");
		else if (fi.contains ("{")) nfi = fi.replace ("{","(");
		else if (fi.contains ("}")) nfi = fi.replace ("}",")");
		else if (fi.contains ("[")) nfi = fi.replace ("[","(");
		else if (fi.contains ("]")) nfi = fi.replace ("]",")");
		else if (fi.contains (" ")) nfi = fi.replace (" ","");

		else if (fi.contains (",!(◻)")) nfi = fi.replace (",!(◻)","");
		else if (fi.contains ("◻,")) nfi = fi.replace ("◻,","");

		else nfi = fi;

		if (nfi == fi) {
			if (formula_toggle.state == false) return fi;
			else return advanced_calculate (nfi);
		}
		else return Calculate (nfi);

	}
	public Solver () {
		headerbar.title = "Logic Solver";
		headerbar.subtitle = "";
 		headerbar.show_close_button = true;
		var step_solve_button = new ToolButton.from_stock (Gtk.Stock.GO_FORWARD);
		var solve_button = new ToolButton.from_stock (Gtk.Stock.JUMP_TO);

		refresh_button = new ToolButton.from_stock (Gtk.Stock.REFRESH);
		refresh_button.set_tooltip_text ("Restore formula");
		refresh_button.set_sensitive (false);
		refresh_button.clicked.connect (() => {
			formula_label.set_label (originalfi);
			override_label.set_label (originaloverride);
   			headerbar.subtitle = "";
   			refresh_button.set_sensitive (false);
   			solve_button.set_sensitive (true);
   			step_solve_button.set_sensitive (true);
   			reset_letters ();
		});

		solve_button.set_tooltip_text ("Auto-solve");
		solve_button.clicked.connect (() => {
		    var dialog = new Gtk.Dialog ();

			//Solve Button clicked action
			var resolution = new Resolution ();
			reset_letters ();
			solve_button.set_sensitive (false);
			letters_sensitive ();
			resolution.add_formula (row_FNC ());
			while (auto_solver () != 1) { 	//Solve
				letter_states ();
				stderr.printf (@" :: $(headerbar.subtitle)\n");
				resolution.add_formula (row_FNC ());
				if (formula_toggle.state == true && headerbar.subtitle == "1") {
					reset_letters ();
					formula_label.set_label (originalfi);
					override_label.set_label (originaloverride);
					headerbar.subtitle = "Invalid Formula";
					return;
				}
			}
			letter_states ();
			stderr.printf (@" :: $(headerbar.subtitle)\n");
			stderr.printf (@"\n");
			resolution.solve ();
			if (formula_toggle.state == true && headerbar.subtitle == "1") { //Final check
				reset_letters ();
				formula_label.set_label (originalfi);
				override_label.set_label (originaloverride);
				headerbar.subtitle = "Invalid Formula";
				return;
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
			headerbar.subtitle = "";
		});

		solve_button.set_tooltip_text ("Terminal Needed to\ndisplay truth table");
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

	public string row_FNC () {
		return @"$(A.val ())$(B.val ())$(C.val ())$(D.val ())$(E.val ())$(F.val ())$(G.val ())$(H.val ())$(I.val ())$(J.val ())$(K.val ())$(L.val ())$(M.val ())$(N.val ())$(O.val ())$(P.val ())$(Q.val ())$(R.val ())$(S.val ())$(T.val ())$(U.val ())$(V.val ())$(W.val ())$(X.val ())$(Y.val ())$(Z.val ())";
	}

	public int letters_sensitive (bool state = false) {
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
}}
