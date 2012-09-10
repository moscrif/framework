include "lib://core/baseClass.ms";

/**

Background drawings, it decorate background of Moscrift controls
@package graphics
@location graphics/drawings/background.ms
*/
class Gradient : BaseClass
{
    /**
    Init Bacground object
    */
    function init()
    {
        super.init();
        this._shape = #linear;
        this._native = null;
    }

    property native(v)
    {
        get {

            if(this._native == null)
                this._createShader();

            return this._native;

        }
    }

    /**
    Type of the gradient shape. Moscrif supports three types of the gradients:
    #linear, #sweep, #bitmap.

    @param Symbol v
    @return Symbol
    */
    property shape(v)
    {
        get return this._shape;
        set {
            assert typeof v === #symbol;
            this._shape = v;
       }
    }

    /**
    The X coordinate of the center of the sweep gradient.

    @param Integer v
    @retrun Integer
    */
    property cx(v)
    {
        get return this._cx;
        set {
            this._cx = v;
        }
    }

    /**
    The Y coordinate of the center of the sweep gradient.

    @param Integer v
    @retrun Integer
    */
    property cy(v)
    {
        get return this._cy;
        set {
            this._cy = v;
        }
    }


    /**
        The start and end points for the gradient.
        @param Object v
        @return Object
        @throw InvalidArgument Expects object
    */
    property points(v)
    {
        get {
            return this._points;
        }
        set {
            if(typeof v == #object){
                this._points = v;
            }else throw new InvalidArgument("[Drawing.points] Expects object");
        }
    }

    /**
        The array of colors, to be distributed between the two points
        @param Array v
        @return Array
        @throw InvalidArgument Expects Array
    */
    property colors(v)
    {
        get {
            return this._colors;
        }
        set {
            if(typeof v == #array){
                this._colors = v;
            }else throw new InvalidArgument("[Drawing.points] Expects Array");
        }
    }

     /**
        Array of float values, or NULL, of the relative position of each corresponding color in the colors array.
        If this is NULL, the colors are distributed evenly between the start and end point.
        If this is not null, the values must begin with 0, end with 1.0, and intermediate values must be strictly increasing.
        @param Array v
        @return Array
        @throw InvalidArgument Expects Array
    */
    property position(v)
    {
        get return this.pos;
        set this.pos = v;
    }

    /**
        Array of float values, or NULL, of the relative position of each corresponding color in the colors array.
        If this is NULL, the colors are distributed evenly between the start and end point.
        If this is not null, the values must begin with 0, end with 1.0, and intermediate values must be strictly increasing.
        @param Array v
        @return Array
        @throw InvalidArgument Expects Array
    */
    property pos(v)
    {
        get {
            return this._pos;
        }
        set {
            if(typeof v == #array){
                this._pos = v;
            }else throw new InvalidArgument("[Drawing.pos] Expects Array");
        }
    }

    /**
    The bitmap to use inside the bitmap shader.

    @param String v
    @return String
    */
    property source(v)
    {
        get return this._source;
        set {
            this._source = v;
        }
    }

     /**
        @visibility private
        Createion of linear gradient.
        Points, colors and positions must be sets to create this gradient
    */
    function _createShader()
    {

        switch(this._shape){
            case #linear:
                this._createLinearShader();
            break;
            case #sweep:
                this._createSweepShader();
            break;
            case #bitmap:
                this._createBitmapShader();
            break;
        }
    }

    /**
    Create linear shader
    @visibility private
    */
    function _createLinearShader()
    {
        if(typeof this._points == #object && typeof this._colors == #array && typeof this._pos == #array)
            this._native = Shader.linear(this._points, this._colors, this._pos, "mode");

    }

    /**
    Create sweep shader
    @visibility private
    */
    function _createSweepShader()
    {
        if(this._cx &&  this._cy && typeof this._colors == #array && typeof this._pos == #array)
            this._native = Shader.sweep(this._cx, this._cy, this._colors, this._pos);

    }

    /**
    Create bitmap shader
    @visibility private
    */
    function _createBitmapShader()
    {
        if(this._source && typeof this._tileModeX == #symbol && typeof this._tileModeY == #symbol )
            this._native = Shader.sweep(this._source, this._tileModeX, this._tileModeY);
    }


}