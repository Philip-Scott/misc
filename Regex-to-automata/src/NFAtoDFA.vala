public const string[] alphabet = {"a","b","c","d","e"};

public class Languages.eClosure {
    public Languages.Node node;
    public List<Languages.Node> outputs;

    public eClosure (Languages.Node node) {
        this.node = node;
        outputs = new List<Languages.Node>();
        set_closures ();
    }

    public void set_closures () {
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
        }
    }

    public void run_afn (NDA automata) {
        current_states = new List<Languages.Node>();
        current_states.append (automata.initial_node);
    }

    private eClosure? get_closure_of (Languages.Node node) {
        foreach (var closure in closures) {
            if (closure.node.index == node.index) return closure;
        }

        return null;
    }
}
