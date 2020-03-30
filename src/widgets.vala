// デスクトップエントリのクラス
public class DesktopEntry : Object {

    private string _name = "";                     // 名前
    private string _comment = "";                  // コメント
    private string _icon = "";                     // アイコン
    private string _exec = "";                     // コマンド
    private Gtk.Button _button;                    // ボタン

    // 初期化
    public DesktopEntry(string name, string comment, string icon, string exec) {
        _name = name;
        _comment = comment;
        _icon = icon;
        _exec = exec;
        // _button = new Gtk.Button();
    }

    private Gtk.Button make_button() {
        return new Gtk.Button();
    }

    // プロパティ
    public string name {
        get { return _name; }
        set { _name = value; }
    }

    public string comment {
        get { return _comment; }
        set { _comment = value; }
    }

    public string icon {
        get { return _icon; }
        set { _icon = value; }
    }

    public string exec {
        get { return _exec; }
        set { _exec = value; }
    }

    // ボタンのアドレスを取得
    public Gtk.Button get_button() {
        return _button;
    }
}

// メニュー用ブタンのクラス
public class MenuButton : Gtk.Button {

    public MenuButton(DesktopEntry entry) {
        Gtk.Box buttonbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
        this.add(buttonbox);
        Gtk.Image buttonicon = new Gtk.Image.from_icon_name(entry.icon, Gtk.IconSize.DIALOG);
        buttonicon.set_pixel_size(48);
        buttonbox.pack_start(buttonicon, true, true, 0);

        Gtk.Label buttonlabel = new Gtk.Label(entry.name);
        buttonlabel.ellipsize = Pango.EllipsizeMode.END;
        buttonbox.pack_start(buttonlabel, true, true, 0);
    }
}

// メニューウィンドウのクラス
public class MenuWindow : Gtk.Window {

    private unowned List<DesktopEntry> _entries;
    public const int COLUMN = 6;
    public const int ROW = 5;

    public MenuWindow(List<DesktopEntry> entries) {
        _entries = entries;
        // this.resizable = false;
        // this.decorated = false;
        this.set_default_size(830, 562);
        this.skip_taskbar_hint = true;
        this.set_position(Gtk.WindowPosition.CENTER_ALWAYS);

        // 検索ボックス
        Gtk.SearchEntry searchentry = new Gtk.SearchEntry();
        this.set_titlebar(searchentry);

        // コンテナ
        Gtk.Box mainbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
        this.add(mainbox);
        // メニュー用スタック
        Gtk.Stack stack = new Gtk.Stack();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.transition_duration = 500;
        mainbox.pack_start(stack, true, true, 0);

        // ページを作成
        for (int page = 0; page < (int)Math.ceil(_entries.length() / (COLUMN * ROW)); page++) {
            Gtk.Grid grid = new Gtk.Grid();
            grid.column_spacing = COLUMN;
            grid.row_spacing = ROW;
            for (int y = 0; y < ROW; y++) {
                for (int x = 0; x < COLUMN; x++) {
                    int index = page * ((COLUMN + 1) * (ROW + 1)) + y * (ROW + 1) + x;
                    if (index >= _entries.length()) { break; }

                    // ボタンの作成
                    /*Gtk.Button button = new Gtk.Button();
                    Gtk.Box buttonbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);*/
                    MenuButton button = new MenuButton(entries.nth_data(index));
                    
                    /*button.add(buttonbox);
                    Gtk.Image buttonicon = new Gtk.Image.from_icon_name(entries.nth_data(index).icon, Gtk.IconSize.DIALOG);
                    buttonicon.set_pixel_size(48);
                    buttonbox.pack_start(buttonicon, true, true, 0);

                    Gtk.Label buttonlabel = new Gtk.Label(entries.nth_data(index).name);
                    buttonlabel.ellipsize = Pango.EllipsizeMode.END;
                    buttonbox.pack_start(buttonlabel, true, true, 0);*/

                    grid.attach(button, x, y, 1, 1);
                }
            }
            // ページを追加
            stack.add_titled(grid, (page + 1).to_string(), (page + 1).to_string());
        }

        // メニュー用スタックスイッチャー
        Gtk.StackSwitcher switcher = new Gtk.StackSwitcher();
        switcher.set_stack(stack);
        mainbox.pack_start(switcher, false, false, 0);

        this.destroy.connect(Gtk.main_quit);
        this.show_all();
    }
}