
public int ID = 0;
List<Languages.Node> nodes;

public class Languages.Node : Object {
    // Input, list of outputs
    public HashTable<string, Gee.ArrayList<Languages.Node>> transitions;
    public int index;

    construct {
        transitions = new HashTable<string, Gee.ArrayList<Languages.Node>>(str_hash, str_equal);
        index = ID++;

        //stdout.printf ("Creating node %d\n", index);
        nodes.append (this);
    }

    public void add_transition (Languages.Node node, string input) {
        weak Gee.List<Languages.Node> list;

        if (!transitions.contains (input)) {
            transitions.insert (input, new Gee.ArrayList<Languages.Node>());
        } else {
            stdout.printf ("%s\n", input);
        }

        list = transitions.get (input);
        list.add (node);
    }

    public void print_transitions () {
        stdout.printf ("Node %d \n", index);

        transitions.foreach ((key, val) => {
            foreach (var node in val) {
                stdout.printf ("  %s : %d\n", key, node.index);
            }
       	});
    }

    public void set_transitions (Languages.Node node_) {
        node_.transitions.foreach ((key, val) => {
            foreach (var node in val) {
                //stdout.printf ("Moving %s : %d to %d\n", key, node.index, index);
                add_transition (node, key);
            }
       	});
    }
}

public class NDA : Object {
    public Languages.Node? initial_node = null;
    public Languages.Node? final_node = null;

    public NDA (string transition) {
        ID = 0;
        initial_node = new Languages.Node ();
        final_node = new Languages.Node ();

        initial_node.add_transition (final_node, transition);
    }
}

public class Languages.PostfixToAFN : Object {
    Queue<NDA> on_hold;

    construct {
        nodes = new List<Node>();
        on_hold = new Queue<NDA> ();
    }

    public void print_transitions () {
        foreach (var node in nodes) {
            node.print_transitions ();
        }
    }

    public NDA? convert (Queue<string> input_stack) {
        string i;
        while ((i = input_stack.pop_tail ()) != null) {
            switch (i) {
                case ".":
                    on_hold.push_head (concatenate (on_hold.pop_head (), on_hold.pop_head ()));
                    break;
                case ",":
                    on_hold.push_head (or_method (on_hold.pop_head (), on_hold.pop_head ()));
                    break;
                case "*":
                    on_hold.push_head (closure (on_hold.pop_head ()));
                    break;
                case "+":
                    on_hold.push_head (closure_plus (on_hold.pop_head ()));
                    break;
                case "": break;
                default:
                    var letter = new NDA (i);
                    on_hold.push_head (letter);
                break;
            }
        }

        stderr.printf ("Initial: %d\nFinal: %d\n", on_hold.peek_head ().initial_node.index, on_hold.peek_head ().final_node.index);
        print_transitions ();

        return on_hold.pop_head ();
    }

    private NDA concatenate (NDA b, NDA a) {
        a.final_node.set_transitions (b.initial_node);
        a.final_node = b.final_node;

        nodes.remove (b.initial_node);

        return a;
    }

    private NDA or_method (NDA b, NDA a) {
        a.initial_node.set_transitions (b.initial_node);

        nodes.remove (b.initial_node);

        var new_node = new Languages.Node ();

        a.final_node.add_transition (new_node, "null");
        b.final_node.add_transition (new_node, "null");

        a.final_node = new_node;

        return a;
    }

    private NDA closure (NDA a) {
        var new_i = new Languages.Node ();
        var new_f = new Languages.Node ();

        new_i.add_transition (a.initial_node, "null");
        a.final_node.add_transition (a.initial_node, "null");
        a.initial_node.add_transition (new_f, "null");

        a.initial_node = new_i;
        a.final_node = new_f;

        return a;
    }

    private NDA closure_plus (NDA a) {
        var new_f = new Languages.Node ();

        a.final_node.add_transition (a.initial_node, "null");
        a.final_node.add_transition (new_f, "null");

        a.final_node = new_f;

        return a;
    }
}
