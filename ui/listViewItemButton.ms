#include "code://ui/tools.ms"

class ListViewItemButton
{
    var id = 0; // static!
    function this(name = null, icon = null, text = null)
    {
        var skin = Application.instance.skin;
        //events handlers
        this._onClickHandler = null;
        this._text = text || "";
        this._icon = icon;
        this._pressed = 0;
        this._view = new Moscrif.View(name || String.printf("listViewItemButton#%d", ListViewItemButton.id++));
        this._view._script = this;
        this._view.focusable = true;
        this._view.left = this._view.top = 0;
        this._view.width = 32;
        this._view.height = 32;
        this._view.onDraw = :sender, canvas {
            skin.drawListViewItemButton(canvas, sender._script);
        };
        //this._view.onPointerPressed = :sender, x, y {
        //	return true;
        //}
        this._view.onPointerPressed = :sender, x, y {
            var self = this super;
            self._pressed = System.tick;
            self._view.invalidate();
            return false;
        }
        this._view.onPointerDragged = :sender, x, y {
            var self = this super;
            if (System.tick - self._pressed > 50)
                self._pressed = 0;//System.tick;
            self._view.invalidate();
            return false;
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
        skin.initListViewItemButton(this);
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
