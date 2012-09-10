/**
Factory class, creation of native user interface instances.
View, ScrollView, TextView, Window ...

@package uix
@location uix/base/uiFactory.ms
*/
class UIFactory
{
    /**
        @static
        Create Moscrif native View instance
    */
    function createView(control)
    {
        var view = new Moscrif.View();
        this.applyEvents(control,view)
        return view;
    }

    /**
        @static
        Create Moscrif native TextView instance
    */
    function createTextView(control)
    {
        var view = new Moscrif.TextView();
        this.applyEvents(control,view)
        return view;
    }

    /**
        @static
        Create Moscrif native ScrollView instance
    */
    function createScrollView(control)
    {
        var view = new Moscrif.ScrollView();
        this.applyEvents(control,view)
        return view;
    }

    /**
        @static
        Create Moscrif native Window instance
    */
    function createWindow(control)
    {
        var view = new Moscrif.Window();
        this.applyEvents(control,view)
        return view;
    }

    /**
        @static
        Apply generic events to the current control and view
    */
    function applyEvents(control,view)
    {
        /**
            onResize Event, defines onresizeHandler
            @param Control sender
            @param Integer w sender width
            @param Integer h sender height
        */
        view.onResize = function(sender,w,h)
        {
            if (control._onResizeHandler != null)
                control._onResizeHandler(sender, w, h);
        }

        /**
            onDraw Event, defines own onDrawhandler or call ondraw method from the skin
            @param Control sender
            @param Canvas canvas
        */
        view.onDraw = function(sender, canvas)
        {
           if (control._onDrawHandler != null){
                control._onDrawHandler(control, canvas);
            }else{
                Application.instance.skin.callDrawMethod(control,canvas);
            }

        }

        /**
            onPointerPressed, defines own onPointerPressedhandler
            @param Control sender
            @param Integer x
            @param Integer y
        */
        view.onPointerPressed = function(sender, x, y)
        {
            if (control._onPointerPressedHandler != null)
                control._onPointerPressedHandler(sender, x, y);

        }

        /**
            onPointerReleased, defines own onPointerReleasedHandler
            @param Control sender
            @param Integer x
            @param Integer y
        */
        view.onPointerReleased = function(sender, x, y)
        {
            if (control._onPointerReleasedHandler != null)
                control._onPointerReleasedHandler(sender, x, y);
        }

        /**
            onPointerDragged, defines own onPointerDraggedHandler
            @param Control sender
            @param Integer x
            @param Integer y
        */
        view.onPointerDragged = function(sender, x, y)
        {
            if (control._onPointerDraggedHandler != null)
                control._onPointerDraggedHandler(sender, x, y);
        }

        /**
            onProcess, defines own onProcessHandler
            @param Control sender
            @return Integer 0 - application terminates
                            1 - invalidate
                            2 - do nathing

        */
        view.onProcess = function(sender)
        {
          if (control._onProcessHandler != null)
                return control._onProcessHandler(sender);

             return 1;
        }

        /**
            onFocusChanged, defines own onFocusChangedHandler
            @param Control sender
            @param Boolean gainFocus

        */
        view.onFocusChanged = function(sender, gainFocus)
        {
            if (control._onFocusChangedHandler != null)
                return control._onFocusChangedHandler(sender, gainFocus);
        }


    }


}