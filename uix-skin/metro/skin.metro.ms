include "lib://graphics/typefaceCache.ms"
include "lib://uix-skin/theme.ms"
include "lib://uix-skin/skin.ms"

class MetroSkin : Skin
{
    //
   function this(options = {})
   {
        this._options = options;
        // TODO: this should be changed to only system.home after framework publish,and application id should be moved to this-optional theme
        this._root = System.home();
        this._defaultTheme = "uix-skin/metro/themes/blue/theme.metro." + this._getVariant() + ".mso";
        this._theme = new Theme(this._root + (this._options.theme ? this._options.theme : this._defaultTheme));

        // get access to theme object
        var theme = this._theme.getStyle("general");
        // visual variables
        this._gap = theme.gap?theme.gap:10;

        this._typefaceCache = new TypefaceCache();
   }

   function _getVariant()
   {
        // this skin is resolution-independent
        return "uni"
   }

  /* function loadTheme(src)
   {
        if (!System.isFile(src)) {
            var msg = String.printf("Cannot find %s!", src);
            System.messageBox(msg);
            throw msg;
        }
        var f = Stream.openFile(mso, "r8");
        if (!f)
            throw String.printf("Cannot load %s!", mso);
        this._data = parseData(f);
        f.close();
   }*/

    function _drawBgDecorator(item, canvas, left = 0, top = 0, width = item.width, height = item.height)
    {
        if (item.bg.image.source == null) {
            canvas.drawRect(left, top, left + width, top + height, item.bg.native);
        } else {
            // because of stretch = #both dimensions may be changed also without width and height property
            item.bg.image.resize(width, height);
            item.bg.drawImage(canvas, left, top);
        }
    }

    function _drawDrawing(item, canvas, bg, left = 0, top = 0, width = item.width, height = item.height)
    {
        if (bg.image.source == null) {
            canvas.drawRect(left, top, left + width, top + height, bg.native);
        } else {
            // because of stretch = #both dimensions may be changed also without width and height property
            bg.image.resize(width, height);
            bg.drawImage(canvas, left, top);
        }
    }

    

    function _getTypeface(obj)
    {
        return this._typefaceCache.getTypeface(obj);
    }

    function _setTypeface(paint, fontTheme, fontStyle = null)
    {
        if (fontStyle.fontFace)
            paint.typeface = this._getTypeface(fontStyle)
        else
            paint.typeface = this._getTypeface(fontTheme)
        if (fontTheme.size != null || fontStyle.size != null) paint.textSize = fontStyle.size ? fontStyle.size : fontTheme.size;
        if (fontTheme.color != null || fontStyle.color != null) paint.color = fontStyle.color ? fontStyle.color : fontTheme.color;
        if (fontTheme.fakeBold != null || fontStyle.fakeBold != null) paint.fakeBoldText = fontStyle.fakeBold ? fontStyle.fakeBold : fontTheme.fakeBold;
        if (fontTheme.strikeThruText != null || fontStyle.strikeThruText != null) paint.fakeBold = fontStyle.strikeThruText ? fontStyle.strikeThruText : fontTheme.strikeThruText;
        if (fontTheme.underline != null || fontStyle.underline != null) paint.underlineText = fontStyle.underline ? fontStyle.underline : fontTheme.underline;
    }

    function _drawCentredVector(path, item, canvas, paint, width = 0, height = 0, left = 0, top = 0)
    {
        var (l, t, r, b) = path.getBounds();
        var matrix = new Matrix();
        var xScale = item.width / (1.0*Math.abs(r - l));
        var yScale = item.height / (1.0*Math.abs(t - b));

        if (width != 0 || height != 0) {
            // if height is null, we keeep side ratio
            if (height == 0) {
                xScale = width / (1.0*Math.abs(r - l));
                yScale = xScale;
            }
            if (width == 0) {
                yScale = height / (1.0*Math.abs(t - b));
                xScale = yScale;
            }

        }
        matrix.setScale(xScale, yScale);
        path.transform(matrix);

        (l, t, r, b) = path.getBounds();

        var dx = (item.width - Math.abs(r - l)) / 2;
        var dy = (item.height - Math.abs(t - b)) / 2;
        path.offset(-l + dx + left, -t + dy + top);
        canvas.drawPath(path, paint);
    }

    /*function _setTypeface(paint, fontTheme, fontStyle)
    {
        paint.typeface = this._getTypeface(fontStyle ? fontStyle : fontTheme); // Typeface.fromName(font.name, font.style);
       if (font.size != null) paint.textSize = fontStyle.textSize ? fontStyle.textSize : fontTheme.textSize;
        if (font.color != null) paint.color = fontStyle.color ? fontStyle.color : fontTheme.color;
        if (font.fakeBold != null) paint.fakeBold = fontStyle.fakeBold ? fontStyle.fakeBold : fontTheme.fakeBold;
        if (font.strikeThru != null) paint.strikeThru = fontStyle.strikeThru ? fontStyle.strikeThru : fontTheme.strikeThru;
        if (font.underline != null) paint.underline = fontStyle.underline ? fontStyle.underline : fontTheme.underline;
    }*/

   property theme(v)
   {
        get return this._theme;
        set this._theme = v;
   }
}

include "lib://uix-skin/metro/controls/skin.metro.tileItem.ms"
include "lib://uix-skin/metro/controls/skin.metro.overlay.ms"

include "lib://uix-skin/metro/skin.metro.vectors.ms"

