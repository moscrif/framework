include "code://ui/tools.ms"

class MenuItem
{
    var counter = 0; // static!
    function this(name = null, text = null)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this._pressed = 0;
        this._view = new View(name || String.printf("menuItem[%d]", MenuItem.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 32;
        this._view.onDraw = :sender, canvas :skin.drawMenuItem(canvas, sender._script);
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
        skin.initMenuItem(this);
    }
    property text(v) {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
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
}

class Menu
{
    var counter = 0; // static!
    function this(name = null)
    {
        var skin = Application.instance.skin;
        name = name || String.printf("menu[%d]", Menu.counter++);
        this._totalHeight = 0;
        this._overlay = new View(name + ".overlay");
        this._overlay._script = this;
        this._overlay.visible = true;
        this._overlay.focusable = false;
        this._overlay.left = this._overlay.top = 0;
        this._overlay.width = System.width;
        this._overlay.height = System.height;
        this._overlay.onDraw = :sender, canvas :skin.drawMenuOverlay(canvas, sender._script);
        this._overlay.onPointerReleased = :sender, x, y :this super.close();
        
        this._view = new View(name);
        this._view._script = this;
        this._view.visible = true;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width / 2;
        this._view.height = 0;
        this._view.onDraw = :sender, canvas {
            skin.drawMenu(canvas, sender._script);
        };
        
        this._overlay.add(this._view);
        
        _addViewProperties(this);
        skin.initMenu(this);
    }
    property name(v) { get return this._view.name; }
    function add(view, onClick = null)
    {
        assert view != null;
        assert view instanceof MenuItem;
        if (onClick) view.onClick.push(:sender :onClick(sender));
        var skin = Application.instance.skin;
        this.height += view.height;
        this._view.add(view.native, #front);
    }
    function showModal()
    {
        var app = Application.instance;
        assert app != null && app instanceof Application;
        this.left = (System.width - this.width) / 2;
        this.top = (System.height - this.height) - (System.height / 8);
        app.add(this._overlay, #front);
    }
    function close()
    {
        this._overlay.detach();
    }
}
