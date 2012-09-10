include "lib://uix/control/button.ms"

/**
@package uix
@location uix\keyboard\keyboardButton.ms

KeyboardButton class definition.
It defines onPointerPressed and onPointerReleased event, called on pressed / released button.
OnClick event is not used. It supports normal state, pressed and disabled state (inherited from Button class).
*/

class KeyboardButton : Button
{
    /**
    Button init controls
    */
    function init()
    {
        super.init();

        //do not focus on keyBoard key
        this.native.focusable = false;
        // text in the button
        this._symbol = null;
        // numer of row in which this button is placed
        this._highlight = false;

        /**
        On Pointer pressed handler
        @param Control sender
        @param Integer x
        @param Integer y
        */
        this.native.onPointerPressed = function(item, x, y)
        {
            if (this super._enabled) {
                this super._clicked = true;
                this.invalidate();
            }
            if (typeof this super._onPointerPressedHandler == #function)
                this super._onPointerPressedHandler(this super, x, y);
        }

        /**
        On Pointer released handler
        @param Control sender
        @param Integer x
        @param Integer y
        */
        this.native.onPointerReleased = function(item, x, y)
        {
            var self = this super;
            if (self._enabled) {
                self._clicked = false;
                this.invalidate();
            }
            if (typeof self._onPointerReleasedHandler == #function)
                self._onPointerReleasedHandler(self, x, y);
        }
    }

    /**
    Cause different appearance on special buttons
    @return Boolean
    @param Boolean
    */
    property highlight(v)
    {
        get return this._highlight;
        set {
            if (typeof v == #boolean) {
                this._highlight = v;
                this.invalidate()
            } else
                throw new InvalidArgument("[KeyboardButton.highlight] Accepts true or false");
        }
    }

    /**
    Symbol shown on the button
    @return Symbol or String
    @param Symbol or String
    */
    property symbol(v)
    {
        get return this._symbol;
        set {
            this._symbol = v;
            this.invalidate();
        }
    }

    
}