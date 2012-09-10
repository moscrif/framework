include "lib://core/baseClass.ms"
include "lib://core/animation/animator.ms"

/**
Scene transition base class defines common features of game transitions.
    This class is used also to extend class defines custom scene transition.
@class SceneTransition
@module game2d
@extends BaseClass
@example
    // create custom transition
    class OwnTransition : SceneTransition
    {
        function init()
        {
            super.init();
            this._scale = 0;
        }
    
        // @region public fuctions
        function draw(canvas)
        {
            super.draw(canvas);
            // draw initial scene
            if (this._sceneFrom) {
                canvas.save();
                this._sceneFrom.draw(canvas);
                canvas.restore();
            }
            // draw end scene
            if (this._sceneTo) {
                canvas.save();
                // scaled and centered new scene
                canvas.translate(System.width / 2 - (System.width / 2*this._scale).toInteger(), System.height / 2 - (System.height / 2*this._scale).toInteger());
                canvas.scale(this._scale, this._scale);
                this._sceneTo.draw(canvas);
                canvas.restore();
            }
        }
    
        // sets local variables according to animation state
        function setState(value)
        {
            this._scale = value * 1.0;
            super.setState(value);
        }
        // @endregion
    }
*/
class SceneTransition : BaseClass
{
    /**
    Init object parameters. The init method sets all needed transition properties according to developer requirements or to default values.
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._duration = this.options.duration || 250; // milis
        this._transition = this.options.transition || Animator.Transition.easeInOut;
        this._sceneFrom = this._sceneTo = null;
    }

    /**
    Event to be fired after transition is completed.
    @event onComplete
    */
    property onComplete(v)
    {
       get return this.complete;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[SceneTransition.onComplete] Expects type of function");
             this.complete = v;
        }
    }

    /**
    Duration of scene transition in miliseconds
    @property duration
    @type Integer
    @example
        game.push(scene, new SlideToBottom({
            duration   : 3000,
            transition : Animator.Transition.veryBouncy
        }));
    */
    property duration(v)
    {
        get return this._duration;
        set { this._duration = v; }
    }

    /**
    Transition property specifies the behaviour of animator. It defines how transition runs on begin or on the end, if it bounce from the top etc.
    @type Transition
    @property transition
    @example
        game.push(scene, new SlideToBottom({
            duration   : 3000,
            transition : Animator.Transition.veryBouncy // or Animator.Transition.easyIn or Animator.Transition.easyOut or Animator.Transition.elastic etc.
        }));
    */
    property transition(v)
    {
        get return this._transition;
        set { this._transition = v; }
    }

    /**
    Start scene
    @property sceneFrom
    @type Scene
    @readOnly
    */
    property sceneFrom(v)
    {
        get return this._sceneFrom;
    }

    /**
    Final scene
    @property sceneTo
    @type Scene
    @readOnly
    */
    property sceneTo(v)
    {
        get return this._sceneTo;
    }

    /**
    Set scenes, scene from and scene to and start transition
    @method push
    @param fromScene {Scene} start scene
    @param toScene {Scene} final scene
    */
    function push(fromScene, toScene)
    {
        this._sceneFrom = fromScene;
        this._sceneTo = toScene;
        this._start();
    }

    /**
    Set scenes, scene from and scene to and start transition
    @method push
    @param fromScene {Scene} start scene
    @param toScene {Scene} final scene
    */
    function pop(fromScene, toScene)
    {
        this._sceneFrom = fromScene;
        this._sceneTo = toScene;
        this._start();
    }

    /**
    This method should be overwritten in extended classes to apply transition effect (f.e.: scale scenes, move scenes, fade out scenens etc..).
    @method setState
    @param value {Float} current position in the transition
    @example
        // sets local variables according to animation state
        function setState(value)
        {
            // scale scene
            this._scale = value * 1.0;
            super.setState(value);
        }
    */
    function setState(value)
    {
        // to be overwritten
    }

    /**
    Start transition
    @method _start
    @private
    */
    function _start() {
        var duration = this._duration;
        var transition = this._transition;
        var onComplete = this.complete;
        var animator = new Animator({duration: duration, transition: transition, onComplete: onComplete});
        animator.addSubject(this)
        animator.play();

    }

    /**
    This method should be overwritten in extended classes to draw scenes with required effect (f.e.: scale scenes, move scenes, fade out scenens etc..).
    @method draw
    @param canvas {Canvas} Instance of Canvas class used to draw graphics
    @protected
    @example
        class OwnTransition : SceneTransition
        {
            function init()
            {
                super.init();
                this._scale = 0;
            }
        
            function draw(canvas)
            {
                super.draw(canvas);
                // draw initial scene
                if (this._sceneFrom) {
                    canvas.save();
                    this._sceneFrom.draw(canvas);
                    canvas.restore();
                }
                // draw end scene
                if (this._sceneTo) {
                    canvas.save();
                    // scaled and centered new scene
                    canvas.translate(System.width / 2 - (System.width / 2*this._scale).toInteger(), System.height / 2 - (System.height / 2*this._scale).toInteger());
                    canvas.scale(this._scale, this._scale);
                    this._sceneTo.draw(canvas);
                    canvas.restore();
                }
            }
            ...
        }
    */
    function draw(canvas) {;}

}
