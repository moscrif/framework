include "lib://graphics/svg/svgElement.ms";

/**
Svg path element defines native Moscrif Path object based on “d” xml element.
*/
class SVGPath : SVGElement
{
    // @region Properties

    /**
    Moscrif native Path object created based on d property.
    @return Path
    */
    property native(v)
    {
        get return this._native;
    }

    /**
    D xml attribute of path element.
    @param v String
    @return String
    */
    property d(v)
    {
        get return this._d;
        set {
            assert v instanceof String;
            this._d = v;
            this._native = Path.fromSVG(v);
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
        var (bl, bt, br, bb) = this.native.getBounds();
        return [bl, bt, br, bb];
    }

    /**
    @public
    Method draw path svg element.
    @param canvas Canvas
    */
    function draw(canvas)
    {
        assert this.native instanceof Path;
        if (this.fill != #none)
            canvas.drawPath(this.native, this.paint);
    }
}