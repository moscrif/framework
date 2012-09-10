include "lib://game2d/base/sceneTransition.ms"
/**
Scene transition SlideToRight, move scene into right. An instance of this class is applied onto {{#crossLink "Game.push"}}{{/crossLink}} or {{#crossLink "Game.pop"}}{{/crossLink}} methods.
@class SlideToRight
@module game2d
@example
    var scene = new Scene();
    game.push(scene, new SlideToRight());
*/
class SlideToRight : SceneTransition
{
    /**
    Init instance
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this._x = 0;
    }

    /**
    Set transition state - current position of the scenes on x-axis
    @method setState
    @protected
    @param value {Integer} curent position in the animation
    */
    function setState(value)
    {
        super.setState(value);
        this._x = Math.floor(value * System.width);
    }

    /**
    Draw method draws new and old scenes. Both scenes are translate on x-axis.
    @method draw
    @protected
    @param canvas {Canvas} Current game canvas
    */
    function draw(canvas)
    {
        super.draw(canvas);
        if (this._sceneFrom) {
            canvas.save();
            canvas.translate(this._x, 0);
            this._sceneFrom.draw(canvas);
            canvas.restore();
        }
        if (this._sceneTo) {
            canvas.save();
            canvas.translate(this._x - System.width, 0);
            this._sceneTo.draw(canvas);
            canvas.restore();
        }
    }
}

