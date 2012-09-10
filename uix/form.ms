include "lib://uix/base/staticContainer.ms";

include "lib://uix/layout/verticalLayout.ms";

/**
    Application form class
    @package uix
    @location uix/form.ms
*/
class Form : StaticContainer
{

    /**
        Init form controls, it sets width, height to system variables
    */
    function init()
    {
        super.init();
        this.native.width = System.width;
        this.native.height = System.height;

        this.layout = new VerticalLayout();
        
        this._onActivateHandler = null;
        this._onDeactivateHandler = null;

    }

    /**
        Make controls availaible as property of current form.
        @example

            var form = new form();
            form.add(new Label({name:"label1"}));
            form.add(new Label({name:"label2"}));

            form.label1.text = "Text 1";
            form.label2.text = "Text 2";

        @param <String> k key
        @param <Multivalue> v value
    */
    property undefined(k,v)
    {
        get {
            var ret = undefined;
            if(typeof this === #object)
            {   if(this[k] !== undefined)
                    ret = this[k];
                else if(this[k.toString()] !== undefined)
                    ret = this[k.toString()];
                else if(this.exists(k, false))
                    ret = this.propertyAt(k)
                if(this.isControl(k))
                    ret = this.getControlByName(k);
            }
            return ret;
        }
    }

    /**
    Called when form is activated.

    @event
    @param Object sender Object what caused this event
    @return Fucntion
    @throw InvalidArgument Expects type of function
    */
    property onActivate(v)
    {
        get return this._onActivateHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Form.onActivate] Expects type of function");
             this._onActivateHandler = v;
        }
    }

    /**
    Called when form is deactivated.

    @event
    @param Object sender Object what caused this event
    @return Fucntion
    @throw InvalidArgument Expects type of function
    */
    property onDeactivate(v)
    {
        get return this._onDeactivateHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Form.onDectivate] Expects type of function");
             this._onDeactivateHandler = v;
        }
    }

    /**
        Function raise onActivate handler. Function is designed for intranal usage only!
        @internal
        @param Object sender
    */
    function raiseOnActivate(sender = null)
    {
        if (this._onActivateHandler)
            this._onActivateHandler(sender || this);
    }

    /**
        Function raise onDeactivate handler. Function is designed for intranal usage only!
        @internal
        @param Object sender
    */
    function raiseOnDeactivate(sender = null)
    {
        if (this._onDeactivateHandler)
            this._onDeactivateHandler(sender || this);
    }

    /**
        Set all values in view, data must be an JSON object with format { name: value, name1:value1 ...}
        Name of the controls and JSON object keys must be equal to make this funcion work
        @param <Object> d JSON object
        @return void
    */
    function setData(d)
    {
        for(var k in d)
            this.setControlValueByName(k,d[k]);

    }

    /**
        Get controls by name
        @param <String> n name of the control
        @return <Object|undefined> return instance of control or undefined
    */
    function getControlByName(n)
    {
        var o = undefined;
        for(var c in this._view)
        {
            if(c.name == n)
            {
                o = c;
                break;
            }
        }
        
        return o;
    }

    /**
        set value of control by name
        @param <String> n name of the control
        @param <Multivalue> v value
        @return void
    */
    function setControlValueByName(n,v)
    {

        var obj = this.getControlByName(n);

        if(obj)
            obj.value = v;
    }

    /**
        check if control exists in form
        @param <String> n name of the control
        @return <Booleab> true if control exists, false if does not.
    */
    function isControl(n)
    {
        return this.getControlByName(n)?true:false;
    }


}

