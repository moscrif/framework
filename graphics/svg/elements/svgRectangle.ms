include "lib://graphics/svg/svgElement.ms";

/**
Rectangle svg element. It defines generic rectangle parameters and appearance of the stroke.
*/
class SVGRectangle : SVGElement
{
    function init()
    {
        super.init();
        this._x = 0;
        this._y = 0;
        this._width = 0;
        this._height = 0;
        this._stroke = new Paint();
        this._stroke.style = #stroke;
    }

    // @region Properties

    /**
    X - coordinate
    @param v Float | Integer | String
    @return Float
    */
    property x(v)
    {
        get return this._x;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGRectangle.x]");
            this._x = v;
        }
    }

    /**
    Y - coordinate
    @param v Float | Integer | String
    @return Float
    */
    property y(v)
    {
        get return this._y;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGRectangle.y]");
            this._y = v;
        }
    }

    /**
    Element width
    @param v Float | Integer | String
    @return Float
    */
    property width(v)
    {
        get return this._width;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGRectangle.width]");
            this._width = v;
        }
    }

    /**
    Element height
    @param v Float | Integer | String
    @return Float
    */
    property height(v)
    {
        get return this._height;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGRectangle.height]");
            this._height = v;
        }
    }

    /**
    Stroke color
    @param v Integer | String
    @return Integer
    */
    property stroke(v)
    {
        get return this._stroke.color;
        set {
            assert v instanceof Integer || v instanceof String;
            var color = 0;
            if (v instanceof String) {
                if (color = SVGColors.getByName(v) || (color = SVGColors.fromValue(v))) {}
                else throw new ParseException("[SVGRectangle.stroke]");
            }
            else color = v;

            var alpha = this._stroke.alpha;
            this._stroke.color = color;
            this._stroke.alpha = alpha;

        }
    }

    /**
    Adjust stroke width.
    @param v Integer
    @return Integer
    */
    property strokeWidth(v)
    {
        get return this._stroke.strokeWidth;
        set {
            assert v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v, Integer)) === undefined)   throw new ParseException("[SVGRectangle.strokeWidth]");
            this._stroke.strokeWidth = v;
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
            if ((v = this._parseNumber(v)) === undefined)    throw new ParseException("[SVGElement.opacity]");
            assert v <= 1.0;
            this._opacity = v;
            var intOp = Math.floor(255*v);
            this.paint.alpha = intOp;
            this._stroke.alpha = intOp;
        }
    }

    // @endregion

    /**
    @public
    Returns the bounds of the element.
    @return Array - [left, top, righ, bottom]
    */
    function getBounds()
    {
        return [this.x - this.strokeWidth, this.y - this.strokeWidth, this.x+this.width + this.strokeWidth, this.y+this.height + this.strokeWidth];
    }

    /**
    @public
    Method draw svg rectangle element.
    @param canvas Canvas
    */
    function draw(canvas)
    {
        if (this.strokeWidth)
            canvas.drawRect(Math.floor(this.x - this.strokeWidth/2), Math.floor(this.y - this.strokeWidth/2), Math.floor(this.x + this.width + this.strokeWidth/2), Math.floor(this.y + this.height + this.strokeWidth/2), this._stroke);
        if (this.fill != #none)
            canvas.drawRect(Math.floor(this.x), Math.floor(this.y), Math.floor(this.x + this.width), Math.floor(this.y + this.height), this.paint);
    }

    /**
    @private
    Parse number from string.
    @param str String
    @param to Type define type to convert
    @return Float
    */
    function _parseNumber(str, to = Float)
    {
        if (str instanceof Integer || str instanceof Float)
            return str;

        var value = [];
        if (to == Float)
            value = str.scanf("%f");
        else if (to == Integer)
            value = str.scanf("%d");

        if (value.length)
            return value[0];
    }
}