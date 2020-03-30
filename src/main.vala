public class Yunlauncher : Object {

    const int FINDING_HEADER = 0;
    const int FINDING_TAGS = 1;

    public static int main(string[] args) {
        // 言語の取得
        string lang = Environment.get_variable("LANG").split("_")[0];
        stdout.printf(@"Hello, world!\n言語は$lang\n");

        // デスクトップエントリの列挙
        string path = "/usr/share/applications/";
        List<string> filenames = new List<string>();
        
        try {
            File directory = File.new_for_path(path);
            FileEnumerator enumerator = directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);
            FileInfo info;
            while ((info = enumerator.next_file()) != null) {
                string name = info.get_name();
                if (info.get_file_type() == FileType.REGULAR && name.contains(".desktop"))
                    filenames.append(path + name);
            }
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
            return 1;
        }

        // デスクトップエントリの解析
        List<DesktopEntry> entries = new List<DesktopEntry>();

        foreach (string filename in filenames) {
            // ファイルを読み込む
            File file = File.new_for_path(filename);
            try {
                // 行を読み込む
                DataInputStream dis = new DataInputStream(file.read());
                string name = "";
                string comment = "";
                string icon = "";
                string exec = "";
                bool nodisplay = false;

                string line;
                int mode = FINDING_HEADER;
                // 解析
                while ((line = dis.read_line(null)) != null) {
                    line = line.strip();
                    // コメントは無視する
                    if (line == "" || line[0] == '#') { continue; }
                    // ヘッダを探す
                    if (mode == FINDING_HEADER) {
                        // タグが見つかったらタグを探す
                        if (line == "[Desktop Entry]") {
                            mode = FINDING_TAGS;
                            continue;
                        }
                    // タグを探す
                    } else if (mode == FINDING_TAGS) {
                        // ヘッダが見つかったら終了
                        if (line[0] == '[') { break; }

                        string param = line.split("=")[0];
                        string _value = line[param.length + 1:line.length].chug();
                        param = param.chomp();
                        
                        if (param == @"Name[$lang]") {              // 名前
                            name = _value;
                        } else if (param == "Name") {
                            if (name == "") { name = _value; }
                        } else if (param == @"Comment[$lang]") {    // コメント
                            comment = _value;
                        } else if (param == "Comment") {
                            if (comment == "") { comment = _value; }
                        } else if (param == "Icon") {               // アイコン
                            icon = _value;
                        } else if (param == "Exec") {               // コマンド
                            exec = _value;
                        } else if (param == "NoDisplay" && _value == "true") {
                            nodisplay = true;
                        }
                        
                    }
                }
                // リストに追加
                if (!nodisplay)
                    entries.append(new DesktopEntry(name, comment, icon, exec));
            } catch (Error e) {
                stderr.printf("%s\n", e.message);
                return 1;
            }
        }

        CompareFunc<DesktopEntry> comparefunc = (a, b) => {
            if (a.name < b.name) {
                return -1;
            } else if (a.name == b.name) {
                return 0;
            } else {
                return 1;
            }
        };

        entries.sort(comparefunc);

        /*foreach (DesktopEntry i in entries) {
            stdout.printf("%s\n%s\n%s\n%s\n\n", i.name, i.comment, i.icon, i.exec);
        }*/

        // ウィンドウの表示
        Gtk.init(ref args);
        Gtk.CssProvider cssprovider = new Gtk.CssProvider();
        cssprovider.load_from_path("/home/mine/Programming/launcher/custom.css");
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), cssprovider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
        MenuWindow window = new MenuWindow(entries);
        Gtk.main();

        return 0;
    }
}