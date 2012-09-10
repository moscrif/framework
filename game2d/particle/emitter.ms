include "lib://core/baseClass.ms"
include "lib://game2d/particle/vector.ms"
include "lib://game2d/particle/particle.ms"
include "lib://game2d/particle/field.ms"

/**
A particle system is a collection of independent objects, often represented by a simple shape or dot. It can be used to model many irregular types of natural phenomena, such as explosions, fire, smoke, sparks, waterfalls, clouds, fog, petals, grass, bubbles, and so on.
Emitter manages the creation and ongoing state of particles. Emitter uses Initializers to customise the initial state of particles that it creates; their position, velocity etc. These are added to the emitter using the addParticle method.
To ensure the proper functioning of emitter it is needed to call emiter's process function from game onProcess event.
@module game2d
@class Emitter
@example
    this._emitters = [
        new Emitter({
            position        : new Vector({x:System.width/2, y:System.height/2}),
            velocity        : new Vector({x:2, y:0}),
            size            : 8,
            particleLife    : 100,
            spread          : Math.PI/10,
            emissionRate    : 4,
            maxParticles    : 1000;
        })
    ];
    ...
    // map onProcess event
    function process()
    {
        var emitters = this._emitters;
        var fields = this._fields;
        
        //process emitters
        for (var emitter in emitters)
            emitter.process(fields);
    }
*/
class Emitter : BaseClass
{
    /**
    Init instance. The init method sets all needed emiter properties acording to developer requirements or to default values.
        This method is called when emiter object is constructed.
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._position      = this.options.position || new Vector({x:0, y:0});
        this._velocity      = this.options.velocity || new Vector({x:0, y:0});
        this._size          = this.options.size || 8;
        this._particleLife  = this.options.particleLife || -1;
        this._spread        = this.options.spread || Math.PI / 32;
        this._emissionRate  = this.options.emissionRate || 4;
        this._maxParticles  = this.options.maxParticles || 2000;
        this._particleClass = Particle;
        this._particles     = [];
    }

    /**
    Vector of the emitter center in pixels.
    @property position
    @type Vector
    @example
        new Emitter({
            // place emiter to the center of the screen
            position        : new Vector({x:System.width/2, y:System.height/2}),
            ...
        )}
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
    Velocity vector (direction and speed). The vector's direction is a direction of the center of particles stream.
        The particles variance can be customized by {{#crossLink "Emitter.spread"}}{{/crossLink}} property.
        The velocity also affects particles' speed. Positive values on x-axis are right and on the y-axis down from the emitter's center.
    @property velocity
    @type Vector
    @example
        new Emitter({
            velocity        : new Vector({x:2, y:0}),
            ...
        )};
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
    How large the particle is for rendering (doesn't affect particle dynamics or collision).
    Default size is 8.
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
    Time of the particle's existence in milliseconds, default is set to -1 (forever);
    @property particleLife
    @type Integer
    @example
        new Emitter({
            particleLife    : 100, // milliseconds
            ...
        });
    */
    property particleLife(v)
    {
        get {
            return this._particleLife;
        }
        set {
            assert typeof v == #integer;
            this._particleLife = v;
        }
    }

    /**
    Spread angle definition. Default is set to Math.PI / 32
    @property spread
    @type Float
    @example
        new Emitter({
            spread          : Math.PI/10,
            ...
        })
    */
    property spread(v)
    {
        get {
            return this._spread;
        }
        set {
            assert typeof v == #float;
            this._spread = v;
        }
    }

    /**
    Defines emission rate, default is set to 4. Emision rate is number of particles emited during one call of {{#crossLink "Emitter.process"}}{{/crossLink}} method.
    @type Integer
    @property emissionRate
    @example
        new Emitter({
            emissionRate    : 5,
            ...
        })
    */
    property emissionRate(v)
    {
        get {
            return this._emissionRate;
        }
        set {
            assert typeof v == #integer;
            this._emissionRate = v;
        }
    }

    /**
    Maximum number of particles. If there are more particles, emitter does not emitt new particles. Value less then 1 means an infinite number of particles.
    @property maxParticles
    @type Integer
    */
    property maxParticles(v)
    {
        get {
            return this._maxParticles;
        }
        set {
            assert typeof v == #integer;
            this._maxParticles = v;
        }
    }

    /**
    Number of particles
    @property count
    @type Integer
    @example
        //process emitters
        for (var emitter in emitters) {
            emitter.process(fields);
            console<<"current count of particles "<<emitter.count<<"\n";
        }
    */
    property count(v)
    {
        get {
            return this._particles.length;
        }
    }

    /**
    Class used to create particles - enables to create custom particles. This property accepts all classes extended from {{#crossLink "Particle"}}{{/crossLink}} class.
    @property particleClass
    @type Class
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
    property particleClass(v)
    {
        get {
            return this._particleClass;
        }
        set {
            assert typeof v == #class;
            this._particleClass = v;
        }
    }

    /**
    Move emiter to new position.
    @method moveTo
    @param point {Vector} position of emitter
    */
    function moveTo(point)
    {
        this._position = point;
    }

    /**
    Method to add particle. Options adjust the particle.
    This method is usually called automatically from {{#crossLink "Emitter.process"}}{{/crossLink}} method.
    @param options {Object}
    @method addParticle
    @protected
    */
    function addParticle(options = null)
    {
        if (this._maxParticles > 0 && this._particles.length >= this._maxParticles)
            return;
        var self = this;
        var template = options ? options.clone() : {};
        template.position = template.position || self._position.copy();
        template.velocity = template.velocity || Vector.fromAngle(self._velocity.getAngle() + self._spread - ((rand(100000) /100000.0) * self._spread * 2), self._velocity.getMagnitude());
        template.ttl = template.ttl || self._particleLife;
        var clazz = this.particleClass;
        var particle = new clazz(template);
        this._particles.push(particle);
        if (typeof this.particleCreated == #function)
            this.particleCreated.call(this, particle);
        return particle;
    }

    /**
    Method draw defines action whithin onDraw.
        It draws all particles from this emitter. Is is usally no need to overweite this method.
    @param canvas {Canvas} Current game canvas
    @method draw
    @protected
    */
    function draw(canvas)
    {
        assert canvas instanceof Canvas;
        //canvas.save();
        for (var particle in this._particles)
            particle.draw(canvas);
        //canvas.restore();
    }

    /**
    Process method makes time step for emitter. It creates new particles and destroys old particles.
    @method process
    @param fields {Array} Array of fields.
    */
    function process(fields = null)
    {
        var particle;
        var death = [];
        for (particle in this._particles) {
            if (!particle.alive())
                death.push(particle);
            else {
                if (fields != null && fields.length > 0)
                    particle.submitToFields(fields);
                particle.move();
            }
        }
        for (particle in death) {
            this._particles.removeByValue(particle);
            if (typeof this.particleDestroyed == #function)
                this.particleDestroyed.call(this, particle);
        }
        for (var i = 0; i < this.emissionRate; i++)
            this.addParticle();
    }


    /**
    Event onParticleCreated, defines action after particle is created
    @event onParticleCreated
    @param particle {Object} new particle
    @example
        var emitter = new Emitter({
            position        : new Vector({x:System.width/2, y:System.height/2}),
            velocity        : new Vector({x:2, y:0}),
            size            : 8,
            particleLife    : 100,
            spread          : 2*Math.PI,
            emissionRate    : 1,
            maxParticles    : 1000;
        })
        emitter.onParticleCreated = function(particle)
        {
          console<<"New particle created "<<particle<<"\n";
        }
    */
    property onParticleCreated(v)
    {
        get return this.particleCreated;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Emitter.onParticleCreated] Expects type of function");
             this.particleCreated = v;
        }
    }

    /**
    Event onParticleDestroyed, defines action after particle is destroyed
    @event onParticleDestroyed
    @param particle {Object} destroyed particle
    @example
        var emitter = new Emitter({
            position        : new Vector({x:System.width/2, y:System.height/2}),
            velocity        : new Vector({x:2, y:0}),
            size            : 8,
            particleLife    : 100,
            spread          : 2*Math.PI,
            emissionRate    : 1,
            maxParticles    : 1000;
        })
        emitter.onParticleDestroyed = function(particle)
        {
            console<<"A particle destroyed "<<particle<<"\n";
        }
    */
    property onParticleDestroyed(v)
    {
        get return this.particleDestroyed;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Emitter.onParticleDestroyed] Expects type of function");
             this.particleDestroyed = v;
        }
    }
}