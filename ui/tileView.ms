//include "code://core/log.ms"
include "code://ui/tools.ms"

// warning: this does not add View properties
class TileViewRow
{
    var counter = 0; // static!

    function this(name = null)
    {
        var skin = Application.instance.skin;
        this._view = new Moscrif.View(name || String.printf("tileViewRow#%d", TileViewRow.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 32;
        this._view.doubleBuffer = false;
        //this._view.onDraw = :sender, canvas {
        //    skin.drawTileViewRow(canvas, sender._script);
        //};
        this._view.onParentScroll = :sender, parent {
            var row = this super._view;
            for (var ch in row) {
                if (typeof ch.onParentScroll == #function)
                    ch.onParentScroll(ch, row);
            }
        }
        skin.initTileViewRow(this);
    }

    property native(v) { get return this._view; }

    property layout(v) { set this._view.layout = v; }

    property width(v)
    {
        get return this._view.width;
        set this._view.width = v;
    }

    property height(v)
    {
        get return this._view.height;
        set this._view.height = v;
    }

    function add(view)
    {
        assert view != null && view instanceof TileViewItem;
        this._view.add(view.native, #front);
    }
}

class TileViewItem
{
    var id = 0; // static!

    function this(name = null, icon = null, text = null)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this._icon = icon;
        this.pressed = 0;
        this._view = new Moscrif.View(name || String.printf("tileViewItem#%d", TileViewItem.id++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = 32;
        this._view.height = 32;
        this._view.onCustomDraw = null;
        this._view.onDraw = :sender, canvas
        {
            skin.drawTileViewItem(canvas, sender._script);
            if (typeof sender._script.onCustomDraw == #function)
                sender._script.onCustomDraw(sender._script, canvas);
        };
        this._view.onPointerPressed = :sender, x, y
        {
            var self = this super;
            self._pressed = System.tick;
            self._view.invalidate();
            return false;
        }
        this._view.onPointerReleased = :sender, x, y
        {
            var self = this super;
            if (!self._pressed) return false;
            if (typeof self._onClickHandler == #function)
                self._onClickHandler(self);
            self._pressed = 0;
            self._view.invalidate();
            return true;
        }
        this._view.onParentScroll = :sender, parent {
            var self = this super;
            //logI(self.name, self._pressed);
            if (self._pressed) {
                self._pressed = 0;
                self._view.invalidate();
            }
        }
        _addViewProperties(this);
        skin.initTileViewItem(this);
    }

    property text(v)
    {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
    }

    property icon(v)
    {
        get return this._icon;
        set {
            if (this._icon == v) return;
            this._icon = v;
            this._view.invalidate();
        }
    }

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
        assert view != null && view.native != null;
        this._view.add(view.native);
    }
}

class TileView
{
    var counter = 0; // static!

    function this(name = null)
    {
        var skin = Application.instance.skin;
        this._view = new Moscrif.ScrollView(String.printf("tileView#%d", TileView.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 100;
        this._view.scrollMode = #vert;
        this._view.dockContent = #top;
        this._view.onDraw = :sender, canvas
        {
            skin.drawTileViewBg(canvas, sender._script);
        };
        _addViewProperties(this);
        skin.initTileView(this);
    }

    property scrollMode(v)
    {
        get return this._view.scrollMode;
        set this._view.scrollMode = v;
    }

    function add(item)
    {
        assert item != null;
        assert item instanceof TileViewRow;
        this._view.add(item.native, #front);
    }

    function removeAll()
    {
        this._view.removeAll();
    }

}