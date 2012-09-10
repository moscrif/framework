include "code://ui/tools.ms"

class ListViewItem
{
    var counter = 0; // static!
    function this(name = null, icon = null, text = null)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this._icon = icon;
        this._clickable = true;
        this._pressed = 0;
        this._detail = false;
        this._drawHint = false;
        this._hint = null;
        //events handlers
        this._onClickHandler = null;
        this._view = new Moscrif.View(name || String.printf("listViewItem[%d]", ListViewItem.counter++));
        this._view._script = this;
        this._view.focusable = false;
        //this._view.onFocusChanged = :sender, gainFocus :logI(sender.name, gainFocus ? "GOT FOCUS" : "LOST FOCUS");
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 32;
        this._view.onDraw = :sender, canvas :skin.drawListViewItem(canvas, sender._script);
        this._view.onPointerPressed = :sender, x, y {
            var self = this super;
            self._pressed = System.tick;
            if (!self._clickable) return false; // return false to continue event bubbling
            self._view.invalidate();
            return false; // return true to stop event bubbling
        }
        this._view.onPointerDragged = :sender, x, y {
            var self = this super;
            if (!self._clickable) return false;
            return false;
        }
        this._view.onPointerReleased = :sender, x, y {
            var self = this super;
            if (!self._pressed || !self._clickable) return false;
            if (typeof self._onClickHandler == #function)
                self._onClickHandler(self, x, y);
            self._pressed = 0;
            self._view.invalidate();
            return true;
        }
        this._view.onParentScroll = :sender, parent {
            var self = this super;
            if (self._pressed) {
                self._pressed = 0;
                self._view.invalidate();
            }
        }
        _addViewProperties(this);
        skin.initListViewItem(this);
    }
    property text(v) {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
    }
    property hint(v) {
        get return this._hint;
        set this._hint = v;
    }
    property icon(v) {
        get return this._icon;
        set {
            if (this._icon == v) return;
            this._icon = v;
            this._view.invalidate();
        }
    }
    property clickable(v) {
        get return this._clickable;
        set this._clickable = v;
    }
    property detail(v) {
        get return this._detail;
        set this._detail = v;
    }
    property pressed(v) { get return this._pressed != 0; }
    //@event #onClick; // (sender)
    property onClick(v)
    {
        get { return this._onClickHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onClickHandler = v;
        }
    }
    function add(view)
    {
        assert view != null;
        assert view.native != null;
        this._view.add(view.native);
    }
    function detach()
    {
        this._view.detach();
    }
}

class ListView
{

    var counter = 0; // static!

    function this(name = null)
    {
        var skin = Application.instance.skin;
        this._view = new Moscrif.ScrollView(String.printf("listView[%d]", ListView.counter++));
        //events handles
        this._onProcessHandler = null;

        this._view.visible = true;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 100;
        this._view.scrollMode = #vert;
        this._view.dockContent = #top;
        //this._view.onProcess = :sender :this super.notify_onProcess(this super);
        this._view.onDraw = :sender, canvas {
            skin.drawListViewBg(canvas, sender._script);
        };
        _addViewProperties(this);
        skin.initListView(this);
    }

    property native(v)
    {
        get return this._view;
    }

    property onProcess(v)
    {
        get { return this._onProcessHandler; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onProcessHandler = v;
            this._view.onProcess = v ? function(sender)
            {
                var self = this super;
                if (typeof self._onProcessHandler == #function)
                    self._onProcessHandler(self);
            } : null;
        }
    }

    function add(item)
    {
        assert item != null;
        assert item instanceof ListViewItem;
        this._view.add(item.native, #front);
    }

    function remove(item)
    {
        assert item != null;
        assert item instanceof ListViewItem;
        item.detach();
    }

    function removeAll()
    {
        this._view.removeAll();
    }

    function performLayout()
    {
        this._view.performLayout();
    }

    property scrollX(v)
    {
        get return this._view.scrollX;
    }

    property scrollY(v)
    {
        get return this._view.scrollY;
    }
}
