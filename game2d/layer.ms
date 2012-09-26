include "lib://core/baseClass.ms"
include "lib://game2d/base/gameObject.ms"
include "lib://game2d/base/gameControl.ms"
include "lib://game2d/sprite.ms"
include "lib://game2d/base/gameObject.ms"
include "lib://game2d/base/gameControl.ms"

/**
Layer, object to define a layer which can consist with sprites or buttons. It can be inclded into scene to group similar objects.
@class Layer
@module game2d
@example
    class ColoringLayer : Layer
    {
        function init()
        {
            super.init();
        }
    
        function draw(canvas)
        {
            canvas.clear(0xffffffff);
            ...
            super.draw(canvas);
        }
    }
    ...
    var layer = new ColoringLayer({z : 2, width : System.width, height : System.height})
    scene.add(layer);
*/
class Layer : GameControl
{
    /**
    Init object parameters.
    @method beforeInit
    @protected
    */
    function beforeInit()
    {
        this._objects = [];
        this._controls = [];
        this._childs = [];  // all objects and controls
    }

    /**
    Access to array of all layers's objects (f.e.: sprites).
    @property objects
    @readOnly
    @type Array
    */
    property objects(v)
    {
        get return this._objects;
    }

    /**
    Access to array of all layers's controls (f.e.: buttons).
    @property controls
    @readOnly
    @type Array
    */
    property controls(v)
    {
        get return this._controls;
    }

    /**
    Access to array of all layers's childs (objects and controls together).
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
        var layer = new Layer({});
        layer.add(new Sprite({name:"sprite1"});
        var ref = layer.sprite1; // sprite1 is not property of Layer. Thanks to UPH of Layer, Layer class will find it's child by name.
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
            logW("[Layer.undefined] Property", name, "hasn't been set. Value to set:", v);
            //if (System.IS_DEBUG)
            //    debug stacktrace;
            return null;
        }
    }

    /**
    Find object (sprite) in the layer acording to its name.
    @method findObject
    @param String name of the object
    @return Object or null
    @example
        var sprite = this.addPolygonBody(..);
        sprite.name = "car";
        this.add(sprite);
        this.findObject("car")....; // car sprite
    */
    function findObject(name)
    {
        var objs = this._objects.filter(:x :x.name == name);
        if (objs.length == 1)
            return objs[0];
        return null;
    }

    /**
    Find control (button) in the layer acording to it name.
    @method findControl
    @param name {String} of the object
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
    Find child in the layer acording to it name.
    @method findChild
    @param name {String} Name of the object
    @return Child or null
    @example
        var sprite = this.addPolygonBody(..);
        sprite.name = "car";
        this.add(sprite);
        this.findChild("car")....; // car sprite
    */
    function findChild(name)
    {
        var childs = this._childs.filter(:x :x.name == name);
        if (childs.length == 1)
            return childs[0];
        return null;
    }

    /**
    Add GameControl or GameObject (Button or Sprite) to the layer.
    @method add
    @chainable
    @param obj {GameControl|Sprite} The object to be stored in layer
    @example
        class Menu : Layer
        {
            function init()
            {
                super.init();
            
                var close = Bitmap.fromFile("app://ico-close.png")
                this._closeBtn = new ImageButton({image : close, x : System.width - close.width, y : close.height, onClick : function(){game.quit();}})
                this.add(this._closeBtn);
                ...
            }
            ...
        }
    */
    function add(obj)
    {
        assert obj != null;
        if (obj instanceof GameControl) {
            this._controls.push(obj);
            this._controls.sort(:a, b {return a.z - b.z});
            this._childs.push(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else if (obj instanceof GameObject) {
            this._objects.push(obj);
            this._objects.sort(:a, b {return a.z - b.z});
            this._childs.push(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else {
            throw "Unsupported object type";
        }
        return this;
    }

    /**
    Remove object from the layer.
    @method detach
    @chainable
    @param obj {GameControl|Sprite} The object to be stored in layer
    */
    function detach(obj)
    {
        assert obj != null;
        if (typeof obj == #string)
            obj = this.findObject(obj) || this.findControl(obj);
        if (obj instanceof GameControl) {
            this._controls.removeByValue(obj);
            this._controls.sort(:a, b {return a.z - b.z});
            this._childs.removeByValue(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else if (obj instanceof GameObject) {
            this._objects.removeByValue(obj);
            this._objects.sort(:a, b {return a.z - b.z});
            this._childs.removeByValue(obj);
            this._childs.sort(:a, b {return a.z - b.z});
        } else {
            throw "Unsupported object type";
        }
        return this;
    }

    /**
    Draws this layer and all added objects. This method can be overwrite to draw something onto layer.
        However it is important to call super.draw(canvas) in overwriten method.
    @method draw
    @protected
    @param canvas {Canvas} The canvas.
    @example
        function draw(canvas)
        {
            canvas.drawRect(0, 0, System.width, System.height, this._bg);
            super.draw(canvas);
        }
    */
    function draw(canvas)
    {
        if (!this._visible)
            return;
        assert canvas instanceof Canvas;
        canvas.save();
        for (var child in this._childs)
            child.draw(canvas);
        canvas.restore();
    }

    /**
    Process event, fire process event to all stored objects
    @method process
    @protected
    */
    function process()
    {
        super.process();
        for (var child in this._childs)
            child.process();
    }

    /**
    This method is called when user tap the screen. It can be overwritten to manage pointer pressed event.
        However, it is important to call super.pointerPressed(x, y) in overwriten method.
    @method pointerPressed
    @protected
    @param x {Integer} Pointer's X-coordinate
    @param y {Integer} Pointer's Y-coordinate
    @example
        function pointerPressed(x, y)
        {
            super.pointerPressed(x, y);

            if (x<System.width / 2)
                console<<"user tap on the left half of screen\n"
        }
    */
    function pointerPressed(x, y)
    {
        super.pointerPressed(x, y);
        for (var control in this._controls)
            if (control.intersectsPoint(x, y))
                control.pointerPressed(x, y);
    }

    /**
    This methos is called, when pointer is dragged.
    @method pointerDragged
    @protected
    @param x {Integer} Pointer's X-coordinate
    @param y {Integer} Pointer's Y-coordinate
    */
    function pointerDragged(x, y)
    {
        super.pointerDragged(x, y);
        for (var control in this._controls)
            if (control.intersectsPoint(x, y))
                control.pointerDragged(x, y);
    }

    /**
    This methos is called, when pointer is released. This method can be overwrite to manage pointer released event.
        However, it is important to call super.pointerReleased(x, y) in overwriten method.
    @method pointerReleased
    @protected
    @param x {Integer} Pointer's X-coordinate
    @param y {Integer} Pointer's Y-coordinate
    @example
        function pointerReleased(x, y)
        {
            super.pointerReleased(x, y);
            if (x<System.width / 2)
                console<<"user tap on the left half of screen\n"
            ...
        }
    */
    function pointerReleased(x, y)
    {
        super.pointerReleased(x, y);
        for (var control in this._controls)
            if (control.intersectsPoint(x, y))
                control.pointerReleased(x, y);
    }
}