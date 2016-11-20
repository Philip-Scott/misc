/*
Infix to Postfix Converter

valac --pkg gio-2.0  InfixConverter.vala
*/

public class Languages.Operand {
    public int precedence;
    public string operator;

    public Operand (string o, int p) {
        precedence = p;
        operator = o;
        Languages.PostfixConverter.SYMBOLS += o;
    }
}

public class Languages.PostfixConverter {
    public static string SYMBOLS = "";

    List<Operand> operators = new List<Operand>();

    public PostfixConverter () {
        SYMBOLS = "";
        operators.append (new Operand ("*", 5));
        operators.append (new Operand ("+", 4));
        operators.append (new Operand (".", 4));
        operators.append (new Operand (",", 3));
        operators.append (new Operand (")", 2));
        operators.append (new Operand ("(", 1));
    }

    public Queue<string> convert (string infix) {
        var expr = cleanup (infix);
        var input_as_array = expr.split(" ");

        var input = new Queue<string> ();
        var op = new Queue<string> ();
        var output = new Queue<string> ();

        for (int i = input_as_array.length - 1; i >= 0; i--) {
          input.push_head (input_as_array[i]);
        }

        int current_pref = 0;
        // RPN Algorithm
        while (!input.is_empty()) {
        switch (current_pref = pref (input.peek_head ())){
            //Input is Value
            case int.MIN:
                //stderr.printf ("Parsing value: %s\n", input.peek_head ());
                output.push_head (input.pop_head ());
                break;
            case 1: // (
                //stderr.printf ("Parsing 1: %s\n", input.peek_head ());
                op.push_head (input.pop_head ());
                break;
            case 2: // )
                //stderr.printf ("Parsing value: %s\n", input.peek_head ());
                while (!(op.peek_head () == "(") && !op.is_empty()) {
                    output.push_head (op.pop_head ());
                }

                op.pop_head ();
                input.pop_head ();
                break;
            default: // Operator
                //stderr.printf ("Parsing default: %s\n", input.peek_head ());
                while(pref (op.peek_head ()) >= pref (input.peek_head ())) {
                    output.push_head (op.pop_head ());
                }

                op.push_head (input.pop_head ());
                break;
            }
        }

        var postfix = print_stack (output);
        stdout.printf ("%s\n", postfix);

        return output;
    }

    private string print_stack (Queue<string> queue) {
        string out = "";
        foreach (var value in queue.head) {
            if (value == "") continue;
            out = value + " "+ out;
        }

        return out.replace ("  ", " ");
    }

    private string cleanup (string s) {
        string sn = "(" + s + ")";
        string str = "";
        bool previous_is_char = false;
        // Add spaces between operators
        for (int i = 0; i < sn.length; i++) {
            if (SYMBOLS.contains (sn.get_char(i).to_string())) {
                str += " " + sn.get_char(i).to_string () + " ";
            } else {
//                if (previous_is_char) {
                    //str += " . " + sn.get_char(i).to_string ();
  //              } else {
                    str += sn.get_char(i).to_string ();
    //                previous_is_char = true;
      //          }
            }
        }

        stderr.printf ("Cleanup: %s\n",str.strip ());

        return str.strip ();
    }

    private int pref (string op) {
        int prf = int.MIN;
        foreach (var operator in operators) {
            if (operator.operator == op) {
                prf = operator.precedence;
                break;
            }
        }

        return prf;
    }
}
