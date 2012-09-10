include "code://ui/tools.ms"
include "code://ui/keyboardButton.ms"
include "code://ui/keyboardDefault.ms"

class Keyboard
{
    var counter = 0; // static!
    function this(name = null)
    {
        var skin = Application.instance.skin;
        
        this._view = new Moscrif.View(name || String.printf("keyboard[%d]", Keyboard.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = 0;
        this._view.width = this._view.height = 100;
        this._view.top = System.height - this._view.height;
        this._view.onDraw = :sender, canvas :skin.drawKeyboard(canvas, sender._script);
        
        _addViewProperties(this);
        skin.initKeyboard(this);
        
        new KeyboardDefault(this);
    }

    /*function show()
    {
        if(this._shown!=true){
            this.createKeyboard();
            this._application.add(this._view,#front);
            this._application.keyboard.form.native.height = System.height - this._view.height;
            this._shown = true;
            this._view.top = System.height - this._view.height;
        }
    }

    function hide()
    {
        this._shown = false;
        this._application.keyboard.form.native.height = System.height;
        this._view.detach();
    }*/

    property onKey(v)
    {
        get { return this._onKeyHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onKeyHandler = v;
        }
    }
    property name(v) { get return this._view.name; }

    property visible(v)
    {
        get return this._view.visible;
        set this._view.visible = v;
    }

    property shown(v)
    {
        get return this._shown;
        set this._shown = v;
    }

    property top(v)
    {
        get return this._view.top;
        set this._view.top = v;
    }

    property height(v)
    {
        get return this._view.height;
        set this._view.height = v;
    }

    property native(v)
    {
        get return this._view;
    }
}
