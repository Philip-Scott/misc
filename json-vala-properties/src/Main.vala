/*
 *  Copyright (C) 2019 Felipe Escoto <felescoto95@hotmail.com>
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

public class Main {

    public static int main (string[] args) {
        var parser = new Json.Parser ();
        parser.load_from_data (TEST_JSON);

        var object = parser.get_root ().get_object ();
        var test = new FileFormat.Testing.TestObject (object);

        test.class_name = "Second Year";

        var second_element = test.classroom.elements.get(1) as FileFormat.Testing.Person;
        second_element.name = "Felipe";
        second_element.skill.level = 42;

        var first_element = test.classroom.elements.get(0) as FileFormat.Testing.Person;
        test.classroom.remove (first_element);

        test.prop_to_null = null;

        print (test.to_string (true));


        print ("\n\nJson Reset test\n\n");
        parser = new Json.Parser ();
        parser.load_from_data (TEST_JSON);

        object = parser.get_root ().get_object ();

        test.override_properties_from_json (object);

        print (test.to_string (true));

        print ("\n\n Testing changes on reset\n");

        first_element = test.classroom.elements.get(0) as FileFormat.Testing.Person;
        first_element.name = "New Name";
        first_element.skill.skill_name = "Smith";
        first_element.skill.level = 1;


        print (test.to_string (true));
        return 0;
    }

    const string TEST_JSON = """
        {
            "invisible-prop" : "should stay when printed",
            "prop-to-null": "should not be printed the first time",
            "class-name": "string content",
            "classroom" : [
                {
                    "name": "Test 1",
                    "skill":
                        {
                            "skill-name": "Sword Figher",
                            "level": 1
                        }
                }, {
                    "name" : "Test 2"
                }
            ]
        }

    """;
}