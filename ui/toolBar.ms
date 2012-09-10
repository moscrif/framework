include "code://ui/tools.ms"

class ToolBarButton
{
    var counter = 0; // static!
    function this(name = null, icon = null, text = null)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this._icon = icon;
        this.pressed = 0;
        this._view = new Moscrif.View(name || String.printf("toolBarButton#%d", ToolBarButton.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = this._view.height = 32;
        this._view.onDraw = :sender, canvas :skin.drawToolBarButton(canvas, sender._script);
        this._view.onPointerPressed = :sender, x, y {
            var self = this super;
            self.pressed = System.tick;
            self._view.invalidate();
            return true;
        }
        this._view.onPointerDragged = :sender, x, y {
            var self = this super;
            if (System.tick - self.pressed > 25)
            	self.pressed = 0;
            self._view.invalidate();
            return true;
        }
        this._view.onPointerReleased = :sender, x, y {
            var self = this super;
            //if (!self.pressed) return true;
            self.pressed = 0;
            try {
                //self.notify_onClick(x, y);
                if (typeof self._onClickHandler == #function)
                    self._onClickHandler(self);
            } finally {
                self._view.invalidate();
            }
            return true;
        }
        _addViewProperties(this);
        skin.initToolBarButton(this);
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
        assert view != null && view.native != null;
        this._view.add(view.native);
    }
}

class ToolBar
{
    var id = 0; // static!

    function this(name = null)
    {
        var skin = Application.instance.skin;
        this._view = new Moscrif.View(name || String.printf("toolBar#%d", ToolBar.id++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 70;
        this._view.onDraw = :sender, canvas :skin.drawToolBar(canvas, sender._script);
        _addViewProperties(this);
        skin.initToolBar(this);
    }

    function add(item, onClick = null)
    {
        assert item != null;
        assert item instanceof ToolBarButton;
        if (onClick) item.onClick = :sender :onClick(sender);
        this._view.add(item.native, #front);
    }
}
