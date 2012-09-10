include "lib://core/exception.ms"

/**
Simple helper for {{#crossLink "Paint"}}{{/crossLink}} class.
@class ColorPaint
@module graphics
*/
class ColorPaint
{
    /**
    Creates new color Paint object in several ways.

    * one parameter: hexadecimal color formatted 0xAARRGGBB, AA = alpha, RR = red, GG = green, BB = blue
    * two paramaters: hex color and stroke's style
    * three parameters: red, green, blue - all ranged 0..255
    * four paramterers: alpha, red, green, blue - all ranged 0..255
    @static
    @method create
    @param color* {Integer} The color, can be expresed as one integer, three colors RGB components or four ARGB components.
    @example
        var opaqueBlue = ColorPaint.create(0xff0000ff);
        var opaqueRed = ColorPaint.create(255, 0, 0);
        var semiGreen = ColorPaint.create(128, 0, 255, 0);
        // it is possible to use 2nd parameter for stroke style
        var opaqueSolidBlueForRect = ColorPaint.create(0xff0000ff, #fill);
        canvas.draw(10, 10, 100, 100, opaqueSolidBlueForRect);
    */
    function create(color..)
    {
        var paint = new Paint();
        paint.style = #stroke;
        if (color.length == 1) {
            paint.color = color[0];
        } else if (color.length == 2) {
            paint.color = color[0];
            if (typeof color[1] == #symbol)
                paint.style = color[1];
        } else if (color.length == 3) {
            paint.color = 0xff000000 | (color[0] << 16) | (color[1] << 8) | (color[2]);
        } else if (color.length == 4) {
            paint.color = (color[0] << 24) | (color[1] << 16) | (color[2] << 8) | (color[3]);
        } else {
            throw InvalidArgument();
        }
        return paint;
    }

    var stockPaints = null;

    /**
    Returns stocked objects. Predefined colors:

    * transparent
    * black - fully opaque black
    * white - fully opaque white
    * red - fully opaque red
    * green - fully opaque green
    * blue - fully opaque blue
    * silver - fully opaque silver (218, 218, 218) or (0xDA, 0xDA, 0xDA)
    @method stock
    @static
    @example
        canvas.drawRect(10, 10, 100, 100, ColorPaint.stock().red);
    */
    function stock()
    {
        if (ColorPaint.stockPaints == null) {
            ColorPaint.stockPaints = {
                transparent: ColorPaint.create(0x00000000),
                black: ColorPaint.create(0xff000000),
                white: ColorPaint.create(0xffffffff),
                red: ColorPaint.create(0xffff0000),
                green: ColorPaint.create(0xff00ff00),
                blue: ColorPaint.create(0xff0000ff),
                silver: ColorPaint.create(0xffdadada),
            }
        }
        return ColorPaint.stockPaints;
    }

}