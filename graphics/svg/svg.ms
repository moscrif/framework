include "lib://core/baseClass.ms";
include "lib://core/parseXML.ms";
include "lib://core/exception.ms";
include "lib://graphics/svg/elements/svgGroup.ms";
include "lib://graphics/svg/elements/svgRectangle.ms";
include "lib://graphics/svg/elements/svgCircle.ms";
include "lib://graphics/svg/elements/svgPath.ms";
include "lib://graphics/svg/graphics/svgGradient.ms";

/**
Main class for SVG graphic.
*/
class SVG : BaseClass
{
    const _baseWidth = 640.0;
    const _baseHeight = 960.0;

    /**
    Init function
    */
    function init()
    {
        super.init();
        this._x = 0;
        this._y = 0;
        this._sx = 1.0;
        this._sy = 1.0;
        this._width = 0;
        this._height = 0;
        this._elements = new Array();
        this._gradients = new Array();
        this._matrix = new Matrix();
    }

    // @region Properties

    /**
    Unique identifier of SVG
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
    X - coordinate
    @param v Float | Integer | String
    @return Float
    */
    property x(v)
    {
        get return this._x;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVG.x]");
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
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVG.y]");
            this._y = v;
        }
    }

    /**
    Scale x
    @param v Float
    @return Float
    */
    property sx(v)
    {
        get return this._sx;
        set {
            assert v instanceof Float || v instanceof Integer;
            this._sx = v;
        }
    }

    /**
    Scale y
    @param v Float
    @return Float
    */
    property sy(v)
    {
        get return this._sy;
        set {
            assert v instanceof Float || v instanceof Integer;
            this._sy = v;
        }
    }

    /**
    Width
    @param v Float | Integer | String
    @return Float
    */
    property width(v)
    {
        get return this._width;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVG.width]");
            this._width = v;
        }
    }

    /**
    Height
    @param v Float | Integer | String
    @return Float
    */
    property height(v)
    {
        get return this._height;
        set {
            assert v instanceof Float || v instanceof Integer || v instanceof String;
            if ((v = this._parseNumber(v)) === undefined)   throw new ParseException("[SVG.height]");
            this._height = v;
        }
    }

    /**
    Title
    @param v String
    @return String
    */
    property title(v)
    {
        get return this._title;
        set {
            assert v instanceof String;
            this._title = v;
        }
    }

    /**
    Description
    @param v String
    @return String
    */
    property description(v)
    {
        get return this._description;
        set {
            assert v instanceof String;
            this._description = v;
        }
    }

    /**
    SVG source - file name or url where the data came from
    @return String
    */
    property source(v)
    {
        get return this._source;
    }

    /**
    Array of SVG elements in ascending render order. Fist in, first out in rendering.
    @param v Array
    @return Array
    */
    property elements(v)
    {
        get return this._elements;
        set {
            assert v instanceof Array;
            this._elements = v;
        }
    }

    /**
    Array of global gradients.
    @param v Array
    @return Array
    */
    property gradients(v)
    {
        get return this._gradients;
        set {
            assert v instanceof Array;
            this._gradients = v;
        }
    }

    /**
    SVG scale - return (sx, sy)
    @return Multivalue
    */
    property scale(v)
    {
        get return [this.sx, this.sy];
    }

    /**
    Width of the SVG based on current scale sx variable
    @return Float
    */
    property scaledWidth(v)
    {
        get return this.width * this.sx;
    }

    /**
    Height of the SVG based on current scale sy variable
    @return Float
    */
    property scaledHeight(v)
    {
        get return this.height * this.sy;
    }

    /**
    Define viewBox
    @param v String - string attribute from xml
    @return Array
    */
    property viewBox(v)
    {
        get {
            if (this._viewBox)
                return [this._vX, this._vY, this._vWidth, this._vHeight];
        }
        set {
            assert v instanceof String;
            var values = v.scanf("%f %f %f %f");
            if (values.length != 4)
                throw new ParseException("[SVG.viewBox]");
            this.setViewBox(values[0], values[1], values[2], values[3]);
        }
    }

    // @endregion

    // @region Public methods

    /**
    @public
    @static
    Create instance of SVG from svg file.
    @param source String|Stream
    @return SVG
    */
    function fromFile(source)
    {
        assert source instanceof String || source instanceof Stream;
        var input = null;
        if (source instanceof String)
            input = Stream.openFile(source, "r8");
        else
            input = source;
        assert input instanceof Stream;

        var svg = this._parseSVGfile(input);
        if (!svg.viewBox) {
            var bounds = svg.getBounds();
            svg.setViewBox(bounds[0], bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1]);
        }
        return svg;
    }

    /**
    @public
    Calculate sx, sy based on vector width and height.
    @param w Float
    @param h Float
    @return SVG rebuild instance of SVG
    @example
        Vector.setSize(System.width,System.height)
    */
    function setSize(w, h)
    {
        this.sx = 1.0*w/this.width;
        this.sy = 1.0*h/this.height;
    }

    /**
    @public
    Set x and y coordinate
    @param x Float
    @param y Float
    */
    function setPos(x, y)
    {
        this.x = x;
        this.y = y;
    }

    /**
    @public
    Set viewBox
    @param x Float
    @param y Float
    @param width Float
    @param height Float
    */
    function setViewBox(x, y, width, height)
    {
        this._vX = x;
        this._vY = y;
        this._vWidth = width;
        this._vHeight = height;
        this._width = width;
        this._height = height;
        this._viewBox = true;
    }

    /**
    @public
    Returns a svg registered element, it could be either group, gradient, path, rectangle.
    @param id String
    @return Element
    */
    function getObject(id)
    {
        for (var e in this.elements)
            if (e.id == id)
                return e;
        for (var g in this.gradients)
            if (g.id == id)
                return g;
    }

    /**
    @public
    Returns the bounds of the svg.
    @return Array - [left, top, righ, bottom]
    */
    function getBounds()
    {
        var bounds = new Array();
        for (var e in this.elements) {
            if (var b = e.getBounds())
                bounds.push(b);
        }
        if (bounds.length) {
            var left = bounds.reduce(:a,b:a[0]<b[0]?a:b); left = left[0];
            var top = bounds.reduce(:a,b:a[1]<b[1]?a:b); top = top[1];
            var right = bounds.reduce(:a,b:a[2]>b[2]?a:b); right = right[2];
            var bottom = bounds.reduce(:a,b:a[3]>b[3]?a:b); bottom = bottom[3];

            return [left, top, right, bottom];
        }
    }

    /**
    @public
    Method to be called within onDraw event, it draw all vector groups
    @param canvas Canvas
    @param x Float
    @param y Float
    @param width Float
    @param height Float
    */
    function draw(canvas, x=#undefined, y=#undefined, width=#undefined, height=#undefined)
    {
        x = (x!==#undefined)?x:this.x;
        y = (y!==#undefined)?y:this.y;
        var sx = (width!==#undefined)?1.0*width/this.width:this.sx;
        var sy = (height!==#undefined)?1.0*height/this.height:this.sy;

        canvas.save(#matrixClip);
        canvas.clipRect(Math.floor(x), Math.floor(y), Math.floor(x+this._vWidth*sx), Math.floor(y+this._vHeight*sy), #intersect);
        canvas.translate(-this._vX*sx, -this._vY*sy);
        canvas.translate(x, y);
        canvas.scale(sx, sy);
        
        for (var e in this.elements)
            e.draw(canvas);
        canvas.restore();
    }

    /**
    @public
    Add element to SVG elements array.
    @param element SVGElement|SVGGradient
    */
    function add(element)
    {
        assert element instanceof SVGElement || element instanceof SVGGradient;
        if (element instanceof SVGElement)
            this.elements.push(element);
        else if (element instanceof SVGGradient)
            this.gradients.push(element);
    }

    // @endregion

    // @region Private methods

    /**
    @private
    Parsing of svg file
    @param source Stream
    */
    function _parseSVGfile(source)
    {
        var svgInstance = null;
        var linearGradient = null;

        var scanner = new XMLScanner(source);
        var token = null;

        function scanNode(parent = null)
        {
            var atts = {};
            var tag = scanner.tag;
    
            while:loop(token = scanner.token())
            switch (token){
                case XMLScanner.EOF:            return;
                case XMLScanner.ERROR:          throw new ParseException("[SVG._parseSVGfile]" + "XML error at line " + scanner.lineNo);
                case XMLScanner.EMPTY_HEAD_END:
                case XMLScanner.HEAD_END:
                                                if (tag == "svg")              { svgInstance = new SVG(atts); parent = svgInstance; }
                                                else if (tag == "g")                { atts[#owner] = parent; var e = new SVGGroup(atts); parent.add(e); parent = e; }
                                                else if (tag == "rect")             { atts[#owner] = parent; var e = new SVGRectangle(atts); parent.add(e); }
                                                else if (tag == "circle")           { atts[#owner] = parent; var e = new SVGCircle(atts); parent.add(e); }
                                                else if (tag == "path")             { atts[#owner] = parent; var e = new SVGPath(atts); parent.add(e); }
                                                else if (tag == "linearGradient")   { linearGradient = new Array(); }
                                                else if (tag == "stop")             { assert linearGradient instanceof Array; linearGradient.push(atts); }

                                                if (token == XMLScanner.HEAD_END)               continue;
                                                else if (token == XMLScanner.EMPTY_HEAD_END)    break loop;

                case XMLScanner.ATTR:           atts[symbol(scanner.attribute)] = scanner.value; continue;
                case XMLScanner.TAIL:           if (tag == "linearGradient")        { atts.stops = linearGradient; atts.svgInstance = svgInstance; parent.add(SVGGradient.linear(atts)); linearGradient = null;}
                                                if (scanner.tag == tag)
                                                    break loop;
                                                else
                                                    throw String.printf("(Unexpected tail of %s at line %d", scanner.tag, scanner.lineNo);
                case XMLScanner.HEAD:           scanNode(parent); continue; // note: recursive call
            }
        }

        while(token = scanner.token()) {
        switch(token) {
            case XMLScanner.HEAD_END:       if (preprocessor) { stdout << scanner.tag << "\n"; if (scanner.tag == "?xml") preprocessor = false; } continue;
            case XMLScanner.EOF:            return;
            case XMLScanner.ERROR:          throw new ParseException("[SVG._parseSVGfile]" + "XML error at line " + scanner.lineNo);
            case XMLScanner.HEAD:           scanNode(); break;
            default:                        continue;
        }
    }

        if (!(svgInstance instanceof SVG)) throw new ParseException("[SVG._parseSVGfile]");
        return svgInstance;
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
    // @endregion
}