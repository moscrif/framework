include "code://core/animation/animator.ms"
include "code://ui/form.ms"

class Application
{
    var instance = null; // this is static
    
    function this(name = "application", skin = null)
    {
        assert Application.instance == null;
        Application.instance = this;

        this._forms = new Array();
        this._skin = skin || new MoscrifSkin();
        this._terminate = false;
        this._animation = false;
        this.onDraw = null;
        this.onAfterDraw = null;

        this._window = new Moscrif.Window(name);
        this._window._script = this;
        this._window.onProcess = function(sender)
        {
            var self = this super;
            if (typeof self._onProcessHandler == #function)
                    self._onProcessHandler(self);
            return this super._terminate ? 0 : 1;
        }
        this._window.onDraw = function(sender, canvas)
        {
            if (sender._script.onDraw) {
                sender._script.onDraw(sender, canvas);
            } else {
                var skin = Application.instance.skin;
                skin.drawApplication(sender._script, canvas);
            }
        }
        this._window.onPointerPressed = function(sender, x, y)
        {
            /*var keyboard = this super._keyboard;

            if (keyboard.shown == true) {
                keyboard.hide();
                keyboard.onKey = null;
            }*/
        }

        this._window.onAfterDraw = :sender, canvas { if (sender._script.onAfterDraw) sender._script.onAfterDraw(sender._script, canvas); };
        this._skin.initApplication(this);
    }

    property home(v) { get return System.home() + System.applicationId ;}

    property native(v) { get return this._window; }

    property skin(v) { get return this._skin; }

    property layout(v)
    {
        get return this._window.layout;
        set this._window.layout = v;
    }

    property onStart(v)
    {
        get { return this._onStartHandler; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onStartHandler = v;
            this._window.onStart = function(sender)
            {
                var self = this super;
               // self.add(self._keyboard, #front);

                if (typeof self._onStartHandler == #function)
                    self._onStartHandler(self);
            }
        }
    }

    property onProcess(v)
    {
        get { return this._onProcessHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onProcessHandler = v;
        }
    }

    property onQuit(v)
    {
        get { return this._onQuitHandler; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onQuitHandler = v;
            this._window.onQuit = function(sender)
            {
                var self = this super;
                if (typeof self._onQuitHandler == #function)
                    self._onQuitHandler(self);
            }
        }
    }

    property onPointerPressed(v)
    {
        get { return this._onPointerPressed; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onPointerPressed = v;
            this._window.onPointerPressed = function(sender, x, y)
            {
                var self = this super;
                if (typeof self._onPointerPressed == #function)
                    self._onPointerPressed(self, x, y);
            }
        }
    }

    property onPointerDragged(v)
    {
        get { return this._onPointerDragged; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onPointerDragged = v;
            this._window.onPointerDragged = function(sender, x, y)
            {
                var self = this super;
                if (typeof self._onPointerDragged == #function)
                    self._onPointerDragged(self, x, y);
            }
        }
    }

    property onPointerReleased(v)
    {
        get { return this._onPointerReleased; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onPointerReleased = v;
            this._window.onPointerReleased = function(sender, x, y)
            {
                var self = this super;
                if (typeof self._onPointerReleased == #function)
                    self._onPointerReleased(self, x, y);
            }
        }
    }

    property onKeyPressed(v)
    {
        get { return this._onKeyPressedHandler; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onKeyPressedHandler = v;
            this._window.onKeyPressed = v ? function(sender, key)
            {
                var self = this super;
                if (typeof self._onKeyPressedHandler == #function)
                    self._onKeyPressedHandler(self,key);
            } : null;
        }
    }

    property onKeyReleased(v)
    {
        get { return this._onKeyReleasedHandler; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onKeyReleasedHandler = v;
            this._window.onKeyReleased = v ? function(sender, key)
            {
                var self = this super;
                if (typeof self._onKeyReleasedHandler == #function)
                    self._onKeyReleasedHandler(self, key);
            } : null;
        }
    }

    property onChar(v)
    {
        get { return this._onCharHandler; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onCharHandler = v;
            this._window.onChar = v ? function(sender, char)
            {
                var self = this super;
                if (typeof self._onCharHandler == #function)
                    self._onCharHandler(self, char);
            } : null;
        }
    }

    property onResize(v)
    {
        get { return this._onResize; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onResize = v;
            this._window.onResize = v ? function(sender, width, height)
            {
                var self = this super;
                if (typeof self._onResize == #function)
                    return self._onResize(self, width, height);
            } : null;
        }
    }

    property onCanChangeOrientation(v)
    {
        get { return this._onCanChangeOrientation; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onCanChangeOrientation = v;
            this._window.onCanChangeOrientation = v ? function(sender, mode)
            {
                var self = this super;
                if (typeof self._onCanChangeOrientation == #function)
                    return self._onCanChangeOrientation(self, mode);
            } : null;
        }
    }

    property onOrientationChanged(v)
    {
        get { return this._onOrientationChanged; }
        set
        {
            assert (v == null) || (typeof v == #function);
            this._onOrientationChanged = v;
            this._window.onOrientationChanged = v ? function(sender, mode)
            {
                var self = this super;
                if (typeof self._onOrientationChanged == #function)
                    self._onOrientationChanged(self, mode);
            } : null;
        }
    }

    function init(allowFPS = false)
    {
        this._window.init(allowFPS);
        return this;
    }

    function run()
    {
        this._window.run();
        return this;
    }

    function quit()
    {
        this._terminate = true;
    }

    function suspendLayout()
    {
        this._window.suspendLayout();
    }

    function resumeLayout()
    {
        this._window.resumeLayout();
    }

    function performLayout()
    {
        this._window.performLayout();
    }

    // Purpose of this function is to add ANY view to form

    function add(view, order = #front)
    {
        assert view != null : "Instance expected";
        this._window.add(view.native ? view.native : view, order);
    }

    // push/pop functions are designed to add Forms to application using navigation (back <-> forward)

    function _raiseFormsChanged()
    {
        //logI("forms changed", this._forms.length);
    }

    function push(form, order = #front)
    {
        assert form != null : "Instance expected";
        assert form instanceof Form : "Form expected";
        form.visible = true;
        for (var f in this._forms)
            f.visible = false;
        this._forms.push(form);
        this._raiseFormsChanged();
        form.raiseOnActivate(this);
        this._window.add(form.native ? form.native : form, order);
    }

    function pushWithAnim(form, order = #front, subject)
    {
        if (this._animation)
            return;

        if (this._forms.length == 0) {
            this.push(form, order);
            this._raiseFormsChanged();
            return;
        }

        this._animation = true;

        assert form != null : "Instance expected";
        assert form instanceof Form : "Form expected";

        var previousForm = this.peek();
        previousForm.suspendDrawing();

        //assert this._forms.filter(:x :x.name === form.name).length === 0;
        this._forms.push(form);
        this._raiseFormsChanged();
        form.raiseOnActivate(this);
        var existing = this._window.find(form.name);
        if (existing == null)
            this._window.add(form.native ? form.native : form, order);
        else {
            var tmp = existing.left;
            existing.left = 0;
            existing.suspendDrawing();
            existing.left = tmp;
        }

        var self = this;
        form.suspendDrawing();
        subject.reset(previousForm);

        var animator = new Animator({
            duration: 550,
            transition: Animator.Transition.easeOut,
            onComplete: function() {
                for (var f in self._forms) {
                    if (f === form) {
                        form.resumeDrawing();
                        break;
                    }
                }
                //previousForm.resumeDrawing();
                this super._animation = false;
            }
        });
        animator.addSubject(/*slide*/subject);
        animator.play();
    }

    // returns poped form

    function pop(detach = true, quitWhenEmpty = true)
    {
        if (this._forms.length == 0) {
            if (quitWhenEmpty)
                this.quit();
            return null;
        }

        //make all forms invisible
        for (var f in this._forms)
            f.visible = false;

        var form = this._forms.pop();
        this._raiseFormsChanged();
        form.raiseOnDeactivate(this);
        if (detach)
            form.detach();
        if (this._forms.length == 0) {
            if (quitWhenEmpty)
                this.quit();
            return null;
        }
        var activeForm = this._forms[this._forms.length - 1];
        activeForm.raiseOnActivate(this);
        activeForm.visible = true;
        return form;
    }

    function popWithAnim(detach = true, subject, quitWhenEmpty = true)
    {
        if (this._animation)
            return;

        if (this._forms.length <= 1) {
            var ret = this.pop();
            this._raiseFormsChanged();
            return ret;
        }

        this._animation = true;

        var form = this._forms.pop();
        this._raiseFormsChanged();
        form.raiseOnDeactivate(this);
        if (this._forms.length == 0) {
            if (detach)
                form.detach();
            if (quitWhenEmpty)
                this.quit();
            return null;
        }

        form.suspendDrawing();

        var activeForm = this._forms[this._forms.length - 1];
//!        activeForm.visible = true;
var tmp = activeForm.left;
activeForm.left = 0;
        activeForm.suspendDrawing();
activeForm.left = tmp;

        subject.attach(form);
        subject.reset(activeForm);

        var animator = new Animator({
            duration: 550,
            transition: Animator.Transition.easeOut,
            onComplete: function() {
                form.resumeDrawing();
//                form.visible = false;
                if (detach)
                    form.detach();
                activeForm.resumeDrawing();
                //logI("activeForm", activeForm.native);
                this super._animation = false;
            }
        });

        animator.addSubject(/*slide*/subject);
        animator.play();

        activeForm.raiseOnActivate(this);
//!        activeForm.visible = true;
        return form;
    }

    function replace(form, detach = true)
    {
        assert form != null : "Instance expected";
        assert form instanceof Form : "Form expected";
        this.pop(detach, false);
        this.push(form, #front);
    }

    // returns active (last) form
    function peek()
    {
        if (this._forms.length == 0)
            return null;
        var activeForm = this._forms[this._forms.length - 1];
        assert activeForm.visible == true;
        return activeForm;
    }

    /*
    function showKeyboard()
    {
    	if (this._keyboard == null) this._createKeyboard();
    	this.add(this._keyboard);
    	//this._window.doLayout();
    }

    function hideKeyboard()
    {
    }

    function _createKeyboard()
    {
    	var skin = this._skin;
    	this._keyboard = new Keyboard(null);

    	skin.initKeyboard(this._keyboard);
    }
    */

    function invalidate(args..)
    {
        if (args.length == 0) {
            this._window.invalidate();
            return;
        }
        assert args.length == 4;
        this._window.invalidate(args[0], args[1], args[2], args[3]);
    }

}