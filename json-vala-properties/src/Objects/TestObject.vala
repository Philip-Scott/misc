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

public class FileFormat.Testing.TestObject : FileFormat.JsonObject {

    public string class_name { get; set; }
    public string prop_to_null { get; set; }

    public ClassroomArray classroom { get; set; }

    public TestObject (Json.Object object) {
        Object (object: object);
        connect_signals ();
    }
}

public class FileFormat.Testing.Person : FileFormat.JsonObject {
    public string name { get; set; default = ""; }
    public FileFormat.Testing.Skill skill { get; set; }

    public Person () {
        Object (object: new Json.Object ());
        connect_signals ();
    }
}

public class FileFormat.Testing.Skill : FileFormat.JsonObject {
    public string skill_name { get; set; default = ""; }
    public int level { get; set; }
}

public class FileFormat.Testing.ClassroomArray : FileFormat.JsonObjectArray {

    public ClassroomArray (Json.Object object, string property_name) {
        Object (object: object, property_name: property_name);
    }

    public override Type get_type_of_array (Json.Object object) {
        return typeof (Person);
    }
}
