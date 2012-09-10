MetroSkin.initSwitchButton = function(item)
{
    var theme = this.theme.getStyle("switchButton");

    item.width = item.style.width ? item.style.width : theme.width;
    item.height = item.style.height ? item.style.height : theme.height;
    var borderWidth = item.style.borderWidth ? item.style.borderWidth : theme.borderWidth;

    // set on off image aond it's position
    item.imageOn = item.style.on ? item.style.on : theme.on;
    item.imageOff = item.style.off ? item.style.off : theme.off;
    item.skinVariablesButtonImageWidth = item.style.imageWidth ? item.style.imageWidth : theme.imageWidth;
    item.skinVariablesButtonImageHeight = item.style.imageHeight ? item.style.imageHeight : theme.imageHeight;

    item.skinVariablesImageBorder = new Paint();
    item.skinVariablesImageBorder.color = item.style.imageBorder ? item.style.imageBorder : theme.imageBorder;
    item.skinVariablesImageBorder.style = #stroke;
    item.skinVariablesImageBorder.strokeWidth = item.style.imageBorderWidth ? item.style.imageBorderWidth : theme.imageBorderWidth;

    //normal state
    this._setTypeface(item.fg, theme.normal.fg, item.style.normal.fg);
    item.bg = item.style.normal.bg ? item.style.normal.bg : theme.normal.bg;
    item.skinVariablesTextButtonNormalBorder = new Paint();
    item.skinVariablesTextButtonNormalBorder.style = #stroke;
    item.skinVariablesTextButtonNormalBorder.strokeWidth = borderWidth;
    item.skinVariablesTextButtonNormalBorder.color = item.style.normal.border ? item.style.normal.border : theme.normal.border;

    //pressed state
    this._setTypeface(item.fgPressed, theme.pressed.fg, item.style.pressed.fg);
    item.bgPressed = item.style.pressed.bg ? item.style.pressed.bg : theme.pressed.bg;
    item.skinVariablesTextButtonPressedBorder = new Paint();
    item.skinVariablesTextButtonPressedBorder.style = #stroke;
    item.skinVariablesTextButtonPressedBorder.strokeWidth = borderWidth;
    item.skinVariablesTextButtonPressedBorder.color = item.style.pressed.border ? item.style.pressed.border : theme.pressed.border;

    //disabled state
    this._setTypeface(item.fgDisabled, theme.disabled.fg, item.style.disabled.fg);
    item.bgDisabled = item.style.disabled.bg ? item.style.disabled.bg : theme.disabled.bg;
    item.skinVariablesTextButtonDisabledBorder = new Paint();
    item.skinVariablesTextButtonDisabledBorder.style = #stroke;
    item.skinVariablesTextButtonDisabledBorder.strokeWidth = borderWidth;
    item.skinVariablesTextButtonDisabledBorder.color = item.style.disabled.border ? item.style.disabled.border : theme.disabled.border;

}

MetroSkin.drawSwitchButton = function(item, canvas)
{
  var paintFg = (item.enabled?(item.pressed?item.fgPressed:item.fg):item.fgDisabled);
   var Bg = (item.enabled?(item.pressed?item.bgPressed:item.bg):item.bgDisabled);
   var paintBr = (item.enabled?(item.pressed?item.skinVariablesTextButtonPressedBorder:item.skinVariablesTextButtonNormalBorder):item.skinVariablesTextButtonDisabledBorder);
   var (w, h) = paintFg.measureText(item.text);
   var imageLeft = 2*this._gap;
   var imageTop = (item.height - item.skinVariablesButtonImageHeight) / 2;

    //draw background
    if (Bg.image.source == null) {
        canvas.drawRect(0, 0, item.width, item.height, Bg.native);
    } else {
        // because of stretch = #both dimensions may be changed also without width and height property
        Bg.image.resize(item.width, item.height);
        Bg.drawImage(canvas, 0, 0);
    }

    //console<<"drawing\n";
    if (item.checked) {
        if (item.imageOn.source == null) {
            canvas.drawRect(imageLeft, imageTop, item.skinVariablesButtonImageWidth + imageLeft, item.skinVariablesButtonImageHeight + imageTop, item.imageOn.native);
            canvas.drawRect(imageLeft, imageTop, item.skinVariablesButtonImageWidth + imageLeft, item.skinVariablesButtonImageHeight + imageTop, item.skinVariablesImageBorder);
        } else {
            // because of stretch = #both dimensions may be changed also without width and height property
            item.imageOn.image.resize(item.skinVariablesButtonImageWidth, item.skinVariablesButtonImageHeight);
            item.imageOn.drawImage(canvas, imageLeft, ImageTop);
        }
    } else {
        if (item.imageOff.source == null) {
            canvas.drawRect(imageLeft, imageTop, item.skinVariablesButtonImageWidth + imageLeft, item.skinVariablesButtonImageHeight + imageTop, item.imageOff.native);
            canvas.drawRect(imageLeft, imageTop, item.skinVariablesButtonImageWidth + imageLeft, item.skinVariablesButtonImageHeight + imageTop, item.skinVariablesImageBorder);
        } else {
            // because of stretch = #both dimensions may be changed also without width and height property
            item.imageOff.image.resize(item.skinVariablesButtonImageWidth, item.skinVariablesButtonImageHeight);
            item.imageOff.drawImage(canvas, imageLeft, imageTop);
        }
    }

   //choose paint by actual state


    //draw text
    canvas.drawText(item.text, item.width/2 - w/2, item.height/2 + h/2, paintFg);

    // draw border
    canvas.drawRect(0, 0, item.width, item.height, paintBr);
}