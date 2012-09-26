include "lib://game2d/base/gameObject.ms"
include "lib://game2d/utils.ms"

/**
Label class is used to show simple text on the screen without support of touch events.
@class Label
@module game2d
@example
    //label (test)
    this.add(new Label({
        text    : "Label text",
        paint   : new Paint(),
        x       : System.width / 2,
        y       : System.height / 2,
    }));
*/
class Label : GameObject
{
    // @region Statics

    var _defaultPaint = null; // static

    function getDefaultPaint()
    {
        if (Label._defaultPaint != null) {
            return Label._defaultPaint;
        }

        var paint = PaintCache.getPaint(Label);
        if (paint) {
            Label._defaultPaint = paint;
            return paint;
        }

        Label._defaultPaint = new Paint();
        Label._defaultPaint.typeface = Typeface.fromName("");
        Label._defaultPaint.textSize = System.height / 15;
        Label._defaultPaint.color = 0xffffffff;

        return Label._defaultPaint;
    }

    // @endregion

    /**
    Object initialisation. It is usally no need to overwrite this method, but it is possible to overwrite it and use it as a class constructor.
    @method init
    */
    function init()
    {
        super.init();
        this._text = this.options.text || "";
        this._anchorX = -1;
        this._anchorY = -1;
    }

    /**
    Text on the label.
    @property text
    @type String
    @example
        this.add(new Label({
            text    : "Label text",
            paint   : new Paint(),
            ...
        }));
    */
    property text(v)
    {
        get return this._text;
        set {
            this._text = v;
            var paint = this._paint || Label.getDefaultPaint();
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
    Width of the label. By default it is set acording to the text dimensins
    @property width
    @type Integer
    */
    property width(v)
    {
        get  return this._width;
    }

    /**
    Height of the label. By default it is set acording to the text dimensins
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
    @example
        // create an instance of Paint class
        var paint = new Paint();
        paint.color = 0xff7DFAFF;
        paint.textSize = System.width / 20;
    
        // add label into scene
        scene.add(new Label({
            text    : "Label text",
            paint   : paint,
            x       : System.width / 2,
            y       : System.height / 2,
        }));
    */
    property paint(v)
    {
        get return this._paint;
        set this._paint = v;
    }

    /**
    Color of the text. The color is in hexadecimal format for four chanels: alpha, red, green and blue. For example:

        black       : 0xff000000;
        white       : 0xffffffff;
        red         : 0xffff0000;
        green       : 0xff00ff00;
        transparent : 0x00000000;
        ...
    @property color
    @example
        // label
        this.add(new Label({
            text    : "Label text",
            color   : 0xffff0000,
            x       : System.width / 2,
            y       : System.height / 2,
        }));
    */
    property color(v)
    {
        get return (this._paint || Label.getDefaultPaint()).color;
        set {
            if (this._paint === Label.getDefaultPaint())
                this._paint = clonePaint(Label.getDefaultPaint());
            else if (this._paint == null)
                this._paint = new Paint();
            this._paint.color = v;
        }
    }

    /*
    This property allows to change text's alpha level.
    @property alpha
    @type Integer
    */
    property alpha(v)
    {
        get return (this._paint || Label.getDefaultPaint()).alpha;
        set {
            if (this._paint === Label.getDefaultPaint())
                this._paint = clonePaint(Label.getDefaultPaint());
            else if (this._paint == null)
                this._paint = new Paint();
            this._paint.alpha = v;
        }
    }

    /**
    Set size of the font used in the label.
    @property textSize
    @type Integer
    @example
        //label
        this.add(new Label({
            text        : "Label text",
            textSize    : 25,
            ...
        }));
    */
    property textSize(v)
    {
        get return (this._paint || Label.getDefaultPaint()).textSize;
        set {
            if (this._paint === Label.getDefaultPaint())
                this._paint = clonePaint(Label.getDefaultPaint());
            else if (this._paint == null)
                this._paint = new Paint();
            //logI(this._paint);
            this._paint.textSize = v;
        }
    }

    /**
    Draw of the Label. It is usally no need to overwrite this method, but it is possible to overwrite it to customize label appearance.
    @method draw
    @param canvas {Canvas}
    */
    function draw(canvas)
    {
        var paint = this._paint || Label.getDefaultPaint();

        canvas.save(#matrix);
        canvas.translate(this._x, this._y);
        canvas.rotate(-(this._angle * 180. / Math.PI)); // rad2deg
        canvas.scale(this._scale, this._scale);
        canvas.translate(-this._anchorX, -this._anchorY);
        //canvas.drawText(this._text, 0, 0 + this._height, paint);
        canvas.drawText(this._text, 0, 0 + (this._height + paint.fontDescent)/2, paint);
        canvas.restore();
    }
}