include "lib://game2d/base/button.ms"
include "lib://game2d/utils.ms"
include "lib://graphics/paintCache.ms"

/**
TextButton class is used to show simple text on the screen.
You do not need to specify image for this object.
What is required is to specify {{#crossLink "Paint"}}{{/crossLink}} instance with typeFace object.
@class TextButton
@module game2d
@example
    var newGame = new TextButton({
        text    : "Start new game",
        x       : System.width / 2,
        paint   : res.paints.buttonText,
        width   : System.width / 2,
        height  : System.height / 2,
    });
    newGame.onClick = function()
    {
        // onClick event
    }
    this.add(newGame);
*/
class TextButton : Button
{

    // @region Statics

    var _defaultPaint = null; // static

    function getDefaultPaint()
    {
        if (TextButton._defaultPaint != null) {
            return TextButton._defaultPaint;
        }

        var paint = PaintCache.getPaint(TextButton);
        if (paint) {
            TextButton._defaultPaint = paint;
            return paint;
        }

        TextButton._defaultPaint = new Paint();
        TextButton._defaultPaint.typeface = Typeface.fromName("");
        TextButton._defaultPaint.textSize = System.height / 15;
        TextButton._defaultPaint.color = 0xffffffff;

        return TextButton._defaultPaint;
    }

    // @endregion

    /**
    Object initialisation. This method is called from class constructor and can be used in overwritten classes as a class constructor.
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._text = this.options.text || "";
        this._anchorX = -1;
        this._anchorY = -1;
    }

    /**
    Text of the button.
    @property text
    @type String
    @example
        var newGame = new TextButton({
            text    : "Start new game",
            x       : System.width / 2,
            paint   : res.paints.buttonText,
            width   : System.width / 2,
            height  : System.height / 2,
        });
    */
    property text(v)
    {
        get return this._text;
        set {
            this._text = v;
            var paint = this._paint || TextButton.getDefaultPaint();
            var (dw, dh) = paint.measureText(this._text);
            this._width = dw;
            this._height = paint.fontBottom - paint.fontTop;
            if (this._anchorX == -1)
                this._anchorX = this.scaledWidth / 2;
            if (this._anchorY == -1)
                this._anchorY = this.scaledHeight / 2;
        }
    }

    /**
    Width of TextButton in pixels
    @property width
    @type Integer
    */
    property width(v)
    {
        get  return this._width;
    }

    /**
    Height of TextButton in pixels
    @property height
    @type Integer
    */
    property height(v)
    {
        get return this._height;
    }

    /**
    Instance of {{#crossLink "Paint"}}{{/crossLink}} class used to draw text. It specifies font size, color, typeface and also other graphics effects.
    @property paint
    @type Paint
    @example
        // create an instance of Paint class
        var paint = new Paint();
        paint.color = 0xff7DFAFF;
        paint.textSize = System.width / 20;
    
        // create a button
        var button = new TextButton({
            text    : "Start new game",
            paint   : paint,
            ...
        });
    */
    property paint(v)
    {
        get return this._paint;
        set this._paint = v;
    }

    /**
    Color of the text. The color is in hexadecimal format for four chanels: alpha, red, green and blue.

        black       : 0xff000000;
        white       : 0xffffffff;
        red         : 0xffff0000;
        green       : 0xff00ff00;
        transparent : 0x00000000;

    @property color
    @type Integer
    @example
        // create a button
        var button = new TextButton({
            text    : "Start new game",
            paint   : new Paint(),
            color   : 0xff0000ff,
            ...
        });
    */
    property color(v)
    {
        get return (this._paint || TextButton.getDefaultPaint()).color;
        set {
            if (this._paint === TextButton.defaultPaint)
                this._paint = clonePaint(TextButton.defaultPaint);
            else if (this._paint == null)
                this._paint = new Paint();
            this._paint.color = v;
        }
    }

    /**
    Set size of the font used in the button;
    @property textSize
    @type Integer
    @example
        // create a button
        var button = new TextButton({
            text     : "Start new game",
            paint    : new Paint(),
            color    : 0xff0000ff,
            textSize : 11,
            ...
        });
    */
    property textSize(v)
    {
        get return (this._paint || TextButton.getDefaultPaint()).textSize;
        set {
            if (this._paint === TextButton.getDefaultPaint())
                this._paint = clonePaint(TextButton.getDefaultPaint());
            else if (this._paint == null)
                this._paint = new Paint();
            this._paint.textSize = v;
        }
    }

    /**
    Draw the button. It is usally no need to overwrite this method, but it is possible to overwrite it to customize button appearance.
    @method draw
    @protected
    @param canvas {Canvas}
    */
    function draw(canvas)
    {
        var paint = this._paint || TextButton.getDefaultPaint();

        canvas.save(#matrix);
        canvas.translate(this._x, this._y);
        canvas.rotate(-(this._angle * 180. / Math.PI)); // rad2deg
        canvas.scale(this._scale, this._scale);
        canvas.translate(-this._anchorX, -this._anchorY);
        canvas.drawText(this._text, 0, 0 + (this._height + paint.fontDescent)/2, paint);
        //debug: canvas.drawRect(0, 0, this._width, this._height, paint);
        canvas.restore();
    }

}
