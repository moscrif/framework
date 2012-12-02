include "lib://core/baseClass.ms"
include "lib://game2d/base/gameObject.ms"
include "lib://game2d/base/gameControl.ms"

/**
Game scene, object to define a scene what can consist with layers, sprites or buttons.
@class Scene
@module game2d
@example
    class Area : Scene
    {
        function init()
        {
            super.init();
            ...
        }
    
        function draw(canvas)
        {
            super.draw(canvas);
            ...
        }
    
        function pointerPressed(x, y)
        {
            super.pointerPressed(x, y);
            ...
        }
    
        function pointerReleased(x,y)
        {
            super.pointerReleased(x,y);
            ....
        }
    }
*/
class Scene : BaseClass
{
    /**
    Method is executed before inititialiation of the scene object. An empty array of childs is created.
    @method beforeInit
    @protected
    */
    function beforeInit()
    {
        super.beforeInit();
        this._objects = [];
        this._controls = [];
        this._childs = [];  // all objects and controls
        //this._onEnterHandler = null;
        //this._onExitHandler = null;
    }

    /**
    Access to array of scene's objects. This array contains object of {{#crossLink "GameObject"}}{{/crossLink}} only.
    @property objects
    @readOnly
    @type Array
    */
    property objects(v)
    {
        get return this._objects;
    }

    /**
    Access to array of scene's controls. This array contains object of {{#crossLink "GameControl"}}{{/crossLink}} only.
    @property controls
    @readOnly
    @type Array
    */
    property controls(v)
    {
        get return this._controls;
    }

    /**
    Access to array of all scene's childs (objects and controls together).
    @property childs
    @readOnly
    @type Array
    */
    property childs(v)
    {
        get return this._childs;
    }

    /**
    This property handler is called to deal with undefined properties. (Undefined Property Handler)
    @property undefined
    @param k {String} Name of undefined property
    @param v {Object} Value of undefined property.
    @type Object
    @example
        var scene = new Scene({});
        scene.add(new Sprite({name:"sprite1"});
        var ref = scene.sprite1; // sprite1 is not property of Scene. Thanks to UPH of Scene, Scene class will find it's child by name.
    */
    property undefined(k, v)
    {
        get {
            var name = k.toString();
            if (this.exists(#_childs, false)) {
                var child = this.findChild(name);
                if (child)
                    return child;
            }
            logW("[Scene.undefined] Property", name, "hasn't been set. Value to set:", v);
            //if (System.IS_DEBUG)
            //    debug stacktrace;
            return null;
        }
    }

    /**
    Find object (sprite) in the scene acording to it name.
    @method findObject
    @param name {String} name of the object
    @return Object or null
    @example
        var sprite = this.addPolygonBody(..);
        sprite.name = "car";
        this.add(sprite);
        this.findObject("car").applyAngularImpulse(10);
    */
    function findObject(name)
    {
        var objs = this._objects.filter(:x :x.name == name);
        if (objs.length == 1)
            return objs[0];
        return null;
    }

    /**
    Find control (button) in the scene acording to it name.
    @method findControl
    @param name {String} name of the object
    @return Control or null
    */
    function findControl(name)
    {
        var ctrls = this._controls.filter(:x :x.name == name);
        if (ctrls.length == 1)
            return ctrls[0];
        return null;
    }

    /**
    Find child in the scene acording to it name.
    @method findChild
    @param name {String} name of the object
    @return Child or null
    @example
        var sprite = this.addPolygonBody(..);
        sprite.name = "car";
        this.add(sprite);
        this.findChild("car").applyAngularImpulse(10);
    */
    function findChild(name)
    {
        var childs = this._childs.filter(:x :x.name == name);
        if (childs.length == 1)
            return childs[0];
        return null;
    }

    /**
    Add object to the scene
    @method add
    @param obj {GameControl|Sprite|Layer} Object to be stored in scene
    @chainable
    @example
        var sprite = new Sprite({image: fileName});
        this.add(sprite);
    */
    function add(obj)
    {
        assert obj != null;
        if (obj instanceof GameControl) {
            this._controls.push(obj);
            this._controls.sort(:a, b {return -a.z - b.z});
            this._childs.push(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else if (obj instanceof GameObject) {
            this._objects.push(obj);
            this._objects.sort(:a, b {return a.z - b.z});
            this._childs.push(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else {
            throw "[Scene.add] Unsupported object type";
        }
        return this;
    }

    /**
    Detach object from the scene
    @method detach
    @chainable
    @param obj {GameControl|Sprite|Layer} Object to be stored in scene
    */
    function detach(obj)
    {
        assert obj != null;
        if (typeof obj == #string)
            obj = this.findObject(obj) || this.findControl(obj);
        if (obj instanceof GameControl) {
            this._controls.removeByValue(obj);
            this._controls.sort(:a, b {return -a.z - b.z});
            this._childs.removeByValue(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else if (obj instanceof GameObject) {
            this._objects.removeByValue(obj);
            this._objects.sort(:a, b {return a.z - b.z});
            this._childs.removeByValue(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else {
            throw "[Scene.detach] Unsupported object type";
        }
        return this;
    }

    /**
    Process event, fire process event to all stored objects.
    @method process
    @protected
    */
    function process()
    {
        for (var child in this._childs)
            child.process();
    }

    /**
    Draw event, fire draw methods to all stored objects. This method can be overwrite to draw something onto scene. However it is important to call super.draw(canvas) in overwriten method.
    @method draw
    @protected
    @param canvas {Canvas} Current scene canvas
    @example
        function draw(canvas)
        {
            canvas.drawRect(0, 0, System.width, System.height, this._bg);
            super.draw(canvas);
        }
    */
    function draw(canvas)
    {
        assert canvas instanceof Canvas;
        canvas.save();
        for (var child in this._childs)
            child.draw(canvas);
        canvas.restore();
    }

    /**
    Event fired, when user tap the screen. This method can be overwrite to manage pointer pressed event. However it is important to call super.pointerPressed(x, y) in overwriten method.
    @method pointerPressed
    @protected
    @param x {Integer} x pointer X-coordinate
    @param y {Integer} y pointer Y-coordinate
    @example
        function pointerPressed(x, y)
        {
            super.pointerPressed(x, y);
    
            ...
        }
    */
    function pointerPressed(x, y)
    {
        for (var control in this._controls)
            if (control.visible && control.intersectsPoint(x, y))
                if (control.pointerPressed(x, y) === true)
                    return true;
    }

    /**
    Event fired, when pointer is dragged. This method can be overwrite to manage pointer dragged event. However, it is important to call super.pointerDragged(x, y) in overwriten method.
    @method pointerDragged
    @protected
    @param x {Integer} x pointer X-coordinate
    @param y {Integer} y pointer Y-coordinate
    */
    function pointerDragged(x, y)
    {
        for (var control in this._controls)
            if (control.visible && control.intersectsPoint(x, y))
                if (control.pointerDragged(x, y) === true)
                    return true;
    }

    /**
    Event fired, when pointer is released. This method can be overwrite to manage pointer released event. However, it is important to call super.pointerReleased(x, y) in overwriten method.
    @method pointerReleased
    @protected
    @param x {Integer} x pointer X-coordinate
    @param y {Integer} y pointer Y-coordinate
    @example
        function pointerReleased(x, y)
        {
            super.pointerReleased(x, y);
            ...
        }
    */
    function pointerReleased(x, y)
    {
        for (var control in this._controls)
            if (control.visible && control.intersectsPoint(x, y))
                if (control.pointerReleased(x, y) === true)
                    return true;
    }

    /**
    Event fired, when user press the key. This method can be overwrite to manage key events. However it is important to call super.keyPressed(key) in overwriten method.
    @method keyPressed
    @protected
    @param key {Symbol} the pressed key
    @example
        function keyPressed(key)
        {
            super.keyPressed(key);
            if (key == #back)
                Game.instance.pop();
            ...
        }
    */
    function keyPressed(key)
    {
    }

    /**
    Event fired, when user releases the keyy. This method can be overwrite to manage key events. However it is important to call super.keyReleased(key) in overwriten method.
    @method keyReleased
    @protected
    @param key {Symbol} the pressed key
    @example
        function keyReleased(key)
        {
            super.keyReleased(key);
            if (key == #back)
                Game.instance.pop();
            ...
        }
    */
    function keyReleased(key)
    {
    }

    /**
    Event fired on enter to the scene
    @event onEnter
    */
    property onEnter(v)
    {
        get return this.enter;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Game.onEnter] Instance of function expected");
            this.enter = v;
        }
    }

    /**
    Event fired on exit to the scene
    @event onExit
    */
    property onExit(v)
    {
        get return this.exit;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Game.onExit] Instance of function expected");
            this.exit = v;
        }
    }

    /**
    Method what execute enter handler if defined.
    @method enter
    @protected
    */
    function enter()
    {
        //if (this._onEnterHandler)
        //    this._onEnterHandler(this);
    }

    /**
    Method what execute exit handler if defined
    @method exit
    @protected
    */
    function exit()
    {
        //if (this._onExitHandler)
        //    this._onExitHandler(this);
    }

}
