/**
    Action Controller, all action are kept in instances of controller.
    Each method of controller means one action
    @package uix
    @location uix/contoller.ms
*/
class Controller
{
    /**
        Contruct of the object, call init method if exists
    */
    function this()
    {
        if(this.exists(symbol("init"),true))
            this.init();

        this._top = null;
        this._content = null;
        this._bottom = null;
    }

    property top(v)
    {
        get return this._top;
        set {
            this._top = v;
        }
    }

    property content(v)
    {
        get return this._content;
        set {
            this._content = v;
        }
    }

    property bottom(v)
    {
        get return this._bottom;
        set {
            this._bottom = v;
        }
    }

    /**
        Invoke an event
        @param <String> name Name of the event
        @param <Array> args.. Array of function arguments
    */
    function invokeEvent(name, args..)
    {
        var methodName = "on" + name.substr(0,1).toUpperCase() + name.substr(1,name.length);
        return this.call(symbol(methodName), args);
    }
}