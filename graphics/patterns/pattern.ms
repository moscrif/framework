
include "lib://graphics/patterns/patternBase.ms";

include "lib://graphics/drawings/background.ms";
include "lib://graphics/drawings/foreground.ms";
include "lib://graphics/drawings/border.ms";

/**
    Basig pattern for Moscrif controls.
    each control can contain Background, foreground and border.
    All of them are rendering on device screen by moscrif Paint object
    @package graphics
    @location graphics/patterns/pattern.ms
*/
class Pattern : PatternBase
{

    /**
        Contructor of the object. It init bg, fg and border property
    */
    function _create()
    {
        this._foreground = null;
        this._background = null;
        this._border = null;

        this._borders = [];
        this._borderTop    = null;
        this._borderLeft   = null;
        this._borderBottom = null;
        this._borderRight  = null;

    }

    /**
        Foreground, defines how foreground should looks like for current Moscrif control.
        Ususaly foreground is a text, therefore this property expects instance of Foreground

        @param Foreground v Instance of Foreground
        @return Foreground
        @throw InvalidArgument Pattern.fg] Accepts instance of Foreground
    */
    property fg(v)
    {
        get return this.foreground;
        set this.foreground = v;

    }

    /**
        Foreground, defines how foreground should looks like for current Moscrif control.
        Ususaly foreground is a text, therefore this property expects instance of Foreground

        @param Foreground v Instance of Foreground
        @return Foreground
        @throw InvalidArgument Pattern.fg] Accepts instance of Foreground
    */
    property foreground(v)
    {
        get
        {
            if(this._foreground == null)
                this._foreground = Foreground.create(Foreground,this.owner,this.ownerProperty + ".fg");

            return this._foreground;
        }
        set
        {
            if(v instanceof Foreground)
                this._foreground = v
            else
                throw new InvalidArgument("[Pattern.fg] Accepts instance of Foreground");
        }

    }

    /**
        Background, defines how bacground of Moscrif control should looks like.
        An instance of Background is expected
        @param Background v
        @return Background
        @throw InvalidArgument [Pattern.bg] Accepts instance of Background
    */
    property bg(v)
    {
        get return this.background;
        set this.background = v;
    }

    /**
        Background, defines how bacground of Moscrif control should looks like.
        An instance of Background is expected
        @param Background v
        @return Background
        @throw InvalidArgument [Pattern.bg] Accepts instance of Background
    */
    property background(v)
    {
        get
        {
            if(this._background == null)
                this._background = Background.create(Background,this.owner,this.ownerProperty + ".bg");

            return this._background;
        }
        set
        {
            if(v instanceof Background)
                this._background = v
            else
                throw new InvalidArgument("[Pattern.bg] Accepts instance of Background");
        }

    }

    /**
        Border, defines how border should looks like. it expects instance of Drawing
        @param Drawing v
        @return Drawing
        @throw InvalidArgument "[Decorator.border] Accepts instance of Drawing"
    */
    property border(v)
    {
        get
        {
            if(this._border == null)
                this._border = Border.create(Border,this.owner,this.ownerProperty + ".border");

            return this._border;
        }
        set
        {
            if(v instanceof Drawing)
                this._border = v
            else
                throw new InvalidArgument("[Decorator.border] Accepts instance of Drawing");
        }

    }

    /**
        Borders keep all bordes information in order [left,top,right,bottom]
        @param Array v
        @return Array
    */
    property borders(v)
    {
        get return this._borders;
        set {
            if(typeof(v) == #array) {
                this._onChanged();
                this._borders = v;
                this._setBorders();
            }
            else throw new InvalidArgument("[Background.borders] expects an Array");
        }
    }

    /**
        Border top Drawing, decorate border top
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderTop(v)
    {
        get {
            if(this._borderTop == null)
                this._borderTop = Border.create(Border,this.owner,this.ownerProperty+".borderTop");
            return this._borderTop;
        }
        set {
            if(v instanceof Drawing){
                this._onChanged();
                this._borderTop = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.borderTop] expects instance of Drawing");

        }
    }

    /**
        Border Left Drawing, decorate border Left
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderLeft(v)
    {
        get {
            if(this._borderLeft == null)
                this._borderLeft = Border.create(Border,this.owner,this.ownerProperty+".borderLeft");
            return this._borderLeft;
        }
        set {
            if(v instanceof Drawing){
                this._onChanged();
                this._borderLeft = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.borderLeft] expects instance of Drawing");

        }
    }

    /**
        Border Bottom Drawing, decorate border Bottom
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderBottom(v)
    {
        get {
            if(this._borderBottom == null)
                this._borderBottom = Border.create(Border,this.owner,this.ownerProperty+".borderBottom");
            return this._borderBottom;
        }
        set {
            if(v instanceof Drawing){
                this._onChanged();
                this._borderBottom = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.border_bottom] expects instance of Drawing");

        }
    }

    /**
        Border Right Drawing, decorate border Right
        @param Drawing v
        @return Drawing
        @throw InvalidArgument expects instance of Drawing
    */
    property borderRight(v)
    {
        get {
            if(this._borderRight == null)
                this._borderRight = Border.create(Border,this.owner,this.ownerProperty+".borderRight");
            return this._borderRight;
        }
        set {
            if(v instanceof Drawing){
                this._onChanged();
                this._borderRight = v
                this.native.invalidate();
            }
            else throw new InvalidArgument("[Background.borderRight] expects instance of Drawing");

        }
    }



}
