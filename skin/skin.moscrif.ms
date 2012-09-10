include "code://core/log.ms"
include "code://skin/skin.moscrif.resolutions.ms"
include "code://graphics/typefaceCache.ms"
include "code://graphics/bitmapCache.ms"

class MoscrifSkin
{
    var instance = null;
    
    function this(theme = "")
    {
        assert MoscrifSkin.instance == null;
        MoscrifSkin.instance = this;
        theme = System.home() + (theme == "" ? "skin/skin.moscrif/" : System.applicationId + "/.themes/skin.moscrif." + theme + "/");
        var sr = new MoscrifSkinResulutions(theme);
        this._res = sr.data;
        this._root = theme + sr.variant + "/";
        this._typefaceCache = new TypefaceCache();
        this._bitmapCache = new BitmapCache();
    }
    
    function _getTypeface(obj)
    {
        return this._typefaceCache.getTypeface(obj);
    }
    
    function _getBitmap(fileName, fromCache = true)
    {
        if (!fromCache && typeof fileName != #symbol)
            return System.isFile(fileName) ? Bitmap.fromFile(fileName) : null;
        var lfn = this._root + fileName;
        if (typeof fileName == #symbol) lfn += ".png";
        return System.isFile(lfn) ? this._bitmapCache.getBitmap(lfn) : null;
    }
    
    function _setTypeface(paint, font)
    {
        paint.typeface = this._getTypeface(font); // Typeface.fromName(font.name, font.style);
        if (font.size != null) paint.textSize = font.size;
        if (font.color != null) paint.color = font.color;
        if (font.fakeBold != null) paint.fakeBoldText = font.fakeBold;
        if (font.strikeThru != null) paint.strikeThruText = font.strikeThru;
        if (font.underline != null) paint.underlineText = font.underline;
    }
    
    function _drawCenteredText(canvas, paint, text, view, x = #center, y = #center, dx = 0, dy = 0)
    {
        var (w, h) = paint.measureText(text);
        if (x === #center) { x = (view.width - w) / 2;  if (y != #center) y += - paint.fontDescent - paint.fontAscent; }
        if (y === #center) y = (view.height - paint.fontDescent - paint.fontAscent) / 2;
        canvas.drawText(text, x + dx, y + dy, paint); // - paint.fontDescent - paint.fontAscent
    }
    
    function _setBackgroundPaint(paint, background)
    {
        //debug stacktrace;
        //background.show();
        //background.colors.show();
        if (background.colors) {
            var gradient = Shader.linear(background.points, background.colors, background.pos, "mode");
            paint.shader = gradient;
            //canvas.drawRect(0, 0, view.width, view.height, paint);
        } else {
            paint.color = background.color;
            //canvas.drawRect(0, 0, view.width, view.height, paint);
        }
    }
    
    function _drawGradientBackground(canvas, background, view)
    {
        var paint = new Paint();
    
        if (background.colors) {
            var gradient = Shader.linear(background.points, background.colors, background.pos, "mode");
            paint.shader = gradient;
            canvas.drawRect(0, 0, view.width, view.height, paint);
        } else {
            paint.color = background.color;
            canvas.drawRect(0, 0, view.width, view.height, paint);
        }
    
        var border = new Paint();
    
        if (background.topBorder) {
            border.color = background.topBorder;
            canvas.drawLine(0, 0, view.width, 0, border);
        }
        if (background.bottomBorder) {
            border.color = background.bottomBorder;
            canvas.drawLine(0, view.height, view.width, view.height, border);
        }
        if (background.leftBorder) {
            border.color = background.leftBorder;
            canvas.drawLine(0, 0, 0, view.height, border);
        }
        if (background.rightBorder) {
            border.color = background.rightBorder;
            canvas.drawLine(view.width, 0, view.width, view.height, border);
        }
    }
    
    function _drawBackground(canvas, paint, background, view)
    {
        canvas.drawRect(0, 0, view.width, view.height, paint);
    
        var border = new Paint();
        border.strokeWidth = 2;
    
        if (background.topBorder) {
            border.color = background.topBorder;
            canvas.drawLine(0, 0, view.width, 0, border);
        }
        if (background.bottomBorder) {
            border.color = background.bottomBorder;
            canvas.drawLine(0, view.height, view.width, view.height, border);
        }
        if (background.leftBorder) {
            border.color = background.leftBorder;
            canvas.drawLine(0, 0, 0, view.height, border);
        }
        if (background.rightBorder) {
            border.color = background.rightBorder;
            canvas.drawLine(view.width, 0, view.width, view.height, border);
        }
    }
    
    /* ***** Application ***** */
    
    function initApplication(app)
    {
        /*
        var layout = new StackLayout();
        layout.orientation = #vert;
        layout.align = #stretch;
        layout.pack = #start;
        app.layout = layout;
        */
    }
    
    function drawApplication(application, canvas)
    {
        var res = MoscrifSkin.instance._res;
        canvas.clear(res.application.background);
    }
    
    /* ***** Label ***** */
    
    function initLabel(label)
    {
        var paint = new Paint();
        paint.textSize = Integer.min(System.width, System.height) / 25;
        paint.antiAlias = true;
        paint.color = 0xff000000;
        label.paint = paint;
        label.vertAlign = label.horzAlign = #center;
    }
    
    function drawLabel(canvas, label)
    {
        //logI(label.left, label.top, label.width, label.heigth);
        //canvas.drawRect(10, 10, label.width-10, label.height-10, label.paint);
    }
    
    /* ***** Button ***** */
    
    function initButton(button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.button[button.kind];
        button.width = System.width / 8;
        button.height = System.height / 10;
        var paint = new Paint();
        this._setTypeface(paint, settings.font);
        button._paint = paint;
    }
    
    function drawButton(canvas, button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.button[button.kind];
        var bitmap = this._getBitmap(settings.nine, true);
        canvas.drawBitmapNine(bitmap, 0, 0, button.width, button.height);
    
        const depth = System.width / 240;
        var (dx, dy) = button.pressed ? (depth, depth) : (0, 0);
        this._drawCenteredText(canvas, button._paint, button.text, button, #center, #center, dx, dy);
    }
    
    /* ***** Form ***** */
    
    function initForm(form)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.form;
        //settings.show();
        var bg = this._getBitmap(settings.background);
        form._backgroundImage = bg;
        form.stretch = #stretch;
        
        var layout = new Moscrif.StackLayout();
        layout.orientation = #vert;
        layout.align = #stretch;
        form.layout = layout;
    }
    
    function drawFormBg(canvas, form)
    {
        if (form._backgroundImage instanceof Bitmap)
            canvas.drawBitmap(form._backgroundImage, 0, 0);
    }
    
    /* ***** Dialogs ***** */
    
    function initDialog(dialog)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.dialog;
    
        dialog.width = System.width / 5 * 4;
        dialog.height = System.height / 4;
    
        dialog.label.horzAlign = #center;
        dialog.label.vertAlign = #center;
        dialog.label.stretch = #both;
        var p = dialog.label.paint || new Paint();
        this._setTypeface(p, settings.font);
        dialog.label.paint = p;
    
        var paint = new Paint();
        paint.color = 0x7f0f0f0f;
        paint.style = #fill;
        dialog._overlayPaint = paint;
    
        paint = new Paint();
        paint.color = settings.background;
        paint.style = #fill;
        dialog._backgroundPaint = paint;
    
        //dialog.buttons.onDraw=:s,c{var paint = new Paint();paint.color = 0xffffffff;c.drawRect(0, 0, s.width, s.height, paint);}
        dialog.buttons.stretch = #horz;
        dialog.buttons.height = settings.buttons.height;
    
        var layout = new Moscrif.StackLayout();
        layout.orientation = #horz;
        layout.spacer = 5;
        layout.setMargin(5, 5, 5, 5);
        layout.align = #stretch;
        layout.pack = #center;
        dialog.buttons.layout = layout;
    
        layout = new Moscrif.StackLayout();
        layout.orientation = #vert;
        layout.setMargin(5, 5, 5, 5);
        layout.align = #stretch;
        dialog.layout = layout;
    }
    
    function initDialogButton(dialog, button)
    {
        button.width = dialog.width / 3;
        //button.height = 30;
    }
    
    function drawDialogOverlay(canvas, dialog)
    {
        canvas.drawRect(0, 0, System.width, System.height, dialog._overlayPaint);
    }
    
    function drawDialog(canvas, dialog)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.dialog;
        canvas.drawRoundRect(0, 0, dialog.width, dialog.height, settings.radiusX, settings.radiusY, dialog._backgroundPaint);
    }
    
    // claendarDialog
    
    function initCalendarDialog(dialog)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.calendarView;
    
        dialog.width = System.width;
        dialog.height =  6 * settings.day.height + settings.title.height + self._res.titleBar.height;
        dialog.top = System.height - dialog.height;
    
        var paint = new Paint();
        paint.color = 0x7f0f0f0f;
        paint.style = #fill;
        dialog._overlayPaint = paint;
        dialog._overlayCancel = this._getBitmap(self._res.dialog.cancel);
    
        var layout = new Moscrif.StackLayout();
        layout.orientation = #vert;
        layout.align = #stretch;
        dialog.layout = layout;
    }
    
    function drawCalendarDialogOverlay(canvas, dialog)
    {
        canvas.drawRect(0, 0, System.width, System.height, dialog._overlayPaint);
        var bmp = dialog._overlayCancel;
        canvas.drawBitmap(bmp, (System.width - bmp.width)/2, dialog.top - bmp.height*3/2);
    }
    
    /* ***** Keyboard ***** */
    
    function initKeyboard(keyboard)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.keyboard;
        keyboard.width = System.width;
        keyboard.height = settings.height;
    
        var paint = new Paint();
        this._setBackgroundPaint(paint, settings.background);
        keyboard._bgPaint = paint;
    }
    
    function drawKeyboard(canvas, keyboard)
    {
        canvas.drawRect(0, 0, keyboard.width, keyboard.height, keyboard._bgPaint);
    }
    
    function initKeyboardButton(button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.keyboardButton;
        button.height = settings.height;
        button.width = settings.width;
        function _getButtonUnitWidth(btn)
        {
            switch(btn) {
                case #shift: case #back : case #altABC: case #alt123: case #altSYM: case #enter: return 1.45;
                case #space: return 3;//2.5;
            }
            if (typeof btn == #string) return btn.length;
            return 1;
        }
        var unitWidth = _getButtonUnitWidth(button.text);
        var newWidth = Math.ceil(unitWidth * settings.width);
        //logI(button.text, unitWidth, newWidth);
        button.width = newWidth;
    
        settings = settings[button.kind];
        button._bg = this._getBitmap(settings.nine, true);
    
        var paint = new Paint();
        this._setTypeface(paint, settings.font);
        button._fg = paint;
    }
    
    function drawKeyboardButton(canvas, button)
    {
        canvas.drawBitmapNine(button._bg, 0, 0, button.width, button.height);
        const depth = System.width / 240;
        var (dx, dy) = button.pressed ? (depth, depth) : (0, 0);
        var t = button.text;
        if (typeof t == #string)
            this._drawCenteredText(canvas, button._fg, t, button, #center, #center, dx, dy);
        else {
            t = this._getBitmap("kb-" + t.toString() + ".png", true);
            if (t) canvas.drawBitmap(t, dx + (button.width - t.width) / 2, dy + (button.height - t.height) / 2);
        }
    }
    
    /* ***** NumericKeyboard ***** */
    
    function initNumericKeyboard(keyboard)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.numericKeyboard;
        keyboard.width = System.width;
        keyboard.height = settings.height;
    
        //var paint = new Paint();
        //this._setBackgroundPaint(paint, settings.background);
        //keyboard._bgPaint = paint;
    
        var layout = new StackLayout();
        layout.orientation = #vert;
        layout.align = #stretch;
        layout.pack = #start;
        keyboard.layout = layout;
    }
    
    function drawNumericKeyboard(canvas, keyboard)
    {
    //var p = new Paint();
    //p.color = 0xaa0000ff;
    //canvas.drawRect(0, 0, keyboard.width, keyboard.height, keyboard._bgPaint);
    }
    
    function initNumericKeyboardButton(button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.numericKeyboardButton;
        button.width = System.width / 3;
        button.height = settings.height;
        button.stretch = #both;
        //logI("initNumericKeyboardButton", button);
    
        var paint = new Paint();
        this._setBackgroundPaint(paint, settings.normal.background);
        button._bgPaint = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.normal.font);
        button._fgPaint = paint;
    
        if (typeof button.text == #symbol) {
            button.icon = this._getBitmap(settings.icons[button.text]);
        }
    }
    
    function drawNumericKeyboardButton(canvas, button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.numericKeyboardButton;
    
        const depth = System.width / 240;
        var (dx, dy) = button.pressed ? (depth, depth) : (0, 0);
    
        this._drawBackground(canvas, button._bgPaint, settings.normal.background, button);
    
        if (typeof button.text == #symbol) {
            var bmp = button.icon;
            canvas.drawBitmap(bmp, (button.width-bmp.width)/2 + dx, (button.height-bmp.height)/2 + dy);
        } else {
            this._drawCenteredText(canvas, button._fgPaint, button.text||"?", button, #center, #center, dx, dy);
        }
    }
    
    /* ***** Menu ***** */
    
    function initMenu(menu)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.menu;
    
        menu.width = System.width / 10 * 9;
    
        var paint = new Paint();
        paint.color = 0x7f0f0f0f;
        paint.style = #fill;
        menu._overlayPaint = paint;
        menu._overlayCancel = this._getBitmap(self._res.dialog.cancel);
    
        var layout = new StackLayout();
        layout.align = #stretch;
        layout.pack = #start;
        layout.orientation = #vert;
        menu.layout = layout;
    }
    
    function drawMenuOverlay(canvas, menu)
    {
        canvas.drawRect(0, 0, System.width, System.height, menu._overlayPaint);
        var bmp = menu._overlayCancel;
        canvas.drawBitmap(bmp, (System.width - bmp.width)/2, menu.top - bmp.height*3/2);
    }
    
    function drawMenu(canvas, menu)
    {
        var p = new Paint();
        p.color = 0xa1ff0000;
        p.style = #fill;
        canvas.drawRect(0, 0, menu.width, menu.height, p);
    }
    
    function initMenuItem(menuItem)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.menuItem;
        menuItem.stretch = #horz;
        menuItem.height = settings.height;
    }
    
    function drawMenuItem(canvas, menuItem)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.menuItem;
        var alt = menuItem.pressed ? settings.pressed : settings.normal;
    
        this._drawGradientBackground(canvas, alt.background, menuItem);
    
        const depth = System.width / 240;
        var (dx, dy) = menuItem.pressed ? (depth, depth) : (0, 0);
    
        var paint = new Paint();
        this._setTypeface(paint, alt.font);
        this._drawCenteredText(canvas, paint, menuItem.text||"", menuItem, #center, #center, dx, dy);
    }
    
    /* ***** Text Controls ***** */
    
    function initTextBox(textBox)
    {
        if (!textBox.multiLine)
            textBox.height = 40;
        else textBox.height = 400;
    
        var paint = new Paint();
        paint.textSize = 18;
        paint.antiAlias = true;
        paint.color = 0xff000000;
        textBox.paint = paint;
    
        paint = new Paint();
        paint.color = 0xff000000;
        paint.style = #stroke;
        textBox._cursorPaint = paint;
    }
    
    function drawTextBox(canvas, textBox)
    {
    }
    
    function drawTextBoxCursor(canvas, textBox, left, top, right, bottom)
    {
        var mode = textBox._mode;
        mode == #insert
            ? canvas.drawLine(right, top, right, bottom, textBox._cursorPaint)
            : canvas.drawRect(left, top, right, bottom, textBox._cursorPaint);
    }
    
    /* ***** TitleBar ***** */
    
    function initTitleBar(titleBar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.titleBar;
        titleBar.height = settings.height;

        const gap = Integer.min(System.width, System.height) / 50;

        var layout = new Moscrif.StackLayout();
        layout.align = #center;
        layout.pack = #start;
        layout.orientation = #horz;
        layout.setMargin(gap, 0, gap, 0);
        layout.spacer = gap;
        titleBar.layout = layout;
        
        var paint = new Paint();
        this._setTypeface(paint, settings.font);
        titleBar._fg = paint;
    }
    
    function drawTitleBarBg(canvas, titleBar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.titleBar;
        
        this._drawGradientBackground(canvas, settings.background, titleBar);
        
        var t = titleBar.text;
        var (w, h) = titleBar._fg.measureText(t);
        var y = /*(titleBar.height - h) / 2;*/ (titleBar.height - titleBar._fg.fontDescent - titleBar._fg.fontAscent) / 2;
        var x = (titleBar.width - w) / 2;
        canvas.drawText(t, x, y, titleBar._fg);
    }
    
    function initTitleBarButton(button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.titleBar;
        button.height = settings.button.height;
        if (button.kind == #space) button.stretch = #horz;
        
        var paint = new Paint();
        this._setTypeface(paint, settings.font);
        button._fg = paint;
    }
    
    function drawTitleBarButton(canvas, button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.titleBar;
        if (button.kind == #space) {
            this._drawCenteredText(canvas, button._fg, button.text, button, #center, #center);
            return;
        }
        var bitmap = button.kind instanceof Bitmap ? button.kind : this._getBitmap(typeof button.kind == #symbol ? settings.button[button.kind] : button.kind, true);
        canvas.drawBitmapNine(bitmap, 0, 0, button.width, button.height);

        const depth = System.width / 240;
        var (dx, dy) = button.pressed ? (depth, depth) : (0, 0);

        if (button.text) {
            var paint = new Paint();
            this._setTypeface(paint, settings.button.font);
            this._drawCenteredText(canvas, paint, button.text, button, #center, #center, dx + (button.kind == #back ? 5 : -5), dy);
        }
    }
    
    /* ***** ToolBar ***** */
    
    function initToolBar(bar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.toolBar;
        bar.height = settings.height;
        var layout = new Moscrif.StackLayout();
        layout.align = #center;
        layout.pack = #center;
        layout.orientation = #horz;
        bar.layout = layout;
    }
    
    function drawToolBar(canvas, bar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.toolBar;
    
        this._drawGradientBackground(canvas, settings.background, bar);
    }
    
    function initToolBarButton(button)
    {
        var self = MoscrifSkin.instance;
        var barSettings = self._res.toolBar;
    
        button.height = barSettings.height;
        button.width = System.width / 3;
    }
    
    function drawToolBarButton(canvas, button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.toolBarButton;
    
        const depth = System.width / 240;
        var (dx, dy) = button.pressed ? (depth, depth) : (0, 0);
    
        if (button.pressed)
            this._drawGradientBackground(canvas, settings.pressed, button);
        else if (button.highlight)
            this._drawGradientBackground(canvas, settings.highlight, button);
    
        if (typeof button.icon == #function) {
            button.icon(canvas, button);
            return;
        }
    
        // should be Path or better image resize
        var bitmap = self._getBitmap(String.printf("ico_%s.png", button.icon));
        if (!bitmap) return;
        dx += (button.width - bitmap.width) / 2;
        var hasText = (button.text||"").length != 0;
        if (!hasText)
            dy += (button.height - bitmap.height) / 2;
        canvas.drawBitmap(bitmap, dx, dy);
        if (hasText) {
            var paint = new Paint();
            this._setTypeface(paint, settings.font);
            dy += bitmap.height;
            this._drawCenteredText(canvas, paint, button.text||"", button, #center, dy);
        }
    }
    
    /* ***** TabBar ***** */
    
    function initTabBar(bar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.tabBar;
        bar.height = settings.height;
    
        var paint = new Paint();
        this._setBackgroundPaint(paint, settings.background);
        bar._bg = paint;
    
        var layout = new StackLayout();
        layout.align = #center;
        layout.pack = #center;
        layout.orientation = #horz;
        bar.layout = layout;
    }
    
    function drawTabBar(canvas, bar)
    {
        this._drawGradientBackground(canvas, bar._bg, bar);
    }
    
    function initTabBarItem(tab)
    {
        var self = MoscrifSkin.instance;
        var barSettings = self._res.tabBar;
        var settings = self._res.tabBarItem;
    
        tab.height = barSettings.height;
        tab.width = System.width / 3;
    
        var paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.normal.font);
        tab._fgNormal = paint;
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.normal);
        tab._bgNormal = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.selected.font);
        tab._fgSelected = paint;
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.selected);
        tab._bgSelected = paint;
    }
    
    function drawTabBarItem(canvas, tab)
    {
        var self = MoscrifSkin.instance;
        var barSettings = self._res.tabBar;
        var settings = self._res.tabBarItem;
    
        const depth = System.width / 240;
        var (dx, dy) = tab.pressed ? (depth, depth) : (0, 0);
        this._drawBackground(canvas,
            tab.selected ? tab._bgSelected : tab._bgNormal,
            (tab.selected ? settings.selected : settings.normal).background,
            tab.selected ? tab : {width: tab.width, height:tab.height - 3});
        this._drawCenteredText(canvas, tab.selected ? tab._fgSelected : tab._fgNormal, tab.text||"", tab, #center, #center, dx, dy);
    }
    
    /* ***** ListView ***** */
    
    function initListView(listView)
    {
        var layout = new Moscrif.StackLayout();
        layout.align = #start;
        layout.pack = #start;
        layout.orientation = #vert;
        listView.layout = layout;
    }
    
    function drawListViewBg(canvas, listView)
    {
    }
    
    function initListViewItem(listViewItem)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.listViewItem;
        listViewItem.stretch = #horz;
        listViewItem.height = settings.height;
    
        var paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.alternate.background);
        listViewItem._bgAlternate = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.normal.background);
        listViewItem._bgNormal = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.pressed.background);
        listViewItem._bgPressed = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.alternate.font);
        listViewItem._fgAlternate = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.normal.font);
        listViewItem._fgNormal = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.hint.font);
        listViewItem._hintPaint = paint;
    
        var layout = new Moscrif.StackLayout();
        layout.orientation = #horz;
        layout.align = #stretch;
        layout.pack = #end;
        listViewItem.layout = layout;
    }
    
    function drawListViewItem(canvas, listViewItem)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.listViewItem;
        var alt = ((listViewItem.clickable && listViewItem.pressed)
            ? settings.pressed
            : (listViewItem.alternate ? settings.alternate : settings.normal)).background;
    
        //this._drawGradientBackground(canvas, alt.background, listViewItem);
        this._drawBackground(canvas, (listViewItem.clickable && listViewItem.pressed)
            ? listViewItem._bgPressed
            : (listViewItem.alternate ? listViewItem._bgAlternate : listViewItem._bgNormal), alt, listViewItem);
    
        const depth = System.width / 240;
        var (dx, dy) = (listViewItem.clickable && listViewItem.pressed) ? (depth, depth) : (0, 0);
        var offY, offX = settings.margin;
        var icon = null, separator = this._getBitmap(settings.icon.separator);
        if (listViewItem.icon != null) {
            icon = listViewItem.icon instanceof Bitmap ? listViewItem.icon : this._getBitmap(listViewItem.icon, false);
            if (icon) offX += settings.icon.width; // + separator.width; // - settings.margin;
        }
    
        var text = listViewItem.text||"";
        if (text.length > 0) {
            canvas.save();
            var width = listViewItem.width;
            if (listViewItem.detail)
                width -= this._getBitmap(settings.icon.detail).width + 2*settings.margin;
            canvas.clipRect(offX, 0, width, listViewItem.height);
            if (listViewItem.ownerDraw)
                listViewItem.ownerDraw(canvas, offX, 0, width, listViewItem.height);
            else
                this._drawCenteredText(canvas, listViewItem.alternate ? listViewItem._fgAlternate : listViewItem._fgNormal, text, listViewItem, offX, #center, dx, dy);
            canvas.restore();
        } else {
            if (listViewItem._drawHint && (listViewItem.hint||"").length) {
                var (w, h) = listViewItem._hintPaint.measureText(listViewItem.hint);
                canvas.drawText(listViewItem.hint,
                    listViewItem.width - w - settings.margin,
                    ((listViewItem.height - h) / 2) - listViewItem._hintPaint.fontDescent - listViewItem._hintPaint.fontAscent,
                    listViewItem._hintPaint);
            }
        }
    
        if (icon) {
            //this._drawGradientBackground(canvas, settings.icon.background, {width: 70, height: 70});
            offY = (listViewItem.height - icon.height) / 2;
            offX = (settings.icon.width - icon.width) / 2;
            canvas.drawBitmap(icon, dx + offX, dy + offY);
            if (!(listViewItem.clickable && listViewItem.pressed))
                canvas.drawBitmap(separator, settings.icon.width - separator.width, 0);
        }
    
        if (listViewItem.detail) {
            icon = this._getBitmap(settings.icon.detail);
            if (icon) {
                offY = (listViewItem.height - icon.height) / 2;
                canvas.drawBitmap(icon, dx + listViewItem.width - icon.width - settings.margin, dy + offY);
            }
        }
    }
    
    function initListViewItemEditor(listViewItemEditor)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.listViewItem;
        var alt = settings.normal;
        listViewItemEditor.height = settings.height;
        listViewItemEditor.stretch = #horz;
    
        var label = listViewItemEditor.label;
        label.width = settings.label.width;
        label.stretch = #vert;
        label.horzAlign = #left;
        label.vertAlign = #middle;
        var paint = new Paint();
        this._setTypeface(paint, alt.font);
        label.paint = paint;
    
        var textBox = listViewItemEditor.textBox;
        textBox.stretch = #both;
        textBox.horzAlign = #left;
        textBox.vertAlign = #middle;
        paint = new Paint();
        this._setTypeface(paint, settings.editor.font);
        textBox.paint = paint;
    
        //textBox.marginX = textBox.marginY = 15;
    
        var layout = new Moscrif.StackLayout();
        var margin = settings.margin;
        layout.setMargin(margin, 0, margin, 0);
        layout.orientation = #horz;
        layout.align = #stretch;
        listViewItemEditor.layout = layout;
    }
    
    function initListViewItemPicker(listViewItemPicker)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.listViewItem;
    
        this.initListViewItemEditor(listViewItemPicker);
        listViewItemPicker._view.performLayout();
    
        var textBox = listViewItemPicker.textBox;
        //textBox.horzAlign = #right;
        textBox.stretch = #both;
        textBox.readOnly = true;
        textBox.focusable = false;
        /////////////////////!!!
        textBox._view.dockContent = #left;
    
        var button = listViewItemPicker.button;
        button.width = settings.icon.width;
        //button.height = settings.icon.height;
        button.stretch = #vert;
        button.icon = #listViewItem-next; // settings.icon.detail;
        //logI("BUTTON\n", button, "\nICON\n", button.icon);
    }
    
    function initListViewItemButton(button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.listViewItem;
        button.left = button.top = 0;
        button.width = settings.icon.width + 10; /* separator */
        button.height = settings.icon.height;
        button.stretch = #vert;
    }
    
    function drawListViewItemButton(canvas, button)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.listViewItem;
    
        const depth = System.width / 240;
        var (dx, dy) = button.pressed ? (depth, depth) : (0, 0);
    
        var icon = this._getBitmap(button.icon, false);
        assert icon != null;
        if (icon) {
            var separator = this._getBitmap(settings.icon.separator);
            var x = (button.width - icon.width) / 2;
            var y = (button.height - icon.height) / 2;
            canvas.drawBitmap(separator, 0, 0);
            canvas.drawBitmap(icon, dx + 10 + x, dy + y);
        }
    }
    
    /* ***** TileView ***** */
    
    function initTileView(tileView)
    {
        var layout = new Moscrif.StackLayout();
        layout.align = #start;
        layout.pack = #start;
        layout.orientation = #vert;
        tileView.layout = layout;
    }
    
    function drawTileViewBg(canvas, tileView)
    {
    }
    
    function initTileViewRow(tileViewRow)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.tileViewItem;
        tileViewRow.height = settings.height;
    
        var layout = new Moscrif.StackLayout();
        layout.align = #stretch;
        layout.pack = #start;
        layout.orientation = #horz;
        tileViewRow.layout = layout;
    }
    
    function drawTileViewRow(canvas, tileViewRow)
    {
    }
    
    function initTileViewItem(tileViewItem)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.tileViewItem;
        tileViewItem.width = settings.width;
        tileViewItem.height = settings.height;
    
        var paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.alternate.background);
        tileViewItem._bgAlternate = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.normal.background);
        tileViewItem._bgNormal = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.pressed.background);
        tileViewItem._bgPressed = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.alternate.font);
        tileViewItem._fgAlternate = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.normal.font);
        tileViewItem._fgNormal = paint;
    }
    
    function drawTileViewItem(canvas, tileViewItem)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.tileViewItem;
        var alt = (tileViewItem.pressed ? settings.pressed : (tileViewItem.alternate ? settings.alternate : settings.normal)).background;
    
        //this._drawGradientBackground(canvas, tileViewItem.pressed ? settings.pressed : settings.background, tileViewItem);
        this._drawBackground(canvas, tileViewItem.pressed
            ? tileViewItem._bgPressed
            : (tileViewItem.alternate ? tileViewItem._bgAlternate : tileViewItem._bgNormal), alt, tileViewItem);
    
        var x, y;
        const depth = System.width / 240;
        var (dx, dy) = tileViewItem.pressed ? (depth, depth) : (0, 0);
        var text = tileViewItem.text||"";
    
        var icon = null;
        if (tileViewItem.icon)
            icon = tileViewItem.icon instanceof Bitmap
                ? tileViewItem.icon
                : this._getBitmap(icon, false);
    
        if (icon) canvas.drawBitmap(icon,
            (tileViewItem.width - icon.width)/2 + dx,
            text.length == 0 ? ((tileViewItem.height - icon.height)/2 + dy) : dy);
    
        var paint = tileViewItem.alternate ? tileViewItem._fgAlternate : tileViewItem._fgNormal;
        this._drawCenteredText(canvas, paint, text, tileViewItem, #center, (icon ? icon.height + paint.fontBottom : #center), dx, dy);
    }
    
    
    /* ***** CalendarView ***** */
    
    function initCalendarView(calendar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.calendarView;
    
        var layout;
    
        layout = new Moscrif.StackLayout();
        layout.align = #stretch;
        layout.pack = #start;
        layout.orientation = #horz;
        calendar.title.height = settings.title.height;
        calendar.title.stretch = #horz;
        calendar.title.layout = layout;
    
        layout = new Moscrif.StackLayout();
        layout.align = #stretch;
        layout.pack = #start;
        layout.orientation = #vert;
        calendar.content.stretch = #horz;
        calendar.content.height = settings.day.height * 6;
        calendar.content.layout = layout;
    
        var paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.title);
        //paint.alpha = 54;
        calendar._titlePaint = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.title.font);
        calendar._titleDayPaint = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.day.normal);
        calendar._normalDayPaintBg = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.day.normal.font);
        calendar._normalDayPaintFg = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.day.weekend);
        calendar._weekendDayPaintBg = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.day.weekend.font);
        calendar._weekendDayPaintFg = paint;
    
        paint = new Paint();
        this._setBackgroundPaint(paint, settings.day.selected);
        calendar._selectedDayPaintBg = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.day.selected.font);
        calendar._selectedDayPaintFg = paint;
    
        paint = new Paint();
        this._setTypeface(paint, settings.day.disabled);
        calendar._disabledDayPaintFg = paint;
    }
    
    function drawCalendarView(canvas, calendar)
    {
    }
    
    function drawCalendarViewTitle(canvas, calendar)
    {
        var self = MoscrifSkin.instance;
        var settings = self._res.calendarView;
        this._drawBackground(canvas, calendar._titlePaint, settings.title, calendar.title);
    }
    
    function drawCalendarViewContent(canvas, calendar)
    {
    }
    
    function drawCalendarViewTitleDay(canvas, calendar, day)
    {
        this._drawCenteredText(canvas, calendar._titleDayPaint, day.text, day);
    }
    
    function drawCalendarViewDay(canvas, calendar, day)
    {
        //logI("drawCalendarViewDay", day.name, day.text);
        var self = MoscrifSkin.instance;
        var settings = self._res.calendarView.day;
        settings = day.weekend ? settings.weekend : settings.normal;
    
        var bg = day.selected
            ? calendar._selectedDayPaintBg
            : (day.weekend ? calendar._weekendDayPaintBg : calendar._normalDayPaintBg);
        var fg = day.selected
            ? calendar._selectedDayPaintFg
            : (day.weekend ? calendar._weekendDayPaintFg : calendar._normalDayPaintFg);
    
        if (calendar.kind == #day && !day.actualMonth) fg = calendar._disabledDayPaintFg;
    
        var x, y;
        const depth = System.width / 240;
        var (dx, dy) = day.pressed ? (depth, depth) : (0, 0);
    
        this._drawBackground(canvas, bg, settings, day);
        this._drawCenteredText(canvas, fg, day.text, day, #center, #center, dx, dy);
    }

}
