include "lib://game2d/base/sceneTransition.ms"
/**
Scene transition SlideToTop, move scene into top. An instance of this class is applied onto {{#crossLink "Game.push"}}{{/crossLink}} or {{#crossLink "Game.pop"}}{{/crossLink}} methods.
@class SlideToTop
@module game2d
@example
    var scene = new Scene();
    game.push(scene, new SlideToBottom());
*/
class SlideToTop : SceneTransition
{
    /**
    Init instance.
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._y = 0;
    }

    /**
    Set transition state - current position of the scenes on y-axis
    @method setState
    @protected
    @param value {Integer} curent position in the animation
    */
    function setState(value)
    {
        this._y = -1 * Math.floor(value * System.height);
        super.setState(value);
    }

    /**
    Draw method draws new and old scene. Both scenes are translate on y-axis.
    @method draw
    @protected
    @param canvas {Canvas} Current game canvas
    */
    function draw(canvas)
    {
        super.draw(canvas);
        if (this._sceneFrom) {
            canvas.save();
            canvas.translate(0, this._y);
            this._sceneFrom.draw(canvas);
            canvas.restore();
        }
        if (this._sceneTo) {
            canvas.save();
            canvas.translate(0, System.height + this._y);
            this._sceneTo.draw(canvas);
            canvas.restore();
        }
    }
}

