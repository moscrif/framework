include "code://ui/tools.ms"
include "code://ui/label.ms"

class Dialog
{
    var counter = 0; // static!
    function this(name = null, text = null)
    {
        var skin = Application.instance.skin;
        name = name || String.printf("dialog[%d]", Dialog.counter++);
        this._text = text || "";
        this._clickable = true;
        this._pressed = 0;
        this._detail = false;

        this._overlay = new Moscrif.View(name + ".overlay");
        this._overlay._script = this;
        this._overlay.focusable = false;
        this._overlay.left = this._overlay.top = 0;
        this._overlay.width = System.width;
        this._overlay.height = System.height;
        this._overlay.onDraw = :sender, canvas {
            skin.drawDialogOverlay(canvas, sender._script);
        };

        this._view = new Moscrif.View(name);
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width / 2;
        this._view.height = System.height / 2;
        this._view.onDraw = :sender, canvas {
            skin.drawDialog(canvas, sender._script);
        };

        this._label = new Label(name + ".label", text, true);
        this._label._script = this;

        this._buttons = new Moscrif.View(name + ".buttons");
        this._buttons._script = this;
        this._buttons.focusable = false;
        this._buttons.stretch = #vert;

        this._overlay.add(this._view);
        this._view.add(this._buttons);
        this._view.add(this._label.native);

        _addViewProperties(this);
        skin.initDialog(this);
    }
    property name(v) { get return this._view.name; }
    property label(v) { get return this._label; }
    property buttons(v) { get return this._buttons; }
    function add(view)
    {
        assert view != null;
        assert view instanceof Button;
        var skin = Application.instance.skin;
        skin.initDialogButton(this, view);
        this._buttons.add(view.native, #front);
        return this;
    }
    function showModal()
    {
        var app = Application.instance;
        assert app != null && app instanceof Application;
        this.left = (System.width - this.width) / 2;
        this.top = (System.height - this.height) / 2;
        //logI(this._label);
        //logI("left", this._label.left, "top", this._label.top, "width", this._label.width, "height", this._label.height);
        app.add(this._overlay, #front);
    }
    function close()
    {
        this._overlay.detach();
    }
}
