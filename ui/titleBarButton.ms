include "code://ui/tools.ms"

class TitleBarButton
{
    var counter = 0;
    function this(name = null, kind = #space, text = null)
    {
        var skin = Application.instance.skin;
        
        this._text = text || "";
        this._kind = kind;
        this._pressed = 0;
        this._view = new Moscrif.View(name || String.printf("titleBarButton#%d", TitleBarButton.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width / 4;
        this._view.height = 20;
        this._view.onDraw = :sender, canvas : skin.drawTitleBarButton(canvas, sender._script);
        this._view.onPointerPressed = :sender, x, y {
            var self = this super;
            self._pressed = System.tick;
            self._view.invalidate();
            return true;
        }
        this._view.onPointerDragged = :sender, x, y {
            var self = this super;
            if (System.tick - self._pressed > 50)
                self._pressed = 0;//System.tick;
            self._view.invalidate();
            return true;
        }
        this._view.onPointerReleased = :sender, x, y {
            var self = this super;
            //if (!self._pressed) return true;
            if (typeof self._onClickHandler == #function)
                    self._onClickHandler(self);
            self._pressed = 0;
            self._view.invalidate();
            return true;
        }
        _addViewProperties(this);
        skin.initTitleBarButton(this);
    }
    property kind(v) { get return this._kind; }
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
    property text(v) {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
    }
    property icon(v) {
        get return this._icon;
        set {
            this._icon = v;
            this._view.invalidate();
        }
    }
    property width(v)
    {
        get return this._view.width;
        set {
            this._view.width = v;
            this._view.invalidate();
        }
    }

    property height(v)
    {
        get return this._view.height;
        set {
            this._view.height = v;
            this._view.invalidate();
        }
    }

    property top(v)
    {
        get return this._view.top;
        set {
            this._view.top = v;
            this._view.invalidate();
        }
    }

    property left(v)
    {
        get return this._view.left;
        set {
            this._view.left = v;
            this._view.invalidate();
        }
    }
    function add(view)
    {
        assert view != null;
        assert view.native != null;
        this._window.add(view.native);
    }
}
