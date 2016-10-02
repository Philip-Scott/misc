/*
View, Read, and Write files from a Zip Files, just as if it's a directory

valac --pkg gio-2.0 --pkg libarchive ZipViewer.vala
*/
public class ZipViewer {

    private Archive.Read? read = null;
    
    public void open_archive (string uri) {
        //stdout.printf ("OPENING FILE\n");
        try {
            read = new Archive.Read ();
            check_ok (read.support_filter_all ());
            check_ok (read.support_format_all ());

            check_ok (read.open_filename (uri, 10240));
        } catch (IOError e) {
            stderr.printf ("Error %s", e.message);
            read = null;
        }
    }

    public void show_all () {
        if (read == null) return;
        //stdout.printf ("READING FILE\n");
        unowned Archive.Entry entry;
        while (read.next_header (out entry) == Archive.Result.OK) {
            stdout.printf ("%s\n", entry.pathname ());
            read.read_data_skip ();
        }
    }

    public string read_file (string file_name) {
        if (read == null) return "";
    
        void* data = null;

        unowned Archive.Entry entry;
        while (read.next_header (out entry) == Archive.Result.OK) {
            if (entry.pathname () == file_name) {   
                stderr.printf ("File found: %d\n", (int) entry.size());
                read.read_data (data, 800);
            } 
        
            read.read_data_skip ();
        }
        

        //stderr.printf ("DATA: " + data.to_string() + "\n");

        //read_line ();

        return "";
    }

    public void write () {
        if (read == null) return;

    }

    private void check_ok (Archive.Result r) throws IOError {
        if (r == Archive.Result.OK)
            return;
        if (r == Archive.Result.WARN)
            return;
        throw new IOError.FAILED ("libarchive returned an error");
    }

    public void write_archive(string outname, string[] filenames) {
            Archive.Write archive = new Archive.Write();
            archive.set_compression_gzip();
            archive.set_format(Archive.Format.ZIP);
            //archive.open(OpenCallback,WriteCallback,CloseCallback);
            int i=0;
            while (i<filenames.length) {
                //Posix.Stat stat = Posix.Stat(filenames[i]);
                Archive.Entry entry = new Archive.Entry();
                //entry.copy_stat(stat);
                entry.set_pathname(filenames[i]);
                //Write.write_header(entry);
                i++;
            }
    }

    public static int main (string[] args) {
        var archive = new ZipViewer ();

        archive.open_archive (args[1]);
        //archive.show_all ();
        archive.read_file ("README.md");
        return 0;
    }
}
