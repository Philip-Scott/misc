
public int ID = 0;
public string postfix_output;
List<Languages.Node> nodes;

public class Languages.Node : Object {
    // Input, list of outputs
    public HashTable<string, Gee.ArrayList<Languages.Node>> transitions;
    public string index;

    construct {
        transitions = new HashTable<string, Gee.ArrayList<Languages.Node>>(str_hash, str_equal);
        index = (ID++).to_string ();
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
        postfix_output += "Node %s \n".printf (index);

        transitions.foreach ((key, val) => {
            foreach (var node in val) {
                postfix_output += "<i>%s : %s</i>\n".printf (key, node.index);
            }
       	});
    }

    public void set_transitions (Languages.Node node_) {
        node_.transitions.foreach ((key, val) => {
            foreach (var node in val) {
                add_transition (node, key);
            }
       	});
    }
}

public class NDA : Object {
    public Languages.Node? initial_node = null;
    public Languages.Node? final_node = null;

    public NDA (string transition) {
        postfix_output = "";
        initial_node = new Languages.Node ();
        final_node = new Languages.Node ();

        initial_node.add_transition (final_node, transition);
    }
}

public class Languages.PostfixToAFN : Object {
    Queue<NDA> on_hold;

    construct {
        ID = 0;

        nodes = new List<Node>();
        on_hold = new Queue<NDA> ();
    }

    public void print_transitions (NDA a) {
        postfix_output = "<b>Initial: %s</b>\n<b>Final: %s\n</b>".printf (a.initial_node.index, a.final_node.index);

        foreach (var node in nodes) {
            node.print_transitions ();
        }
    }

    // Removes:
    // a ----> b ----> c = a ----> c
    //   null    null        null
    public void remove_double_nulls (NDA a, List<Languages.Node> nodes) {
        return;
        bool removed = false;
        do {
            removed = false;
            foreach (var node_a in nodes) {
                node_a.transitions.foreach ((key_a, transitions_a) => {
                    foreach (var node_b in transitions_a) {
                        stderr.printf ("Checking node b: %s\n", node_b.index);
                        node_b.transitions.foreach ((key_b, transitions_b) => {
                            foreach (var node_c in transitions_b) {
                                if (key_a == key_b && key_a == "null" && node_a.index != node_b.index) {
                                    if (node_b.transitions.size () == 1) {
                                        // Removing transition
                                        stderr.printf ("2 chained nulls found: %s -> %s -> %s\n", node_a.index, node_b.index, node_c.index);
                                        removed = override_transition (node_a, node_b);

                                    }
                                }
                            }
                        });
                    }
                });
            }
        } while (removed);
    }

    public bool override_transition (Languages.Node to_remove, Languages.Node replacement) {
        bool found = false;
        foreach (var node_a in nodes) {
            node_a.transitions.foreach ((key_a, transitions_a) => {
                foreach (var node_b in transitions_a) {
                    if (node_b.index == to_remove.index) {
                        node_b.index = replacement.index;
                        found = true;
                    }
                }
            });
        }

        if (found) {
            nodes.remove (to_remove);
        }

        return found;
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
        new_i.add_transition (new_f, "null");

        a.final_node.add_transition (a.initial_node, "null");
        a.final_node.add_transition (new_f, "null");

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
