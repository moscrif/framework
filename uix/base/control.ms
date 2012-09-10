include "lib://core/baseClass.ms";
include "lib://uix/base/uiFactory.ms";

/**
@package uix
@location uix/base/control.ms

This class defines generic Moscrif Control properties and methods
*/
class Control : BaseClass
{

    function init()
    {
        super.init();
        this._skipDrawing = false;                          
        this._initDefaults = false;                         //init default is false when object inits
        this._styleName = this.options.styleName || null;   //set style name from option if presented

        this._marginLeft = 0;
        this._marginTop = 0;
        this._marginRight = 0;
        this._marginBottom = 0;

        this._paddingLeft = 0;
        this._paddingTop = 0;
        this._paddingRight = 0;
        this._paddingBottom = 0;

    }


    function setDefaults()
    {
       //apply control defaults
       Application.instance.skin.callInitMethod(this);
       this._initDefaults = true;
    }

    /**
    Native, instance of native UI object(View,ScrollView,Window)
    @return View|ScrollView|Window
    */
    property native(v)
    {
        get return this._view;
    }

    /**
    Flag to indicates default style of control
    @return Boolean
    */
    property initDefaults(v)
    {
        get return this._initDefaults;
    }

    /**
    Parent, instance of native UI object where current Control is assigned.
    Basicaly is a container where control was added.
    @return View|ScrollView|Window
    */
    property parent(v)
    {
        get return this._view.parent;
    }

    /**
    Skip control drawing. It used if control is part of composite control what manage
    drawing bu itself.
    @param Boolean v
    @retrun Boolean
    */
    property skipDrawing(v)
    {
        get return this._skipDrawing;
        set {

            this._skipDrawing = v;

            if(this._skipDrawing == true)
                this._onDrawHandler = null;

        }
    }

    /**
    Name of the Control
    @param String
    @return String
    */
    property name(v)
    {
        get return this._view.name;
        set this._view.name = v;
    }

    /**
    Gets or sets if the view's width is stretchable.
    @param Symbol v     #fixed
                        #width
                        #height
    @return Symbol
    */
    property stretch(v)
    {
        get return this._view.stretch;
        set this._view.stretch = v;
    }

    /**
    Width of the Control (in pixels).
    @param Integer v
    @return Integer
    */
    property width(v)
    {
        get return this._view.width;
        set {
            this._view.width = v;

        }
    }

    /**
    Height of the Control (in pixels).
    @param Integer v
    @return Integer
    */
    property height(v)
    {
        get return this._view.height;
        set {
            this._view.height = v;
            this.invalidate();
        }
    }

    /**
    X - coordinates of Control's position
    @param Integer v
    @return Integer
    */
    property left(v)
    {
        get return this._view.left;
        set {
            this._view.left = v;
        }
    }

    /**
    Y - coordinates of control's position
    @param Integer v
    @return Integer
    */
    property top(v)
    {
        get return this._view.top;
        set {
            this._view.top = v;
        }
    }

    /**
    Layout used to layout elements into the object.
    @param StackLayout v
    @return StackLayout
    */
    property layout(v)
    {
        get return this._view.layout;
        set {

            if(v instanceof Moscrif.StackLayout)
            {
                this._view.layout = v;
                logW("Moscrif.StackLayout going to be obsolete");
            }
            else if(v instanceof Layout)
            {
                v.owner = this;
                v.setMargin(this.marginLeft, this.marginTop, this.marginRight, this.marginBottom);
                this._view.layout = v.native;
            }
            else throw("Unsupported Layout");

            this.invalidate();
        }
    }

    //@region Control Styling
    /**
    Style name, returns custom style name otherwise class name.
    @param String v
    @return String
    */
    property styleName(v)
    {
        get {
            var className = this.className.toString();
            return this._styleName ? this._styleName : className.substr(0,1).toLowerCase() + className.substr(1,className.length);
        }
        set {
            this._styleName = v;
        }
    }

    /**
    Foreground drawing, it holds instance of Foreground object to decorate text of Control
    @param Foreground v
    @return Foreground
    @throw InvalidArgument  Accepts instance of Foreground
    */
    property fg(v)
    {
        get return this.foreground;
        set this.foreground = v;

    }

    /**
    Foreground drawing, it holds instance of Foreground object to decorate text of Control
    @param Foreground v
    @return Foreground
    @throw InvalidArgument  Accepts instance of Foreground
    */
    property foreground(v)
    {
        get
        {
            if(this._foreground == null)
                this._foreground = Foreground.create(Foreground,this,"fg");

            return this._foreground;
        }
        set
        {
            if(v instanceof Foreground)
                this._foreground = v
            else
                throw new InvalidArgument("[Decorator.fg] Accepts instance of Foreground");
        }
    }

    property fgPressed(v)
    {
        get
        {
            if(this._fgPressed == null)
                this._fgPressed = Foreground.create(Foreground,this,"fgPressed");

            return this._fgPressed;
        }
        set
        {
            if(v instanceof Foreground)
                this._fgPressed = v
            else
                throw new InvalidArgument("[Decorator.fgPressed] Accepts instance of Foreground");
        }
    }

    /**
    Background drawing, it holds instance of Background to decorate background
    @param Background v
    @return Background
    @throw InvalidArgument Accepts instance of Background
    */
    property bg(v)
    {
        get return this.background;
        set this.background = v;
    }
    
    /**
    Background drawing, it holds instance of Background to decorate background
    @param Background v
    @return Background
    @throw InvalidArgument Accepts instance of Background
    */
    property background(v)
    {
        get
        {
            if(this._background == null)
                this._background = Background.create(Background,this,"bg");

            return this._background;
        }
        set
        {
            if(v instanceof Background){
                this._background = v
                //this.native.invalidate();
            }else
                throw new InvalidArgument("[Decorator.bg] Accepts instance of Background");
        }

    }

    property bgPressed(v)
    {
        get
        {
            if(this._bgPressed == null)
                this._bgPressed = Background.create(Background,this,"bgPressed");

            return this._bgPressed;
        }
        set
        {
            if(v instanceof Background){
                this._bgPressed = v
                this.native.invalidate();
            }else
                throw new InvalidArgument("[Decorator.bgPressed] Accepts instance of Background");
        }

    }


    property margin(v)
    {
        set {
            if(typeof v === #object)
            {
                for(var k in v){

                    switch (k) {
                        //left margin
                        case "left" :
                            this.marginLeft = v[k];
                            break;
                        //right margin
                        case "right" :
                            this.marginRight = v[k];
                            break;
                        //top margin
                        case "top" :
                            this.marginTop = v[k];
                            break;
                        //bottom margin
                        case "bottom" :
                            this.marginBottom = v[k];
                            break;
                        //top and left margin
                        case "vertical" :
                            this.marginTop = this.marginBottom = v[k];
                            break;
                        //right and left margin
                        case "horizontal":
                            this.marginLeft = this.marginRight = v[k];
                            break;
                    }

                }

            }else{
                this.marginTop = this.marginBottom = this.marginLeft = this.marginRight = v;
            }
        }
    }

    /**
    Left Margin of List items
    @param Integer v
    @return Integer
    */
    property marginLeft(v)
    {
        get return this._marginLeft;
        set {
            this._marginLeft = v;
            this._setMargins();
        }
    }

    /**
    Top Margin of List items
    @param Integer v
    @return Integer
    */
    property marginTop(v)
    {
        get return this._marginTop;
        set {
            this._marginTop = v;
            this._setMargins();
        }
    }

    /**
    Right Margin of List items
    @param Integer v
    @return Integer
    */
    property marginRight(v)
    {
        get return this._marginRight;
        set {
            this._marginRight = v;
            this._setMargins();
        }
    }

    /**
    Bottom Margin of List items
    @param Integer v
    @return Integer
    */
    property marginBottom(v)
    {
        get return this._marginBottom;
        set {
            this._marginBottom = v;
            this._setMargins();
        }
    }

        /**
    @visibility private
    Set margins to layout
    */
    function _setMargins()
    {
        if(this.layout)
            this.layout.setMargin(this._marginLeft, this._marginTop, this._marginRight, this._marginBottom);
    }


    property padding(v)
    {
        set {
            if(typeof v === #object)
            {
                for(var k in v){

                    switch (k) {
                        //left margin
                        case "left" :
                            this.paddingLeft = v[k];
                            break;
                        //right margin
                        case "right" :
                            this.paddingRight = v[k];
                            break;
                        //top margin
                        case "top" :
                            this.paddingTop = v[k];
                            break;
                        //bottom margin
                        case "bottom" :
                            this.paddingBottom = v[k];
                            break;
                        //top and left margin
                        case "vertical" :
                            this.paddingTop = this.paddingBottom = v[k];
                            break;
                        //right and left margin
                        case "horizontal":
                            this.paddingLeft = this.paddingRight = v[k];
                            break;
                    }

                }

            }else{
                this.paddingTop = this.paddingBottom = this.paddingLeft = this.paddingRight = v;
            }
        }
    }

    /**
    Left padding of List items
    @param Integer v
    @return Integer
    */
    property paddingLeft(v)
    {
        get return this._paddingLeft;
        set {
            this._paddingLeft = v;
            this._setPaddings();
        }
    }

    /**
    Top padding of List items
    @param Integer v
    @return Integer
    */
    property paddingTop(v)
    {
        get return this._paddingTop;
        set {
            this._paddingTop = v;
            this._setPaddings();
        }
    }

    /**
    Right padding of List items
    @param Integer v
    @return Integer
    */
    property paddingRight(v)
    {
        get return this._paddingRight;
        set {
            this._paddingRight = v;
            this._setPaddings();
        }
    }

    /**
    Bottom padding of List items
    @param Integer v
    @return Integer
    */
    property paddingBottom(v)
    {
        get return this._paddingBottom;
        set {
            this._paddingBottom = v;
            this._setPaddings();
        }
    }

    function _setPaddings()
    {
       ;
    }

    //@endregion

    /**
    Visibility of the Control.
    @param Boolean v True = visible (default)
                     False = invisible
    @return Boolean
    */
    property visible(v)
    {
        get return this._view.visible;
        set this._view.visible = v;
    }

    /**
    Icon, other way how o set control image. It accept symbol of vector,
    location to bitmap, instance of bitmap or instance of path.
    This property can be used only if image is defined

    @param Symbol|String|Path|Bitmap
    */
    property icon(v)
    {
        set {
            if (this.exists(symbol("image"),true)) {
                if (typeof v == #symbol) {
                    if (Application.instance.skin.vectors[v])
                        this.image.source = Application.instance.skin.vectors[v];
                    else
                        new InvalidArgument("[Property icon] skin has no vector for: " + v);
                } else if (v instanceof String || v instanceof Bitmap || v instanceof Path)
                    this.image.source = v;
                else
                    new InvalidArgument("Property icon accepts instance of symbol, path or bitmap");
            } else {
                new Exception("Icon property had been called on unsupported object.");
            }
        }
    }

   /**
    function to set width and hight of control
    @param Integer width
    @param Integer height
    @return Control
   */
   function setSize(width, height)
    {
        this.width = width;
        this.height = height;
        return this;
    }

    /**
     Function to set control left and top position
     @param Integer left
     @param Integer top
     @return Control
    */
    function setLocation(left, top)
    {
        this.left = left;
        this.top = top;
        return this;
    }

    /**
     Function sets focus to the Control.
    */
    function setFocus()
    {
        this._view.setFocus();
    }

    /**
    Returns true if this Control has focus. Otherwise, function returns false.
    @return Boolean
    */
    function hasFocus()
    {
        return this._view.hasFocus();
    }

    /**
     This function ensure redrawing a rectangle, determined by parameters.
     Redrawing manages the function, which is set to onDraw event.
    */
    function invalidate()
    {
        this._view.invalidate();
    }

    /**
    Pause layer's recalculating.
    */
    function suspendLayout()
    {
        this._view.suspendLayout();
    }

    /**
    Resume layer's recalculating.
    */
    function resumeLayout()
    {
        this._view.resumeLayout();
    }

    /**
    Performs (force) layout calculations.
    */
    function performLayout()
    {
        this._view.performLayout();
    }

    /**
    Returns two values (width, height) of child's union content
    @return multiValue (width, height)
    */
    function getChildrenSize()
    {
        return this._view.getChildrenSize();
    }

    /**
    Returns four values (left, top, right, bottom) of child's union content.
    @return multiValue (left, top, right, bottom)
    */
    function getChildrenBounds()
    {
        return this._view.getChildrenBounds();
    }

    /**
    Ability to have a focus.
    @return Boolean
    */
    property focusable(v)
    {
        get return this._focusable;

    }

    //@region Events

    /**
    This event occurs, when it is necessary to redraw object. onDraw event is usually managed by skin.
    @event
    @param Object sender Object what requests render feature
    @param Canvas canvas Place  where requested object going to be rendered
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onDraw(v)
    {
        get return this._onDrawHandler;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[StaticContainer.onDraw] Expects type of function");
             this._onDrawHandler = v;
        }
    }

    /**
    Callback function, which is called from the object every 25ms.
    @event
    @return Fucntion
    @throw InvalidArgument Expects type of function
    */
    property onProcess(v)
    {
        get return this._onProcessHandler;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Screen.onProcess] Expects type of function");

            this._onProcessHandler = v;

        }
    }

    /**
    Called when touch (click) is stared.
    @event
    @param Object sender Object what caused this event
    @param Integer x  X coordinates of pointer
    @param Integer y  Y coordinates of pointer
    @return Fucntion
    @throw InvalidArgument Expects type of function
    */
    property onPointerPressed(v)
    {
        get return this._onPointerPressedHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[StaticContainer.onPointerPressed] Expects type of function");
             this._onPointerPressedHandler = v;
        }
    }

    /**
    Called when touch (click) is moved.
    @event
    @param Object sender Object what caused this event
    @param Integer x  X coordinates of pointer
    @param Integer y  Y coordinates of pointer
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onPointerDragged(v)
    {
        get return this._onPointerDraggedHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[StaticContainer.onPointerDragged] Expects type of function");
             this._onPointerDraggedHandler = v;
        }
    }

    /**
    Called when touch (click) is finished.
    @event
    @param Object sender Object what caused this event
    @param Integer x  X coordinates of pointer
    @param Integer y  Y coordinates of pointer
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onPointerReleased(v)
    {
        get return this._onPointerReleasedHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[StaticContainer.onPointerReleased] Expects type of function");
             this._onPointerReleasedHandler = v;
        }
    }

    /**
    This event is raised by press the key.
    @event
    @param Object sender Object what caused this event
    @param Symbol|Char key Pressed key value
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onKeyPressed(v)
    {
       get return this._onKeyPressed;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Control.onKeyPressed] Expects type of function");
             this._onKeyPressed = v;
        }

    }

     /**
    This event is raised by release the key.
    @event
    @param Object sender Object what caused this event
    @param Symbol|Char key Pressed key value
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onKeyReleased(v)
    {
       get return this._onKeyReleased;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Control.onKeyReleased] Expects type of function");
             this._onKeyReleased = v;
        }

    }

     /**
    This event is raised by release an UNICODE character key.
    @event
    @param Object sender Object what caused this event
    @param Integer charCode Pressed key value
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onChar(v)
    {
       get return this._onChar;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Control.onChar] Expects type of function");
             this._onChar = v;
        }

    }

     /**
    Occurs when the control is resized.
    @event
    @param Object sender Object what caused this event
    @param Integer width New width value
    @param Integer height New height value
    @return Function
    @throw InvalidArgument Expects type of function
    */
    property onResize(v)
    {
       get return this._onResizeHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Control.onResize] Expects type of function");
             this._onResizeHandler = v;
        }

    }

    //@endregion
}