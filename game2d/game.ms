include "lib://core/baseClass.ms"
include "lib://graphics/paintCache.ms"
include "lib://game2d/scene.ms"
include "lib://game2d/sprite.ms"
include "lib://game2d/base/sceneTransition.ms"

/**
Game class is a base class for all Moscrif game projects, which use framework.
    This class map all system events like onStart, onDraw, onPointerPressed etc.
    It provides correct working of other framework elements (provides its drawing, reaction onto user events etc).
@class Game
@module game2d
@example
    include "lib://game2d/game.ms"

    // create new instances of game and resource classes
    var game = new Game();

    game.onStart = function()
    {
        ...
    }

    // hardware key reaction
    game.onKeyPressed = function(keyCode)
    {
        if (keyCode == #back || keyCode == #home)
            game.quit();
    }

    game.run();
*/
class Game : BaseClass
{
    /**
    Singleton of the game object.
    @static
    @attribute instance
    @type Game
    */
    var instance = null;

    /**
    Sanity check before init of game object instance.
    @method beforeInit
    @protected
    */
    function beforeInit()
    {
        assert Game.instance == null;
        Game.instance = this;
    }

    /**
    Init game object instance. This method is called from class constructor and it is usually no needed to change it.
    @method init
    @protected
    */
    function init()
    {
        super.init();

        this._transition = null;
        this._window = new Moscrif.Window();

        this._window.onDraw = function(sender, canvas)
        {
            var self = this super;
            if (typeof self.draw == #function)
                self.draw.call(self, canvas);
        }

        this._window.onProcess = function(sender) {
            var self = this super;
           if (typeof self.process == #function)
                self.process.call(self);
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.process();
            for (var sprite in self._sprites)
                sprite.process();
            sender.invalidate();
            return self._terminate ? 0 : 1;
        }

        this._window.onStart = function(sender)
        {
            var self = this super;
            if (typeof self.start == #function)
                // !!! TODO: toto ma za nasledok, ze sa vola start() 2x
                // !!! self.start.call(self);
                self.start();
        }

        this._window.onPointerPressed = function(sender, x, y, pointer)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.pointerPressed != null)
               // self.pointerPressed.call(self, x, y, pointer);
                self.pointerPressed.call(self, x, y, pointer);
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.pointerPressed(x, y, pointer);
                //scene.pointerPressed(x, y);
        }

        this._window.onPointerDragged = function(sender, x, y, pointer)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.pointerDragged != null)
                self.pointerDragged.call(self, x, y, pointer);
                //self.pointerDragged.call(self, x, y);
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.pointerDragged(x, y, pointer);
                //scene.pointerDragged(x, y);
        }

        this._window.onPointerReleased = function(sender, x, y, pointer)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.pointerReleased != null)
                self.pointerReleased.call(self, x, y, pointer);
                //self.pointerReleased.call(self, x, y);
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.pointerReleased(x, y, pointer);
                //scene.pointerReleased(x, y);
        }

        this._window.onKeyPressed = function(sender, key)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.keyPressed != null)
                self.keyPressed.call(self, key);
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.keyPressed(key);
            return true;
        }

        this._window.onKeyReleased = function(sender, key)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.keyReleased != null)
                self.keyReleased.call(self, key);
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.keyReleased(key);
            return true;
        }

        this._window.onChar = function(sender, key)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.char != null)
                self.char(self, String.fromCharCode(key));
        }

        this._window.onForeground = function(sender)
        {
            var self = this super;
            if (self.foreground != null)
                return self.foreground.call(self);
        }

        this._window.onBackground = function(sender)
        {
            var self = this super;
            if (self.background != null)
                return self.background.call(self);
        }

        this._window.onOrientationChanged = function(sender, orientation)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.orientationChanged != null)
                return self.orientationChanged.call(self, orientation);
        }

        this._window.onGesturePinch = function(sender, state, scale, velocity)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.gesturePinch != null)
                return self.gesturePinch.call(self, state, scale, velocity);
        }

        this._window.onGestureRotate = function(sender, state, angle, velocity)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.gestureRotate != null)
                return self.gestureRotate.call(self, state, angle, velocity);
        }

        this._window.onGesturePan = function(sender, state, transX, transY, velX, velY)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.gesturePan != null)
                return self.gesturePan.call(self, state, transX, transY, velX, velY);
        }

        this._window.onGestureSwipe = function(sender, direction)
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.gestureSwipe != null)
                return self.gestureSwipe.call(self, direction);
        }

        this._window.onGestureTap = function()
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.gestureTap != null)
                return self.gestureTap.call(self);
        }

        this._window.onGesturePress = function()
        {
            var self = this super;
            if (self._transition)
                return;
            if (self.gesturePress != null)
                return self.gesturePress.call(self);
        }

        this._sprites = [];
        this._scenes = [];
    }

    /**
    Function starts a game. It creates a game window and an events managment.
    @method run
    @chainable
    @param allowFPS=false {Boolean} Enable or disable FPS calculating.
    @example
        include "lib://game2d/game.ms"
        
        // create new instances of game and resource classes
        var game = new Game();
        
        game.onStart = function()
        {
            ...
        }
    
        ...
        
        game.run();
    */
    function run(allowFPS = false)
    {
        this._window.init(allowFPS);
        this._window.run();
        return this;
    }

    /**
    Enforce redraw window. By default a game is redraw many time per second, what meant that it is no need to enforce window redraw.
    @method invalidate
    @chainable
    */
    function invalidate()
    {
        this._window.invalidate();
        return this;
    }

    /**
    Quit application.
    @method quit
    @chainable
    @example
        // hardware key reaction
        game.onKeyPressed = function(keyCode)
        {
            if (keyCode == #back || keyCode == #home)
                game.quit();
        }
    */
    function quit()
    {
        this._terminate = true;
        return this;
    }

    /**
    Implements the drawing of the game.
    @method draw
    @protected
    @param canvas {Canvas} The canvas used to draw graphics
    */
    function draw(canvas)
    {
        // TODO: temporary solution because of OpenGL
        var paintCache = PaintCache.instance;
        if (!paintCache._drawCached) {
            const strA = "abcdefghijklmnopqrstuvwxyz";
            const strB = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const strC = "0123456789 .,;:-+*/";
            for (var key in paintCache.paints) {
                var paint = paintCache.paints[key];
                canvas.drawText(strA, 0, 100, paint);
                canvas.drawText(strB, 0, 110, paint);
                canvas.drawText(strC, 0, 120, paint);
            }
            paintCache._drawCached = true;
        }
        // <--
        var self = this;
        if (self._transition) {
            self._transition.draw(canvas);
        } else {
            var scene = self._scenes.length ? self._scenes[self._scenes.length - 1] : null;
            if (scene)
                scene.draw(canvas);
        }
        for (var sprite in self._sprites)
            sprite.draw(canvas);
    }

    /**
    Default method mapped onto onStart event.
    @protected
    @method start
    */
    function start()
    {
    }

    /*
    Push new scane to the game. The scene can be pushed with nice transition effect.
    @method push
    @param scene {Scene} The instance of scene class which should be added to the game
    @param [transition=null] {SceneTransition} The instance of scene trnasition. See also: ({{#crossLink "SlideToBottom"}}{{/crossLink}}, {{#crossLink "SlideToTop"}}{{/crossLink}}, {{#crossLink "SlideToLeft"}}{{/crossLink}}, {{#crossLink "SlideToRight"}}{{/crossLink}}), which defines transition effect
    @example
        // prepare game instance before it runs
        game.onStart = function()
        {
            // create menu scene
            var scene = new Scene();
            this.push(scene, new SlideToBottom());
        }
    */
    function push(scene, transition = null)
    {
        assert scene instanceof Scene;
        if (transition)
            this._setTransition(transition);
        var previousScene = this._scenes.length ? this._scenes[this._scenes.length - 1] : null;
        if (previousScene)
            previousScene.exit();
        scene.enter();
        this._scenes.push(scene);
        if (transition)
            transition.push(previousScene, scene);
    }

    /**
    Return to previous scene. Scenes could be changed with a transition effect.
    @method pop
    @param [transition=null] {SceneTransition} Instance of SceneTransition classes: ({{#crossLink "SlideToBottom"}}{{/crossLink}}, {{#crossLink "SlideToTop"}}{{/crossLink}}, {{#crossLink "SlideToLeft"}}{{/crossLink}}, {{#crossLink "SlideToRight"}}{{/crossLink}}), which defines transition effect
    */
    function pop(transition = null)
    {
        if (transition)
            this._setTransition(transition);
        var currentScene = this._scenes.length ? this._scenes[this._scenes.length - 1] : null;
        if (currentScene) {
            currentScene.exit();
        } else {
            this.quit();
            return;
        }
        this._scenes.pop();
        var previousScene = this._scenes.length ? this._scenes[this._scenes.length - 1] : null;
        if (previousScene) {
            previousScene.enter();
        } else {
            this.quit();
            return;
        }
        if (transition)
            transition.pop(currentScene, previousScene);
    }

    /**
    Add sprite to the game.
    @method add
    @param obj {Sprite} The instance of Sprite class which should be added to the game
    */
    function add(obj)
    {
        assert obj instanceof Sprite;
        if (obj instanceof Sprite)
            this._sprites.push(obj);
    }

    /**
    Enable gesture swipe and set supported direction and required number of touches. By this gesture user user can execute a command by swiping his finger across the screen.
    @method setGestureSwipe
    @param enable {Boolean} Enables or disables gestures.
    @param numberOfTouchesRequired {Integer} Required number of touches
    @param direction {Symbol} Supported directions are #left, #right, #up, #down or #all
    */
    function setGestureSwipe(enable, numberOfTouchesRequired, direction)
    {
        this._window.setGestureSwipe(enable, numberOfTouchesRequired, direction);
    }

    /**
    Enable and tap gesture. Developer can specify number of taps and touches required to recognize the gesture.
    @method setGestureTap
    @param enable {Boolean} Enables or disables gestures.
    @param numberOfTapsRequired {Integer} required number of taps
    @param numberOfTouchesRequired {Integer} required number of touches
    */
    function setGestureTap(enable, numberOfTapsRequired, numberOfTouchesRequired)
    {
        this._window.setGestureTap(enable, numberOfTapsRequired, numberOfTouchesRequired);
    }

    /**
    Enable and set press gesture.  Developer can specify number of taps and touches required to recognize the gesture.
    @method setGesturePress
    @param enable {Boolean} enable gesture
    @param numberOfTapsRequired {Integer} number of required taps
    @param numberOfTouchesRequired {Integer} number of required touches
    @example
        this.setGesturePress(true, 0, 1);
    */
    function setGesturePress(enable, numberOfTapsRequired, numberOfTouchesRequired)
    {
        this._window.setGesturePress(enable, numberOfTapsRequired, numberOfTouchesRequired);
    }

    /**
    Enable and set gesture pinch. Pinch gesture is commonly used to resize photos or zoom the screen.
    @method setGesturePinch
    @param enable {Boolean} enable gesture
    */
    function setGesturePinch(enable)
    {
        this._window.setGesturePinch(enable);
    }

    /**
    Enable and set rotate gesture. The rotate gesture enable to rotate screen by more fingers.
    @method setGestureRotate
    @param enable {Boolean} enable gesture
    @example
        this.setGestureRotate(true);
    */
    function setGestureRotate(enable)
    {
        this._window.setGestureRotate(enable);
    }

    /**
    Enable and pan gesture.
    @method setGesturePan
    @param enable {Boolean} enable gesture
    @example
        this.setGesturePan(true);
    */
    function setGesturePan(enable)
    {
        this._window.setGesturePan(enable);
    }

    /**
    Enable / disable multi touch. If multi touch is enabled the pointer events has last parameter -> index (order of touch);
    @property multiTouch
    @type {Boolean}
    */
    property multiTouch(v)
    {
        get return this._window.multiTouch;
        set this._window.multiTouch = v;
    }


    /**
    OnStart event appears, when application starts. It is called only once after start of application.
    @event onStart
    @example
        // create new instances of game and resource classes
        var game = new Game();

        game.onStart = function()
        {
            // create a scene, whre whole game is situated
            this.push(new GameScene());
        }
    */
    property onStart(v)
    {
        get return this.start;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Game.onStart] Instance of function expected");
            this.start = v;
        }
    }

    /**
    OnDraw event appears every time, when it is needed to redraw application window.
    @event onDraw
    @param canvas {Canvas} The instance of Canvas class, used to draw a graphics onto screen
    @example
        game.onDraw = function(canvas)
        {
            // fill screen with blue color
            canvas.clear(0xff0000ff);
        }
    */
    property onDraw(v)
    {
        get return this.draw;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onDraw] Expects type of function");
             this.draw = v;
        }
    }

    /**
    On process event appears at every about 25 miliseconds, and is a good place for asynchronous operations. F.e.: it is good place to remove physics elements from physics world, or check changes in source data etc.
    @event onProcess
    */
    property onProcess(v)
    {
        get return this.process;
        set {

             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onDraw] Expects type of function");
             this.process = v;
        }
    }

    /**
    This event is raised by user tap the screen.
    @event onPointerPressed
    @param x {Integer} X coordinates of pointer
    @param y {Integer} Y coordinates of pointer
    @param pointer {Integer} Order of touch if multi-touch is enabled
    */
    property onPointerPressed(v)
    {
        get return this.pointerPressed;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onPointerPressed] Expects type of function");
             this.pointerPressed = v;
        }
    }

    /**
    Called when user moves his finger on the screen.
    @event onPointerDragged
    @param x {Integer} X coordinates of pointer
    @param y {Integer} Y coordinates of pointer
    @param pointer {Integer} Order of touch if multi-touch is enabled
    */
    property onPointerDragged(v)
    {
        get return this.pointerDragged;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onPointerDragged] Expects type of function");
             this.pointerDragged = v;
        }
    }

    /**
    Called when touch (click) is finished.
    @event onPointerReleased
    @param x {Integer} X coordinates of pointer
    @param y {Integer} Y coordinates of pointer
    @param pointer {Integer} Order of touch if multi-touch is enabled
    */
    property onPointerReleased(v)
    {
        get return this.pointerReleased;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onPointerReleased] Expects type of function");
             this.pointerReleased = v;
        }
    }

    /**
    This event is raised by press the key.
    @event onKeyPressed
    @param key {Symbol|Char} Pressed key value (symbols #back for back arrow, #home for home button and #menu for menu button)
    @example
        // reaction to hardware keyboard press
        game.onKeyPressed = function(keyCode)
        {
            if (keyCode == #back || keyCode == #home)
                app.quit();
        }
    */
    property onKeyPressed(v)
    {
       get return this.keyPressed;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onKeyPressed] Expects type of function");
             this.keyPressed = v;
        }

    }

    /**
    This event is raised by release the key.
    @event onKeyReleased
    @param key {Symbol|Char} Pressed key value (symbols #back for back arrow, #home for home button and #menu for menu button)@return Function
    */
    property onKeyReleased(v)
    {
       get return this.keyReleased;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onKeyReleased] Expects type of function");
             this.keyReleased = v;
        }
    }

    /**
    This method is called when game moves to background. An application moves to foreground when:

    * Application starts
    * Application is selected from Task Manager
    * Application is restored form hibernation
    * Application becomes active after system calls (incoming call etc …) finish

    @event onChar
    @param charCode {Integer} Pressed key value
    */
    property onChar(v)
    {
       get return this.char;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onChar] Expects type of function");
             this.char = v;
        }

    }

    /**
    This method is called when game moves to background. An application moves to foreground when:

    * Application starts
    * Application is selected from Task Manager
    * Application is restored form hibernation
    * Application becomes active after system calls (incoming call etc …) finish

    @event onForeground
    @example
        game.onForeground = function()
        {
            musicPlayer.play();
        }
    */
    property onForeground(v)
    {
       get return this.foreground;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onForeground] Expects type of function");
             this.foreground = v;
        }
    }

    /**
    This event is raised when game moves to background. An application moves to background when:

    * Application moves to hibernation state
    * Other application is activated
    * In the case of  system calls (incoming call or displaying other system dialog or window)

    @event onBackground
    @example
        game.onBackground = function()
        {
            musicPlayer.stop();
        }
    */
    property onBackground(v)
    {
       get return this.background;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onBackground] Expects type of function");
             this.background = v;
        }
    }

    /**
    This event is raised by change device orientation.
    @event onOrientationChanged
    @param orientation {Symbol} New orientation of device
    @example
        game.onOrientationChanged = function(orientation)
        {
            // resize all photos to current orientation
            logI("new orientation is : ", orientation);
        }
    */
    property onOrientationChanged(v)
    {
       get return this.orientationChanged;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onOrientationChanged] Expects type of function");
             this.orientationChanged = v;
        }
    }

    /**
    This event is raised by pinch gesture.
    @event onGesturePinch
    @param state {Symbol} The following symbols are used:

    * #began: the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
    * #chnaged: the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
    * #ended: the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
    * #cancelled: the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
    @param scale {Float} Scale from the previous call of this event
    @param velocity {Float} velocity from the previous call of this event
    @example
        // manage gestures
        game.onGesturePinch = function(state, scale, velocity)
        {
        
            this._scale = this._scale * scale;
            if (this._scale < this._minScale)
                this._scale = this._minScale;
            else if (this._scale > this._maxScale)
                this._scale = this._maxScale;
        }
    */
    property onGesturePinch(v)
    {
       get return this.gesturePinch;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onGesturePinch] Expects type of function");
             this.gesturePinch = v;
        }

    }

    /**
    This event is raised by rotate gesture.
    @event onGestureRotate
    @param state {Symbol} The following symbols are used:

    * #began: the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
    * #chnaged: the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
    * #ended: the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
    * #cancelled: the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
    @param angle {Float} Rotation from the previous call of this event
    @param velocity {Float} velocity from the previous call of this event
    @example
        game.onGestureRotate = function(state, angle, velocity)
        {
            this.state = state;
            if (state != #ended) {
                // radians to degrees
                this._angle -= this.lastRotation - angle * 180.0/ Math.PI;
                this.lastRotation = angle  * 180.0/ Math.PI;
                this.rotating = true;
            } else {
                this.lastRotation = 0;
                this.rotating = false;
            }
        }
    */
    property onGestureRotate(v)
    {
       get return this.gestureRotate;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onGestureRotate] Expects type of function");
             this.gestureRotate = v;
        }

    }

    /**
    This event is raised by pan gesture.
    @event onGesturePan
    @param state {Symbol} The following symbols are used:

    * #began: the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
    * #chnaged: the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
    * #ended: the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
    * #cancelled: the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
    @param transX {Float} translationX Movement on x axis from the previous call of this event
    @param transY {Float} translationY Movement on y axis from the previous call of this event
    @param velX {Float} velocityX Velocity on x axis from the previous call of this event
    @param velY {Float} velocityY Velocity on y axis from the previous call of this event
    @example
    game.onGesturePan = function(state, transX, transY, velX, velY)
    {
        // translate photo
        this._translateX -= transX;
        this._translateY -= transY;
    }
    */
    property onGesturePan(v)
    {
       get return this.gesturePan;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onGesturePan] Expects type of function");
             this.gesturePan = v;
        }

    }

    /**
    This event is raised by swipe gesture. By this gesture user user can execute a command by swiping his finger across the screen.
    @event onGestureSwipe
    @param direction {Symbol} The Direction: #left, #right, #up or #down.
    */
    property onGestureSwipe(v)
    {
       get return this.gestureSwipe;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onGestureSwipe] Expects type of function");
             this.gestureSwipe = v;
        }

    }

    /**
    This event is raised by tap gesture. Number of reguired taps and touches can be customized by set setGestureTap method.
    @event onGestureTap
    */
    property onGestureTap(v)
    {
       get return this.gestureTap;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onGestureTap] Expects type of function");
             this.gestureTap = v;
        }

    }

    /**
    This event is raised by press gesture. Number of reguired taps and touches can be customized by set setGesturePress method.
    @event onGesturePress
    @example
        game.onGesturePress = function()
        {
        
            this.gesturePinch(true);
            this.gestureRotate(true);
            this.gesturePan(false);
            this.action = #scale;
        }
    */
    property onGesturePress(v)
    {
       get return this.gesturePress;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Game.onGesturePress] Expects type of function");
             this.gesturePress = v;
        }

    }

    /**
    This property sets supported device orientations. If there are more supported orientations event onOrientationChanged is called, when device orientation change.
        Supported are:

    * #portrait
    * #landscape-left
    * #landscape-right
    @property orientation
    @type {Symbol}
    */
    property orientation(v)
    {
       get return this._window.orientation;
       set this._window.orientation = v;
    }

    /**
    Sets transition.
    @method _setTransition
    @param transition {SceneTransition}
    @private
    */
    function _setTransition(transition)
    {
        this._transition = transition;
        this._transition.onComplete = function() {
            this super._transition = null;
        }
    }
}
