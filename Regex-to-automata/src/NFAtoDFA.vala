public const string[] alphabet = {"a","b","c","d","e"};

public class Languages.eClosure {
    public Languages.Node node;
    public List<Languages.Node> outputs;

    public eClosure (Languages.Node node) {
        this.node = node;
        outputs = new List<Languages.Node>();
        set_closures ();
    }

    private void set_closures () {
        outputs.append (node);
        follow_node (node);
    }

    // Returns true if it had another null
    private bool follow_node (Languages.Node node) {
        bool followed = false;
        node.transitions.foreach ((key_a, transitions_a) => {
            if (key_a == "null") {
                foreach (var node_o in transitions_a) {
                    if (node_has_null (node_o)) {
                        follow_node (node_o);
                    } else {
                        outputs.append (node_o);
                    }
                }
            }
        });

        return followed;
    }

    private bool node_has_null (Languages.Node node) {
        bool is_null = false;
        //stderr.printf ("checking for null: %s\n", node.index);
        node.transitions.foreach ((key_a, transitions_a) => {
            if (key_a == "null") is_null = true;
        });

        return is_null;
    }

    public string get_closures () {
        string output =  "e-closure (%s): ".printf (node.index);
        foreach (var nod in outputs) {
            output += "%s ".printf (nod.index);
        }

        stdout.printf ("%s\n", output);
        return output + "\n";
    }
}

public int DFAIndex;

public class Languages.NFAtoDFA {
    public string output = "";
    public List<eClosure> closures;

    public List<Languages.Node> current_states;

    public NFAtoDFA () {
        DFAIndex = 1;
        closures = new List<eClosure>();
        foreach (var node in nodes) {
            var eclosure = new eClosure (node);
            output += eclosure.get_closures ();

            closures.append (eclosure);
        }
    }

    public bool run_afn (NDA automata, string to_check) {
        this.current_states = new List<Languages.Node>();
        add_closure_nodes (get_closure_of (automata.initial_node), ref current_states);

        var char_array = to_check.to_utf8 ();

        foreach (var input in char_array) {
            print_current_states (this.current_states, input);
            this.current_states = run_afn_step (this.current_states, input);
        }

        return has_final_step (ref current_states, automata.final_node);
    }

    private List<Languages.Node> run_afn_step (List<Languages.Node> current_states, char letter) {
        var new_states = new List<Languages.Node>();

        foreach (var node in current_states) {
            if (node.transitions.contains (letter.to_string ())) {
                var outputs = node.transitions.get (letter.to_string ());

                foreach (var out_node in outputs) {
                    add_closure_nodes (get_closure_of (out_node), ref new_states);
                }
            }
            
            if (node.transitions.contains ("&")) {
                var outputs = node.transitions.get ("&");

                foreach (var out_node in outputs) {
                    add_closure_nodes (get_closure_of (out_node), ref new_states);
                }
            }
        }

        return new_states;
    }

    private bool has_final_step (ref List<Languages.Node> states, Languages.Node node) {
        foreach (var state in states) {
            if (state.index == node.index) {
                return true;
            }
        }

        return false;
    }

    private void add_closure_nodes (eClosure closure, ref List<Languages.Node> states) {
        foreach (var node in closure.outputs) {
            if (states.index (node) == -1) {
                states.append (node);
            }
        }
    }

    private eClosure? get_closure_of (Languages.Node node) {
        foreach (var closure in closures) {
            if (closure.node.index == node.index) {
                return closure;
            }
        }

        return null;
    }

    private void print_current_states (List<Languages.Node> states, char letter) {
        string output = @"AFN run: $letter :";

        foreach (var node in states) {
            output += " %s".printf (node.index);
        }

        stdout.printf (output + "\n");
    }
}
