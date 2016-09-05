namespace ProyectoDeLogica {

public class Resolution : Object {
	public List<string> fi;
	
	public Resolution (string fi_l = "", string fi_r = "(G|F)") { 
		List<string> fi = new List<string> ();
		
	}
	public int add_formula (string fi_) {
		if (fi_.contains ("!!")) fi.append (@"$(fi_.replace ("!!","!"))");
		else fi.append (@"$(fi_)");
		return 0;
	}
	
	public void solve () {
		stdout.printf (""); //DEBUG 
	}
}

}
