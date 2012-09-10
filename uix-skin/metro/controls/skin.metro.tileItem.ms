 MetroSkin.initTileItem = function(item)
{
    // get access to theme object
    var theme = this.theme.getStyle("tileItem");

    item._setDefaults(theme);
    item.skinVariableView3D = new View3D();
    item.skinVariableView3D.save();
}

MetroSkin.drawTileItem = function(item, canvas)
{
    // move canvas for good animation
    var leftMove = 0;
    var topMove = 0;
    if(item.clicked) {
        // save unpressed canvas
        item.skinVariableView3D.save();
        // select good type of animation
        // in the midle of item we only pressed it
        logI("x", item._lastY);
        if (Math.abs(item._lastX-item.width / 2) < item.width / 8 && Math.abs(item._lastY-item.height / 2) < item.height / 8) {
            canvas.translate(item.width / 2, item.height / 2);
            leftMove = item.width / -2;
            topMove = item.height / -2;
            item.skinVariableView3D.translate(0, 0, 35);
        } else {
            // decide around which axis item rotate (first condition thanks to short evaluation, prevents division by zero)
            if (Math.abs(item.width / 2 - item._lastX) != 0 && 1.0*item.height / item.width > Math.abs(item.height / 2.0 - item._lastY) / Math.abs(item.width / 2 - item._lastX))
                // decide side of animation
                if (item._lastX - item.width / 2 < 0) {
                    canvas.translate(item.width, item.height / 2);
                    leftMove = item.width * -1;
                    topMove = item.height / -2;
                    item.skinVariableView3D.rotateY(-15 * item.height / item.width);
                } else {
                    canvas.translate(0, item.height / 2);
                    leftMove = 0;
                    topMove = item.height / -2;
                    item.skinVariableView3D.rotateY(15 * item.height / item.width);
                }
            else
                // decide side of animation
                if (item._lastY - item.height / 2 < 0) {
                    canvas.translate(item.width / 2, item.height);
                    leftMove = item.width / -2;
                    topMove = item.height * -1;
                    item.skinVariableView3D.rotateX(15);
                } else {
                    canvas.translate(item.width / 2, 0);
                    leftMove = item.width / -2;
                    topMove = 0;
                    item.skinVariableView3D.rotateX(-15);
                }
        }
    } else {
        // restore unpressed canvas
        item.skinVariableView3D.restore();
    }
    item.skinVariableView3D.applyToCanvas(canvas);
    /*** draw backgound ***/

    this._drawBgDecorator(item, canvas, leftMove, topMove, item.width, item.height);

    /*** draw icon ***/
    if (item.icon.source != null) {
       // because of stretch = #both dimensions may be changed also without width and height property
       item.icon.height = (0.53 * item.height).toInteger();
       // vector image should have same color as text
       item.icon.paint = item.fg.native;
       item.icon.drawImage(canvas, leftMove + (item.width - item.icon.width) / 2, topMove + (item.height - item.icon.height) / 2);
    }

    if (item.badge != null)
    {
        item.badge.left = item.width - item.badge.width - this._gap;
        item.badge.top = this._gap;

    }
    if (item.text != null)
        canvas.drawText(item.text, leftMove + this._gap / 2, topMove + item.height - this._gap / 2, item.fg.native);
}