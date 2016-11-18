
/*
* Unit testing geting a human string from a gps location using Geocode
* 
* How to compile: $ valac geo.vala --pkg geocode-glib-1.0
*/
public class GeolocationTest {
    public static int tests = 0;
    public static int failed = 0;

    public static void main (string[] args) {
        assert_equals ("Dallas, Texas", 32.82648265054915, -96.82250976312508);
        assert_equals ("Arlington, Texas", 32.74667668984993, -97.094764706972748);
        assert_equals ("Fort Worth, Texas", 32.754761563808096, -97.33234405267586);
        assert_equals ("Zapopan, Jalisco", 20.669206968662802, -103.42151641595711);
        assert_equals ("Zapopan, Jalisco", 20.617802374844526, -103.45584869134774);
        assert_equals ("Hacienda Santa Fe, Jalisco", 20.51993051590355, -103.37890148131589);
        assert_equals ("Tlajomulco de Zúñiga, Jalisco", 20.47249073624735, -103.44623565423836);
        assert_equals ("Chapala, Jalisco", 20.30055935449265, -103.19286346185555);
        assert_equals ("Montréal, Québec", 45.497954621981734, -73.56685638177743);
        assert_equals ("NYC, New York", 40.773075230678714, -73.97341250907601);
        assert_equals ("Snohomish, Washington", 47.91287560000001, -122.09818480000001);

        // Currently fails returning Île-de-France instead of France. 
        // It's not wrong, but not what is expected
        assert_equals ("Paris, France", 48.856614, 2.3522219000000177); 

        stdout.printf ("\nResults:\nTests run: %d, Failures: %d\n", tests, failed);
    }

    private static string get_place (double lat, double long) {
        string output = "";
        var location = new Geocode.Location (lat, long);
        var reverse = new Geocode.Reverse.for_location (location);

        try {
            Geocode.Place place = reverse.resolve ();

            if (place.get_state () != null) {
                if (place.get_town () != null) {
                    output = place.get_town () + ", " + place.get_state ();
                } else if (place.get_county () != null) {
                    output = place.get_county () + ", " + place.get_state ();
                } else {
                    output = place.get_state () + ", " + place.get_country ();
                }
            }
        } catch (Error e) {
            warning ("Failed to obtain place: %s", e.message);
        }

        return output;
    }

    private static void assert_equals (string expected, double lat, double long) {
        Geocode.Place place;
        var location = GeolocationTest.get_place (lat, long);
        tests++;
        if (expected != location) {
            stderr.printf ("\nGeolocationTest failed: \nExpected :%s \nResult   :%s\n", expected, location);
            failed++;
        }
    }
}
