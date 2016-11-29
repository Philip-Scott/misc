



public class Languages.Window : Gtk.Window {
    public Gtk.Entry regex;
    public Gtk.TextView text;

    public Gtk.Label output;
    public Gtk.TextView result;

    public Window () {
        build_ui ();
        connect_signals ();
    }

    private void connect_signals () {
        destroy.connect (Gtk.main_quit);

        regex.activate.connect (() => {
            if (regex.text.strip () != "") {
                var converter = new Languages.PostfixConverter ();
                var postfix = converter.convert (regex.text);

                var to_afn = new Languages.PostfixToAFN ();
                to_afn.convert (postfix);

                stdout.printf (postfix_output);
                output.label = postfix_output;
            }
        });
    }

    private void build_ui () {
        window_position = Gtk.WindowPosition.CENTER;
        width_request = 560;
        height_request = 600;

        var headerbar = new Gtk.HeaderBar ();
        headerbar.title = "Regex-to-Automata";
        headerbar.subtitle = "By: Felipe Escoto";
        headerbar.set_show_close_button (true);

        set_titlebar (headerbar);
        hide_titlebar_when_maximized = true;

        output = new Gtk.Label ("");
        output.use_markup = true;
        output.valign = Gtk.Align.START;
        output.justify = Gtk.Justification.LEFT;

        regex = new Gtk.Entry ();
        regex.get_style_context ().add_class ("h2");
        regex.set_placeholder_text ("Regular expression...");

        text = new Gtk.TextView ();
        text.expand = true;

        result = new Gtk.TextView ();
        result.expand = true;

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.row_spacing = 12;
        grid.column_spacing = 6;
        grid.orientation = Gtk.Orientation.VERTICAL;

        var pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        var frame1 = new Gtk.Frame (null);
        frame1.add (text);

        var output_scroll = new Gtk.ScrolledWindow (null, null);
        output_scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        output_scroll.add (output);

        pane.pack1 (frame1, true, false);

        grid.attach (regex, 0, 0, 2, 1);
        grid.attach (pane, 0, 1, 1, 1);
        grid.attach (output_scroll, 1, 1, 1, 1);
        this.add (grid);

        this.set_keep_above (true);
        this.show_all ();
    }
}
