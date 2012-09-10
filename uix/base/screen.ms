include "lib://uix/base/container.ms";

/**
    @package uix
    @location uix/base/screen.ms

    This class is a wrapper for Moascrif native Window.
    Sreen is used as first responder of game or enterprise application.
*/
class Screen : Container
{
    /**
        Init class controls
    */
    function init()
    {
        this._view = UIFactory.createWindow(this);
        this._view.top = this._view.left = 0;
        this._view.width = System.width;
        this._view.height = System.height;
        this._terminate = false;
        this._allowFPS = false;
        /**
        Set on start event
        @param Control sender Object what caused this event
        */
        this._view.onStart = function(sender)
        {
            if (this super._onStartHandler != null)
                this super._onStartHandler(sender);
        }

        /**
        Set onQuit event
        @param Control sender Object what caused this event
        */
        this._view.onQuit = function(sender)
        {
            if (this super._onQuitHandler != null)
                this super._onQuitHandler(sender);
        }

        /**
        Set onProcess event
        @param Control sender Object what caused this event
        */
        this._view.onProcess = function(sender)
        {
            if (this super._onProcessHandler != null)
                this super._onProcessHandler(sender);
            return this super._terminate ? 0 : 1;
        }
    }

    /**
    Allow showing of Frame per second (FPS).
    By default is set to false.
    @param Boolean v
    @return Boolean
    */
    property allowFPS(v)
    {
        get return this._allowFPS;
        set this._allowFPS = v;
    }

    /**
    This event appears, when application starts - only once during the application life cycle.

    @event
    @param Object sender Object what caused this event
    @return Function
    @throw InvalidArgument Expects instance of function
    */
    property onStart(v)
    {
        get return this._onStartHandler;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Screen.onStart] Instance of function expected");

            this._onStartHandler = v;

        }
    }

    /**
    On Quit Handler, executed when game or application ends

    @event
    @param Object sender Object what caused this event
    @throw InvalidArgument Instance of function expected
    */
    property onQuit(v)
    {
        get return this._onQuitHandler;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Screen.onQuit] Instance of function expected");

            this._onQuitHandler = v;

        }
    }

    /**
    Init method, inits game or application
    @private
    @param Boolean allowFPS
    */
    function _init(allowFPS)
    {
        this._view.init(allowFPS);
        return this;
    }

    /**
    Run method, runs game or application
    */
    function run()
    {
        this._init(this.allowFPS)
        this._view.run();
        return this;
    }

    /**
    Function signals to terminate application
    */
    function quit()
    {
        this._terminate = true;
    }
}