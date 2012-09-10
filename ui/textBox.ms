include "code://ui/tools.ms"

class TextBox
{

    var counter = 0; // static!

    function this(name = null, multiLine = false, value = "")
    {
        var skin = Application.instance.skin;
        this._mode = #insert;
        this.focused = false;

        //events handlers
        this._onClickHandler = null;
        this._onChangedHandler = null;
        this._onFocusChangedHandler = null;

        this._view = new Moscrif.ScrollView(name || String.printf("textBox#%d", TextBox.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.onDraw = :sender, canvas :skin.drawTextBox(canvas, sender._script);
        this._view.dockContent = #left-top;
        this._view.scrollMode = multiLine ? #both : #horz;
        this._view.onResize = :sender, w, h
        {
            var editor = sender._script._editor;
            if (editor.autoSize != #width) editor.width = w;
            if (editor.autoSize != #height) editor.height = h;
        }
        this._view.onPointerPressed = :sender, x, y
        {
            var self = this super;
            self._editor.setFocus();
            //self.pressed = true;
            try {
                if (typeof self._onClickHandler == #function)
                    self._onClickHandler(self);
            } finally {
                self._view.invalidate();
            }
            return true;
        }

        this._editor = new Moscrif.TextView(this._view.name + ".editor");
        this._editor._script = this;
        this._editor.text = (value);
        this._editor.readOnly = false;
        this._editor.autoSize = multiLine ? #height: #width;
        this._editor.multiLine = multiLine;
        this._editor.focusable = true;
        this._editor.left = this._editor.top = 0;
        this._editor.width = this._view.width;
        this._editor.height = 12;
        this._editor.onDrawCursor = :sender, canvas, left, top, right, bottom :skin.drawTextBoxCursor(canvas, sender._script, left, top, right, bottom);
        this._editor.onChar = :sender, ch :this super.acceptKey(ch);
        this._editor.onKeyPressed = :sender, k
        {
            var self = this super;
            var oldText = sender.text;
            var newText = "";
            if (k == #home) sender.doCursorKey(k); // home
            if (k == #end) sender.doCursorKey(k); // end
            if (k == #backspace) this super.acceptKey(k); // back  symbol send also hardwaer button arrow on Android
          //  if (k == #send) sender.backspace(false); // send (in emulator F3)
            if (k == #up) sender.doCursorKey(k); // up
            if (k == #down) sender.doCursorKey(k); // down
            if (k == #left) this super.cursorKey(k); // left
            if (k == #right) this super.cursorKey(k); // right
            newText = sender.text;
            if (oldText != newText) {
               if (typeof self._onChangedHandler == #function)
                        self._onChangedHandler(self, newText);

            }
            //self._view.performLayout();
            //s.invalidate();
            return true;
        };
        this._editor.onFocusChanged = :sender, gainFocus //:this super.notify_onFocusChanged(gainFocus)
        {
            var self = this super;
            if (this super.focused)
                this super.focused = false;
            else
                this super.focused = true;
            if (typeof self._onFocusChangedHandler == #function)
                self._onFocusChangedHandler(self, gainFocus);
            this super._view.invalidate();
        }

        this._editor.onPointerReleased = :sender, x, y {
            var self = this super;
            return false; // !important, this enable continue to bubble event (scrollview)
        }

        _addViewProperties(this);
        skin.initTextBox(this);
        this._view.add(this._editor);
        this._editor.doCursorKey(#end);
    }
    
    //@event #onChanged;      // (sender, text)
    property onChanged(v)
    {
        get { return this._onChangedHandler;}
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onChangedHandler = v;
        }
    }
    
    //@event #onFocusChanged; // (sender, text)
    property onFocusChanged(v)
    {
        get { return this._onFocusChangedHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onFocusChangedHandler = v;
        }
    }

    //@event #onClick;        // (sender, text)
    property onClick(v)
    {
        get { return this._onClickHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onClickHandler = v;
        }
    }

    function invalidate()
    {
        this._view.invalidate();
    }

    function setFocus()
    {
        this._editor.setFocus();
    }
    
    function acceptKey(key)
    {
        var oldText = this.text;
        var oldWidth = this._editor.width;

        if (key == #space)
            key = " ";

        if (key == #backspace)  {
            this._editor.backspace();
        } else {
            if (typeof key == #string)
                key = key.charCodeAt(0);
            var mode = this._mode;
            mode == #insert ? this._editor.insert(key) : this._editor.replace(key);
        }

        this._view.performLayout();

        var newText = this.text;
        if (oldText != newText) {
            if (typeof this._onChangedHandler == #function)
            this._onChangedHandler(this, newText);
        }
        /*
        if (this._horzAlign == #right) {
            this._view.scrollTo( this._view.scrollX - this._editor.width + oldWidth, 0);
        } else {    //left
            if (this._editor.width > this._view.width)
                this._view.scrollTo(this._view.scrollX - this._editor.width + oldWidth, 0);
        }
        */
    }

    function cursorKey(k)
    {
        var (left, top, right, bottom);
        switch (k) {
            case #left:
                this._editor.doCursorKey(k);
                //(left, top, right, bottom) = this._editor.cursorRect
                // if (this._view.scrollX < -1 && left < (-1 * this._view.scrollX + this._view.width / 3) )
                //    this._view.scrollTo(-1*(left - this._view.width / 3),0);
            break;
            case #right:
                this._editor.doCursorKey(k);
                //(left, top, right, bottom) = this._editor.cursorRect
                // if (-1 * this._view.scrollX < (this._editor.width - this._view.width) && right > (-1 * this._view.scrollX + 2*this._view.width / 3) )
                //     this._view.scrollTo(-1*(left - 2 * this._view.width / 3),0);
            break;
         }
    }
    
    property paint(v)
    {
        get return this._editor.paint;
        set this._editor.paint = v;
    }
    
    property text(v)
    {
        get return this._editor.text;
        set {
            this._editor.text = v;
            //this._editor.invalidate();
            // TODO:
            //this._editor.doCursorKey(3); // home
        }
    }
    
    property multiLine(v)
    {
        get return this._editor.multiLine;
        set {
            this._editor.multiLine = v;
            this._editor.invalidate();
        }
    }

    property autoSize(v)
    {
        get return this._editor.autoSize;
        set {
            this._editor.autoSize = v;
            this._editor.invalidate();
        }
    }
    
    property vertAlign(v)
    {
        get return this._editor.vertAlign;
        set {
            this._editor.vertAlign = v;
            this._editor.invalidate();
        }
    }
    
    property horzAlign(v)
    {
        get return this._horzAlign;
        set {
            switch (v) {
                case #right:
                     this._view.dockContent = #right-top;
                     this._horzAlign = #right;
                     this._editor.left = this._view.width;
                     //console << "XXX " << this._editor.left << "\n";
                break;
                case #left:
                     this._view.dockContent = #left-top;
                     this._horzAlign = #left;
                break;
            }
        }
    }
    
    property readOnly(v)
    {
        get return this._editor.readOnly;
        set this._editor.readOnly = v;
    }
    
    property marginX(v)
    {
        get return this._editor.marginX;
        set this._editor.marginX = v;
    }
    
    property marginY(v)
    {
        get return this._editor.marginY;
        set this._editor.marginY = v;
    }

}

// eof
