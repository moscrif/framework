include "lib://game2d/base/gameObject.ms"

/**
Generic game control class which creates onClick event. This class extends all buttons used in games.
@class GameControl
@module game2d
@example
    class Button : GameControl
    {
        ....
    }
*/
class GameControl : GameObject
{
    /**
    Init Game control instance. This method should be used as a class constructor in extended classes. However, it is important to call parent's init method (by super.init()) to ensure correct object initialization.
    @method init
    @protected
    */
    function init(options = {})
    {
        super.init(options);
        this._clicked = false;
        this.click = null;
    }


    /**
    Method is called when pointer was pressed.
    @method pointerPressed
    @protected
    @param x {Integer} X-coordinate in pixels from the left top screen corner
    @param y {Integer} Y-coordinate in pixels from the left top screen corner
    */
    function pointerPressed(x, y)
    {
        this._clicked = true;
    }

    /**
    Method is called when pointer moves on the screen.
    @method pointerDragged
    @protected
    @param x {Integer} X-coordinate in pixels from the left top screen corner
    @param y {Integer} Y-coordinate in pixels from the left top screen corner
    */
    function pointerDragged(x, y)
    {
    }

    /**
    Method is called when pointer was released. This method detects onClick event
    @method pointerReleased
    @protected
    @param x {Integer} X-coordinate in pixels from the left top screen corner
    @param y {Integer} Y-coordinate in pixels from the left top screen corner
    */
    function pointerReleased(x, y)
    {
        var result;

        if (!this._clicked)
            return;

        if (this.click)
            result = this.click.call(this);

        this._clicked = false;

        return result;
    }

    /**
    Method is called when the user clicks on the object.
    @method click
    @protected
    */

    /**
    The onClick event occurs when the user clicks on the object.
    @event onClick
    */
    property onClick(v)
    {
        get return this.click;
        set
        {
            if(typeof(v) != #function || v == null)
                throw new InvalidArgument("[Button.onClick] Instance of function expected");
            this.click = v;
        }
    }
}