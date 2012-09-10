include "lib://graphics/drawings/drawing.ms";

/**

Background drawings, it decorate background of Moscrift controls
@package graphics
@location graphics/drawings/background.ms
*/
class Border : Drawing
{
    //Border with constance
    const BORDER_WIDTH = System.width/50;
    //Border style
    const BORDER_STYLE = #stroke;

    function init()
    {
        super.init();
        this._rx = 0;
        this._ry = 0;
        this._shape = #rectangle;
    }

   
    
    /**
        Border width
        @param Integer v
        @return Integer
    */
    property borderWidth(v)
    {
        get return this._borderWidth;
        set this._borderWidth = v;
    }

    /**
        Border style
        @param Symbol v     #fill - fill the geometry.
                            #stroke - stroke the geometry.
                            #stroke+fill - fill and stroke the geometry.
        @return Symbol

    */
    property borderStyle(v)
    {
        get return this._borderStyle;
        set this._borderStyle = v;
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
        Set borders properties, ecpects array of colors or array of drawings objects
        [left top right bottom]
        @visibility private
    */
    function _setBorders()
    {
        for(var i=0;i<this._borders.length;i++)
        {
             switch(i) {
                case 0 : this._setBorder("Left",this.borders[i]);break;
                case 1 : this._setBorder("Top",this.borders[i]);break;
                case 2 : this._setBorder("Right",this.borders[i]);break;
                case 3 : this._setBorder("Bottom",this.borders[i]);break;
            }
        }
    }

    /**
        Set properties to border
        @visibility private
        @params <string> l location of border
        @params <integer|object> d data , accepet color definition or drawing object settings
    */
    function _setBorder(l,d)
    {
        var p = symbol("border"+l);
        var o = this.propertyAt(p);

        if(typeof(d) === #integer){
            o.color = d;
            o.strokeWidth = this.boderWidth?this.boderWidth:BORDER_WIDTH;
            o.style = this.borderStyle?this.borderStyle:BORDER_STYLE;
        }else if(typeof(d) === #object){

            for(var pp in d)
                this._setProperty(o,d,pp);

        }else throw new InvalidArgument("[Background._setBorder] expect color or Drawing object");



    }


}