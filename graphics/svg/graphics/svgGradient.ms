include "lib://core/baseClass.ms";
include "lib://graphics/svg/graphics/svgColors.ms";

/**
This object exist only if SVG defines global gradient for reusing in other case shader can be created by static method Gradient.linear(options).
*/
class SVGGradient : BaseClass
{
    /**
    Unique identifier of linear gradient.
    @param v String
    @return String
    */
    property id(v)
    {
        get return this._id;
        set {
            assert v instanceof String;
            this._id = v;
        }
    }

    /**
    Define a gradient vector for the linear gradient.
    @param v Float|String
    @return Float
    */
    property x1(v)
    {
        get return this._x1;
        set {
            assert v instanceof Float || v instanceof String;
            if (v instanceof String)    { v = v.toNumber(); if (v === #undefined) throw new ParseException("[SVGGradient.x1]"); }
            this._x1 = v;
        }
    }

    /**
    Define a gradient vector for the linear gradient.
    @param v Float|String
    @return Float
    */
    property x2(v)
    {
        get return this._x2;
        set {
            assert v instanceof Float || v instanceof String;
            if (v instanceof String)    { v = v.toNumber(); if (v === #undefined) throw new ParseException("[SVGGradient.x2]"); }
            this._x2 = v;
        }
    }

    /**
    Define a gradient vector for the linear gradient.
    @param v Float|String
    @return Float
    */
    property y1(v)
    {
        get return this._y1;
        set {
            assert v instanceof Float || v instanceof String;
            if (v instanceof String)    { v = v.toNumber(); if (v === #undefined) throw new ParseException("[SVGGradient.y1]"); }
            this._y1 = v;
        }
    }

    /**
    Define a gradient vector for the linear gradient.
    @param v Float|String
    @return Float
    */
    property y2(v)
    {
        get return this._y2;
        set {
            assert v instanceof Float || v instanceof String;
            if (v instanceof String)    { v = v.toNumber(); if (v === #undefined) throw new ParseException("[SVGGradient.y2]"); }
            this._y2 = v;
        }
    }

    /**
    Gradient definition object
    @param v Object
    @return Object
    */
    property gOptions(v)
    {
        get return this._gOptions;
        set this._gOptions = v;
    }

    /**
    Moscrif native object Shader
    @param v Shader
    @return Shader
    */
    property native(v)
    {
        get return this._shader;
        set {
            assert v instanceof Shader;
            this._shader = v;
        }
    }

    /**
    @public
    @static
    Method creates new shader based on g.stops
    @param options Object
    @param options Object
    @return SVGGradient
    */
    function linear(options)
    {
        var g = new SVGGradient(options);
        g.x1 = g.x1 === #undefined? 0.0 : g.x1;
        g.y1 = g.y1 === #undefined? 0.0 : g.y1;
        g.x2 = g.x2 === #undefined? g.svgInstance.width : g.x2;
        g.y2 = g.y2 === #undefined? 0.0 : g.y2;
        var _pts = {
            start: {
                x: Math.floor(g.x1),
                y: Math.floor(g.y1)
            },
            end:   {
                x: Math.floor(g.x2),
                y: Math.floor(g.y2),
            }
        };
        g.gOptions = {pts: _pts, clrs: [], pos: []}
        for (var i = 0; i < g.stops.length; i++) {
            // parse offset
            var value = [];
            var t = #undefined;
            if (g.stops[i].offset.endsWith("%")) {
                value = g.stops[i].offset.scanf("%d%");
                t = #percentage;
            }
            else {
                value = g.stops[i].offset.scanf("%f");
                t = #number;
            }
            if (value.length == 1) {
                if (t == #percentage)
                    value[0] = value[0] / 100.0;
                if (value[0] < 0)       value[0] = 0.0;
                else if (value[0] > 1)  value[0] = 1.0;
                g.gOptions.pos.push(value[0]);
            }
            else
                throw new ParseException("[SVGGradient.linear]");
            // parse style
            g.gOptions.clrs.push(this._parseStyle(g.stops[i].style));
        }
        g.native = Shader.linear(g.gOptions.pts, g.gOptions.clrs, g.gOptions.pos, 0);
        return g;
    }

    /**
    @private
    Parse style attribute
    @param str String
    @return Integer color
    */
    function _parseStyle(str)
    {
        // add end char
        if (!str.endsWith(";"))
            str += "\"";
        var color = 0xff000000;
        var attr = #undefined;
        var colon = false;
        for (var i = 0; i < str.length; i++) {
            // jump spaces
            if (str[i] == ' ' || str[i] == '\t' || str[i] == '\n' || str[i] == ';')  continue;
            // crop start of string where are spaces
            str = str.substring(i, -1);
            i = 0;
            if (str.startsWith("stop-color")) {
                // crop start of string
                str = str.substring(10, -1);
                // set iterator to init state
                i = -1;
                attr = #color;
            } else if (str.startsWith("stop-opacity")) {
                str = str.substring(12, -1);
                i = -1;
                attr = #opacity;
            } else if (str.startsWith(":")) {
                str = str.substring(1, -1);
                i = -1;
                colon = true;
            } else if (colon) {
                var endChar = new Array();
                endChar.push(str.indexOf("\""));
                endChar.push(str.indexOf(" "));
                endChar.push(str.indexOf("\t"));
                endChar.push(str.indexOf("\n"));
                endChar.push(str.indexOf(";"));
                // remove values with index less than 0
                endChar = endChar.filter(:e:e>=0);
                // choose minimum
                endChar = endChar.reduce(:a,b: a<b?a:b);
                var value = str.substring(0, endChar);
                if (attr == #color) {
                    if (color = SVGColors.getByName(value) || (color = SVGColors.fromValue(value))) {}
                    else
                        throw new ParseException("[SVGGradient._parseStyle]");
                }
                else if (attr == #opacity) {
                    value = value.toNumber();
                    if (value === #undefined)
                        throw new ParseException("[SVGGradient._parseStyle]");
                    value = Math.floor(255*value);
                    value = value << 24;
                    color = (color & 0x00ffffff) | value;
                }
                str = str.substring(endChar+1, -1);
                i = -1;
                colon = false;
            } else
                throw new ParseException("[SVGGradient._parseStyle]");
        }
        return color;
    }
}