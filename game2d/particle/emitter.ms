include "lib://core/baseClass.ms"
include "lib://game2d/particle/particle.ms"
include "lib://game2d/particle/field.ms"

/**
A particle system is a collection of independent objects, often represented by a simple shape or dot. It can be used to model many irregular types of natural phenomena, such as explosions, fire, smoke, sparks, waterfalls, clouds, fog, petals, grass, bubbles, and so on.
Emitter manages the creation and ongoing state of particles. Emitter uses Initializers to customise the initial state of particles that it creates; their position, velocity etc. These are added to the emitter using the addParticle method.
To ensure the proper functioning of emitter it is needed to call emiter's process function from game onProcess event.
@module game2d
@class Emitter
@example
    this._emitter = new PointEmitter({
        x : System.width / 2,
        y : System.height / 2,
        speed : 600,
        angle : 5*Math.PI / 4,
        spread : Math.PI / 8,
        particleLife : 1100,
        emissionRate : 50,
        particleClass : CustomParticle,
    });
    ...
    // map draw method
    function draw(canvas)
    {
        super.draw(canvas);

        this._emitter.draw(canvas);
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
        this._x                 = this.options.x || 0;
        this._y                 = this.options.y || 0;
        this._speed             = this.options.speed || 100;
        this._particleLife      = this.options.particleLife || -1;
        this._spread            = this.options.spread || Math.PI / 20;
        this._emissionRate      = this.options.emissionRate || 40;
        this._maxParticles      = this.options.maxParticles || 2000;
        this._particleClass     = this.options.particleClass || Particle;
        this._particles         = this.options.particles || [];
        this._fields            = this.options.fields || [];
        this._particleOptions   = this.options.particleOptions || {};
        this._stepsPerSeconds   = this.options.stepsPerSeconds || 40;
        this._angle             = this.options.angle || 0.0;

        this._timer             = new Timer(1000 / this._stepsPerSeconds, true);
        this._timer.onTick      = function ()
        {
            this super._timeStep();
        }
        this.start(1000 / this._stepsPerSeconds);

        // the variable which helps to calculate when it is needed to emit the particle if rate is less then steps per seconds
        this._i = 0.0;
    }

// @region properties

    /**
    Horizontal position of the emiter in pixels
    @property x
    @type Integer
    @example
        this._emitter = new PointEmitter({
            x : System.width / 2,
            y : System.height / 2,
            ...
        });
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
        this._emitter = new PointEmitter({
            x : System.width / 2,
            y : System.height / 2,
            ...
        });
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
    Speed of the emited particles in pixels per second
    @property speed
    @type Integer
    @example
    this._emitter = new PointEmitter({
        speed : 10,
        ...
    });
    */
    property speed(v)
    {
        get {
            return this._speed;
        }
        set {
            assert v instanceof Integer;
            this._speed = v;
        }
    }

    /**
    Options applied onto particles
    @property particleOptions
    @type Object
    @example
        this._emitter = new LineEmitter ({
            particleOptions : {
                image       : GFX.snow;
            }
        });
    */
    property particleOptions(v)
    {
        get {
            return this._particleOptions;
        }
        set {
            assert typeof v == #object;
            this._particleOptions = v;
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
    Spread angle definition. Default is set to Math.PI / 32, whole circle is 2*Math.PI
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
    Number of emision in one second. Default is 40
    @property stepsPerSeconds
    @type Integer
    */
    property stepsPerSeconds(v)
    {
        get {
            return this._stepsPerSeconds;
        }
        set {
            assert v instanceof Integer;
            this._stepsPerSeconds = v;
        }
    }


    /**
    Number of particles emitted in one second. Default is 40.
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
        //class CustomParticle - used by comet effect emitter
        class CustomParticle : Particle
        {
            // static variables
            // static paint used by all instances to draw bitmap
        
            function init()
            {
                super.init();
        
                // create paint used to bitmap effect
                this._paint = new Paint();
                this._paint.alpha = 80;
        
                // create animator
                var animator = new Animator({
                    transition: Animator.Transition.easeIn,     // start up slowly and then quickly speed up at the end of the animation
                    duration: 1100,                              // length of animation in miliseconds
                }); 
                animator.addSubject(function(state) {           // state starts from 1.0 to 0.0
                    this super._paint.alpha = 255-(state*255).toInteger();
                }); 
                animator.play();
            }
        
            function draw(canvas)
            {
                canvas.drawBitmap(GFX.star, (this.x).toInteger() - GFX.star.width / 2, (this.y).toInteger() - GFX.star.height / 2, this._paint);
            }
        }
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
    Angle of the emited particles.
    @property angle
    @type Float
    */
    property angle (v)
    {
        get {
            return this._angle;
        }
        set {
            assert typeof v == #float;
            this._angle  = v;
        }
    }

    /**
    Array of force fialds affecting particle movement.
    @property fields
    @type Array
    */
    property fields(v)
    {
        get return this._fields;
        set {
            assert typeof v == #array;
            this._fields = v;
        }
    }

    /**
    Move emiter to new position.
    @method moveTo
    @param x {Integer} horizontal position of emitter
    @param y {Integer} vertical position of emitter
    */
    function moveTo(x, y)
    {
        this.x = x;
        this.y = y;
    }

    /**
    Start emition
    @method start
    */
    function start()
    {
        this._timer.start();
    }

    /**
    Stop emition
    @method start
    */
    function stop()
    {
        this._timer.stop();
    }

    /**
    Stop emitter and release all resources.
    @method start
    */
    function dispose()
    {
        this._timer.dispose();
    }

    /*
    Method to add particle. Options adjust the particle.
    This method is usually called automatically from {{#crossLink "Emitter.process"}}{{/crossLink}} method.
    @param options {Object}
    @method addParticle
    @protected
    */
    function _addParticle(options = null)
    {
        if (this._maxParticles > 0 && this._particles.length >= this._maxParticles)
            return;
        var self = this;

        var clazz = this.particleClass;
        var particle = new clazz(this._particleOptions);
        particle.x = this.x * 1.0;
        particle.y = this.y * 1.0;

        var angle = this._angle + rand((this._spread*1000).toInteger())*1.0/1000 - this._spread / 2;
        
        particle.vx = this.speed * Math.cos(angle);
        particle.vy = this.speed * Math.sin(angle);
        this._particles.push(particle);
        if (typeof this.particleCreated == #function)
            this.particleCreated.call(this, particle);
        return particle;
    }

    /**
    Method draw defines action whithin onDraw.  It draws all particles from this emitter. Is is usally no need to overweite this method.
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
    @method _timeStep
    */
    function _timeStep()
    {
        var particle;
        for (particle in this._particles) {
            if (this._particleLife != -1 && particle._age > this._particleLife) {
                this._particles.removeByValue(particle);
                if (typeof this.particleDestroyed == #function)
                    this.particleDestroyed.call(this, particle);
            } else {
                if (this._fields != null && this._fields.length > 0)
                    particle.move(1000 / this._stepsPerSeconds, this._fields);
                else
                    particle.move(1000 / this._stepsPerSeconds);
            }
        }

        var number = this._emissionRate * 1.0 / this._stepsPerSeconds;
        if (number > 0.9)
            for (var i = 0; i < (number).toInteger(); i++)
                this._addParticle();
        else {
            this._i += number;
            if (this._i > 1.0) {
                this._addParticle();
                this._i = 0.0;
            }

        }
    }

// @region events
    /*
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
  /*  property onParticleCreated(v)
    {
        get return this.particleCreated;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Emitter.onParticleCreated] Expects type of function");
             this.particleCreated = v;
        }
    }*/

    /*
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
    /*property onParticleDestroyed(v)
    {
        get return this.particleDestroyed;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Emitter.onParticleDestroyed] Expects type of function");
             this.particleDestroyed = v;
        }
    }*/
// @endregion
}