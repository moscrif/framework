include "lib://graphics/patterns/pattern.ms";

/**
    helper class which contains paterns for all box states
    @package graphics
    @location graphics/patterns/boxPattern
*/
class BoxPattern : PatternBase
{
    /**
        Contstructor of object, it initialise control states such normal, pressed or disabled states are.
    */
    function _create()
    {
        this._pressed = null;
        this._normal = null;
        this._disabled = null;
    }

    /**
        Normal state of Moscrif control
        @return Pattern
    */
    property normal(v)
    {
        get {
            if(this._normal == null)
                this._normal = Pattern.create(Pattern,this.owner,this.ownerProperty + ".normal");
            return this._normal;
        }
    }

    /**
        Pressed state of Moscrif control
        @return Pattern
    */
    property pressed(v)
    {
        get {
            if(this._pressed == null)
                this._pressed = Pattern.create(Pattern,this.owner,this.ownerProperty + ".pressed");

            return this._pressed;
        }
    }

     /**
        Disabled state of Moscrif control
        @return Pattern
    */
    property disabled(v)
    {
        get {
           if(this._disabled == null)
                this._disabled = Pattern.create(Pattern,this.owner,this.ownerProperty + ".disabled");
           return this._disabled;
        }
    }
}