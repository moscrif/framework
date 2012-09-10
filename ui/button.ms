//include "code://ui/tools.ms"

class Button
{
    var counter = 0; // static!

    function this(name = null, text = null, kind = #normal)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this._kind = kind;
        this.pressed = 0;

        this._view = new Moscrif.View(name || String.printf("button[%d]", Button.counter++));
        this._view._script = this;
        this._view.focusable = true;
        this._view.left = this._view.top = 0;
        this._view.width = 100;
        this._view.height = 32;
        this._view.onDraw = :sender, canvas :skin.drawButton(canvas, sender._script);
        this._view.onPointerPressed = :sender, x, y
        {
            var self = this super;
            self.pressed = System.tick;
            self._view.invalidate();
            return true;
        }
        this._view.onPointerDragged = :sender, x, y
        {
            var self = this super;
            if (System.tick - self.pressed > 25)
            	self.pressed = 0;//System.tick;
            self._view.invalidate();
            return true;
        }
        this._view.onPointerReleased = :sender, x, y
        {
            var self = this super;
            self.pressed = 0;
            try {
                if (typeof self._onClickHandler == #function)
                    self._onClickHandler(self);
            } finally {
                if (self._view.isValid())
                    self._view.invalidate();
            }
            return true;
        }
        skin.initButton(this);
    }

    property kind(v) { get return this._kind; }

    property text(v)
    {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
    }

    property native(v) { get return this._view; }

    property onClick(v)
    {
        get { return this._onClickHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onClickHandler = v;
        }
    }

    property width(v) {
        get return this._view.width;
        set {
            this._view.width = v;
            this._view.invalidate();
        }
    }

    property height(v) {
        get return this._view.height;
        set {
            this._view.height = v;
            this._view.invalidate();
        }
    }
}
