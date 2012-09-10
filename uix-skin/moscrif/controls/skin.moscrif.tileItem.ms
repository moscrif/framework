MoscrifSkin.initTileItem = function(control)
{

    // get access to theme object
    var theme = this.theme.getStyle("tileItem");
    control._setDefaults(theme);

}

MoscrifSkin.drawTileItem = function(control, canvas)
{
    // move canvas for good animation
    var leftMove = 0;
    var topMove = 0;
    var fgPaint = control.clicked?control.pressed.fg:control.fg;
    var bgPaint = control.clicked?control.pressed.bg:control.bg;


    /*** draw backgound ***/
    this._drawBackground(control, canvas, { bg : bgPaint, left : leftMove, top : topMove });

    /*** draw icon ***/
    if (control.icon.source != null) {
       // because of stretch = #both dimensions may be changed also without width and height property
       control.icon.height = (0.53 * control.height).toInteger();
       // vector image should have same color as text
       control.icon.paint = control.fg.native;
       control.icon.drawImage(canvas, leftMove + (control.width - control.icon.width) / 2, topMove + (control.height - control.icon.height) / 2);
    }

    if (control.badge != null)
    {
        control.badge.left = control.width - control.badge.width - this._gap;
        control.badge.top = this._gap;

    }
    if (control.text != null)
        canvas.drawText(control.text, leftMove + this._gap / 2, topMove + control.height - this._gap / 2, fgPaint.native);
}