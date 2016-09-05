using Gtk;
using GLib;
using Granite.Widgets;

//
//sudo cp org.felipe.CookieClicker*.gschema.xml /usr/share/glib-2.0/schemas
//sudo glib-compile-schemas /usr/share/glib-2.0/schemas
//
//valac --pkg gtk+-3.0 --thread --target-glib 2.32 --pkg granite Clicker.vala && ./Clicker
namespace CookieClicker {
	public uint64 handmade = 0;
	public uint64 Cash = 0;
	public double Cashtemp = 0;
	public double CPS = 0;
	public int unlocked;
	public int Buildings = 0;

	ModeButton mode_button;
	Gtk.Box ubox;
	GLib.Settings settings;

	class Timer : GLib.Object {
		private string name;
		private CookieClicker.headerbar head = null;
		private CookieClicker.Clicker clicks = null;


		public Timer () {
			this.name = "";
		}
		public int setvars(CookieClicker.headerbar heada, CookieClicker.Clicker clicksa) {
		head = heada;
		clicks = clicksa;

		return 0;
		}

		public void* thread_func () {
			while (true) {
			while (CPS < 999999) {
				Thread.usleep (100000);
				Cashtemp = Cashtemp + (CPS / 10);
				if (Cashtemp > 1) {
					Cash = Cash + (int)Cashtemp;
					Cashtemp = Cashtemp - (double)((int)Cashtemp);
				}
				head.update();

			}
			while (!(CPS < 999999)) {
				Thread.usleep (100000);
				Cashtemp = Cashtemp + (CPS / 10);
				if (Cashtemp > 1) {
					Cash = Cash + (int)Cashtemp;
					Cashtemp = Cashtemp - (double)((int)Cashtemp);
				}
				head.update_64(); }
			}
		}
	}

class Clicker : Gtk.Button {
	public double gainfromCPS;
	public double gain = 0;
	public int modifier = 1;
	public int CPC = 1;
	public int BCPC = 1;
	public int[] applied = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

	public void upgrade (int id, double gain_, bool fromCPS = false, int ap = -1) {

		if (ap != -1) ap = id;

		if (gain_ == 0) { //Twice as efficient upgrade
			settings.changed[@"u$(id)"].connect (() => {
				bool temp = settings.get_boolean(@"u$(id)");
				if (temp == true && applied[ap] == 0) {
					modifier = modifier * 2;
					applied[ap] = 1;
				}
				update();
			});
		}

		else { //Gain upgrade
			settings.changed[@"u$(id)"].connect (() => {
				bool temp = settings.get_boolean(@"u$(id)");
				if (temp == true && applied[ap] == 0) {
					if (fromCPS == false ) gain = gain + gain_;
					else gainfromCPS = gainfromCPS + gain_;
					applied[ap] = 1;
				}
				update();
			});
		}

	}

	public void update() {
		CPC  = (int)((BCPC * modifier) + (gain * Buildings));
	}

	public Clicker (CookieClicker.headerbar head) {

		//Upgrade (UpgradeID, CpCGain, gainfromCpS?, Applied alternative storage)
		//if CpCGain == 0, then it's a x2 modifier;
		//GainfromCpS Default == false; if true, then it get;s a value from CPS
		//Applied alternatibe storage: The 1/0
		upgrade (0, 0);
		upgrade (1, 0);
		upgrade (2, 0);
		upgrade (3, 0.1);
		upgrade (4, 0.5);
		upgrade (75, 1, true, 5);
		upgrade (76, 1, true, 6);
		upgrade (77, 1, true, 7);
		upgrade (78, 1, true, 8);
		upgrade (119,1, true, 9);

		this.label = ("Click Me!");
		this.set_image_position ( Gtk.PositionType.LEFT );
		this.clicked.connect (() => {
			handmade = handmade + CPC + (int)(CPS * gainfromCPS / 100);
			Cash = Cash + CPC + (int)(CPS * gainfromCPS / 100 * modifier);;
		});
	}
}

class Upgrade : Gtk.Box {
	public bool enabled;
	public bool purchased;
	public uint64 amount;

	public string format(string original_) {
		var builder = new StringBuilder ();
		string original = original_.reverse ();
		unichar c;
		for (int i = 0; original.get_next_char (ref i, out c);) {
   			if (i > 3 && (i - 1) % 3 == 0) builder.append(",");
   			builder.append(@"$(c)");
		}
		return @"$(builder.str)".reverse();
	}

	//				Upgrade name  Upgrade Price		Description	Storageid		Dependency		How many from shop is needed to unlock
	public Upgrade (string name, int64 price, string description, string ID, string shop, int64 unlock, string comment = "") {
		enabled = false;
		purchased = settings.get_boolean (@"u$(ID)");

		var label_name = new Label ("");
		var button = new Button ();

		button.label = "$ " + format(@"$(price)");
		button.xalign = 0;
		label_name.xalign = 0;
		label_name.label = name;
		label_name.set_tooltip_text (description);

		button.clicked.connect (() => {
			if (Cash >= price) {
				Cash = Cash - price;
				button.set_sensitive(false);
				settings.set_boolean (@"u$(ID)", true);
				button.label = ("- - -");
				button.set_tooltip_text (comment);
				purchased = true;
		}});

		if (purchased == true) {
			settings.set_boolean (@"u$(ID)", true); //To apply upgrades to the shop
		}

		this.homogeneous = true;
		this.add(label_name);
		this.add(button);
		this.visible = true;

		//When the Upgrades button is clicked, enable upgrade is unlocked, not purchased and hasnent passed the limit of 10
		//
		mode_button.mode_changed.connect (() => {
			if (mode_button.selected == 0){
				if (shop == "handmade") amount = handmade;

				else amount = settings.get_int(shop);

				enabled = false;
				if (purchased == false && amount >= unlock && unlocked < 10) {
					enabled = true;
					unlocked = unlocked + 1;
				}

				if (enabled == true) {
					ubox.add(this);
					ubox.show_all ();
				}
			}

			else {
				if (enabled == true) {
					ubox.remove(this);

				}

			}
		});

	}
}

class UpgradesControler : GLib.Object {

	public UpgradesControler()	{

	}

	public int Populate()	{
		unlocked = 0;

		//Clicker
		new Upgrade("Plastic Mouse", 50000, "Cursor gains +1% of your cps",  "75", "handmade", 1000);
		new Upgrade("Iron Mouse", 5000000, "Cursor gains +1% of your cps",  "76", "handmade", 100000);
		new Upgrade("Titanium Mouse", 500000000, "Cursor gains +1% of your cps",  "77", "handmade", 10000000);
		new Upgrade("Adamantium Mouse", 50000000000, "Cursor gains +1% of your cps",  "78", "handmade", 1000000000);
		new Upgrade("Unobtainium Mouse", 5000000000000, "Cursor gains +1% of your cps",  "119", "handmade", 1000000000000);



		//Cursor
		new Upgrade("Reinforced finger", 100, "The mouse and cursor are twice as efficient!",  "0", "cursor", 1);
		new Upgrade("Carpal tunnel\nprevention cream", 400, "The mouse and cursor are twice as efficient!", "1", "cursor", 1,"it... hurts to click....");
		new Upgrade("Ambidextrous", 10000, "The mouse and cursor are\ntwice as efficient!", "2", "cursor", 10);
		new Upgrade("Thousand fingers", 500000, "Cursors are twice as efficient!\nMouse gains +0.1 for each object owned", "3", "cursor", 20);
		new Upgrade("Million fingers", 50000000, "Cursors are twice as efficient!\nMouse gains +0.5 for each object owned", "4", "cursor", 40);

		//grandmas
		new Upgrade("FW: From grandma", 1000, "Grandmas gain +0.3 base CpS", "7", "granma", 1);
		new Upgrade("Steel-plated rolling pins", 10000, "Grandmas are twice as efficient", "8", "granma", 1);
		new Upgrade("Lubricated dentures", 100000, "Grandmas are twice as efficient", "9", "granma", 10);
		new Upgrade("Prune juice", 5000000, "Grandmas are twice as efficient", "44", "granma", 50);
		new Upgrade("Double-thick glasses", 100000000, "Grandmas are twice as efficient", "110", "granma", 100);
		//Special Grandmas
		new Upgrade("Farmer grandmas", 50000, "Grandmas are twice as efficient", "57", "farm", 15);
		new Upgrade("Worker grandmas", 300000, "Grandmas are twice as efficient", "58", "factory", 15);
		new Upgrade("Miner grandmas", 1000000, "Grandmas are twice as efficient", "59", "mine", 15);
		new Upgrade("Cosmic grandmas", 4000000, "Grandmas are twice as efficient", "60", "ship", 15);
		new Upgrade("Transmuted grandmas", 20000000, "Grandmas are twice as efficient", "61", "lab", 15);
		new Upgrade("Altered grandmas", 166666600, "Grandmas are twice as efficient", "62", "portal", 15);
		new Upgrade("Grandmas' grandmas", 12345678900, "Grandmas are twice as efficient", "63", "time", 15);
		new Upgrade("Antigrandmas", 399999999900, "Grandmas are twice as efficient", "103", "anti", 15);

		//farms
		new Upgrade("Cheap hoes", 5000, "Farms gain +1 base CpS", "10", "farm", 1);
		new Upgrade("Fertilizer", 50000, "Farms are twice as efficient!", "11", "farm", 1);
		new Upgrade("Cookie trees", 500000, "Farms are twice as efficient!", "12", "farm", 10);
		new Upgrade("Genetically-modified cookies", 25000000, "Farms are twice as efficient!", "45", "farm", 50);
		new Upgrade("Gingerbread scarecrows",500000000, "Farms are twice as efficient!", "111", "farm", 100);

		//factory
		new Upgrade("Sturdier conveyor belts", 30000, "Factories gain +4 base CpS", "13", "factory", 1);
		new Upgrade("Child labor", 300000, "Factories are twice as efficient!", "14", "factory", 1);
		new Upgrade("Sweatshop", 3000000, "Factories are twice as efficient!", "15", "factory", 10);
		new Upgrade("Radium reactors", 150000000, "Factories are twice as efficient!", "46", "factory", 50);
		new Upgrade("Recombobulators",3000000000, "Factories are twice as efficient!", "112", "factory", 100);

		//mine
		new Upgrade("Sugar gas ", 100000, "Mines gain +10 base CpS", "16", "mine", 1);
		new Upgrade("Megadrill", 1000000, "Mines are twice as efficient!", "17", "mine", 1);
		new Upgrade("Ultradrill", 10000000, "Mines are twice as efficient!", "18", "mine", 10);
		new Upgrade("Ultimadrill", 500000000, "Mines are twice as efficient!", "47", "mine", 50);
		new Upgrade("H-bomb mining",10000000000, "Mines are twice as efficient!", "113", "mine", 100);

		//ship
		new Upgrade("Vanilla nebulae", 400000, "Shipments gain +30 base CpS", "19", "ship", 1);
		new Upgrade("Wormholes", 4000000, "Shipments are twice as efficient!", "20", "ship", 1);
		new Upgrade("Frequent flyer", 40000000, "Shipments are twice as efficient!", "21", "ship", 10);
		new Upgrade("Warp drive ", 2000000000, "Shipments are twice as efficient!", "48", "ship", 50);
		new Upgrade("Chocolate monoliths", 40000000000, "Shipments are twice as efficient!", "114", "ship", 100);

		//lab
		new Upgrade("Antimony", 2000000, "Alchemy labs gain +100 base CpS", "22", "lab", 1);
		new Upgrade("Essence of dough", 20000000, "Alchemy labs are twice as efficient!", "23", "lab", 1);
		new Upgrade("True chocolate", 200000000, "Alchemy labs are twice as efficient!", "24", "lab", 10);
		new Upgrade("Ambrosia", 10000000000, "Alchemy labs are twice as efficient!", "49", "lab", 50);
		new Upgrade("Origin crucible", 200000000000, "Alchemy labs are twice as efficient!", "115", "lab", 100);

		//Portals
		new Upgrade("Ancient tablet", 16666660, "Portals gain +1,666 base CpS", "25", "portal", 1);
		new Upgrade("Insane oatling workers", 166666600, "Portals are twice as efficient!", "26", "portal", 1);
		new Upgrade("Soul bond", 1666666000, "Portals are twice as efficient!", "27", "portal", 10);
		new Upgrade("Sanity dance", 83333300000, "Portals are twice as efficient!", "50", "portal", 50);
		new Upgrade("Brane transplant", 1666666000000, "Portals are twice as efficient!", "116", "portal", 100);
		//Time
		new Upgrade("Flux capacitors", 1234567890, "Time machines gain +9,876 base CpS", "28", "time", 1);
		new Upgrade("Time paradox resolver", 9876543210, "Time machines are twice as efficient!", "29", "time", 1);
		new Upgrade("Quantum conundrum", 98765456789, "Time machines are twice as efficient!", "30", "time", 10);
		new Upgrade("Causality enforcer", 1234567890000, "Time machines are twice as efficient!", "50", "time", 50);
		new Upgrade("Yestermorrow comparators ", 123456789000000, "Time machines are twice as efficient!", "116", "time", 100);

		//Matter
		new Upgrade("Sugar bosons", 39999999990, "Cookie condensers gain +99,999 base CpS", "99", "anti", 1);
		new Upgrade("String theory", 399999999900, "Cookie condensers are twice as efficient!", "100", "anti", 1);
		new Upgrade("Large macaron collider", 3999999999000, "Cookie condensers are twice as efficient!", "101", "anti", 10);
		new Upgrade("Big bang bake", 199999999950000, "Cookie condensers are twice as efficient!", "102", "anti", 50);
		new Upgrade("Reverse cyclotrons", 3999999999000000, "Cookie condensers are twice as efficient!", "118", "anti", 100);

		return 0;
	}
}

class Shop : Gtk.Box {

		public string sname;
		public int amount = 0;
		public int[] appliedupgrades = {0,0,0,0,0,0,0};
		public int modifier = 1;
		public uint64 base_cost = 0;
		public double base_CPS = 0;
		public double added_CPS = 0;
		public double temp = 1.15;
		public uint64 price_64 = 0;

		public string format(string original_) {
			var builder = new StringBuilder ();
			string original = original_.reverse ();
			unichar c;
			for (int i = 0; original.get_next_char (ref i, out c);) {
    			if (i > 3 && (i - 1) % 3 == 0) builder.append(",");
    			builder.append(@"$(c)");

			}

			return @"$(builder.str)".reverse();
		}

		public void ShopUpgrade (int id, double gain_, int ap) {
			if (gain_ == 0) { //Modifier upgrade
				settings.changed[@"u$(id)"].connect (() => {
					bool temp = settings.get_boolean(@"u$(id)");
					if (temp == true && appliedupgrades[ap] == 0) {
						modifier = modifier * 2;
						appliedupgrades[ap] = 1;
						UpdateShop();
					}
					else if (temp == false && appliedupgrades[ap] == 1) {
						modifier = modifier / 2;
						appliedupgrades[ap] = 0;
						UpdateShop();
					}
					else {
					}
				});
			}
			else { //CPS upgrade
				settings.changed[@"u$(id)"].connect (() => { //CPS UPGRADE
					bool temp = settings.get_boolean(@"u$(id)");
					if (temp == true && appliedupgrades[ap] == 0) {
						base_CPS = base_CPS + gain_;
						appliedupgrades[ap] = 1;
						UpdateShop();
					}
					else if (temp == false && appliedupgrades[ap] == 1) {
						base_CPS = base_CPS - gain_;
						appliedupgrades[ap] = 0;
						UpdateShop();
					}
					else {
					}
				});
			}
		}

		public Shop (string name, uint64 price, double basecps, string description, string sname_, int CpSUpgrade_id, double addCPS, int upgrades1, int upgrades2, int upgrades3, int upgrades4, int upgrades5 = -1, int upgrades6= -1, int upgrades7= -1, int upgrades8= -1, int upgrades9= -1, int upgrades10 = -1,int upgrades11 = -1,int upgrades12 = -1) {

			sname = sname_;
			amount = settings.get_int (sname);
			Buildings = Buildings + amount;
			base_CPS = basecps;
			base_cost = price;
			var label_name = new Label ("? ? ? ? ?");
			var label_amount = new Label (@"$(amount)");
			var Button = new Button.with_label (@"$$ ");
			label_name.set_tooltip_text (@"? ? ?");
			label_name.set_use_markup (true);

			Button.focus_on_click = false;
			CookieClicker.mode_button.mode_changed.connect (() => {

				if (mode_button.selected == 1)
				Button.set_sensitive(true);
				else
				Button.set_sensitive(false);

			});


			ShopUpgrade (CpSUpgrade_id, addCPS, 0);	//CPS
			ShopUpgrade (upgrades1, 0, 1); 			//UPgrade 1
			ShopUpgrade (upgrades2, 0, 2); 			//upgrade 2
			ShopUpgrade (upgrades3, 0, 3); 			//upgrade 3
			ShopUpgrade (upgrades4, 0, 4); 			//upgrade 4
			if (upgrades5 != -1) ShopUpgrade (upgrades5, 0, 5);
			if (upgrades6 != -1) ShopUpgrade (upgrades6, 0, 6);
			if (upgrades7 != -1) ShopUpgrade (upgrades7, 0, 7);
			if (upgrades8 != -1) ShopUpgrade (upgrades8, 0, 8);
			if (upgrades9 != -1) ShopUpgrade (upgrades9, 0, 9);
			if (upgrades10 != -1) ShopUpgrade (upgrades10, 0, 10);
			if (upgrades11 != -1) ShopUpgrade (upgrades11, 0, 10);
			if (upgrades12 != -1) ShopUpgrade (upgrades12, 0, 10);

			settings.set_boolean(@"u$(CpSUpgrade_id)", settings.get_boolean(@"u$(CpSUpgrade_id)"));
			settings.set_boolean(@"u$(upgrades1)", settings.get_boolean(@"u$(upgrades1)"));
			settings.set_boolean(@"u$(upgrades2)", settings.get_boolean(@"u$(upgrades2)"));
			settings.set_boolean(@"u$(upgrades3)", settings.get_boolean(@"u$(upgrades3)"));
			settings.set_boolean(@"u$(upgrades4)", settings.get_boolean(@"u$(upgrades4)"));
			if (upgrades5 != -1) settings.set_boolean(@"u$(upgrades5)", settings.get_boolean(@"u$(upgrades5)"));
			if (upgrades6 != -1) settings.set_boolean(@"u$(upgrades6)", settings.get_boolean(@"u$(upgrades6)"));
			if (upgrades7 != -1) settings.set_boolean(@"u$(upgrades7)", settings.get_boolean(@"u$(upgrades7)"));
			if (upgrades8 != -1) settings.set_boolean(@"u$(upgrades8)", settings.get_boolean(@"u$(upgrades8)"));
			if (upgrades9 != -1) settings.set_boolean(@"u$(upgrades9)", settings.get_boolean(@"u$(upgrades9)"));
			if (upgrades10 != -1)settings.set_boolean(@"u$(upgrades10)", settings.get_boolean(@"u$(upgrades10)"));
			if (upgrades11 != -1)settings.set_boolean(@"u$(upgrades11)", settings.get_boolean(@"u$(upgrades11)"));
			if (upgrades12 != -1)settings.set_boolean(@"u$(upgrades12)", settings.get_boolean(@"u$(upgrades12)"));

			settings.changed[sname].connect (() => { //Purchased buildings
				amount = settings.get_int(sname);
		    	if (amount == 0) {

		    		modifier = 1;
		    		price = (uint64)(base_cost);
		    		price_64 = price;
		    		Button.label = ("$ " + format(@"$(price_64)"));

					label_name.label =  ("? ? ? ? ?");
					label_name.set_tooltip_text ("? ? ?");
					label_amount.set_tooltip_text ("");
					CPS = CPS - added_CPS;
					added_CPS = 0;
					Button.set_sensitive(true);
				}
				else {
					temp = 1;
					int n;
					for (n = 0; n < amount;n++) {
						temp = temp * 1.15;
					}
					CPS = CPS - added_CPS;
					added_CPS = (base_CPS * amount * modifier);
					CPS = CPS + added_CPS;
					price_64 = 	(uint64)((base_cost)  * temp) ;

					if (price_64 == 0) {
						Button.label = ("- - -");
						Button.set_sensitive(false);
					}

					else {
						Button.label = ("$ " + format(@"$(price_64)"));
						Button.set_sensitive(true);
					}


					label_amount.label = (@"$(amount)");
					label_name.label =  (@"<b>$(name) : </b>");
					label_name.set_tooltip_text (@"$(name) \n$(description)");
					label_amount.set_tooltip_text (@"$((float)added_CPS) CpS");
					temp = 1.15;
				}
				if (mode_button.selected == 0) {
						Button.set_sensitive(false);
					}
		        label_amount.label = (@"$(amount)");

		    });
		    settings.set_int (sname, amount);

			Button.xalign = 0;
			Button.clicked.connect (() => {
				if (Cash >= price_64) {
					Cash = Cash - price_64;
					amount = amount  + 1;
					settings.set_int (sname, amount);
					Buildings = Buildings + 1;
			}});

			label_name.xalign = 0;
			var abox = new Box (Orientation.HORIZONTAL, 2);
			abox.add(label_name);
			abox.add(label_amount);
			abox.homogeneous = true;
			this.homogeneous = true;
			this.add(abox);
			this.add(Button);
		}

		public int UpdateShop() {
			settings.set_int (sname, amount);

			return 0;
		}

	}

class headerbar : Gtk.HeaderBar {

		unichar c;
		int i;

		public string format(string original_) {
			var builder = new StringBuilder ();
			string original = original_.reverse ();

			for (i = 0; original.get_next_char (ref i, out c);) {
   				if (i > 3 && (i - 1) % 3 == 0) builder.append(",");
   				builder.append(@"$(c)");
			}

			return @"$(builder.str)".reverse();
		}


		public int update () {
			this.set_subtitle (@"Cookies: $(format(@"$(Cash)"))  |   CpS: $((float)CPS)");
			return 0;
		}

		public int update_64 () {
			this.set_subtitle (@"Cookies: $(format(@"$(Cash)"))  |   CpS: $((uint64)CPS)");
			return 0;
		}

		public headerbar () {
			this.set_has_subtitle (true);
			//this.set_subtitle (@"$(Cash)");

		}
	}


class MyApp : Gtk.Window
	{

		public MyApp()
		{
			this.title = "Cookie Clicker";
			this.border_width = 10;
			this.width_request = 60;
			this.height_request = 70;
			this.destroy.connect (Gtk.main_quit);
			this.window_position = Gtk.WindowPosition.CENTER;
		}


		public static int main(string[] args)
		{
			Gtk.init (ref args);
			var App = new MyApp ();

			if (Thread.supported () == false) {
				stdout.printf ("Cannot run without thread support!\n");
				return 1;
			}

			settings = new GLib.Settings ("org.felipe.CookieClicker");  //Loading "Save file"
			var wsettings = new GLib.Settings ("org.felipe.CookieClickerWindow");
			Cash = int64.parse(settings.get_string ("cookies"));
			handmade = int64.parse(settings.get_string ("handmade"));

			var thread_a_data = new  Timer();	//CpS Timer
			var header_bar = new headerbar();

			//THEME BUTTON
			var theme_button = new ModeButton();
			theme_button.append_text("Light");
			theme_button.append_text("Dark");
			theme_button.set_active (0);
			theme_button.mode_changed.connect (() => {
				if (theme_button.selected == 1) {
					Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
					wsettings.set_boolean("darktheme", true);
				}
				else {
					Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
					wsettings.set_boolean("darktheme", false);
				}
			});

			mode_button = new ModeButton();
			ubox = new Gtk.Box (Orientation.VERTICAL, 10);

			var button_clicks = new Clicker (header_bar);
			var Cursor =	new Shop ("Cursor" , 15, 0.1, "Autoclicks once every 10 second", "cursor", 0, 0.1, 1,2,3,4);
			var Granma = 	new Shop ("Grandma", 100,	0.5, "A nice grandma\nto bake more cookies.", "granma", 7, 0.3, 8,9,44,110,57,58,59,60,61,62,63,103);
			var Farm = 		new Shop ("Farm", 500,	4, "Grows cookie plants\nfrom cookie seeds", "farm", 10, 1, 11,12,45,111);
			var Factory = 	new Shop ("Factory", 3000, 10, "Produces large quantities\nof cookies", "factory", 13,4,14,15,46,112);
			var Mine = 		new Shop ("Mine", 10000, 40, "Cookie dough and chocolate\nchip mining operation", "mine", 16, 10,17,18,47,113);
			var Ship = 		new Shop ("Shipment", 40000, 100, "Brings fresh cookies\nfrom the cookie planet", "ship", 19, 30, 20,21,48,114);
			var Lab	= 		new Shop ("Alchemy Lab", 200000, 400, "Turns gold into cookies!", "lab",22,100,23,24,49,115);
			var Portal =	new Shop ("Portal", 1666666, 6666, "A door to the Cookieverse", "portal",25,1666,26,27,50,116);
			var Time = 		new Shop ("Time Machine", 123456789, 98765, "Bring cookies from the past\nbefore they are even eaten!", "time",28,9876,29,30,51,117);
			var Anti = 		new Shop ("Cookie Condenser", 3999999999, 999999,"Condences the matter of the universe into cookies", "anti", 99,99999,100,101,102,118 );

			//Starting CpS Thread
			thread_a_data.setvars(header_bar, button_clicks);
			Thread<void*> thread_a = new Thread<void*> ("thread_a", thread_a_data.thread_func);
			if (thread_a_data == thread_a_data);
			if (thread_a == thread_a);

			var abox = new Box (Orientation.HORIZONTAL, 10);
			var vbox = new Box (Orientation.VERTICAL, 10);
			abox.add (vbox);
			abox.add (button_clicks);
			vbox.add (Cursor);
			vbox.add (Granma);
			vbox.add (Farm);
			vbox.add (Factory);
			vbox.add (Mine);
			vbox.add (Ship);
			vbox.add (Lab);
			vbox.add (Portal);
			vbox.add (Time);
			vbox.add (Anti);

			var upgrades = new UpgradesControler();
			var upgrades_title = new Label ("No upgrades avalible");
			upgrades.Populate(); //Generating Upgrade objects
			abox.add(ubox); //Ubox: Enabled upgrades are stored here

			//Mode Button
			mode_button.append_text("Upgrades");
			mode_button.append_text("Clicker");

			mode_button.set_active(1); //Enables Clicker as default
			bool mode = true; //Checker if ubox has something
			ubox.add(upgrades_title);
			ubox.add.connect(() => {
				if (mode == true) {
					ubox.remove(upgrades_title);
					mode = false;
				}
			});
			
			ubox.remove.connect(() => {
				if (mode == false) {
					ubox.add(upgrades_title);
					mode = true;
				}
			});

			mode_button.mode_changed.connect (() => {
				string CashString = @"$(Cash)";
				settings.set_string ("cookies", CashString);
				if (mode_button.selected == 0){ //Upgrades box enabled
					unlocked = 0;
					button_clicks.visible = false;
					ubox.visible = true;
				}
				else { //Clicker Enabled
					ubox.visible = false;
					button_clicks.visible = true;
				}
			});
			
			header_bar.pack_end (mode_button);
			header_bar.pack_start (theme_button);

			header_bar.show_close_button = true;
			App.set_titlebar (header_bar);
			App.title = "Cookie Clicker";

 			abox.homogeneous = true;

			App.add (abox);
			App.show_all ();
			ubox.visible = false;

			if (wsettings.get_boolean("darktheme") == true) {
				theme_button.set_active (1);
				//Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true; //Dark theme?
			}

			App.resize(880,5);
			Gtk.main ();

			settings.set_string ("cookies", @"$(Cash)");
			settings.set_string ("handmade", @"$(handmade)");

			return 0;
		}
	}
}
