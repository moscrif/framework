include "lib://graphics/patterns/pattern.ms";
include "lib://uix/base/staticContainer.ms"

/**
@package uix
@location uix/contol/item.ms

Base class definition for items used in list view, tile view, form, etc.
It contains definition of label, value or icon.
*/
class Item : StaticContainer
{
    /**
    Init Item controls
    */
    function init()
    {
        super.init();
        // create default text, image and icon
        this._text = "";
        this._icon = null;

        this._value = #undefined;
        this._badge = null
        this._clicked = false;
        // default text paint
        this._textWidth = 0;
        this._textHeight = 0;

        //default margin
        this._marginX = 0;
        this._marginY = 0;
        this._align = #left;

        this._pressed = null;

        // create handlers
        this._onClickHandler = null;

        // handlers
        this._onClickHandler = 0;

        this._onPointerPressedHandler = function(sender, x, y)
        {
            this._clickedPossible = true;
        }

        this._view.onParentScroll = function(sender, parent)
        {
            var self = this super;
            self._clickedPossible = false;
        }

        this._onPointerReleasedHandler = function(sender, x, y)
        {
            var self = this super;
            if (!this._clickedPossible)
                return;

            this._clicked = true;
            this.invalidate();

            var deselect = new Timer(25, false);
            deselect.onTick = function(sender) {
                var self = this super;
                self._clickedPossible = self._clicked = false;
                self.invalidate();
                deselect.dispose();
                if (self._onClickHandler != null)
                    return self._onClickHandler(self, x, y);
            }
            deselect.start(40);
        }
    }

    function afterInit()
    {
        super.afterInit();
        // create label for text
        //this.layout = new Moscrif.StackLayout();
        //this.layout.align = #stretch;
    }

    /**
    Setting up label of item
    @param String v
    @return String
    */
    property label(v)
    {
        set this._label = v;
        get return this._label;
    }

    /**
    Pressed pattern drawing, it specify how foregraound, background or border drawing should looks like
    if item is pressed. Definition of default drawing is in skin theme
    @param Pattern v
    @return Pattern
    @throw InvalidArgument Accepts instance of Pattern
    */
    property pressed(v)
    {
        get
        {
            if(this._pressed == null)
                this._pressed = Pattern.create(Pattern,this,"pressed");

            return this._pressed;
        }
        set
        {
            if(v instanceof Pattern)
                this._pressed = v
            else
                 throw new InvalidArgument("[Button.pressed] Accepts instance of Pattern");

        }
    }

    /**
    Icon, an image property to keeps information about bitmap or vector image
    @param Image v
    @return Image
    @throw InvalidArgument Accepts instance of Image, Path, String or Bitmap
    */
    property icon(v)
    {
        get {
            if(this._icon == null)
                this._icon = new Image();

            return this._icon;
        }
        set {
            // we acceprt instnace of Drawing
            if (v instanceof Image)
                this._icon = v;
            else if (v instanceof String || v instanceof Bitmap || v instanceof Path)
                this._icon.source = v;
            else
                // report invalide type of parameter
                throw new InvalidArgument("[Item.icon] Accepts instance of Image, Path, String or Bitmap ");
        }
    }

    /**
    Icon Align
    @param Symbol v
        #left align to left
        #right align to right
    @return Symbol
    */
    property iconAlign(v)
    {
        get return this._iconAlign;
        set {
            if (v != #left || v != #right)

            this._iconAlign = v;
        }
    }

    /**
    Item horizontal align
    @param Symbol v
        #left align to left
        #center align to center
        #right align to right
    @return Symbol
    */
    property horzAlign(v)
    {
        get return this._horzAlign;
        set this._horzAlign = v;
    }

    /**
    On click evnet handler

    @event
    @param Object sender Object what caused this event
    @return Function
    @throw InvalidArgument Expects instance of function
    */
    property onClick(v)
    {
        get return this._onClickHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Button.onClick] Expects instance of function");
             this._onClickHandler = v;
        }
    }

    /**
    Flag clicked, to define clicked state
    @param Boolean v
        true item is clecked
        false item is relesed or unclicked
    @return Boolean
    */
    property clicked(v)
    {
        get return this._clicked;
        set this._clicked = v;
    }

    /**
    Text property of item
    @param String v
    @retrun String
    */
    property text(v)
    {
        set {
            this._text = v;
            /*var (w, h) = this._textPaint.measureText(this._text);
            this._textWidth = w;
            this._textHeight = h*/
        }
        get return this._text;

    }

    /**
    Value property of item.
    @param Any v
    @return Any
    */
    property value(v)
    {
        set this._value = v;
        get return this._value;
    }

    /**
    Property of Badge.
    It holds instance of Badge to display state of item.
    @param Badge v
    @return Badge
    */
    property badge(v)
    {
        get return this._badge;
        set {
            if (v instanceof Badge) {
               // only one badge is alowed in the window
                if (this._badge instanceof Badge)
                    this._badge.native.detach();
                // add badge to the item
                this.add(v);
                this._badge = v;
            }
        }
    }

     /**
     * Property for margin on axis x
     * @param int marginX
     * @return int marginX
     */
    property marginX(v)
    {
        get return this._marginX;
        set {
            this._marginX = v;
            this.invalidate();
        }
    }

    /**
     * Property for margin on axis y
     * @param int marginY
     * @return int marginY
     */
    property marginY(v)
    {
        get return this._marginY;
        set {
            this._marginY = v;
            this.invalide();
        }
    }

    /**
    Align of item
    @param Symbol v
        #left align to left
        #center align to center
        #right align to right
    */
    property align(v)
    {
        get return this._align;
        set this._align = v;
    }


}