 class Form
{
    var counter = 0; // static!

    function this(name = null)
    {
        var skin = Application.instance.skin;
        name = name || String.printf("form#%d", Form.counter++);
        this._view = new Moscrif.View(name);
        this._view._script = this;
        this._view.focusable = true;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = System.height;
        this._view.stretch = #both;
        this.onProcess = null;
        this._view.onProcess = function(sender)
        {
            var self = this super;
            if (typeof self.onProcess == #function)
                return self.onProcess(self);
            return 1;
        }
        this._onActivateHandler = null;
        this._onDeactivateHandler = null;
        this._view.onDraw = function(sender, canvas)
        {
            skin.drawFormBg(canvas, sender._script);
        }
        skin.initForm(this);
    }

    property native(v) { get return this._view; }

    property name(v) { get return this._view.name; }

    property left(v) { get return this._view.left; set this._view.left = v; }
    property top(v) { get return this._view.top; set this._view.top = v; }
    property width(v) { get return this._view.width; set this._view.width = v; }
    property height(v) { get return this._view.height; set this._view.height = v; }

    property layout(v) { get return this._view.layout; set this._view.layout = v; }

    property visible(v) { get return this._view.visible; set this._view.visible = v; }

    property onActivate(v)
    {
        get { return this._onActivateHandler; }
        set
        {
            assert typeof v == #function;
            this._onActivateHandler = v;
        }
    }

    function raiseOnActivate(sender)
    {
        if (typeof this._onActivateHandler == #function)
            this._onActivateHandler(sender);
    }

    property onDeactivate(v)
    {
        get { return this._onDeactivateHandler; }
        set
        {
            assert typeof v == #function;
            this._onDeactivateHandler = v;
        }
    }

    function raiseOnDeactivate(sender)
    {
        if (typeof this._onDeactivateHandler == #function)
            this._onDeactivateHandler(sender);
    }

    function suspendDrawing()
    {
        //logI("suspendDrawing", this._view.name);
        this._view.suspendDrawing();
    }

    function resumeDrawing()
    {
        //logI("resumeDrawing", this._view.name);
        this._view.resumeDrawing();
    }

    function suspendLayout()
    {
        this._view.suspendLayout();
    }

    function resumeLayout()
    {
        this._view.resumeLayout();
    }

    function performLayout()
    {
        this._view.performLayout();
    }

    function add(view, pos = #front)
    {
        var known = (view instanceof Moscrif.View) || (view instanceof Moscrif.ScrollView) || (view instanceof Moscrif.TextView);
        assert (view != null && view.native != null) || known;
        this._view.add(known ? view : view.native, pos);
    }

    function detach()
    {
        //logI("detaching", this.name)l
        this._view.detach();
    }

    function invalidate()
    {
        this._view.invalidate();
    }

}