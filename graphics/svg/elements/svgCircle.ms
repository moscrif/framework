include "lib://graphics/svg/svgElement.ms";

/**
Definition of svg circle element.
*/
class SVGCircle : SVGElement
{
    function init()
    {
        super.init();
        this._cx = 0;
        this._cy = 0;
        this._r = 0;
    }
    // @region Properties

    /**
    x-coordinate of the center of the cirle
    @param v Float | Integer | String
    @return Float
    */
    property cx(v)
    {
        get return this._cx;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGCircle.cx]");
            this._cx = v;
        }
    }

    /**
    y-coordinate of the center of the cirle
    @param v Float | Integer | String
    @return Float
    */
    property cy(v)
    {
        get return this._cy;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGCircle.cy]");
            this._cy = v;
        }
    }

    /**
    Radius of the circle.
    @param v Float | Integer | String
    @return Float
    */
    property r(v)
    {
        get return this._r;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVGCircle.radius]");
            this._r = v;
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
        return [this.cx-this.r, this.cy-this.r, this.cx+this.r, this.cy+this.r];
    }

    /**
    @public
    Method draw circle svg element.
    @param canvas Canvas
    */
    function draw(canvas)
    {
        if (this.fill != #none)
            canvas.drawCircle(Math.floor(this.cx), Math.floor(this.cy), Math.floor(this.r), this.paint);
    }

    /**
    @private
    Parse number from string.
    @param str String
    @return Float
    */
    function _parseNumber(str)
    {
        if (str instanceof Float || str instanceof Integer)
            return str;
        var value = str.scanf("%f");
        if (value.length)
            return value[0];
    }
}