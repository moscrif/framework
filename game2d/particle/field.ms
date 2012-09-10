include "lib://core/baseClass.ms"

/**
Fields class represents force field, which affects velocity of particles. An instance of this class is set to {{#crossLink "Emitter.process"}}{{/crossLink}} method.
@module game2d
@class Fields
@example
    function process()
    {
        var emitters = this._emitters;
        var fields = this._fields;
        
        //process emitters
        for (var emitter in emitters)
            emitter.process(fields);
    }
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
        this._position  = this.options.position || new Vector({x:0, y:0});
        this._size      = this.options.size || 8;
        this._mass      = this.options.mass || 100;
    }

   /**
    Location of the field center in pixels.
    @property position
    @type Vector
    @example
        new Field ({
            position    : new Vector({x:System.width/2, y:System.height/2}),
            mass        : 250
        })
   */
   property position(v)
    {
        get {
            return this._position;
        }
        set {
            assert v instanceof Vector;
            this._position = v;
        }
    }

    /**
    Defines how large the field size is for dynamics computations.
    Default is set to 8.
    @property size
    @type Integer
    */
    property size(v)
    {
        get {
            return this._size;
        }
        set {
            assert typeof v == #integer;
            this._size = v;
        }
    }

    /**
    The mass of the field. Default is set to 100.
    @property mass
    @type Integer
    @example
        new Field ({
            position    : new Vector({x:System.width/2, y:System.height/2}),
            mass        : 250
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
    Move field onto a new positoin.
    @method moveTo
    @param point {Vector} X and y coordinates of new field position
    */
    function moveTo(point)
    {
        this._position = point;
    }
}