using GLib;
using Gtk;

//valac-0.26 --pkg gtk+-3.0 solver.vala && ./solver
namespace ProyectoDeLogica {
	string originalfi;
	Label formula_label;
	Box box;
	Solver app;
	Letters A[26];
	
public class Letters : Gtk.ToggleButton {
	bool init = false;
	
	public int update () {	
		
		if (init) {
			if (this.active) formula_label.set_label (formula_label.label.replace (this.label,"1"));
			else formula_label.set_label (formula_label.label.replace (this.label,"0"));	
		}
		return 1;
	}
	
	public Letters (string letter) {
		this.can_focus = false;
		this.set_label (@"$letter");
		if (originalfi.contains (letter)) {
			box.add (this);
			this.init = true;
		}
		
		
		this.toggled.connect (() => {
			formula_label.set_label (originalfi);
			app.update ();
		});
	}
}

public class Solver : Gtk.Window {
	public signal void update ();
	public string? Calculate (string fi) {
		string nfi = fi;
		
		//And
		if (fi.contains ("(1&1)")) nfi = fi.replace ("(1&1)","1");
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
	public Solver (string formula_) {
		this.set_border_width (12);
		this.resizable = false;		
		var headerbar = new Gtk.HeaderBar ();
		this.set_titlebar (headerbar);
		headerbar.title = "Logic Solver";
		headerbar.subtitle = "By: Felipe Escoto";
 		headerbar.show_close_button = true;
		
		originalfi = formula_;
		this.window_position = Gtk.WindowPosition.CENTER;
		this.destroy.connect (Gtk.main_quit);
		this.set_default_size (350, 70);
		
		box = new Box (Orientation.VERTICAL, 12);
		this.add (box);
		formula_label = new Label (formula_);	
		formula_label.get_style_context ().add_class ("h2");
		box.add (formula_label);
		
		var refresh_button = new ToolButton.from_stock (Gtk.Stock.REFRESH);
    	refresh_button.clicked.connect (() => {
    	    formula_label.set_label (formula_);
   	    	headerbar.subtitle = "By: Felipe Escoto";
    	});
		headerbar.pack_end (refresh_button);
		
		var A =	new Letters ("A");
		var B =	new Letters ("B");
		var C =	new Letters ("C");
		var D =	new Letters ("D");
		var E =	new Letters ("E");
		var F =	new Letters ("F");
		var G =	new Letters ("G");
		var H =	new Letters ("H");
		var I =	new Letters ("I");
		var J =	new Letters ("J");
		var K =	new Letters ("K");
		
		this.update.connect (() => {
			A.update ();
			B.update ();
			C.update ();
			D.update ();
			E.update ();
			F.update ();
			G.update ();
			H.update ();
			headerbar.subtitle = Calculate (formula_label.label);
		});
	}
}

public static int main (string[] args) {
	Gtk.init(ref args);
	
	app = new Solver ("((A | B) ⇔ (C & D))");
	app.show_all ();
	
	Gtk.main();
	return 0;
}}		
