MetroSkin.initOverlay = function(item)
{
    var theme = this.theme.getStyle("overlay");
    item._setDefaults(theme);
}

MetroSkin.drawOverlay = function(item, canvas)
{
   this._drawBgDecorator(item, canvas);
}