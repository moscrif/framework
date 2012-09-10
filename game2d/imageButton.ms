include "lib://game2d/base/button.ms";

/**
Implements game button functionality. This button can be filled with image. It supports diferent image for normal and pressed state. These two states can be placed in two separate files, or in one file with two frames.
@module game2d
@class ImageButton
@extends Button
@example
    // create new instanco of ImageButton with images from the resources
    var button = new ImageButton ({
        image       : res.img.continueButton,
        x           : System.width/2,
        y           : top,
        frameWidth  : res.img.continueButton.width,
        frameHeight : res.img.continueButton.height / 2,
    });
    // manage onClick event
    button.onClick = function()
    {
        ...
    }
    scene.add(button);
*/
class ImageButton : Button
{
    /**
    Singleton of the game object.
    @static
    @attribute instance
    @type ImageButton
    */
    var instance = 0;

    /**
    Init button. This method is called from class constructor and can be used in overwritten classes as a class constructor.
    @method init
    @protected
    */
    function init(options = {})
    {
        super.init(options);
        this._name = String.printf("imageButton%d", ImageButton.instance++);
        this._mode = #sequence;
        this._imagePressed = null;

        this._frame = 0;
        this._frameWidth = -1;
        this._frameHeight = -1;
        this._totalFrames = 0;
    }

    /**
    Init button. This method is called from class constructor and it is usually no needed to change it.
    @method aftetInit
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
            this._sequence = [];
            for (var i = 0; i < this._totalFrames; i++)
                this._sequence.push(i);
        }

    }

    /**
    Image on the button. If image contains two frames, first frame is used for normal state and second for pressed state.
    @property image
    @type {Bitmap|String}
    @example
        var button = new ImageButton ({
            image       : res.img.continueButton,
            x           : System.width/2,
            y           : top,
            frameWidth  : res.img.continueButton.width,
            frameHeight : res.img.continueButton.height / 2,
        });
    */
    property image(v)
    {
        get return this._image;
        set {
            assert v instanceof Bitmap || typeof v ==  #string;
            if (typeof v == #string)
                v = Bitmap.fromFile(v);
            this._width = this.image.width;
            this._height = this.image.height;
            this._image = v;
            if (!(this._imagePressed instanceof Bitmap))
                this._imagePressed = this._image;
        }
    }

    /**
    Image on pressed button, displays image when user click on the button.
        The pressed image can be palced also in one file with normal image.
    @property imagePressed
    @type {Bitmap|String}
    @example
        var button = new ImageButton ({
            image           : res.img.continueButton,
            imagePressed    : res.img.continueButtonPressed,
            x               : System.width/2,
            y               : top,
        });
    */
    property imagePressed(v)
    {
        get return this._imagePressed;
        set {
            if (typeof v == #string)
                v = Bitmap.fromFile(v);
            this._imagePressed = v;
            this._mode = #image;
        }
    }

    /**
    Get frame index first frame has index 0 then 1, 2 ...
    @property frame
    @type {Integer}
    */
    property frame(v)
    {
        get return this._frame;
        set this._frame = v;
    }

    /**
    Set frame width. Button's image is automatically divided into frames acording to frame width and height.
    @property frameWidth
    @type {Integer}
    @example
        var button = new ImageButton ({
            image       : res.img.continueButton,
            x           : System.width/2,
            y           : top,
            frameWidth  : res.img.continueButton.width,
            frameHeight : res.img.continueButton.height / 2,
        });
    */
    property frameWidth(v)
    {
        get return this._frameWidth;
        set this._frameWidth = v;
    }

    /**
    Set frame height. Button's image is automatically divided into frames acording to frame width and height.
    @property frameHeight
    @type {Integer}
    @example
        var button = new ImageButton ({
            image       : res.img.continueButton,
            x           : System.width/2,
            y           : top,
            frameWidth  : res.img.continueButton.width,
            frameHeight : res.img.continueButton.height / 2,
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
    @type {Integer}
    */
    property scaledWidth(v)
    {
        get return Math.floor(this._frameWidth * this._scale);
    }

    /**
    Get scaled height of this object
    @property scaledHeight
    @readOnly
    @type {Integer}
    */
    property scaledHeight(v)
    {
        get return Math.floor(this._frameHeight * this._scale);
    }

    /**
    This property sets sequence of the button frames.
    @property sequence
    @type {Array}
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
    Displaying game button mode:
        1. #sequence, this mode calculate based frameWidth or frameHight, segiences and frames
        Maximum allowed frames for game button is Two
        2. #image, game button expect two images. One for normal state second one for pressed state.
        If pressedImage is not set by default is set to the image
    @property mode
    @type {Symbol}
    */
    property mode(v)
    {
        get return this._mode;
        set {

            assert typeof v === #symbol;
            this._mode = v;
        }
    }

    /**
    Draw method draws the button.
    @method draw
    @protected
    @param canvas {Canvas} Current game canvas
    */
    function draw(canvas)
    {
        if (!this.visible)
            return;
        switch(this.mode)
        {
            case #sequence:
                this._drawSequence(canvas);
                break;
            case #image:
                this._drawImage(canvas);
                break;
            default:
        
               // throw new Exception("ImageButton: incorrect mode");
                break;
        }
    }

    /**
    Method do draw sequence mode, display frame based on button state.
    @method _drawSequence
    @private
    @param canvas {Canvas} Canvas used to draw sequence
    */
    function _drawSequence(canvas)
    {

        assert canvas instanceof Canvas;
        assert this._image instanceof Bitmap;

        canvas.save(#matrix);
        canvas.translate(this._x, this._y);
        canvas.rotate(-(this.angle * 180. / Math.PI)); // rad2deg
        canvas.scale(this._scale, this._scale);
        canvas.translate(-this._anchorX, -this._anchorY);

        if (this._sequence.length < 2)
            this._frame = 0;
        else
            this._frame = this._clicked ? 1 : 0;

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

    /**
    Draw Image mode, display image based on button state
    @method _drawImage
    @private
    @param canvas {Canvas} Canvas used to draw sequence
    */
    function _drawImage(canvas)
    {
        assert canvas instanceof Canvas;
        assert this._image instanceof Bitmap;
        assert this._imagePressed instanceof Bitmap;

        canvas.save(#matrix);
        canvas.translate(this._x, this._y);
        canvas.scale(this._scale, this._scale);
        canvas.translate(-this._anchorX, -this._anchorY);

        var image = this._clicked ? this._imagePressed : this._image;

        if (this.paint instanceof Paint) {
            canvas.drawBitmapRect(image,
                0, 0, this._frameWidth, this._frameHeight,
                0, 0, this._frameWidth, this._frameHeight,this.paint);

        } else {
            canvas.drawBitmapRect(image,
                0, 0, this._frameWidth, this._frameHeight,
                0, 0, this._frameWidth, this._frameHeight);
        }

        canvas.restore();
    }

}
