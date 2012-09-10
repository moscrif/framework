include "lib://core/exception.ms";

/**
This class is base for all framework object.
It provides basiv functionality of settings object attributes via options
@class BaseClass
@module core
*/
class BaseClass
{
    /**
    Construct of the object calls following method in order:

        1. {{#crossLink "BaseClass/beforeInit"}}{{/crossLink}}
        2. {{#crossLink "BaseClass/init"}}{{/crossLink}}
        3. {{#crossLink "BaseClass/setDefaults"}}{{/crossLink}}
        4. {{#crossLink "BaseClass/setOptions"}}{{/crossLink}}
        5. {{#crossLink "BaseClass/afterInit"}}{{/crossLink}}

    @class BaseClass
    @method this
    @param <object> options
    */
    function this(options = {})
    {
        this._options = options;

        this.beforeInit();
        //initialise all controls
        this.init();
        this.setDefaults();
        this.setOptions();
        this.afterInit();

    }

    /**
    Method is executed to initialize object
    @method init
    @protected
    */
    function init()
    {
    }

    /**
    Method is executed before inititialiation of this object
    @method beforeInit
    @protected
    */
    function beforeInit()
    {
        this._initialized = false;
    }

    /**
    Method is executed after inititialization of this object
    @method afterInit
    @protected
    */
    function afterInit()
    {
        this._initialized = true;
    }


    /**
    Method is setting default class values
    @method setDefaults
    @protected
    */
    function setDefaults()
    {
    }

    /**
    Method is setting options passed as class parameters
    @method setOptions
    @protected
    */
    function setOptions()
    {
        this._setOptions();
    }

    /**
    @property options
    @type {Object}
    @readOnly
    */
    property options(v)
    {
        get return this._options;
    }

    /**
    @property initialized
    @type {Boolean}
    @readOnly
    */
    property initialized(v)
    {
        get return this._initialized;
    }
    
    /**
    Sets default controls options
    @property defaults
    @type {object}
    */
    property defaults(v)
    {
        get return this._defaults;
    }

    /**
    Special property (Undefined Property Handler - UPH) executed when property is undefined.
        It can be that JSON format is in format "key" : "value".
        Key is an string, so if this is the case methot return "value".
        As well as k is a regular property of the class it returns getter of this
        property
    @property undefined
    @param key {String}
    @param value {Object}
    @type {Object}
    */
    property undefined(k,v)
    {
        get
        {
            var ret;
            if(this[k] !== undefined)
               ret = this[k];
            else if(this[k.toString()] !== undefined)
               ret = this[k.toString()];
            else if(this.exists(k, false))
               ret = this.propertyAt(k)
            else
               ret = undefined;
           return ret;
        }
    }

    /**
    Method is setting control's option variables.
        Options is present at the contstuct of the object after
        defaults are applied.
    @method _setOptions
    @private
    */
    function _setOptions()
    {
        for (var p in this.options)
            this._setProperty(this,this.options,p);
    }

    /**
    Method is setting control's defaults variables set
        from current theme.
    @method _setDefaults
    @private
    */
    function _setDefaults(defaults)
    {
        this._defaults = defaults;
        for (var p in this._defaults)
            this._setProperty(this,this._defaults,p);
    }

    /**
    Method is parsing options and set properties to the control.
        Options is a JSON object.
    @method _setProperty
    @private
    */
    function _setProperty(obj,data,p)
    {
        if (typeof p != #symbol)
            return false;

        if (typeof data[p] == #object && data[p] !== null) {
            //if current value is instance of Base class set it to current property
            if (data[p] instanceof BaseClass) {
                obj[symbol(p)] = data[p];
            } else {
                var o = obj.propertyAt(symbol(p));
                if( o == undefined) {
                    //o is not real object, to parse properties
                    //set object tu current property
                    obj[symbol(p)] = data[p];
                } else {
                    for(var pp in data[p])
                        this._setProperty(o,data[p],pp);
                }
           }
           return true;
        }
        else if(typeof data[p] == #string) obj[symbol(p)] = data[p].toString();
        else obj[symbol(p)] = data[p];

    }


}