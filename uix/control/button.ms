include "lib://graphics/patterns/pattern.ms";

include "lib://uix/base/staticContainer.ms";
include "lib://uix/control/image.ms";
include "lib://uix/control/label.ms";

include "lib://uix/layout/verticalLayout.ms";

/**
@package uix
@location uix/control/button.ms

Button class definition. To decorate a Button in application.
It defines onCleck event, what suppose to happen when user clicked on button.
It supports normal state, pressed and disabled state. Appearance of all states are
defined in Skin theme.

*/
class Button : StaticContainer
{

    /**
    Button init controls
    */
    function init()
    {
        super.init();

        this.width = System.width;
        this.height = System.height / 10;
        this.borderWidth = System.width / 50;

        this._clicked = false;
        this._enabled = true;
        this.native.focusable = true;

        this._normal = null;
        this._pressed = null;
        this._disabled = null;

        this._image = null;// new Image();
        this._label = null; //new Label();
        this._change = false;
        this._align = #bottom;

        this.layout = new VerticalLayout();

        this._onClickHandler = null;

        /**
        On Pointer pressed handler
        @param Control sender
        @param Integer x
        @param Integer y
        */
        this._onPointerPressedHandler = function (sender, x, y)
        {
            var self = this super;
            if (self._enabled) {
                self._clicked = true;
                self.invalidate();
            }
        }

        /**
        On Pointer released handler
        @param Control sender
        @param Integer x
        @param Integer y
        */
        this._onPointerReleasedHandler = function (sender, x, y)
        {
            var self = this super;
            if (self._enabled) {
                self._clicked = false;
                self.invalidate();
    
                if (self._onClickHandler != null)
                    self._onClickHandler(self, x, y);
            }
        }
    }

    /**
    Clicked flag
    @param Boolean v true  - clicked
                     false - none
    @return Boolean
    */
    property clicked(v)
    {
        get return this._clicked;
        set {
            this._clicked = v;
            this.invalidate();
        }
    }

    /**
    Flag to enable/disable Button
    @param Boolean v true enabled
                     false disabled
    @return boolean
    */
    property enabled(v)
    {
        get return this._enabled;
        set {
            this._enabled = v;
        }
    }

    /**
    Pressed pattern property, it defines what drawing is used when Button is clicked.
    Pattern specify Foreground, bacgkround and border paints
    @param Pattern v
    @return Pattern
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
    Disabled pattern property, it defines what drawing is used when Button is disabled.
    Pattern specify Foreground, bacgkround and border paints
    @param Pattern v
    @return Pattern
    */
    property disabled(v)
    {
        get
        {
            if(this._disabled == null)
                this._disabled = Pattern.create(Pattern,this,"disabled");

            return this._disabled;
        }
        set
        {
            if(v instanceof Pattern)
                this._disabled = v
            else
                 throw new InvalidArgument("[Button.disabled] Accepts instance of Pattern");

        }

    }

    /**
    On click event

    @event
    @param Object sender Object what caused this event
    @return Function
    */
    property onClick(v)
    {
        get return this._onClickHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Button.onClick]");
             this._onClickHandler = v;
        }
    }

    /**
    Image property, to set bitmap or vector picture to the Button
    @param Image v
    @retrun Image
    */
    property image(v)
    {
        get {
            if (this._image == null) {
                this._image = new Image();
                this._image.stretch = #both;
                this.add(this._image,#front);
            }
            return this._image;
        }
        set {
            if (v instanceof Image) {
                this.image.source = v.source;
            } else {
                this.image.source = v;
            }
        }
    }

    /**
    Is image test
    @return Boolean true if image instance is set
                    false image instance is not set
    */
    function isImage()
    {
        return this._image instanceof Image?true:false;
    }

    /**
    Text of button label
    @param String v
    @return String
    */
    property text(v)
    {
        get return this.label.text;
        set {
            if (typeof v == #string)
                    this.label.text = v;
            else
                throw new InvalidArgument("[TextButton.text]");
        }
    }

    /**
    Button Label definition
    @param Label v
    @return Label
    */
    property label(v)
    {
        get {
            if (this._label == null) {
                this._label = new Label();
                this._label.stretch = #both;
                this.add(this._label,#back);
                this._change = true;
            }
            return this._label;
        }
        set {
            if (v instanceof Label)
                this._label = v;
            else
                throw new InvalidArgument("[ImageButton.label]");
        }
    }

    /**
    Align of button components
    @param Symbol v
    @return Symbol
    */
    property align(v)
    {
        get return this._align;
        set this._align = v;
    }


}