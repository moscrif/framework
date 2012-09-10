include "lib://core/log.ms"
include "lib://core/baseClass.ms"

/**
GameObject is a base class for all objects used in games.
    It implements object's base properties like position, width, height etc...
@class GameObject
@extends BaseClass
@module game2d
*/
class GameObject : BaseClass
{
    /**
    Initialise Game object instance. This method should be used as a class constructor in extended classes.
        However, it is important to call parent's init method (by super.init()) to ensure correct object initialization.
    @method init
    @protected
    @example
        function init()
        {
            super.init();
            this._name = String.printf("sprite%d", Sprite.instance++);
            this._frame = 0;
            this._frameWidth = -1;
            this._frameHeight = -1;
            this._totalFrames = 0;
        }
    */
    function init()
    {
        super.init();

        this._visible = true;

        this._scale = 1.0;
        this._angle = 0;

        this._x = 0;
        this._y = 0;
        this._z = 0;

        this._width = 0;
        this._height = 0;

        this._anchorX = -1;
        this._anchorY = -1;

        this._onProcessHandler = null;
    }

    /**
    X - coordinates of object's centre
    @property x
    @type Integer
    @example
        object.x = 100; //pixels
    */
    property x(v)
    {
        get return this._x;
        set this._x = v;
    }

    /**
    Y - coordinates of objects's centre
    @property y
    @type Integer
    @example
        object.y = System.height / 2; // place object to the center of the screen (vertically)
    */
    property y(v)
    {
        get return this._y;
        set this._y = v;
    }

    /**
    The z-index property specifies the stack order of an element.
        An element with greater stack order is always in front of an element with a lower stack order
    @property z
    @type Integer
    */
    property z(v)
    {
        get return this._z;
        set this._z = v;
    }

    /*
    AnchorPoint is the point around which all transformations and positioning manipulations take place. It's like a pin in the node where it is "attached" to its parent.
        This property sets or gets X-axis value ranged from 0 to {{#crossLink "GameObject/width"}}{{/crossLink}} of this object.
    @property anchorX
    @type Integer
    */
    property anchorX(v)
    {
        get return this._anchorX;
        set this._anchorX = v;
    }

    /**
    AnchorPoint is the point around which all transformations and positioning manipulations take place. It's like a pin in the node where it is "attached" to its parent.
        This property sets or gets Y-axis value ranged from 0 to {{#crossLink "GameObject/height"}}{{/crossLink}} of this object.
    @property anchorY
    @type Integer
    */
    property anchorY(v)
    {
        get return this._anchorY;
        set this._anchorY = v;
    }

    /**
    Width of the object in pixels.
    @property width
    @type Integer
    */
    property width(v)
    {
        get return this._width;
        set this._width = v;
    }

    /**
    Height of the object in pixels.
    @property height
    @type Integer
    */
    property height(v)
    {
        get return this._height;
        set this._height = v;
    }

    /**
    Scaled width of this object. Scaled width is {{#crossLink "GameObject.width"}}{{/crossLink}} * {{#crossLink "GameObject.scale"}}{{/crossLink}}
    @property scaledWidth
    @readOnly
    @type Integer
    */
    property scaledWidth(v)
    {
        get return Math.floor(this._width * this._scale);
    }

    /**
    Get scaled height of this object. Scaled width is {{#crossLink "GameObject.height"}}{{/crossLink}} * {{#crossLink "GameObject.scale"}}{{/crossLink}}
    @property scaledHeight
    @readOnly
    @type Integer
    */
    property scaledHeight(v)
    {
        get return Math.floor(this._height * this._scale);
    }

    /**
    The visible property specifies whether or not an element is visible. Default is set to visible true.
    @property visible
    @type Boolean
    */
    property visible(v)
    {
        get return this._visible;
        set this._visible = v;
    }

    /**
    Scale of the game object. The value 1.0 means no scale, value less then 1.0 scales down, vales up to 1.0 scale the object up.
    @property scale
    @type Float
    */
    property scale(v)
    {
        get return this._scale;
        set this._scale = v;
    }

    /**
    Name of the game object. Elements in scene or layer can be axxess also by theirs name.
    @property name
    @type String
    @example
        var layer = new Layer({});
        layer.add(new Sprite({name:"sprite1"});
        var ref = layer.sprite1; // sprite1 is not property of Layer. Thanks to UPH (undefined property handler) of Layer, Layer class will find it's child by name.
    */
    property name(v)
    {
        get return this._name;
        set this._name = v;
    }

    /**
    Current body rotation angle in radians.
    @property angle
    @type Float
    */
    property angle(v)
    {
        get return this._angle;
        set this._angle = v;
    }

    /**
    Move object onto new position, given by two parameters (x and y coordinnates), on or position of another object.
    @method setPos
    @chainable
    @param args* {Integer|Object} Two integers to place object onto two required coordinates (x and y), or one instance of GameObject class to place object onto same coorinates as GameObject has.
    @example
        // place onto required position
        character.setPos(300, 150);
        // place onto position of another object
        var sprite = new Sprite({x: 0, y:0});
        character.setPos(sprite);
    */
    function setPos(args..)
    {
        if (args.length == 1) {
            this._x = args[0]._x;
            this._y = args[0]._y;
            return this;
        }
        assert args.length == 2;
        this._x = args[0];
        this._y = args[1];
    }

    /**
    Check if some object lies within this object.
    @method intersectsBounds
    @protected
    @param obj {GameObject} Object which position may be checked
    @return {Boolean} true if passed object intersects this object
    */
    function intersectsBounds(obj)
    {
        assert obj instanceof GameObject;
        var tx = this._x - this._anchorX*this._scale;
        var ty = this._y - this._anchorY*this._scale;
        var ox = obj._x - obj._anchorX*obj.scale;
        var oy = obj._y - obj._anchorY*obj.scale;
        return (
            tx + this.scaledWidth > ox && tx < ox + obj.scaledWidth &&
            ty + this.scaledHeight > oy && ty < oy + obj.scaledHeight
        );
    }

    /**
    Check if x and y coordinates lies inside the object
    @method intersectsPoint
    @protected
    @param x {Integer} X-coordinate
    @param y {Integer} Y-coordinate
    @return {Boolean} True if x and y coordinates lies inside the object
    */
    function intersectsPoint(x, y)
    {
        var tx = this._x - this._anchorX*this._scale;
        var ty = this._y - this._anchorY*this._scale;

        return (
            x >= tx && x <= tx + this.scaledWidth &&
            y >= ty && y <= ty + this.scaledHeight
        );
    }

    /**
    Method to defines what is done to redraw object This method can be overwrite to draw something onto object.
    @method draw
    @protected
    @param canvas {Canvas} Current game canvas
    @example
        function draw(canvas)
        {
            canvas.clear(0xffaabbcc);

            super.draw(canvas);
        }
    */
    function draw(canvas)
    {
    }

    /**
    On process event appears at every about 25 miliseconds, and is a good place for asynchronous operations. F.e.: it is good place to remove physics elements from physics world, or check changes in source data etc.
    @event onProcess
    */
    property onProcess(v) {
        get return this.process;
        set {
            assert v == null || typeof v == #function;
            this.process = v;
        }
    }

    /**
    On process method is called every about 25 miliseconds, and is a good place for asynchronous operations. F.e.: it is good place to remove physics elements from physics world, or check changes in source data etc.
    @method process
    @protected
    */
    function process()
    {

    }

}