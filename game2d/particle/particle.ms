include "lib://core/baseClass.ms"

/**
Particle is a abstract entity with a small set of attributes such as position and color that ultimately dictate the particle's behavior and appearance. This class is a base class for classes, whih are used to create particles.
@module game2d
@class Particle
@example
    //class CustomParticle - used by comet effect emitter
    class CustomParticle : Particle
    {
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
    ...
    new Emitter({
       ...
       particleClass   : CustomParticle
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
        this._x             = this.options.x || 0.0;
        this._y             = this.options.y || 0.0;
        this._vx            = this.options.vx || 0.0;
        this._vy            = this.options.vy || 0.0;
        this._ax            = this.options.ax || 0.0;
        this._ay            = this.options.ay || 0.0;
        this._width         = -1;
        this._height        = -1;
        this._image         = null;
        this._age           = 0;     // ms
    }

    /**
    Width of the particle in pixels. It is automatically sets according to particle's image width.
    @property width
    @type Integer
    */
    property width(v)
    {
        get return this._width;
        set {
            assert v instanceof Integer;
            this._width = v;
        }
    }

    /**
    Height of the particle in pixels. It is automatically sets according to particle's image width.
    @property height
    @type Integer
    */
    property height(v)
    {
        get return this._height;
        set {
            assert v instanceof Integer;
            this._height = v;
        }
    }

    /**
    Image used as a particle image. If no image is set only black dot is used.
    @property image
    @type Bitmap
    @example
    this._emitterA = new PointEmitter({
            ...
            particleOptions : {
                image : GFX.starSmall
            }
        });
    */
    property image(v)
    {
        get return this._image;
        set {
            assert v instanceof Bitmap;
            this._image = v;
            if (this._width == -1)
                this.width = v.width;
            if (this._height == -1)
                this.width = v.height;
        }
    }

    /**
    Particle's horizontal position. The value is usually no need to change. It is calculated automatically by the particle system.
    @property x
    @type Float
    */
    property x(v)
    {
        get {
            return this._x;
        }
        set {
            if (v instanceof Integer)
                v = v*1.0;
            assert v instanceof Float;
            this._x = v;
            if (this._startx === false)
                this._startx = v;
        }
    }

    /**
    Particle's vertical position. The value is usually no need to change. It is calculated automatically by the particle system.
    @property x
    @type Float
    */
    property y(v)
    {
        get {
            return this._y;
        }
        set {
            if (v instanceof Integer)
                v = v*1.0;
            assert v instanceof Float;
            this._y = v;
            if (this._startx === false)
                this._startx = v;
        }
    }

    /**
    Particle's horizontal speed in px/second. The value is usually no need to change. It is calculated automatically by the particle system.
    @property vx
    @type Float
    */
    property vx(v)
    {
        get {
            return this._vx;
        }
        set {
            if (v instanceof Integer)
                v = v*1.0;
            assert v instanceof Float;
            this._vx = v;
        }
    }

    /**
    Particle's vertical speed in px/second. The value is usually no need to change. It is calculated automatically by the particle system.
    @property vy
    @type Float
    */
    property vy(v)
    {
        get {
            return this._vy;
        }
        set {
            if (v instanceof Integer)
                v = v*1.0;
            assert v instanceof Float;
            this._vy = v;
        }
    }

    /**
    Particle's horizontal acceleration. The value is usually no need to change. It is calculated automatically by the particle system.
    @property vy
    @type Float
    */
    property ax(v)
    {
        get {
            return this._ax;
        }
        set {
            if (v instanceof Integer)
                v = v*1.0;
            assert v instanceof Float;
            this._ax = v;
        }
    }

    /**
    Particle's vertical acceleration. The value is usually no need to change. It is calculated automatically by the particle system.
    @property vy
    @type Float
    */
    property ay(v)
    {
        get {
            return this._ay;
        }
        set {
            if (v instanceof Integer)
                v = v*1.0;
            assert v instanceof Float;
            this._ay = v;
        }
    }

    /**
    Method to move particle based on acceleration and velocity vector.
    @method move
    @param timestep
    
    */
    function move(timeStep, fields = null)
    {
        this._age += timeStep;
        var ax = 0.0;
        var ay = 0.0;
        var (fx, fy);

        if (fields != null) {
            for (var i in fields) {
                (fx, fy) = i.getForce(this.x, this.y);

                ax += fx;
                ay += fy;
            }
        }

        this.ax = ax;
        this.ay = ay;

        this.vx += this.ax;//* (timeStep*1.0 / 1000);
        this.vy += this.ay;//* (timeStep*1.0 / 1000);
        this.x += this.vx * (timeStep*1.0 / 1000);
        this.y += this.vy * (timeStep*1.0 / 1000);
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
        if (this.image == null)
            canvas.drawCircle((this.x).toInteger(), (this.y).toInteger(), 1, Particle.paint);
        else
            canvas.drawBitmap(this.image, (this.x).toInteger() - GFX.star.width / 2, (this.y).toInteger() - GFX.star.height / 2, Particle.paint);
    }
}