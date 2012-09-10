include "lib://uix/base/scrollContainer.ms";
include "lib://core/log.ms";

/**
@package uix
@location uix/control/textBox.ms

TextBox definition, to insert characters.
Once TextBox is active, onFocus application keybord is show.
Keybord can be system as well but it depends to platform and application settings.

*/
class TextBox : ScrollContainer
{
    /**
    Init TextBox controls
    */
    function init()
    {

        super.init();

        this._editor = new Moscrif.TextView();
        this._editor.focusable = true;
        this._editor.readOnly = false;
        this._editor.vertAlign = #middle;
        this._editor.autoSize = #width;
        this._editor.left = this._editor.top = 0;

        this._autoKeyboard = true;
        this._onFocusChangedHandler = null;
        this._keyboardType = #default;

        /**
        This event is raised by release an UNICODE character key.
        @param TextView s
        @param Char char
        */
        this._editor.onChar = function (s, char)
        {
            this super.acceptKey(char);
        }

        /**
        This event is raised by press the key.
        @param TextView sender
        @param Char
        */
        this._editor.onKeyPressed = function (sender, k)
        {
            this super.processKey(k);
        };


        // this._editor.height = 100;

        this._isEmpty = true;
        this._hint = "";

        /**
        On Focus Changed event
        @param TextView sender
        @param Boolean gainFocus
            true if text box has focus
            false if does not
        */
        this._editor.onFocusChanged = function(sender, gainFocus)
        {

            if (this super._autoKeyboard) {
                if(gainFocus)
                    Application.instance.requestKeyboard(function(key){
                            this super super.acceptKey(key)
                    },this super.keyboardType);
                else
                    Application.instance.hideKeyboard();
            }

            if (typeof this super._onFocusChangedHandler == #function) {
                this super._onFocusChangedHandler(this super, gainFocus);
            }

            this super.doFocusChanged(sender, gainFocus);

            this super.invalidate();

        }

        /**
        on Draw cursor event
        @param TextBox sender
        @param Canvas canvas
        @param Integer left
        @param Integer top
        @param Integer right
        @param Integer bottom

        */
        this._editor.onDrawCursor = function(sender,canvas,left,top,right,bottom)
        {
            if(this super.cursor instanceof Drawing)
                Application.instance.skin.drawTextBoxCursor(this super, canvas, {left : left, top:top, right:right, bottom:bottom});
        }

        /**
        On cursor changed event
        @param TextView sender
        @param Integer pos
        @param Integer line
        @param Char char
        */
        this._editor.onCursorChanged = function(sender, pos, line, char)
        {
            this super.onCursorChanged(this super, pos, line, char);
        }

        /**
        On pointer Pressed Handler
        @param TextBox sender
        @param Integer x
        @param Integer y
        */
        this._view.onPointerPressed = function(sender, x, y)
        {
            this super._editor.setFocus();
            this super._editor.doCursorKey(#end);
        }

        /**
        On change handler, event is fired when text is changed
        @param TextBox sender
        @param String text
        */
        this._onChangedHandler = function(sender,text)
        {
           /* var (w,h) = sender.fg.native.measureText(text);
            if(sender.width <= w + sender.marginX){
                this.native.scrollMode = #horz;
                this.native.scrollTo(this.native.width - w,this.native.scrollY);
            }else {
                this.native.scrollMode = #none;
            }*/

            //If position is at the beginning mark object as empty
            if(text.length == 0)
                this._isEmpty = true;

        }


        this._bgInactive = Drawing.create(Drawing, this, "bgInactive");

        this.native.focusable = false;
        this.native.dockContent = #left;
        this.native.scrollMode = #horz;

        this.horzAlign = #left;

        this.mode = #insert;
        this.add(this._editor);

    }

    function setDefaults()
    {
        super.setDefaults();
        //set text paint object
        this.editor.paint = this.fg.native;
    }


    /**
    On focus changed event

    @event
    @param Object sender Object what caused this event
    @param Boolean gainFocus true, object got focus, false object lost focus
    @return Function
    */
    property onFocusChanged(v)
    {
        get return this._onFocusChangedHandler;
        set {
            if (typeof v == #function)
                this._onFocusChangedHandler = v;
            else
                throw new InvalidArgument("[TextBox.onFocusChanged] Accepts instance of function");
        }
    }

    /**
    If this flag is true, the keyboard will appear automatically when user clicks to the text box.
    @param Boolean
    @return Boolean
    */
    property autoKeyboard(v)
    {
        get return this._autoKeyboard;
        set this._autoKeyboard = v;
    }


    /**
    Value property of textbox
    @param String v
    @retrun String
    */
    property value(v)
    {
        get return (this._isEmpty?"":this._editor.text);
        set {
            this._isEmpty = (v == "") ? true : false;
            this._editor.text = (v == "") ? this.hint : v;
            this._onChangedHandler(this,v);
        }
    }

    /**
    Instance of TextView
    @retrun TextView
    */
    property editor(v)
    {
        get return this._editor;
    }

    /**
    Property Hint
    @param String v
    @return String
    */
    property hint(v)
    {
        get return this._hint;
        set {
            this._hint = v;
            if (this._isEmpty) {
                this._editor.text = this._hint;
            }
        }
    }

    /**
    Insertion mode
    @param Symbol
        #insert, #overwrite
    @return Symbol
    */
    property mode(v)
    {
        get { return this._mode; }
        set {
            assert v == #insert || v == #overwrite;
            this._mode = v;
            this.invalidate();
        }
    }

    /**
    Margin X
    @param Integer v
    @retrun Integer
    */
    property marginX(v)
    {
        get return this._editor.marginX;
        set this._editor.marginX = v
    }

    /**
    Margin Y
    @param Integer v
    @return Integer
    */
    property marginY(v)
    {
        get return this._editor.marginY;
        set this._editor.marginY = v;
    }

    /**
    Vertical align
    @param Symbol v
        #left, #midlle, #right
    @Return Symbol
    */
    property vertAlign(v)
    {
        get return this._editor.vertAlign;
        set {
            this._editor.vertAlign = v;
            this._editor.invalidate();
        }
    }

    /**
    Horizontal align
    @param Symbol v
        #left, #right
    @Return Symbol
    */
    property horzAlign(v)
    {
        get return this._horzAlign;
        set {
            switch (v) {
                case #right:
                     this._view.dockContent = this.multiLine ? #right-top : #right;
                     this._horzAlign = #right;
                break;
                case #left:
                     this._view.dockContent = this.multiLine ? #left-top : #left;
                     this._horzAlign = #left;
                break;
            }
            this._editor.invalidate();
        }
    }

    /**
    Focusable property
    @param Boolen v
        true - focus is allowed
        false - focus is permitted
    */
    property focusable(v)
    {
        get return this._editor.focusable;
        set this._editor.focusable = v;
    }

    /**
    Multiline property
    @param Boolean v
        true - text box is multiline
        false - text box single line only
    @return Boolen
    */
    property multiLine(v)
    {
        get return this._editor.multiLine;
        set
        {
          if(v) this.native.scrollMode = #vert;
          this._editor.multiLine = v;

          if(v === true){
            this._editor.autoSize = this.native.autoSize = #fixed;
            this._editor.vertAlign = #top;
          }else{
            this._editor.autoSize = this.native.autoSize = #width;
            this._editor.vertAlign = #middle;
          }

        }
    }

    /**
    Read only property
    @param Boolen v
        true - read only
        false - allows to write
    @return Boolean
    */
    property readOnly(v)
    {
        get return this._editor.readOnly;
        set this._editor.readOnly = v;
    }

    /**
    Gets or sets auto-size flag of this TextView;
    @param Symbol
    @return Symbol
    */
    property autoSize(v)
    {
        get return this._editor.autoSize;
        set this._editor.autoSize;
    }

    /**
    Cursor drawing property
    @param Drawing v
    @return Drawing
    @throw InvalidArgument Accepts instance of Drawing
    */
    property cursor(v)
    {
        get {
            if(this._cursor == null)
                this._cursor = Drawing.create(Drawing,this,"cursor");
            return this._cursor;
        }
        set {
            if(v instanceof Drawing)
                this._cursor = v
            else
                throw new InvalidArgument("[TextBox.cursor] Accepts instance of Drawing")  ;
        }
    }

    /**
    Drawing of Inactive state of textBox
    @param Drawing v
    @return Drawing
    @throw InvalidArgument Accepts instance of Drawing
    */
    property inactive(v)
    {
        get {
            if (this._inactive == null)
                this._inactive = Drawing.create(Drawing,this,"inactive");
            return this._inactive;
        }
        set {
             // we acceprt instnace of Drawing
            if (v instanceof Drawing)
                this._inactive = v;
            else
                // report invalide type of parameter
                throw new InvalidArgument("[TextBox.inactive] Accepts instance of Drawing");
        }
    }

    /**
    Width of the object (in pixels).
    @param Integer v
    @return Integer
    */
    property width(v)
    {
        get return this.native.width;
        set {
            this.native.width = v;
            this.editor.width = v;
        }
    }

    /**
    Height of the object (in pixels).
    @param Integer v
    @return Integer
    */
    property height(v)
    {
        get return this.native.height;
        set {
            this.native.height = v
            this.editor.height = v;
        }
    }

    /**
    Text size, value is per pixel. It set Width and text size of the Foreground drawing object
    @param Integer v
    @return Integer
    */
    property textSize(v)
    {
        get return this.fg.textSize;
        set {
            this.fg.textSize = v;
        }
    }


    /**
    Keyboard type, based on this parameter system will show requested keyboard.
    @param Symbol v
        #default, #email, #web, #pin, #phone
    @return Symbol
    */
    property keyboardType(v)
    {
        get return this._keyboardType;
        set {
            assert typeof v == #symbol;
            this._keyboardType = v;
        }
    }

    /**
    On changed event (is called when user changes text in the box)

    @event
    @param Object sender Object what caused this event
    @return Function
    */
    property onChanged(v)
    {
        get return this._onChangedHandler;
        set {
            if (typeof v == #function)
                this._onChangedHandler = v;
            else
                throw new InvalidArgument("[TextBox.onChanged] Accepts instance of function!");
        }
    }

    /**
    Invalidate of curent textBox. TextBox will be redrawen
    */
    function invalidate()
    {
        super.invalidate();
        this._editor.invalidate();
    }

    /**
    onKey fired when proccesing KEY
    */
    property onKey(v)
    {
        get return this.doKey;
        set {
            assert typeof(v) == #function || v == null;
            this.doKey = v;
        }
    }

    /**
    Precess key function
    @param Char key
    */
    function processKey(key)
    {
        if (typeof this.doKey == #function) {
            this.doKey.call(this, key);
        }

        var changed = false;
        var posBefore;
        var posAfter;

        if (key == #enter)
            Application.instance.hideKeyboard();

        switch (key) {
            case #space:
                key = " ";
                changed = true;
            break;
            case #left:
            case #right:
            case #up:
            case #down:
            case #home:
            case #end:
            case #enter:
                this._editor.doCursorKey(key);
            break;
            case #backspace:
                this._editor.backspace();
            break;
            default:
                if(typeof key == #string) {
                    key = key.charCodeAt(0);
                    this._editor.insert(key);
                    this._isEmpty = false;
            }

        }

       this._onChangedHandler(this, this._editor.text);

    }

    /**
    Set focus to current textBox
    */
    function setFocus()
    {
        //change focus only if is focusable
            if(this.focusable == true
                && this.readOnly == false)
                    this._editor.setFocus();
    }

    /**
    Check if textBox has focus
    @return true  - has focus
            false - has not focus
    */
    function hasFocus()
    {
        return this._editor.hasFocus();
    }

    /**
    Event on focus changed
    @event
    @param TextView sender
    @param Integer pos
    @param Integer line
    @param Char char
    */
    function onCursorChanged(sender, pos, line, char)
    {
        var (cl, ct, cr, cb) = this._editor.cursorRect;

        if (this.horzAlign == #left) {
            cl += this.native.scrollX;
            cr += this.native.scrollX;
        } else if (this.horzAlign == #right) {
            cl += this.native.scrollX;
            cr += this.native.scrollX;
        }
        this._view.scrollTo(cl, ct, cr, cb);
        if (this.horzAlign == #right)
            this._view.performLayout();
    }

    /**
    Event focus changed
    @param TextView sender
    @param Boolean gainFocus
        true  - has focus
        false - has not focus
    */
    function doFocusChanged(sender, gainFocus)
    {

        if (gainFocus) {
            if (this._isEmpty) {
                this._editor.text = "";
                this._editor.width = 2 * this.marginX;
            }
        } else {
            if (this._isEmpty) {
                this._editor.text = this._hint;
            }
        }
    }

    /**
    Accept key function
    @param Char key
    */
    function acceptKey(key)
    {

        if (typeof key == #symbol)
            return this.processKey(key);

        if (typeof key == #string)
            key = key.charCodeAt(0);

         var mode = this._mode;
         mode == #insert ? this._editor.insert(key) : this._editor.replace(key);

        //this._view.performLayout();
        this._isEmpty = false;

        //call on changed handler
        this._onChangedHandler(this, this._editor.text);

    }

    /**
    On resize event
    @event
    @param TextBox sender
    @param Integer width
    @param Integer height
    */
    function onResize(sender,w,h)
    {
         //set width
        if(this.autoSize != #width)
            this._editor.width = w;

        //set height
        if(this.autoSize != #height)
            this._editor.height = h;
    }


}