include "lib://core/baseClass.ms"

/**
Field class represents force field, which affects velocity of particles. An instance of this class is set to {{#crossLink "Emitter.process"}}{{/crossLink}} method.
@module game2d
@class Fields
@example
    this._emitter = new LineEmitter ({
        fields : [
            new Field({
                x : System.width / 2,
                ...
            })
        ]
    });
*/
class Field : BaseClass
{
    /**
    Init instance. The init method sets all needed fields properties acording to developer requirements or to default values. This method is called when field object is constructed.
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._x         = this.options.x || 0;
        this._y         = this.options.y || 0;
        this._mass      = this.options.mass || 1;
        this._g         = this.options.mass || 10.0;                  // gravity constant
    }

    /**
    Horizontal position of the emiter in pixels
    @property x
    @type Integer
    @example
        new Field({
            x : System.width / 2,
            ...
        })
    */
    property x(v)
    {
        get {
            return this._x;
        }
        set {
            assert v instanceof Integer;
            this._x = v;
        }
    }

    /**
    Vertical position of the emiter in pixels
    @property y
    @type Integer
    @example
        new Field({
            y : System.height / 2,
            ...
        })
    */
    property y(v)
    {
        get {
            return this._y;
        }
        set {
            assert v instanceof Integer;
            this._y = v;
        }
    }

    /**
    The mass of the field in kg. Default is set to 1 kg.
    @property mass
    @type Integer
    @example
        new Field({
            mass : 10,
            ...
        })
    */
    property mass(v)
    {
        get {
            return this._mass;
        }
        set {
            assert typeof v == #integer;
            this._mass = v;
        }
    }

    /**
    Gravity koeficient used to calculate the force. Default is 10.0
    @property g
    @type Float
    @example
        new Field ({
            g : 9.81,
        })
    */
    property g(v)
    {
        get {
            return this._g;
        }
        set {
            assert v instanceof Float;
            this._g = v;
        }
    }

    /**
    Move field onto a new positoin.
    @method moveTo
    @param x
    @param y
    */
    function moveTo(x, y)
    {
        this._x = x;
        this._y = y;
    }

    /**
    Calculate force affecting the particle in a point in the fild
    @param x horizontal position of the particle
    @param y vertical position of the particle
    */
    function getForce(x, y)
    {
        var distance = Math.sqrt((this._x - x)*(this._x - x) + (this._y - y)*(this._y - y));  //c^2 = x^2 + y^2

        if (distance == 0.0)
            distance = 0.0001;

        var fy = -1*this._g*this._mass/distance*((y - this._y));      //
        var fx = -1*this._g*this._mass/distance*((x - this._x));      //

        return (fx, fy);
    }
}