include "lib://game2d/base/gameObject.ms";

/**
Sprite class creates game characters and manages their animation and movement. The sprite class do not mamange user events like pointer pressed / released etc. The user events are managed in GameControl class and all classes extended from this class.
@class Sprite
@module game2d
@example
    class Character : Sprite
    {
        function init()
        {
            super.init();
            // load image
            this.image = Bitmap.fromFile("app://gfx/character.png");
            // size of one frame
            this.frameWidth = 27;
            this.frameHeight = 32;
            // create timer
            this._createTimer();
        }
    
        function _createTimer()
        {
            // create timer (interval, repeat)
            var timer = new Timer(200, true);
            timer.onTick = function(sender)
            {
                // animate character
                var self = this super;
                self.nextFrame();
            }
            // start timer with 0 ms delay
            timer.start(0);
        }
    }
    // add character to scene or layer
    var character = new Character({x: 100, y: 100});
    this.add(character);
*/
class Sprite : GameObject
{
    /**
    Singleton of the game object.
    @static
    @attribute instance
    @type Game
    */
    var instance = 0;

    /**
    Init sprite object instance. This method should be used as a class constructor in extended classes. However, it is important to call parent's init method (by super.init()) to ensure correct object initialization.
    @method init
    @protected
    @example
        class Character : Sprite
        {
            function init()
            {
                super.init();
                // load image
                this.image = Bitmap.fromFile("app://gfx/character.png");
                // size of one frame
               ....
            }
            ...
        }
    */
    function init()
    {
        super.init();
        this._name = String.printf("sprite%d", Sprite.instance++);
        this._frame = 0;
        this._frameWidth = -1;
        this._frameHeight = -1;
        this._totalFrames = 0;
    }

    /**
    Initialize properties onto default values
    @method afterInit
    @protected
    */
    function afterInit()
    {
        super.afterInit();

        if (this._image instanceof Bitmap) {
            this._width = this._image.width;
            this._height = this._image.height;
        }

        if (this._frameWidth == -1)
            this._frameWidth = this._width;

        if (this._frameHeight == -1)
            this._frameHeight = this._height;

        if (this._anchorX == -1)
            this._anchorX = this._frameWidth / 2;
        if (this._anchorY == -1)
            this._anchorY = this._frameHeight / 2;

        if (this._image instanceof Bitmap) {
            this._totalFrames = (this._image.width / this._frameWidth) * (this._image.height / this._frameHeight);

            if (this._sequence == null) {
                this._sequence = [];
                for (var i = 0; i < this._totalFrames; i++)
                    this._sequence.push(i);
            }
        }
    }

    /**
    Instance of Bitmap or string with location of bitmap, used to draw sprite. The image can contains more frames, which are automatically divided into frames acording to frame width or height.
    @property image
    @type Bitmap|String
    @example
        var sprite = new Sprite({
            x: 100,
            y: 100,
            image: img
        });
    */
    property image(v)
    {
        get return this._image;
        set {
            if (v == null) {
                this._width = 0;
                this._height = 0;
                this._image = 0;
                return;
            }
            assert v instanceof Bitmap || typeof v ==  #string;
            if (typeof v == #string)
                v = Bitmap.fromFile(v);
            this._width = this.image.width;
            this._height = this.image.height;
            this._image = v;
        }
    }

    /**
    Object used for final decoration. The Paint object allows to apply various effect like alpha level, mask or color filter onto sprite.
    @property Paint
    @type Paint
    @example
        // fade out
        function hide()
        {
            this.paint = new Paint();
            // create animator
            var animator = new Animator({
                transition  : Animator.Transition.easeOut,   // start up slowly and then quickly speed up at the end of the animation
                duration    : 1500,                          // length of animation in miliseconds
            });
            animator.addSubject(function(state) {            // state starts from 1.0 to 0.0
                var self = this super;
                self.paint.alpha = (state*255).toInteger();
            })
            // play animator
            animator.reverse();
        }
    */
    property paint(v)
    {
        get return this._paint;
        set {
            assert v instanceof Paint;
            this._paint = v;
        }
    }

    /**
    This property allows to change sprite's alpha level.
    @property alpha
    @type Integer
    @example
    function hide()
    {
        // create animator
        var animator = new Animator({
            transition  : Animator.Transition.easeOut,   // start up slowly and then quickly speed up at the end of the animation
            duration    : 1500,                          // length of animation in miliseconds
        });
        animator.addSubject(function(state) {            // state starts from 1.0 to 0.0
            var self = this super;
            self.alpha = (state*255).toInteger();
        })
        // play animator
        animator.reverse();
    }
    */
    property alpha(v)
    {
        get return (this._paint || {alpha:255}).alpha;
        set {
            if (this._paint == null)
                this._paint = new Paint();
            this._paint.alpha = v;
        }
    }

    /**
    Get/set index of current frame
    @property frame
    @type Integer
    */
    property frame(v)
    {
        get return this._frame;
        set this._frame = v;
    }

    /**
    Set frame width. There can be more frames into bitmap in image property, which is automatically divided into separate frames according to frame width and height.
    @property frameWidth
    @type Integer
    @example
        var sprite = new Sprite({
            image       : Bitmap.fromFile("app://gfx/character.png");
            frameWidth  : 27;
            frameHeight : 32;
        });
    */
    property frameWidth(v)
    {
        get return this._frameWidth;
        set this._frameWidth = v;
    }

    /**
    Set frame height There can be more frames into bitmap in image property, which is automatically divided into separate frames according to frame width and height.
    @property frameHeight
    @type Integer
    @example
        var sprite = new Sprite({
            image       : Bitmap.fromFile("app://gfx/character.png");
            frameWidth  : 27;
            frameHeight : 32;
        });
    */
    property frameHeight(v)
    {
        get return this._frameHeight;
        set this._frameHeight = v;
    }

    /**
    Get scaled width of this object
    @property scaledWidth
    @readOnly
    @type Integer
    */
    property scaledWidth(v)
    {
        get return Math.floor(this._frameWidth * this._scale);
    }

    /**
    Get scaled height of this object
    @property scaledHeight
    @readOnly
    @type Integer
    */
    property scaledHeight(v)
    {
        get return Math.floor(this._frameHeight * this._scale);
    }

    /**
    Draw next frame in the sequence.
    @method nextFrame
    @param rewind=true {Boolean}  Set current sequence position to the begin if the sequence is at the end.
        Default value is true.
    @example
        function init()
        {
            super.init();
            // load image
            this.image = Bitmap.fromFile("app://gfx/character.png");
            // size of one frame
            this.frameWidth = 27;
            this.frameHeight = 32;
            // create timer
            this._createTimer();
        }
        // animate sprite
        function _createTimer()
        {
            // create timer (interval, repeat)
            var timer = new Timer(200, true);
            timer.onTick = function(sender)
            {
                // animate character
                var self = this super;
                self.nextFrame();
            }
            // start timer with 0 ms delay
            timer.start(0);
        }
    */
    function nextFrame(rewind = true)
    {
        if (this._frame < this._sequence.length - 1)
            this._frame++;
        else {
            if (rewind)
                this._frame = 0;
        }
    }

    /**
    Draw next previous frame in the sequence.
    @method prevFrame
    @param rewind {Boolean }Set current sequence position to the end if the sequence if sequence is at the beginning.
        Default value is true.
    @example
        function init()
        {
            super.init();
            // load image
            this.image = Bitmap.fromFile("app://gfx/character.png");
            // size of one frame
            this.frameWidth = 27;
            this.frameHeight = 32;
            // create timer
            this._createTimer();
        }
        // animate sprite
        function _createTimer()
        {
            // create timer (interval, repeat)
            var timer = new Timer(200, true);
            timer.onTick = function(sender)
            {
                // animate character
                var self = this super;
                self.prevFrame();
            }
            // start timer with 0 ms delay
            timer.start(0);
        }
    */
    function prevFrame(rewind = true)
    {
        if (this._frame > 0)
            this._frame--;
        else {
            if (rewind)
                this._frame = this._sequence.length - 1;
        }
    }


    /**
    Sequence of the frames. The sequence defines order of frames in animation. Frames can be gradually drawn by {{#crossLink "Sprite/nextFrame"}}{{/crossLink}} or  {{#crossLink "Sprite/prevFrame"}}{{/crossLink}}.
    @property sequence
    @type Array
    @example
        // define all sequences
        this._rest = [0];
        this._run = [0, 1, 2, 3, 4, 5, 6, 7];
        this._end = [8, 9, 10, 11, 12];
        this._jumpUp = [13];
        this._jumpDown = [14];
        this._win = [16, 17, 18, 19, 20, 21, 22, 23 ];
        // set current sequence
        this.sequence = this._run;
    */
    property sequence(v)
    {
        get return this._sequence;
        set {
            assert typeof v == #array;
            this._sequence = v;
            this._frame = 0;
        }
    }

    /**
    Method to defines what is done if onDraw event is called. This method can be overwrite to draw something onto sprite. However, it is important to call super.draw(canvas) in overwriten method.
    @method draw
    @protected
    @param canvas {Canvas}  Current game canvas
    */
    function draw(canvas)
    {
        if (!this.visible || this._width == 0 || this._height == 0 || this._image == null)
            return;

        assert canvas instanceof Canvas;
        assert this._image instanceof Bitmap;

        canvas.save(#matrix);
        canvas.translate(this._x, this._y);
        canvas.rotate(-(this.angle * 180. / Math.PI)); // rad2deg
        canvas.scale(this._scale, this._scale);
        canvas.translate(-this._anchorX, -this._anchorY);

        var sequenceFrame = this._frame;
        sequenceFrame = this._sequence[this._frame];
        var slices = this._image.width / this._frameWidth;
        var sl = (sequenceFrame % slices) * this._frameWidth;
        var st = (sequenceFrame / slices) * this._frameHeight;

        if (this.paint instanceof Paint) {
            canvas.drawBitmapRect(this._image,
                sl, st, sl + this._frameWidth, st + this._frameHeight,
                0, 0, this._frameWidth, this._frameHeight, this.paint);
        } else {
            canvas.drawBitmapRect(this._image,
                sl, st, sl + this._frameWidth, st + this._frameHeight,
                0, 0, this._frameWidth, this._frameHeight);
        }

        canvas.restore();
    }
}
