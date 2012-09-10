include "lib://graphics/typefaceCache.ms"
include "lib://graphics/bitmapCache.ms"

class Skin
{
    var instance = null;

    function this(options = {})
    {
        this._options = options;
        this._bitmapCache = new BitmapCache();
    }

    property theme(v)
    {
        get return this._theme;
        set {
            if(v instanceof Theme)
                this._theme = v;
            else throw new InvalidArgument("[Skin.theme] expexts instance of Theme");
        }
    }

    function loadImage(name) {
        var res = "DVGA";
        switch (System.width) {
            case 640:
                res = "DVGA"
                break;
            case 600:
                res = "WSVGA"
                break;
            case 320:
                res = "HVGA"
                break;
            case 800:
                res = "VXGA"
                break;
            case 768:
                res = "XGA"
                break;
            case 540:
                res = "QHD"
                break;
            case 480:
                switch (System.height) {
                    case 800:
                        res = "WVGA";
                        break;
                    default :
                        assert System.messageBox(String.printf("Unsupported resolution (" + System.width + "x" + System.height + ")!"));
                        app.quit();
                        break;
                }
                break;
            default:
                assert System.messageBox(String.printf("Unsupported resolution (" + System.width + "x" + System.height + ")!"));
                app.quit();
                break;
        }

        var lfn = "app://skin/" + res + "/" + name;
        return System.isFile(lfn) ? this._bitmapCache.getBitmap(lfn) : null;

        //return Bitmap.fromFile("app://skin/" + res + "/" + name);
    }

    function callInitMethod(args..)
    {
        var methodName = "init" + args[0].className;
        if(this.exists(symbol(methodName),true))
            return this.call(symbol(methodName), args);
        else {
            var style = this.theme.getStyle(args[0].styleName);
            if(style)
                args[0].call(symbol("_setDefaults"),new Array(style));
        }

    }

    function callDrawMethod(args..)
    {
        var methodName = "draw" + args[0].className;

        //do not clone paint object within draw method
        if(this.exists(symbol(methodName),true)){
            return this.call(symbol(methodName), args);
        }

    }

    /* ***** Application ***** */

    function drawApplication(app, canvas)
    {
        this._drawBackground(app, canvas);
    }

    function drawForm(form, canvas)
    {
        this._drawBackground(form, canvas);
    }

    function drawLabel(control, canvas)
    {

        this._drawBackground(control, canvas);
        control.native.paint = control.fg.native;
        
    }

    function drawTextBox(control, canvas)
    {

        if (control.hasFocus() === true)
            this._drawBackground(control, canvas);
        else {

            if (control.inactive.image.source == null) {
                canvas.drawRect(0, 0, control.width, control.height, control.inactive.native);
            } else {
                // because of stretch = #both dimensions may be changed also without width and height property
                control.inactive.image.resize(item.width, item.height);
                control.inactive.drawImage(canvas, 0, 0);
            }
        }
    }

    function drawTextBoxCursor(control, canvas,options)
    {
        assert typeof options.left == #integer;
        assert typeof options.top == #integer;
        assert typeof options.right == #integer;
        assert typeof options.bottom == #integer;

        canvas.drawLine(options.left+1, options.top, options.left+1, options.bottom, control.cursor.native)
    }

    function drawBarBase(control, canvas)
    {
        this._drawBackground(control, canvas);
    }

    function drawItem(control, canvas)
    {
        this._drawBackground(control, canvas);
    }

    function drawToolBar(control, canvas)
    {
        this._drawBackground(control, canvas);
    }

    function drawToolBarButton(control,canvas)
    {
        this.drawButton(control, canvas);
    }

    function drawTitleBar(control, canvas)
    {
        this._drawBackground(control, canvas);
    }

    function drawList(control, canvas)
    {
        this._drawBackground(control, canvas);
    }

    function initListItem(control)
    {
        // get access to theme object
        var theme = this.theme.getStyle("listItem");

        control._setDefaults(theme);
        //this._setTypeface(item.fg, theme.font, item.style.font);
        //item.icon.paint.color = item.fg.color;
        control.marginX = 2 * this._gap;
    }

    function drawListItem(control, canvas)
    {
        var fg = control.fg;
        var bg = control.bg;
    
        if (control.clicked) {
            fg = control.pressed.fg;
            bg = control.pressed.bg;
        }
        var textLeft = control.marginX;
        var textRight = control.width - control.marginX;
        /*** draw backgound ***/
        this._drawBackground(control, canvas,{ bg : bg });
    
        /*** draw icon ***/
        if (control.icon.source != null) {
            // icon should have same color as text
            control.icon.paint = fg.native;
            if (control.iconAlign == #right) {
                control.icon.height = control.height / 2;
                control.icon.drawImage(canvas, control.width - control.icon.width - control.marginX, (control.height - control.icon.height) / 2);
                textRight = control.width - 2 * control.icon.width - control.marginX;
            } else {
                control.icon.height = control.height / 2;
                control.icon.drawImage(canvas, control.marginX, (control.height - control.icon.height) / 2);
                textLeft = 2 * control.marginX + control.icon.width;
            }
        }
    
        var textGap = 0;
        var (w, h);
        switch (control.horzAlign) {
            case #left:
                textGap = 0;
                break;
            case #center:
                (w, h) = fg.measureText(control.text);
                textGap = (control.width - w) / 2 - textLeft;
                break;
            case #right:
                (w, h) = fg.measureText(control.text);
                textGap = - w - textLeft + textRight - 2;
                break;
            default:
                 throw new Exception("[ListItem.horzAlign] ListItem accepts #left, #center or #right");
                break;
        }
        if (control.text != null)
            canvas.drawTextBox(control.text, textLeft + textGap, 0, textRight, control.height, fg.native, #center);
        if (control.badge != null) {
            control.badge.top = control.height / 10;
            control.badge.left = 19 * control.width / 20;
        }
        // draw separator line
        // canvas.drawLine(item.marginX, item.height, item.width, item.height, item._skinVariablesListItemSeparatorPaint);
    }

    function initRow(control)
    {
        var theme = this.theme.getStyle("row");
        control.layout.spacer = theme.layout.spacer;
        control._setDefaults(theme);
    }

    function drawRow(control, canvas)
    {
    }

    function initTile(control)
    {
        // get access to theme object
        var theme = this.theme.getStyle("tile");
        control._setDefaults(theme);
        control.layout.spacer = theme.layout.spacer
    }

    function drawTile(control, canvas)
    {
        this._drawBackground(control, canvas);
    }


    function drawButton(item, canvas)
    {
       var paintFg = (item.enabled?(item.clicked?item.pressed.fg:item.fg):item.disabled.fg);
       var paintBg = (item.enabled?(item.clicked?item.pressed.bg:item.bg):item.disabled.bg);

        //draw backgaund
        this._drawBackground(item,canvas,{bg : paintBg });

        //draw border
        this._drawBorder(item, canvas, {object: item.enabled ? item : item.disabled});


        item.label.fg = paintFg;
        item.label.vertAlign = #center;

        if(item.isImage() === true)
        {
            // place image
            this._placeButtonImage(item);
            item.image.paint = paintFg.native;
        }

    }


    function drawBadge(control, canvas)
    {
        /*** draw backgound (we can't use _drawBgDecorator, because we need to draw circle not rectangle***/
        if (control.bg.image.source == null) {
           canvas.drawCircle(control.width / 2, control.height / 2, control.width / 2, control.bg.native);
        } else {
           // because of stretch = #both dimensions may be changed also without width and height property
           control.bg.image.resize(control.width, control.height);
           control.bg.drawImage(canvas);
        }
        if (control.text != 0) {
            var (w, h) = control.fg.measureText(control.text);
            canvas.drawText(control.text, (control.width - w) / 2, (control.height + h) / 2, control.fg.native);
        }
    }


    function _placeButtonImage(item)
    {
        switch (item.align) {
            case #left:
                // resize image
                item.image.height = 8 * item.height / 10;
                // place elements
                item.image.left = 3 * this._gap;
                item.image.top = (item.height - item.image.height) / 2;
                item.label.left = 2 * item.image.left + item.image.width;
                item.label.top = (item.height - item.label.height) / 2;
            break;
            case #top:
                // resize image
                item.image.height = item.height / 3;
                // place elements
                item.image.left = (item.width - item.image.width) / 2;

                if (item.label.text)
                    item.image.top = item.height / 10;
                else
                    item.image.top = (item.height - item.image.height) / 2;
    
                item.label.left = (item.width - item.label.width) / 2;
                item.label.top = 2 * item.height / 10 + item.image.height ;
            break;
            case #right:
                // resize image
                item.image.height = 8 * item.height / 10;
                // place elements
                item.image.left = item.width - 3 * this._gap - item.image.width;
                item.image.top = (item.height - item.image.height) / 2;
    
                item.label.left = item.image.left - 3 * this._gap - item.label.width;
                item.label.top = (item.height - item.label.height) / 2;
            break;
            case #bottom:
                // resize image
                item.image.height = item.height / 3;
                // place elements
                if (item.label.text)
                    item.image.top = 9 * item.height / 10 - item.image.height;
                else
                    item.image.top = (item.height - item.image.height) / 2;
                item.image.left = (item.width - item.image.width) / 2;

                item.label.left = (item.width - item.label.width) / 2;
                item.label.top = item.height / 10;
            break;
        }
    }

    function _drawBackground(control, canvas,options = {})
    {
        var left = options.left ? options.left : 0
        var top  = options.top ? options.top : 0
        var width  = options.width ? options.width : control.width
        var height = options.height ? options.height : control.height;
        var bg = options.bg instanceof Background ? options.bg : control.bg

        if(bg.shape == #rectangle)
            canvas.drawRect(left, top, width + left, height + top, bg.native);
        else if(bg.shape == #roundRectangle)
            canvas.drawRoundRect(left, top, width + left, height + top, bg.rx, bg.ry, bg.native);

        if (bg.image._image instanceof Bitmap || bg.image._image instanceof Path)
        {
            // because of stretch = #both dimensions may be changed also without width and height property
            bg.image.resize(width, height);
            bg.image.drawImage(canvas, left, top,bg.native);
        }else if(bg.image._image instanceof SVG) {
            bg.image.drawImage(canvas, width/2, height/2);
        }

        this._drawBorder(control,canvas, {bg : bg });

   }

    function _drawBorder(control,canvas,options = {}){

        var left = options.left ? options.left : 0
        var top  = options.top ? options.top : 0
        var width  = options.width ? options.width : control.native.width;
        var height = options.height ? options.height : control.native.height;
        var bg = options.bg ? options.bg : control.bg

        if (bg._border instanceof Border && bg.border.visible === true) {

           if(bg.border.shape == #rectangle)
                canvas.drawRect(left, top, width + left, height + top, bg.border.native);
            else if(bg.border.shape == #roundRectangle)
                canvas.drawRoundRect(left, top, width + left, height + top, bg.border.rx, bg.border.ry, bg.border.native);

        } else {

            if (bg._borderTop instanceof Border)
                canvas.drawLine(0, 0, width + left, 0, bg.borderTop.native);

            if (bg._borderBottom  instanceof Border)
                canvas.drawLine(0, height + top, width + left, height + top, bg.borderBottom.native);

            if (bg._borderLeft instanceof Border)
                canvas.drawLine(0, 0, 0, height + top, bg.borderLeft.native);

            if (bg._borderRight instanceof Border)
                canvas.drawLine(width + left, 0, width + left, height + top, bg.borderRight.native);
       }

    }


    function drawCheckBox(control, canvas)
    {
        var fg = (control.enabled?(control.clicked?control.pressed.fg:control.fg):control.disabled.fg);
        var bg = (control.enabled?(control.clicked?control.pressed.bg:control.bg):control.disabled.bg);
        var box = (control.enabled?(control.clicked?control.box.pressed:control.box.normal):control.box.disabled);

        // get text dimensions
        var (w, h) = fg.measureText(control.text);

        // apply align
        var left = 0;
        var textLeft = 0;
        var leftMargin = 0;
        var rightMargin = 0;
        if (control.boxAlign == #left) {
            left = 2 * this._gap;
            leftMargin = 2 * this._gap + box.width;
        } else {
            left = control.width - 2 * this._gap - box.width;
            rightMargin = 2 * this._gap + box.width;
        }

        // apply text align
        switch (control.textAlign) {
            case #left:
                textLeft = leftMargin + 2 * this._gap;
            break;
            case #center:
                textLeft = (control.width - w) / 2;
            break;
            case #right:
                textLeft = control.width - rightMargin - 2 * this._gap - w;
            break;
        }
        var top = (control.height - box.height) / 2;
        // draw control
        this._drawBackground(control, canvas, {bg : bg});
        // draw box background
        this._drawBackground(control, canvas, {bg : box.bg, left : left, top : top, width : box.width, height : box.height});
        // draw fg only if box is checked fg should be tick or something like it
        if (control.checked && box.fg.image.source) {
            box.fg.image.resize(2 * box.width / 3, 2 * box.height / 3);
            box.fg.image.paint = box.fg.native;
            box.fg.image.drawImage(canvas, left + box.width / 6, top + box.height / 6 );
        }
        // draw text
        canvas.drawText(control.text, textLeft, (control.height + h)/2, fg.native);
    }

    function drawSlider(control, canvas)
    {
        this._drawBackground(control, canvas, {bg : control.bg});
    }

    function drawSliderButton(control, canvas)
    {
        this._drawBackground(control, canvas);
    }

    function drawComboBox(control, canvas)
    {
        var fg = control.fg;
        var bg = control.bg;

        if (control.clicked) {
            fg = control.pressed.fg;
            bg = control.pressed.bg;
        }

        this._drawBackground(control, canvas, {bg : bg});
        this._drawBorder(control, canvas);


        if (control.text != null) {
            var textLeft = 0;
            var (w, h) = fg.measureText(control.text);
            switch (control.align) {
                case #left:
                    textLeft = 2 * this._gap;
                    break;
                case #center:
                    textLeft = (control.width - w) / 2;
                    break;
                case #right:
                    textLeft = control.width - w - 2 * this._gap;
                    break;
                default:
                     throw new Exception("[ComboItem.align] ListItem accepts #left, #center or #right");
                    break;
            }
            canvas.drawText(control.text, textLeft, (control.height + h) / 2, fg.native);
        }
    }

    function drawComboItem(control, canvas)
    {
        var fg = control.fg;
        var bg = control.bg;

        if (control.clicked) {
            fg = control.pressed.fg;
            bg = control.pressed.bg;
        }

        if (control.checkable) {
            this.drawCheckBox(control, canvas);
        } else {
    
            this._drawBackground(control, canvas, {bg : bg});
            this._drawBorder(control,canvas);

            var textLeft = 0;
            var (w, h) = fg.measureText(control.text);
            switch (control.textAlign) {
                case #left:
                    textLeft = 0;
                    break;
                case #center:
                    textLeft = (control.width - w) / 2;
                    break;
                case #right:
                    textLeft = control.width - w;
                    break;
                default:
                     throw new Exception("[ComboItem.align] ListItem accepts #left, #center or #right");
                    break;
            }
            if (control.text != null)
                canvas.drawText(control.text, textLeft, (control.height + h) / 2, fg.native);
        }
    }


    function drawSwitchControl(control, canvas)
    {
        var box = control.box;
        var slider = control.enabled?control.slider.propertyAt(control.state):control.slider.disabled;
        var fg = (control.enabled?(control.clicked?control.pressed.fg:control.fg):control.disabled.fg);
        var bg = (control.enabled?(control.clicked?control.pressed.bg:control.bg):control.disabled.bg);

        this._drawBackground(control, canvas, {bg : bg});

        // place box
        var boxLeft;
        var leftMargin = 0;
        var rightMargin = 0;
        var gap = 2;

        if (control.boxAlign == #left) {
            boxLeft = 2 * gap;
            leftMargin = 2 * gap + box.off.width;
        } else {
            boxLeft = control.width - 2 * gap - box.off.width;
            rightMargin = 2 * gap + box.off.width;
        }

        // draw box
        /*if (control.enabled)
            this._drawBackground(control, canvas, {bg : box.off.bg , left : boxLeft, top : (control.height - box.off.height) / 2, width : box.off.width, height : box.off.height });
        else
            this._drawBackground(control, canvas, {bg : box.disabled.bg , left : boxLeft, top : (control.height - box.disabled.height) / 2, width : box.disabled.width, height : box.off.height });
        */

        this._drawBackground(control, canvas, {bg : box.propertyAt(control.state).bg , left : boxLeft, top : (control.height - box.propertyAt(control.state).height) / 2, width :/* boxLeft +*/ control._boxButtonLeft + 1, height : box.propertyAt(control.state).height });
        this._drawBorder(control, canvas, {left : boxLeft, top : (control.height - box.on.height) / 2, width :/* boxLeft +*/ control._boxButtonLeft + 1, height : box.on.height });

        // draw slider to the box
        this._drawBackground(control, canvas, {bg : slider.bg , left : boxLeft + control._boxButtonLeft, top : (control.height - slider.height) / 2, width : slider.width, height : slider.height });

        if (control.text) {
            // get text dimensions
            var (w, h) = fg.measureText(control.text);

            // apply text align
            var textLeft;
            switch (control.textAlign) {
                case #left:
                    textLeft = leftMargin + 2 * this._gap;
                break;
                case #center:
                    textLeft = (control.width - w) / 2;
                break;
                case #right:
                    textLeft = control.width - rightMargin - 2 * this._gap - w;
                break;
            }
            var top = (control.height + h) / 2;
    
            canvas.drawText(control.text, textLeft, top, fg.native);
        }
    }
    function initKeyPreview(item)
    {
        // get access to theme object
        var theme = this.theme.getStyle("keyPreview");
        item._setDefaults(theme);
    }
    
    function drawKeyPreview(control, canvas)
    {
        this._drawBackground(control, canvas,{ bg : control.bg });
    
        if (control.symbol instanceof String) {
             var (w, h) = control.fg.measureText(control.symbol);
             canvas.drawText(control.symbol, (control.width - w) / 2, (control.height + h) / 2, control.fg.native);
        }
    }

    function initKeyboard(item)
    {
        // get theme
        var theme = this.theme.getStyle("keyboard");
    
        item._setDefaults(theme);
    
        item.layout.align = #stretch;
        item.layout.orientation = #vert;

        // set rows options*/
        for (var i = 0; i < item._rows.length; i++) {
            item.rows[i].stretch = #both;
            item.rows[i].layout = new StackLayout();
            item.rows[i].layout.align = #stretch;
            item.rows[i].layout.pack = #start;
            item.rows[i].layout.spacer = theme.rowsStyle[i].spacer ? theme.rowsStyle[i].spacer : 0;
            item.rows[i].layout.setMargin(theme.rowsStyle[i].marginX ? theme.rowsStyle[i].marginX : 0, theme.rowsStyle[i].marginY ? theme.rowsStyle[i].marginY : 0, theme.rowsStyle[i].marginX ? theme.rowsStyle[i].marginX : 0, theme.rowsStyle[i].marginY ? theme.rowsStyle[i].marginY : 0);
        }
    }

    function drawKeyboard(item, canvas)
    {
        this._drawBackground(item, canvas);
    }

    function initKeyboardButton(item)
    {
        var theme = this.theme.getStyle("keyboardButton");
        item._setDefaults(theme);
    }
    
    function drawKeyboardButton(item, canvas)
    {
        var fg = (item.enabled?(item.clicked?item.pressed.fg:item.fg):item.disabled.fg);
        var bg = (item.enabled?(item.clicked?item.pressed.bg:item.bg):item.disabled.bg);
    
        this._drawDrawing(item, canvas, bg);
    
        var s = "";
        if (item.symbol instanceof String) {
             s = item.symbol;
        } else {
            switch (item.symbol) {
                case #space:
                    s = "space";
                break;
                case #alt123:
                    s = "&123";
                break;
                case #alt123_:
                    s = "&123";
                break;
                case #alt@123:
                    s = "@123";
                break;
                case #altABC:
                    s = "ABC";
                break;
                case #altWeb:
                    s = "www";
                break;
                case #altSymbols:
                    s = "#+=";
                break;
                case #shift:
                    s = #shift;
                break;
                case #backspace:
                    s = #backspace;
                break;
                case #enter:
                    s = "back"
                break;
            }
        }
    
        if (s instanceof String) {
             var (w, h) = item.fg.measureText(s);
             canvas.drawText(s, (item.width - w) / 2, (item.height + fg.native.textSize) / 2, fg.native);
        } else {
             this._drawCentredVector(this.vectors[s], item, canvas, fg.native, null/*keep aspect ratio*/, item.height / 3);
        }
    
        // draw green cicle to shift buttn if it is neede
        if (item.symbol == #shift && item.value == 2) {
            var paint = new Paint();
            paint.color = 0xff00ff00;
            canvas.drawCircle(item.width / 5, item.width / 5, item.width / 10, paint);
        }
    }


    function drawInformativDialog(control, canvas)
    {
        this._drawBackground(control, canvas);
        canvas.drawRect(0, 0, control.width, control.height, control.border.native);
    }

    function drawInfoDialog(control, canvas)
    {
        this.drawDialog(control, canvas);
    }

    function drawConfirmDialog(control, canvas)
    {
        this.drawDialog(control, canvas);
    }

    function drawDialog(control, canvas)
    {
        this._drawBackground(control, canvas);
    }
}