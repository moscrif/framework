include "code://ui/tools.ms"

class TitleBar
{
    var counter = 0; // static!

    function this(name = null, text = null)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this._view = new Moscrif.View(name || String.printf("titleBar#%d", TitleBar.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.stretch = #horz
        this._view.height = 70;
        this._view.onDraw = function(sender, canvas)
        {
            skin.drawTitleBarBg(canvas, sender._script);
        };
        _addViewProperties(this);
        skin.initTitleBar(this);
    }

    property native(v) { get return this._view }

    property text(v)
    {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
    }

    function add(view)
    {
        assert view != null || view.native != null;
        this._view.add(view.native || view, #front);
    }

}