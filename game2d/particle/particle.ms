include "lib://core/baseClass.ms"
include "lib://game2d/particle/vector.ms"

/**
Particle is a abstract entity with a small set of attributes such as position and color that ultimately dictate the particle's behavior and appearance. This class is a base class for classes, whih are used to create particles.
@module game2d
@class Particle
@example
    // custom paricle class
    class MyParticle : Particle
    {
        // static variables
        // static paint used by all instances to draw bitmap
        var paint = null;
        // static bitmap used by all instances
        var img = Bitmap.fromFile("app://fire.png");
    
        function init()
        {
            super.init();
    
            ...
        }
    
        // owerwrite ancestor's draw function
        function draw(canvas)
        {
            // set bitmap translate acording to actual particle position
            this._matrix.translateX = this._position.x;
            this._matrix.translateY = this._position.y;
            // draw custom particle bitmap
            canvas.drawBitmapMatrix(MyParticle.img, this._matrix, MyParticle.paint);
        }
    }
    ...
    new Emitter({
       ...
       particleClass   : MyParticle
    })
*/
class Particle : BaseClass
{
    /**
    Singleton of the paint object.
    @static
    @attribute paint
    @type Paint
    */
    var paint = new Paint();

    /**
    Init instance. The init method sets all needed fields properties acording to developer requirements or to default values. This method is called when field object is constructed.
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._position     = this.options.position || new Vector({x: 0, y:0});
        this._velocity     = this.options.velocity || new Vector({x: 0, y:0});
        this._acceleration = this.options.acceleration || new Vector({x: 0, y:0});
        this._ttl          = this.options.ttl || -1;
        this._lived        = this.options.lived || 0;
    }

   /**
    Location of the particle center.
    @property position
    @type Vector
    @example
        // owerwrite ancestor's draw function
        function draw(canvas)
        {
            // set bitmap translate acording to actual particle position
            this._matrix.translateX = this._position.x;
            this._matrix.translateY = this._position.y;
            // draw custom particle bitmap
            canvas.drawBitmapMatrix(MyParticle.img, this._matrix, MyParticle.paint);
        }
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
    Velocity vector of the particle. The initial velocity is given to the particle, when it is emitted from emitter.
    @property velocity
    @type Vector
    */
    property velocity(v)
    {
        get {
            return this._velocity;
        }
        set {
            assert v instanceof Vector;
            this._velocity = v;
        }
    }

    /**
    Particle acceleration
    @property acceleration
    @type Vector
    */
    property acceleration(v)
    {
        get {
            return this._acceleration;
        }
        set {
            assert v instanceof Vector;
            this._acceleration = v;
        }
    }

    /**
    Time to live in milliseconds, default is set to -1, which menas live forever.
    @property ttl
    @type Integer
    */
    property ttl(v)
    {
        get {
            return this._ttl;
        }
        set {
            assert typeof v == #integer;
            this._ttl = v;
        }
    }

    /**
    Age of the particle, define time how long particle can be alive.
    @property lived
    @type Integer
    */
    property lived(v)
    {
        get {
            return this._lived;
        }
        set {
            assert typeof v == #integer;
            this._lived = v;
        }
    }

    /**
    This function affect particle's movement by a force fields.
    @method submitToFields
    @param fields {Array} Array of Field
    */
    function submitToFields(fields)
    {
        var totalAccelerationX = 0;
        var totalAccelerationY = 0;
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            assert field instanceof Field;
            var vectorX = field.position.x - this._position.x;
            var vectorY = field.position.y - this._position.y;
            var force = field.mass / Math.pow((vectorX*vectorX+field.mass/2+vectorY*vectorY+field.mass/2),1.5);
            totalAccelerationX += vectorX * force;
            totalAccelerationY += vectorY * force;
        }
        this._acceleration = new Vector({x:totalAccelerationX, y:totalAccelerationY});
    }

    /**
    Method to move particle based on acceleration and velocity vector.
    @method move
    */
    function move()
    {
        this._velocity.x += this._acceleration.x;
        this._velocity.y += this._acceleration.y;
        this._position.x += this._velocity.x;
        this._position.y += this._velocity.y;
    }

    /**
    Check if particle is a live.
    @method alive
    */
    function alive()
    {
        if (this._ttl < 0)
            return true;
        this._lived++;
        return this._lived < this._ttl;
    }

    /**
    Method draw defines action whithin onDraw. This method can be overwriten to customize particle appearance.
    @method draw
    @param canvas {Canvas} canvas used to draw graphics
    @example
        // owerwrite ancestor's draw function
        function draw(canvas)
        {
            // set bitmap translate acording to actual particle position
            this._matrix.translateX = this._position.x;
            this._matrix.translateY = this._position.y;
            canvas.drawBitmapMatrix(MyParticle.img, this._matrix, MyParticle.paint);
        }
    */
    function draw(canvas)
    {
        canvas.drawCircle(Math.floor(this._position.x), Math.floor(this._position.y), 1, Particle.paint);
    }

    /**
    Event fired on Draw of particle.
    @event onDraw
    @param canvas {Canvas} canvas used to draw graphics
    */
    property onDraw(v)
    {
        get return this.draw;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Particle.onDraw] Expects type of function");
             this.draw = v;
        }
    }

}
