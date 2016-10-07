/*
View, Read, and Write files from a Zip Files, just as if it's a directory

valac --pkg gio-2.0  ZipViewer.vala
*/
public class ZipViewer : Object {
    const ZlibCompressorFormat FORMAT = ZlibCompressorFormat.GZIP;

    private string TEMP_DIR;
    private string uri;

    public ZipViewer (string uri) {
        this.uri = uri;
    }

    void compress (File source, File dest) throws Error {
        convert (source, dest, new ZlibCompressor (FORMAT));
    }

    void decompress (File source, File dest) throws Error {
        convert (source, dest, new ZlibDecompressor (FORMAT));
    }

    void convert (File source, File dest, Converter converter) throws Error {
        var src_stream = source.read ();
        var dst_stream = dest.replace (null, false, 0);
        var conv_stream = new ConverterOutputStream (dst_stream, converter);
        // 'splice' pumps all data from an InputStream to an OutputStream
        conv_stream.splice (src_stream, 0);
    }

    public string read_file (string file_name) {
        return "";
    }

    public void write () {

    }

    public void write_archive(string outname, string[] filenames) {

    }

    public static int main (string[] args) {
        var archive = new ZipViewer (args[1]);

        return 0;
    }
}
