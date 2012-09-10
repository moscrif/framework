include "lib://graphics/drawings/drawing.ms";

/**
Text drawing class, class handling native Paint
@package graphics
@location graphics/drawings/foreground.ms
*/
class Foreground : Drawing
{
    /**
        Setting controls of TextDrawing class
    */
    function _create(args)
    {
        super._create(args);

        this.fontFace = null;
        this._fontStyle = null;
        this._decoration = #none;
        this._transform = #none;
    }

    /**
    Set decoration of the text
    #none,#strikethrough,#underline,fakebold

    @property Symbol v
    @return Symbol
    */
    property decoration(v)
    {
        get return this._decoration;
        set {
            this._onChanged();
            this._decoration = v;
            switch(this._decoration)
            {
                case #strikethrough :
                    this.fakeBoldText = false;
                    this.strikeThruText = true;
                    this.underlineText = false;
                break;
                case #underline :
                    this.fakeBoldText = false;
                    this.strikeThruText = false;
                    this.underlineText = true;
                break;
                case #fakebold :
                    this.fakeBoldText = true;
                    this.strikeThruText = false;
                    this.underlineText = false;
                break;
                default :
                    this.fakeBoldText = false;
                    this.strikeThruText = false;
                    this.underlineText = false;
            }

        }
    }

    /**
    Transform text to uppercase, lovercase or First letter as capital
    #uppercase, #lowercase, #capitalize

    @property Symbol v
    @return Symbol
    */
    property transform(v)
    {
        get return this._transform;
        set {
            this._onChanged();
            this._transform = v;
        }
    }

    /**
    Text size, sets text size to paint object
    @param Integer v Text size
    @return Integer
    */
    property size(v)
    {
        get return this.textSize;
        set this.textSize = v;
    }


    /**
    Text size, sets text size to paint object
    @param Integer v Text size
    @return Integer
    */
    property textSize(v)
    {
        get return this._paint.textSize;
        set {
            this._onChanged();
            this.native.textSize = v;
        }
    }

    /**
    Linear Text, sets text size to paint object
    @param Boolean v Linear Text
    @return Boolean
    */
    property linearText(v)
    {
        get return this._paint.linearText;
        set {
            this._onChanged();
            this.native.linearText = v;
        }
    }

    /**
    subpixelText, sets tsubpixelText to paint object
    @param Boolean v subpixelText
    @return Boolean
    */
    property subpixelText(v)
    {
        get return this._paint.subpixelText;
        set {
            this._onChanged();
            this.native.subpixelText = v;
        }
    }

    /**
    underlineText, sets underlineText to paint object
    @param Boolean v underlineText
    @return Boolean
    */
    property underlineText(v)
    {
        get return this._paint.underlineText;
        set {
            this._onChanged();
            this.native.underlineText = v;
        }
    }

    /**
    strikeThruText, sets strikeThruText to paint object
    @param Boolean v strikeThruText
    @return Boolean
    */
    property strikeThruText(v)
    {
        get return this._paint.strikeThruText;
        set {
            this._onChanged();
            this.native.strikeThruText = v;
        }
    }

    /**
    fakeBoldText, sets fakeBoldText to paint object
    @param Boolean v fakeBoldText
    @return Boolean
    */
    property fakeBoldText(v)
    {
        get return this._paint.fakeBoldText;
        set {
            this._onChanged();
            this.native.fakeBoldText = v;
        }
    }

    /**
    Paint's Align value for drawing text.
    Used only in canvas.drawTextBox feature.
    @param Symbol v #top
                    #middle
                    #bottom
    @return Symbol
    */
    property textAlign(v)
    {
        get return this._paint.textAlign;
        set {
            this._onChanged();
            this.native.textAlign = v;
        }
    }

    /**
    Name of the font face(family name) for TypeFace object
    @param String v Font face(family name)
    @return String
    */
    property family(v)
    {
        get return this.fontFace;
        set this.fontFace = v;
    }

    /**
    Name of the font face(family name) for TypeFace object
    @param String v Font face(family name)
    @return String
    */
    property fontFace(v)
    {
        get {
            this._onChanged();
            return this._fontFace;
        }
        set
        {
            if(typeof v == #string){
                this._onChanged();
                this._fontFace = v;
                this._createTypeface();
            }
        }

    }

    /**
    Font style symbols for TypeFace object
    @param Symbol v  #normal
                    #bold
                    #italic
                    #bold+italic
    @return Symbol
    */
    property style(v)
    {
        get return this.fontStyle;
        set this.fontStyle = v;
    }

    /**
    Font style symbols for TypeFace object
    @param Symbol v  #normal
                    #bold
                    #italic
                    #bold+italic
    @return Symbol
    */
    property fontStyle(v)
    {
        get {
            this._onChanged();
            return this._fontStyle;
        }
        set
        {
             if(typeof v == #symbol){
                this._onChanged();
                this._fontStyle = v;
                this._createTypeface();
            }
        }
    }

    /**
    The greatest distance above the baseline for any glyph (will be <= 0).
    @return Float v
    */
    property fontTop(v)
    {
        get return this.native.fontTop;
    }

    /**
    The recommended distance above the baseline (will be <= 0).
    @return Float
    */
    property fontAscent(v)
    {
        get return this.native.fontAscent;
    }

    /**
    The recommended distance below the baseline (will be >= 0).
    @return Float
    */
    property fontDescent(v)
    {
        get return this.native.fontDescent;
    }

    /**
    The greatest distance below the baseline for any glyph (will be >= 0).
    @return Float
    */
    property fontBottom(v)
    {
        get return this.native.fontBottom;
    }

    /**
    The recommended distance to add between lines of text (will be >= 0).
    @return Float
    */
    property fontLeading(v)
    {
        get return this.native.fontLeading;
    }

    /**
    The average charactor width (>= 0)
    @return Float
    */
    property fontAvgCharWidth(v)
    {
        get return this.native.fontAvgCharWidth;
    }

    /**
    The minimum bounding box x value for all glyphs.
    @return Float
    */
    property fontXMin(v)
    {
        get return this.native.fontXMin;
    }

    /**
    The maximum bounding box x value for all glyphs.
    @return Float
    */
    property fontXMax(v)
    {
        get return this.native.fontXMax;
    }

    /**
    The height of an 'x' in px, or 0 if no 'x' in face
    @return Float
    */
    property fontXHeight(v)
    {
        get return this.native.fontXHeight;
    }

    /**
    Return the recommend line spacing. This will be Descent - Ascent + Leading
    @return Float
    */
    property fontSpacing(v)
    {
        get return this.native.fontSpacing;
    }

    /**
    Property keeps instence of native Typeface object.
    To create TypeFace object fontFace and fontStyle must by set
    @return TypeFace
    */
    property typeface(v)
    {
        get return this.native.typeface;
        set {
            assert v instanceof Typeface;
            this.native.typeface = v;
        }
    }

    /**
    Measuring of text. It returns width and height
    @return Multiplevalue
    */
    function measureText(text)
    {
        return this.native.measureText(text);
    }

    /**
    @visibility private
    Creation of typeface object. If fontFace and FontStyle is set
    it creates TypeFace object and set typeface property.
    */
    function _createTypeface()
    {
      if(typeof this._fontFace == #string &&
                typeof this._fontStyle == #symbol){
            this.typeface  = Typeface.fromName(this._fontFace, this._fontStyle);
       }

    }


}