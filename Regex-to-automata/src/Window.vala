



public class Languages.Window : Gtk.Window {
    public Gtk.Entry regex;
    public Gtk.TextView text;

    public Gtk.Label output_dirty;
    public Gtk.Label output_clean;
    public Gtk.TextView result;
    public Gtk.Label results;

    public Window () {
        build_ui ();
        connect_signals ();
    }

    private void connect_signals () {
        destroy.connect (Gtk.main_quit);

        regex.changed.connect (run_test);
        text.buffer.changed.connect (run_test);
    }

    private void run_test () {
        if (regex.text.strip () != "") {
            var converter = new Languages.PostfixConverter ();
            var postfix = converter.convert (regex.text);

            var to_afn = new Languages.PostfixToAFN ();
            var converted = to_afn.convert (postfix);

            to_afn.print_transitions (converted);
            output_dirty.label = postfix_output.replace ("&", "&amp;");

            to_afn.remove_double_nulls (converted, nodes);
            to_afn.print_transitions (converted);

            var dfa = new NFAtoDFA ();

            to_afn.print_transitions (converted);
            output_clean.label = dfa.output;

            var input_data = text.buffer.text.split ("\n");
            results.label = "";

            foreach (var line in input_data) {
                if (dfa.run_afn (converted, line)) {
                    results.label += "✓\n";
                } else {
                    results.label += "✗\n";
                }
            }

            if (output_dirty.label == output_clean.label) {
                output_clean.label = "";
            }

            stdout.printf (postfix_output);
        }
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

        output_dirty = new Gtk.Label ("");
        output_dirty.use_markup = true;
        output_dirty.valign = Gtk.Align.START;
        output_dirty.justify = Gtk.Justification.LEFT;

        output_clean = new Gtk.Label ("");
        output_clean.use_markup = true;
        output_clean.valign = Gtk.Align.START;
        output_clean.justify = Gtk.Justification.LEFT;

        results = new Gtk.Label ("");
        results.use_markup = true;
        results.valign = Gtk.Align.START;
        results.justify = Gtk.Justification.LEFT;
        results.get_style_context ().add_class ("h3");

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

        var output_scroll_dirty = new Gtk.ScrolledWindow (null, null);
        output_scroll_dirty.hscrollbar_policy = Gtk.PolicyType.NEVER;
        output_scroll_dirty.add (output_dirty);

        var output_scroll_clean = new Gtk.ScrolledWindow (null, null);
        output_scroll_clean.hscrollbar_policy = Gtk.PolicyType.NEVER;
        output_scroll_clean.add (output_clean);

        pane.pack1 (frame1, true, false);

        grid.attach (regex, 0, 0, 4, 1);
        grid.attach (results, 0, 1, 1, 1);
        grid.attach (pane, 1, 1, 1, 1);
        grid.attach (output_scroll_dirty, 2, 1, 1, 1);
        grid.attach (output_scroll_clean, 3, 1, 1, 1);
        this.add (grid);

        this.set_keep_above (true);
        this.show_all ();
    }
}
