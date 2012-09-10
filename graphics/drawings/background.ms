include "lib://graphics/drawings/drawing.ms";
include "lib://graphics/drawings/gradient.ms";

/**

Background drawings, it decorate background of Moscrift controls
@package graphics
@location graphics/drawings/background.ms
*/
class Background : Drawing
{

    function init()
    {
        super.init();
        this._gradient = null;
        this._rx = 0;
        this._ry = 0;
        this._shape = #rectangle;

        this._border = null;
        this._borders = [];
        this._borderTop    = null;
        this._borderLeft   = null;
        this._borderBottom = null;
        this._borderRight  = null;

    }

    

    /**
    Border type, it can be rectangle or oval rectangle
    @return Symbol #rectangle, #ovalRectangle
    */
    property shape(v)
    {
        get return this._shape;
    }

    /**
    X-radius of the oval used to round the corners
    @param Float v
    @return Float
    */
    property rx(v)
    {
        get return this._rx;
        set {
            this._rx = v;
            this._shape = #roundRectangle
        }
    }

    /**
    Y-radius of the oval used to round the corners
    @param Float v
    @return Float
    */
    property ry(v)
    {
        get return this._ry;
        set {
            this._ry = v;
            this._shape = #roundRectangle
        }
    }


    /**
    The tiling mode to use when sampling the bitmap in the x-direction. For supported modes see Gradient modes.
    #clamp - Draw bitmap only ones.
    #repeat - Repeat bitmap more times.
    #mirror - Repeat bitmap more times, but mirror turned.

    @param Symbol v
    @return Symbol
    */
    property tileModeX(v)
    {
        get return this._tileModeX;
        set {
            assert typeof v === #symbol;
            this._onChanged();
            this._tileModeX = v;
            this._createShader();
        }
    }

    /**
    The tiling mode to use when sampling the bitmap in the y-direction. For supported modes see Gradient modes.
    #clamp - Draw bitmap only ones.
    #repeat - Repeat bitmap more times.
    #mirror - Repeat bitmap more times, but mirror turned.

    @param Symbol v
    @return Symbol
    */
    property tileModeY(v)
    {
        get return this._tileModeY;
        set {
            assert typeof v === #symbol;
            this._onChanged();
            this._tileModeY = v;
            this._createShader();
        }
    }

    /**
    Border drawing, it holds instance of Drawing to decorate border
    @param Drawing v
    @return Drawing
    @throw InvalidArgument Accepts instance of Drawing
    */
    property border(v)
    {
        get
        {
            if(this._border == null)
                this._border = Border.create(Border,this.owner,"bg.border");

            return this._border;
        }
        set
        {
            if(v instanceof Drawing)
                this._border = v
            else
                throw new InvalidArgument("[Decorator.border] Accepts instance of Drawing");
        }

    }

    /**
        Border top Drawing, decorate border top
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderTop(v)
    {
        get {
            if(this._borderTop == null)
                this._borderTop = Border.create(Border,this.owner,"bg.borderTop");
            return this._borderTop;
        }
        set {
            if(v instanceof Drawing){
                this._borderTop = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.borderTop] expects instance of Drawing");

        }
    }

    /**
        Border Left Drawing, decorate border Left
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderLeft(v)
    {
        get {
            if(this._borderLeft == null)
                this._borderLeft = Border.create(Border,this.owner,"bg.borderLeft");
            return this._borderLeft;
        }
        set {
            if(v instanceof Drawing){
                this._borderLeft = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.borderLeft] expects instance of Drawing");

        }
    }

    /**
        Border Bottom Drawing, decorate border Bottom
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderBottom(v)
    {
        get {
            if(this._borderBottom == null)
                this._borderBottom = Border.create(Border,this.owner,"bg.borderBottom");
            return this._borderBottom;
        }
        set {
            if(v instanceof Drawing){
                this._borderBottom = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.border_bottom] expects instance of Drawing");

        }
    }

    /**
        Border Right Drawing, decorate border Right
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderRight(v)
    {
        get {
            if(this._borderRight == null)
                this._borderRight = Border.create(Border,this.owner,"bg.borderRight");
            return this._borderRight;
        }
        set {
            if(v instanceof Drawing){
                this._borderRight = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.borderRight] expects instance of Drawing");

        }
    }


    /**
        Drawing of the image
        @param canvas
        @param Integer left
        @param Integer top
    */
    function drawImage(canvas, left = 0, top = 0)
    {
        this._image.drawImage(canvas, left, top, this._paint);
    }

}