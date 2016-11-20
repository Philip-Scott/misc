


public static void main (string[] args) {
    var converter = new Languages.PostfixConverter ();
    var postfix = converter.convert (args[1]);
    
    var to_afn = new Languages.PostfixToAFN ();
    to_afn.convert (postfix);
    
}
