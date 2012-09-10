include "lib://graphics/patterns/boxPattern.ms";


include "lib://uix/control/button.ms";
include "lib://core/exception.ms";

/**
@package uix
@location uix/control/checkBox.ms

Check box Control.
IT has two states, checked and unchecked. To visualise check box, Moscrif use box pattern.
It hase on and off drawing properies, which can be customalised per project in skin theme file.

*/
class CheckBox : Button
{
    /**
    Init Check Box Control
    */
    function init()
    {
        super.init();

        this._boxAlign = #left;
        this._textAlign = #left;
        this._checked = false;
        this._box = BoxPattern.create(BoxPattern,this,"box");
        this._text = "";

        /**
        On pressed process handler
        @param CheckBox sender
        @param Integer x X - coordinate
        @param Integer y Y - coordinate
        */
        this._onPointerPressedHandler = function (sender, x, y)
        {
            if (this.enabled) {
                this._checked = !this._checked;
                this._clicked = true;
            }
            sender.invalidate();
        }

        
    }

    /**
    Checked flag
    @param Boolean v
    @return Boolean
    */
    property checked(v)
    {
        get return this._checked;
        set {
            this._checked = v;
            this.invalidate() 
        }
    }

    /**
    Box Align
    @param Symbol v
        #left align left
        #right align right
    @return Symbol
    */
    property boxAlign(v)
    {
        get return this._boxAlign;
        set this._boxAlign = v;
    }

    /**
    Text Align
    @param Symbol v
        #left align to left
        #center align to center
        #right align to right
    @return Symbol
    */
    property textAlign(v)
    {
        get return this._textAlign;
        set this._textAlign = v;
    }

    /**
    Text property
    @param String v
    @return String
    */
    property text(v)
    {
        get return this._text;
        set this._text = v;
    }

    /**
    Box Pattern, it keeps on and off drawing of check box
    @return BoxDrawing
    */
    property box(v)
    {
        get
        {
            return this._box;
        }
    }
}
