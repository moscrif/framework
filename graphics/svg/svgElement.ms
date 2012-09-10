include "lib://core/baseClass.ms";
include "lib://graphics/svg/graphics/svgColors.ms";

/**
@abstract
Svg element is a base element, extended form base class.
*/
class SVGElement : BaseClass
{
    function init()
    {
        super.init();
        this._paint = new Paint();
        this._opacity = 1.0;
    }

    function afterInit()
    {
        super.afterInit();
        if (this._fill)
            this.createPaint(this._fill);
    }

    // @region Properties

    /**
    Unique identifier of svg element
    @param v String
    @return String
    */
    property id(v)
    {
        get return this._id;
        set this._id = v;
    }

    /**
    Definition how element going to be filled
        - none, do not fill object
        - color, fill object by color
        - gradient id, fill object by gradient
    @return Symbol|Integer|String
    */
    property fill(v)
    {
        get return this._fill;
        set {
            this._fill = v;
        }
    }

    /**
    Opacity
    @param v Float
    @return Float
    */
    property opacity(v)
    {
        get return this._opacity;
        set {
            assert v instanceof Float || v instanceof String;
            if (v instanceof String)    { v = v.toNumber(); if (v === #undefined) throw new ParseException("[SVGElement.opacity]"); }
            assert v <= 1.0;
            this._opacity = v;
            this.paint.alpha = Math.floor(255*v);
        }
    }

    /**
    Instance of Paint object
    @param v Paint
    @return Paint
    */
    property paint(v)
    {
        get return this._paint;
        set {
            assert v instanceof Paint;
            this._paint = v;
        }
    }

    /**
    Instance of SVG, to be able to access global gradients
    @return SVG
    */
    property owner(v)
    {
        get return this._owner;
        set {
            assert v instanceof SVG || v instanceof SVGGroup;
            this._owner = v;
        }
    }

    // @endregion

    /**
    @public
    Create moscrif native paint object based on fill parameter.
    @param fill String
    @return Paint
    */
    function createPaint(fill)
    {
        assert fill instanceof String;

        if (fill == "none") {
            this._fill = #none;
        }
        else if (var color = SVGColors.getByName(fill) || (color = SVGColors.fromValue(fill))) {
            this._fill = color;
            var alpha = this.paint.alpha;
            this.paint.color = color;
            this.paint.alpha = alpha;
        }
        else if (var id = this._parseUrl(fill)) {
            if (var object = this.owner.getObject(id)) {
                assert object instanceof SVGGradient;
                assert object.native instanceof Shader;
                this.paint.shader = object.native;
            }
            else
                throw new Exception("[SVGElement.createPaint] Url id does not exist.");
        }
    }

    /**
    @private
    Parse id from url string
    @param str String
    @return String
    */
    function _parseUrl(str)
    {
        var url = false;
        var leftBracket = false;
        var grid = false;
        for (var i = 0; i < str.length; i++) {
            // jump spaces
            if (str[i] == ' ' || str[i] == '\t' || str[i] == '\n')  continue;
            // crop start of string where are spaces
            str = str.substring(i, -1);
            i = 0;
            if (str.startsWith("url")) {
                // crop start of string
                str = str.substring(3, -1);
                // set iterator to init state
                i = -1;
                url = true;
            } else if (url && str.startsWith("(")) {
                str = str.substring(1, -1);
                i = -1;
                leftBracket = true;
            } else if (url && str.startsWith("#")) {
                str = str.substring(1, -1);
                i = -1;
                grid = true;
            } else if (url && leftBracket && grid) {
                var rightBracket = str.indexOf(")");
                if (rightBracket >= 0) {
                    return str.substring(0, rightBracket);
                }
            }
        }
    }
}