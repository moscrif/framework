/**

    Model definition class. It contain model data handling
    @package uix
    @location uix/model.ms
*/
class Model
{
    /**
        Contructor
    */
    function this()
    {
        this._data = {};
        this._dirty = true;
        this._loaded = false;
    }

    /**
        Flag to check if data are dirty.
        If data has been changed flag is set to true
        @param <Boolean> v flag dirty
        @return <Boolean>
    */
    property dirty(v)
    {
        get return this._dirty;
        set this._dirty = v;
    }

    /**
        If model is created flag is set to false, if model was loaded from DB or JSON file flag is set to true.
        @param <Boolean> v flag loaded
        @return <Boolean>
    */
    property loaded(v)
    {
        get return this._loaded;
        set this._loaded = v;
    }

   /**
       Make data value availaible as property of model
       @example
            var model = new Model()
            model.setData({key:"value",key2:"value2" ....})

            console << model.key, model.key2 <<
       @param <String> k key
       @param <Any> v value
       @return <Any>
   */
   property undefined(k,v)
   {
        get
        {
           var ret = undefined;
           if(this._data[k] !== undefined)
               ret = this._data[k];
           else if(this._data[k.toString()] !== undefined)
               ret = this._data[k.toString()];
           return ret;
        }
    }


    /**
        @static
        Function to Create and load class
        @param <symbol> cls class name
        @param <Any> args method arguments
        @return <Object>
    */
    function load(cls,args ..)
    {
        var obj = new cls();
        if (obj._load(args))
            obj.loaded = true;
        else
            obj.loaded = false;
        return obj;
    }

    /**
        @static
        Function to Create class
        @param <symbol> cls class name
        @param <Any> args method arguments
        @return <Object>
    */
    function create(cls,args ..)
    {
        var obj = new cls();
        obj._create(args);
        return obj;
    }

    /**
        method to save data into storage
        @throw <Exception> Saving of model failed
    */
    function save()
    {
        try
        {
            this._save();
            this.dirty = false;
        }
        catch(e)
        {
            this._onDatabaseErrorHandler();
        }

    }

}