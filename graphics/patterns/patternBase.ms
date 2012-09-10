/**
    Base pattern class, create pattern instance via static methods
    @package graphics
    @location graphics/patterns/patternBase.ms
*/
class PatternBase
{

    /**
        Contructor of the object.
    */
    function this()
    {
        this._owner = null;
        this._property = null;
    }

    function create(cls,args ..)
    {
        var obj = new cls();
        obj._create(args);
        obj._owner = args[0];
        obj._property = args[1];
        return obj;
    }

    /**
    @protected
    Methods to be called when instance is creating.
    @param Array args Array of function properties 
    */
    function _create(args)
    {
        ;
    }

    /**
    Returns owner of the Pattern.
    @return Control
    */
    property owner(v)
    {
        get return this._owner;
    }

     /**
    Property owner, where current Drawing belongs
    @return String
    */
    property ownerProperty(v)
    {
        get return this._property;
    }

}
