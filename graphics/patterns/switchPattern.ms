include "lib://graphics/patterns/pattern.ms";

/**
  Only helper class which contains paterns for all box states
  @package graphics
  @location graphics/patterns/switchPattern.ms
*/
class SwitchPattern : PatternBase
{
    /**
        Contructor of Switch Pattern, creates
        all necessary Pattern properties
    */
    function _create()
    {
        this._on = null;
        this._off = null;
        this._disabled = null;

    }

    /**
        On state pattern
        @return Pattern
    */
    property on(v)
    {

        get {
            if(this._on == null)
                this._on = Pattern.create(Pattern,this.owner,this.ownerProperty + ".on");
            return this._on;
        }
    }

    /**
        Off state pattern
        @return Pattern
    */
    property off(v)
    {
        get {
            if(this._off == null)
                this._off = Pattern.create(Pattern,this.owner,this.ownerProperty + ".off");
            return this._off;
        }
    }

    /**
        Disable state pattern
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