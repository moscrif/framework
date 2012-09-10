MetroSkin.initComboBox = function(item)
{
    var theme = this.theme.getStyle("comboBox");
    //set foreground
    this._setTypeface(item.fg, theme.fg, item.style.fg);

    //set background
    item.bg = item.style.bg ? item.style.bg : theme.bg;

    item.borderColor = item.style.borderColor ? item.style.borderColor : theme.borderColor;
}

MetroSkin.drawComboBox = function(item, canvas)
{
    this._drawBgDecorator(item, canvas);
    canvas.drawRect(0, 0, item.width, item.height, item._border);
}