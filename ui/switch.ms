#include "code://ui/tools.ms"

class Switch
{
    var counter = 0; // static!
    function this(name = null)
    {
        var skin = Application.instance.skin;
        this._state = #on;       //#on or #off

        this._view = new View(name || String.printf("Switch#%d", Switch.counter++));
        this._view._script = this;
        this._view.left = 0; this._view.top = 0;
        this._view.width = this._view.height = 100;
        this._view.onDraw = function(sender, canvas) {canvas.clear(0xff00ff00);}//:sender, canvas :skin.drawLabel(canvas, sender._script);
        this._view.onPointerReleased = :sender, x, y {
            var self = this super;
            if (self._state == #on)
                self._state = #off;
            else
                self._state = #on;
            self.notify_onChanged( self._state);
            self._view.invalidate();
            return true;
        }
        _addViewProperties(this);
        //skin.initSwitch(this);
    }
    property name(v)
    {
        get return this._view.name;
    }
    property state(v)
    {
        get return this._state;
    }
    property native(v) {
        get return this._view;
    }
    @event #onChanged; // (sender, text)
}
