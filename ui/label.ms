#include "code://ui/tools.ms"

class Label
{
    var counter = 0; // static!
    function this(name = null, text, multiLine = false)
    {
        var skin = Application.instance.skin;
        
        //this._paint = new Paint();
        
        this._view = new Moscrif.TextView(name || String.printf("label#%d", Label.counter++));
        this._view._script = this;
        this._view.text = text;
        this._view.readOnly = true;
        this._view.multiLine = multiLine;
        this._view.autoSize = #fixed; //multiLine ? #height : #fixed;
        this._view.focusable = false;
        this._view.left = 0; this._view.top = 0;
        this._view.width = this._view.height = 100;
        this._view.paint = this._paint = new Paint();
        //this._view.onResize = :sender, width, height { logI("onResize", sender.name, width, height); sender.invalidate(); }
        this._view.onDraw = :sender, canvas :skin.drawLabel(canvas, sender._script);
        _addViewProperties(this);
        skin.initLabel(this);
    }
    property native(v) { get return this._view; }
    property name(v)
    {
        get return this._view.name;
    }
    property text(v)
    {
        get return this._view.text;
        set {
            this._view.text = v;
            this._view.invalidate();
        }
    }
    property multiLine(v)
    {
        get return this._view.multiLine;
        set {
            this._view.multiLine = v;
            this._view.invalidate();
        }
    }
    property autoSize(v)
    {
        get return this._view.autoSize;
        set {
            this._view.autoSize = v;
            this._view.invalidate();
        }
    }
    property vertAlign(v)
    {
        get return this._view.vertAlign;
        set {
            this._view.vertAlign = v;
            this._view.invalidate();
        }
    }
    property horzAlign(v)
    {
        get return this._view.horzAlign;
        set {
            this._view.horzAlign = v;
            this._view.invalidate();
            //this._view.paint.textAlign = v;
            //this._view.invalidate();
            //logI(v);
        }
    }
    property marginX(v)
    {
        get return this._view.marginX;
        set this._view.marginX = v;
    }
    property marginY(v)
    {
        get return this._view.marginY;
        set this._view.marginY = v;
    }
    property paint(v)
    {
        get { return this._paint; }
        set { this._paint = this._view.paint = v; }
    }
}
