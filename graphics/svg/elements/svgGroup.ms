include "lib://graphics/svg/svgElement.ms";
include "lib://core/exception.ms";

/**
SVG group specify SVG items what suppose to be drawn as one part. Group can adjust opacity of the items, transform group or rotate group.
*/
class SVGGroup : SVGElement
{
    function init()
    {
        super.init();
        this._transform = new Matrix();
        this._elements = new Array();
        this._gradients = new Array();
    }

    // @region Properties

    /**
    Define how rendered matrix should be transformed.
    @param v String
    @return Matrix
    @example SVGGroup.transform = "translate(20,10) rotate(45)";
    */
    property transform(v)
    {
        get return this._transform;
        set {
            assert v instanceof String;
            // return array of JSON {name:symbol, value:array}
            var transforms = this._parseTransform(v);
            // reset matrix
            this._transform.reset();
            for (var t in transforms) {
                if (t.name == #translate) {
                    // chceck count of parameters
                    if (t.value.length == 1) {
                        this._transform.preTranslate(t.value[0], t.value[0]);
                    }
                    else if (t.value.length == 2) {
                        this._transform.preTranslate(t.value[0], t.value[1]);
                    }
                    // wrong count of parameters
                    else throw new ParseException("[SVGGroup.transform.set]");
                }
                else if (t.name == #scale) {
                    if (t.value.length == 1) {
                        this._transform.preScale(t.value[0], t.value[0], 0, 0);
                    }
                    else if (t.value.length == 2) {
                        this._transform.preScale(t.value[0], t.value[1], 0, 0);
                    }
                    else throw new ParseException("[SVGGroup.transform.set]");
                }
                else if (t.name == #rotate) {
                    if (t.value.length == 1) {
                        this._transform.preRotate(t.value[0], 0, 0);
                    }
                    else if (t.value.length == 3) {
                        this._transform.preRotate(t.value[0], t.value[1], t.value[2]);
                    }
                    else throw new ParseException("[SVGGroup.transform.set]");
                }
                else if (t.name == #skewX) {
                    if (t.value.length == 1) {
                        this._transform.preSkew(t.value[0], 0, 0, 0);
                    }
                    else throw new ParseException("[SVGGroup.transform.set]");
                }
                else if (t.name == #skewY) {
                    if (t.value.length == 1) {
                        this._transform.preSkew(0, t.value[0], 0, 0);
                    }
                    else throw new ParseException("[SVGGroup.transform.set]");
                }
                else if (t.name == #matrix) {
                    if (t.value.length == 6) {
                        // nothing
                    }
                    else throw new ParseException("[SVGGroup.transform.set]");
                }
            }
        }
    }

    /**
    Opacity for all object in group
    @param v Float
    @return Float
    */
    property opacity(v)
    {
        get return this._opacity;
        set {
            assert v instanceof Float || v instanceof String;
            if (v instanceof String)    { v = v.toNumber(); if (v === #undefined) throw new ParseException("[SVGGroup.opacity]"); }
            assert v <= 1.0;
            this._opacity = v;
        }
    }

    /**
    Array of vector elements. Element can be a path, rectangle or circle.
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
    Array of vector elements. Element can be a path, rectangle or circle.
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

    // @endregion

    // @region Public methods

    /**
    @public
    Returns the bounds of the group.
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
    Method trigger drawing of each registered elements.
    @param canvas Canvas
    */
    function draw(canvas)
    {
        canvas.save(#matrix);
        canvas.concat(this.transform);
        for (var e in this.elements)
            e.draw(canvas);
        canvas.restore();
    }

    /**
    @public
    Method returns a svg registered element, it could be either group, gradient, path, rectangle.
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

        if (this.owner)
            return this.owner.getObject(id);
    }

    /**
    @public
    Add element into elements array.
    @param element Element
    */
    function add(element)
    {
        assert element instanceof SVGElement || element instanceof SVGGradient;
        element.owner = this;
        if (element instanceof SVGElement) {
            if (element.fill instanceof String)
                element.createPaint(element.fill);
            element.opacity *= this.opacity;
            this.elements.push(element);
        }
        else if (element instanceof SVGGradient)
            this.gradients.push(element);
    }

    // @endregion

    /**
    @private
    Parse transform atribut and return array of JSON {name:symbol, value:Array}
    @param str String input string
    @return Array
    */
    function _parseTransform(str)
    {
        var transforms = new Array();
        var at = null; // actual transform
        for (var i = 0; i < str.length; i++) {
            // jump spaces
            if (str[i] == ' ' || str[i] == '\t' || str[i] == '\n')  continue;
            // crop start of string where are spaces
            str = str.substring(i, -1);
            i = 0;

            if (str.startsWith("translate")) {
                // crop start of string
                str = str.substring(9, -1);
                // set iterator to init state
                i = -1;
                // create new transform
                at = {name: #translate, value: null};
            } else if (str.startsWith("rotate")) {
                str = str.substring(6, -1)
                i = -1;
                at = {name: #rotate, value: null};
            } else if (str.startsWith("scale")) {
                str = str.substring(5, -1);
                i = -1;
                at = {name: #scale, value: null};
            } else if (str.startsWith("skewX")) {
                str = str.substring(5, -1);
                i = -1;
                at = {name: #skewX, value: null};
            } else if (str.startsWith("skewY")) {
                str = str.substring(5, -1);
                i = -1;
                at = {name: #skewY, value: null};
            } else if (str.startsWith("matrix")) {
                str = str.substring(6, -1)
                i = -1;
                at = {name: #matrix, value: null};
            } else if (at && !at.value && str.startsWith("(")) {
                var rightBracket = str.indexOf(")");
                // if there are not right bracket
                if (rightBracket == -1)
                    throw new ParseException("[SVGGroup._parseTransform]");

                var value = str.substring(1, rightBracket);
                var values = value.split(",");
                if (!values.length)
                    // wrong input format
                    throw new ParseException("[SVGGroup._parseTransform]");

                for (var i = 0; i < values.length; i++) {
                    values[i] = values[i].toNumber();
                    // error at parsing number
                    if (values[i] === #undefined)
                        throw new ParseException("[SVGGroup._parseTransform]");
                }
                // assign convert numbers
                at.value = values;
                // add transform to array
                transforms.push(at);
                at = null;
                // crop proccessed part of string
                str = str.substring(rightBracket+1, -1);
                // set iterator to start
                i = -1;
            }
            else throw new ParseException("[SVGGroup._parseTransform]");
        }
    // return array of transforms
    return transforms;
    }
}