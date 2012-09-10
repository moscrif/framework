include "lib://uix/control/navigation/barBase.ms";
include "lib://uix/control/label.ms";
include "lib://uix/layout/horizontalLayout.ms"

/**
@package uix
@location uix/control/navigation/titleBar.ms

Tittle Bar class definition. Tittle Bar is devided into middle bar, lef and right Bar.
Middle part usually carries tittle of the application or current Form. Left and Right bar
carries navigation buttons, or buttun to access aditional application feature.

*/
class TitleBar : BarBase
{
    /**
    Init Tittle Bar controls
    */
    function init()
    {
        super.init();

        this.layout = new HorizontalLayout();
       
        this.position = #top;
        this._label = null;

        //define left Bar
        this._rightBar = new BarBase({width:0});
        this._rightBar.name = "Righ Bar"
        this._rightBar.stretch = #vert;

        this._rightBar.layout = new HorizontalLayout({align:#right});
        this.native.add(this._rightBar);

        //define middle bar
        this._middleBar = new BarBase({width:50});
        this._middleBar.name = "Middle Bar";
        this._middleBar.layout = new HorizontalLayout({align:#center});

        this._middleBar.stretch = #both;
        this.native.add(this._middleBar);


        //define right bar
        this._leftBar = new BarBase({width:0});
        this._leftBar.name = "Left Bar";
        this._leftBar.stretch = #vert;

        this._leftBar.layout = new HorizontalLayout({align:#left});
        this.native.add(this._leftBar);

        this.performLayout();
    }

    /**
    Label Control of title bar. Label is set by default to the middle bar
    @param Label v
    @return Label
    @throw InvalidArgument
    */
    property label(v)
    {
        get {
            if(this._label == null){
               this._label = new Label({vertAlign: #center});
               this.add(this._label,#middle);
            }
            return this._label;
        }
        set {
            if (v instanceof Label) {
                this._label = v;
                //remove previously set labels
                this.middleBar.removeAll();
                this.add(this._label,#middle);
            }
            else
                throw new InvalidArgument("[TitleBar.label]");
        }
    }

    /**
    This property sets text to the label
    @param String v
    @return String
    */
    property title(v)
    {
        get return this.label.text;
        set {
            this.label.text = v;
            this._setContainerWidth(this.middleBar);
            this.performLayout();
        }
    }

    /**
    Middle bar, property carry container of Controls in the middle of the title bar
    @param BarBase v
    @return BarBase
    */
    property middleBar(v)
    {
        get return this._middleBar;
        set {
            this._middleBar = v;
            this.native.add(this._middleBar);
        }
    }

    /**
    Left bar, property carry container of Controls in the left of the title bar
    @param BarBase v
    @return BarBase
    */
    property leftBar(v)
    {
        get return this._leftBar;
        set {
            this._leftBar = v;
            this.native.add(this._leftBar);
            //this._change = true;
        }
    }

    /**
    Right bar, property carry container of Controls in the right of the title bar
    @param BarBase v
    @return BarBase
    */
    property rightBar(v)
    {
        get return this._rightBar;
        set {
            this._rightBar = v;
            this.native.add(this._rightBar);
        }
    }

    /**
    Sets horizontal margin of Controls
    @param Integer v
    @return Integer
    */
    property marginX(v)
    {
        set {
            this._leftBar.marginX = v;
            this._middleBar.marginX = v;
            this._rightBar.marginX = v;
        }
    }

    /**
    Sets vertical margin of Controls
    @param Integer v
    @return Integer
    */
    property marginY(v)
    {
        set {
            this.leftBar.marginY = v;
            this.middleBar.marginY = v;
            this.rightBar.marginY = v;
        }
    }

    /**
    Add control to title bar and set width's of containers.
    @param Control control
    @param Symbol v
        #left   - left bar
        #middle - middle bar
        #right  - right bar
    */
    function add(control,location)
    {
        var currBar = null;
        switch(symbol(location)){
            case "left" :
                this.leftBar.add(control,#front);
                this._setContainerWidth(this.leftBar);
            break;
            case "middle" :
                this.middleBar.add(control,#front);
                this._setContainerWidth(this.middleBar);
            break;
            case "right" :
                this.rightBar.add(control,#back);
                this._setContainerWidth(this.rightBar);

            break;
        }

        this.performLayout();

     }


    /**
    @private
    Set size of all title containers left,middle,right
    */
    function _setContainerWidth(container)
    {

       var width = 0;
       for(var c in container.native)
       {
            if(c instanceof Label){
                 c.fg = this.fg;
                 var (w,h) = c.fg.measureText(c.text);
                 c.width = w + c.fg.fontDescent;
                 width  += c.width
            }else{
                width += c.width;
            }
       }
       container.width = width;
    }
    
}