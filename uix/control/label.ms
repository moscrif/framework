include "lib://core/exception.ms";
include "lib://uix/base/textComponent.ms";


/**
   @package uix
   @location uix/control/label.ms
 * Class provides text display.
 */
class Label : TextComponent
{
    /**
     * Init variables
     */
    function init()
    {
        //init StaticContainer
        super.init();
        
        //Set properties on default values
        this.marginX = 0;
        this.marginY = 0;
        this.horzAlign = #center;
        this.vertAlign = #center;
        this.multiline = true;
        this.autoSize = #fixed;

       /* //Handler on user defined onDraw function
        this._onDrawHandler = function (sender,canvas)
        {
            skin.drawLabel(this, canvas);
        }*/
        this._text = "";
    }

    /**
    Multiline property, default is set to false.
    @param Boolean v
    @return Boolean
    */
    property multiLine(v)
    {
        get return this.native.multiline;
        set this.native.multiline = v;
    }

    /**
    Gets or sets auto-size flag of this Label
    @param Symbol v
    @return Symbol
    */
    property autoSize(v)
    {
        get return this.native.autoSize;
        set this.native.autoSize = v;
    }

    /**
     * Property for margin on axis x
     * @param Integer marginX
     * @return Integer marginX
     */
    property marginX(v)
    {
        get return this.native.marginX;
        set {
            this.native.marginX = v;
//            this._setSize();
            this.invalidate();
        }
    }

    /**
     * Property for margin on axis y
     * @param Integer marginY
     * @return Integer marginY
     */
    property marginY(v)
    {
        get return this.native.marginY;
        set {
            this.native.marginY = v;
           // this._setSize();
            this.invalidate();
        }
    }

   

    /**
     * Property fot text label.
     * @param String text
     * @return String text
       @throw InvalidArgument instance of string expected
     */
    property text(v)
    {
        get return this.native.text;
        set {
            if (typeof v == #string) {
                this.native.text = v;
                //this._setSize();
                this.invalidate();
            }
            else
                throw new InvalidArgument("[Label.text] instance of string expected");
        }
    }

    /**
     * Property for horizontal align
     * @param Symbol v
        #left, #center, #right  align
     * @return Symbol
     */
    property horzAlign(v)
    {
        get return this.native.horzAlign;
        set {
            this.native.horzAlign = v;
           // this._setSize();
            this.invalidate();
        }
    }

    /**
     * Property for vertical align
     * @param Symbol v
       #top, #center, #bottom  align
     * @return Symbol
     */
    property vertAlign(v)
    {
        get return this.native.vertAlign;
        set {
            this.native.vertAlign = v;
            //this._setSize();
            this.invalidate();
        }
    }


}