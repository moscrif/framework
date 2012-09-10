include "code://ui/tools.ms"

class NumericKeyboard
{
    var counter = 0; // static!
    function this(name = null, left="*", right="#")
    {
        var skin = Application.instance.skin;
        
        this._left = left;
        this._right = right;
        this._view = new View(name || String.printf("numericKeyboard[%d]", NumericKeyboard.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = this._view.height = 100;
        this._view.top = System.height - this._view.height;
        this._view.onDraw = :sender, canvas :skin.drawNumericKeyboard(canvas, sender._script);
        
        _addViewProperties(this);
        skin.initNumericKeyboard(this);
        
        this._build(skin);
    }
   // @event #onKey; // (sender, key)
   property onKey(v)
    {
        get { return this._onKeyHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onKeyHandler = v;
        }
    }
    property name(v) { get return this._view.name; }
    function _build(skin)
    {
        function getText(index)
        {
            if (index == 10) return "0";
            if (index == 9) return this super._left;
            if (index == 11) return this super._right;
            return (index + 1).toString();
        }
        function addRow(row)
        {
            var layout = new StackLayout();
            layout.orientation = #horz;
            layout.align = #stretch;
            layout.pack = #start;
            this super._view.add(row, #front);
            row.layout = layout;
        }
        var btn, row = null, name;
        for (var i = 0; i < 9+3; i++) {
            name = this._view.name + String.printf(".row[%d]", i / 3);
            if (i % 3 == 0) {
                if (row) addRow(row);
                row = new View(name);
                //row.i = i;
                row.visible = true;
                row.focusable = false;
                row.width = System.width;
                row.height = System.height / 20;
                //row.onDraw = :sender, canvas { logI("X"); var p = new Paint();p.color=0x55aa0000 + (sender.i<<8) + (sender.i*50); canvas.drawRect(0,0,sender.width,sender.height,p); }
                row.stretch = #both;
            }
            name = name + String.printf(".cell[%d]", i % 3);
            btn = new View(name);
            btn._script = btn;
            //btn.pressed = 0;
            btn.text = getText(i);
            btn.visible = true;
            btn.stretch = #both;
            btn.onPointerPressed = :sender, x, y {
                sender.pressed = System.tick;
                sender.invalidate();
                return true;
            }
            btn.onPointerDragged = :sender, x, y {
                if (System.tick - sender.pressed > 50)
                    sender.pressed = 0;//System.tick;
                sender.invalidate();
                return true;
            }
            btn.onPointerReleased = :sender, x, y {
                //if (!sender.pressed) return true;
                var self = this super;
                var key = sender.text;
                //this super.notify_onKey(key);
                if (typeof self._onKeyHandler == #function)
                    self._onKeyHandler(self, key);
                sender.pressed = 0;
                sender.invalidate();
                return true;
            }
            btn.onDraw = :sender, canvas: skin.drawNumericKeyboardButton(canvas, sender);
            skin.initNumericKeyboardButton(btn);
            row.add(btn, #front);
            //logI("build", btn, row.name);
        }
        if (row) addRow(row);
        //logI("last", btn);
        //this._view.doLayout();
    }
}
