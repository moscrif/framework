include "lib://uix/control/image.ms"
include "lib://graphics/paintCache.ms"

/**
Wrapper of Moscrif native Paint class. This class is use to decore Moscrif Controls
@package graphics
@location graphics/drawings/drawing.ms

*/
class Drawing : BaseClass
{
    var count = 0;
    /**
        Contructor, it initialise all required controls.
    */
    function init()
    {
        super.init();

        //Control which hold current drawing
        this._owner = null;
        this._property = null;
        this._cloned = false;
        this._visible = true;
    }

     /**
        @static
        Function to Create class
        @param <symbol> cls class name
        @param <Any> args method arguments
        @return <Object>
    */
    function create(cls,args ..)
    {
        var styleName = args[0].styleName;
        var suffix = "_" + args[1];
        var key = styleName + suffix;
        var obj = null;

        obj = new cls();
        obj._calledClass = cls;
        obj._owner = args[0];
        obj._ownerProperty = args[1];


        if(PaintCache.instance.hasPaint(key) && !obj._owner.initDefaults){
            obj._paint = PaintCache.instance.getPaint(key);
        }else {
            obj._paint = new Paint();
            count++;
            obj._paint.id = count;
            //cache only theme styles
            PaintCache.instance.storePaint(key,obj._paint);
        }

        return obj;
    }

    /**
    Owner of drawing object
    @return Control
    */
    property owner(v)
    {
        get return this._owner;
    }

    /**
    Property owner, where current Drawing belongs
    @return String
    */
    property ownerProperty(v)
    {
        get return this._ownerProperty;
    }

    /**
        Moscrif native instance. Used in drawing functions where
        instance of native Paint object is expected.

        @return Paint
    */
    property native(v)
    {
        get {

            if(this._gradient && this._gradient instanceof Gradient){
                this._paint.shader = this._gradient.native;
            }

            return this._paint;
        }
    }

    /**
    Type of the gradient. Moscrif supports three types of the gradients:
    #linear, #sweep, #bitmap.

    @param Symbol v
    @return Symbol
    */
    property gradient(v)
    {
        get {


            if(this._gradient == null)
                this._gradient = new Gradient();

            return this._gradient;
        }
        set {
            assert typeof v === Gradient;
            this._gradient = v;
            this.shader = this._gradient.native;
       }
    }
    
    /**
    Visibility of Drawings
    @param Boolean v
    @return Boolean
    */
    property visible(v)
    {
        get return this._visible;
        set {
         this._visible = v
        }
    }

    /**
        Define paint color. Paint consist with alpha channel and with RGB in hexadecimal format [channel + RGB].
        @example
            var color = 0xff0000ff
            //alpha channel:ff, R:00, G:00, B:ff
        @param Float v color in hexadecimal format
        @return Float
    */
    property color(v)
    {
        get return this.native.color;
        set {
            this._onChanged();
            this.native.color = v;
        }

    }

    /**
        Helper to getColor() that just setting or returning the color's alpha value.
        @param Integer v
        @return Integer
    */
    property alpha(v)
    {
        get return this.native.alpha;
        set {
            this._onChanged();
            this.native.alpha = v;
        }
    }

    /**
        Helper for Flags, setting or returning AntiAlias
        @param Boolean v
        @return Boolean
    */
    property antiAlias(v)
    {
        get return this.native.antiAlias;
        set {
            this._onChanged();
            this.native.antiAlias = v;
        }
    }

    /**
        Setting or returning paint's style, used for controlling how primitives' geometries are interpreted.
        @param Symbol v #fill - fill the geometry.
                        #stroke - stroke the geometry.
                        #stroke+fill - fill and stroke the geometry.
        @retrun Symbol
    */
    property style(v)
    {
        get return this.native.style;
        set {
            this._onChanged();
            this.native.style = v;
        }
    }

    /**
        Width for stroking. A value of 0 strokes in hairline mode. Hairlines always draw 1-pixel wide, regardless of the matrix.
        @param Float v
        @return float
    */
    property strokeWidth(v)
    {
        get return this.native.strokeWidth;
        set {
            this._onChanged();
            this.native.strokeWidth = v;
        }
    }

    /**
        Paint's stroke cap type, controlling how the start and end of stroked lines and paths are treated.
        @param Symbol v     #butt - begin/end contours with no extension
                            #round - begin/end contours with a semi-circle extension
                            #square - begin/end contours with a half square extension
        @return Symbol

    */
    property strokeCap(v)
    {
        get return this.native.strokeCap;
        set {
            this._onChanged();
            this.native.strokeCap = v;
        }
    }

    /**
        Drawings's stroke join type.
        @param Symbol v     #miter - connect path segments with a sharp join.
                            #round - connect path segments with a round join.
                            #bevel - connect path segments with a flat bevel join.
        @return Symbol
    */
    property strokeJoin(v)
    {
        get return this.native.strokeJoin;
        set {
            this._onChanged();
            this.native.strokeJoin = v;
        }
    }

    property filterBitmap(v)
    {
        get return this.native.filterBitmap;
        set {
            this._onChanged();
            this.native.filterBitmap = v;
        }
    }

    /**
        Drawings's Maskfilter object.
        Pass NULL to clear any previous maskfilter. As a convenience, the parameter passed is also returned.
        @param MaskFilter v
    */
    property maskFilter(v)
    {
        set {
            this._onChanged();
            this.native.maskFilter = v;
        }
    }

    /**
        Drawing's colorFilter Object
        @param ColorFilter v
    */
    property colorFilter(v)
    {
        set {
            this._onChanged();
            this.native.colorFilter = v;
        }
    }

     /**
    Shader instance. Shader can be linear, sweep or bitmap.
    To create linear shader position, color and position of collors must be sets
    @param Shader v
    */
    property shader(v)
    {
        set {
            ;//this.native.shader = v;
        }
    }

    /**
    Image control instantance to handle images in bitmap or in vector format.
    Setter accepts instance of Image, String location of bitmap, bitmap instance or path instance
    @param Image|String|Path|Bitmap
    @return Image
    */
    property image(v)
    {
        set {
            if (v instanceof Image)
                this.image = v;
            else if (v instanceof String || v instanceof Path || v instanceof Bitmap)
                this.image.source = v;
        }
        get {
            if (this._image == null)
                this._image = new Image();
            return this._image;
        }
    }

    /**
    Function called on property changed
    */
    function _onChanged()
    {
        if(!this.owner.initDefaults)
            return false;

        return this._clone();

    }

    /**
    Clone current object
    */
    function _clone()
    {

        if(this._cloned === true)
            return false;

        this._paint = new Paint();
        this._cloned = true;
       //finde default theme data
        var data = this.owner.defaults;
        for(var p in this.ownerProperty.split("."))
            data = data[symbol(p)];

        for(var p in data)
        {
            //set defaults to current property
            this.owner._setProperty(this,data,p);
        }

        return true;
    }

}