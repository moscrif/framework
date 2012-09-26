include "lib://game2d/base/sceneTransition.ms"
/**
Scene transition SlideToLeft, move scene into left. An instance of this class is applied onto {{#crossLink "Game.push"}}{{/crossLink}} or {{#crossLink "Game.pop"}}{{/crossLink}} methods.

@class SlideToLeft
@module game2d
@example
    var scene = new Scene();
    game.push(scene, new SlideToLeft());
*/
class SlideToLeft : SceneTransition
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
    Set transition state
    @method setState
    @protected
    @param value {Integer} curent position in the animation
    */
    function setState(value)
    {
        this._x = -1 * Math.floor(value * System.width);
        super.setState(value);
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
            canvas.clipRect(this._x, 0, this._x + System.width, System.height, #intersect);
            canvas.translate(this._x, 0);
            this._sceneFrom.draw(canvas);
            canvas.restore();
        }
        if (this._sceneTo) {
            canvas.save();
            canvas.clipRect(System.width + this._x, 0, System.width, System.height, #intersect);
            canvas.translate(System.width + this._x, 0);
            this._sceneTo.draw(canvas);
            canvas.restore();
        }
    }
}

