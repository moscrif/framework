include "code://ui/tools.ms"

class KeyboardButton
{
    var counter = 0; // static!
    function this(name = null, text)
    {
        var skin = Application.instance.skin;
        this._pressed = 0;
        this.text = text;
        this._view = new Moscrif.View(name || String.printf("keyboardButton[%d]", Button.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = 32;
        this._view.height = 32;
        this._view.onDraw = :sender, canvas :skin.drawKeyboardButton(canvas, sender._script);
        this._view.onPointerPressed = :sender, x, y
        {
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
            var key = sender._script.text;
            if (typeof self._onKeyHandler == #function)
                    self._onKeyHandler(self, key);
            self._pressed = 0;
            self._view.invalidate();
            return true;
        }
        _addViewProperties(this);
        skin.initKeyboardButton(this);
    }
    property kind(v) { get return this._kind; }
    property text(v)
    {
        get return this._text;
        set {
            if (this._text && this._text == v) return;
            //logI(this._text, v);
            var text = v;
            if (text == #enter) this._kind = #enter;
            else if (text == #space || typeof text == #symbol) this._kind = #control;
            else this._kind = #normal;
            
            this._text = v;
            
            var skin = Application.instance.skin;
            skin.initKeyboardButton(this);
            if (this._view) this._view.invalidate();
        }
    }
    property pressed(v) { get return this._pressed != 0; }
    //@event #onKey; // (sender, key)
    property onKey(v)
    {
        get { return this._onKeyHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onKeyHandler = v;
        }
    }
}
