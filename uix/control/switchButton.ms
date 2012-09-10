include "lib://graphics/patterns/pattern.ms";

include "lib://uix/base/component.ms";
include "lib://uix/control/image.ms";
include "lib://uix/control/label.ms";

class SwitchButton : Button
{
    function init()
    {
        super.init();

        this._onPointerPressedHandler = function (sender, x, y)
        {
            var self = this super;
            if (self._enabled) {
                self._clicked = true;
                self.invalidate();
            }
        }

        this._onPointerReleasedHandler = function (sender, x, y)
        {
            var self = this super;
            if (self._enabled) {
                self._clicked = false;
                self.invalidate();

                if (self._onClickHandler != null)
                    self._onClickHandler(self, x, y);
            }
        }
    }

    property onPointerReleased(v)
    {
        get return this._onPointerReleasedHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Button.onClick]");
             this._onPointerReleasedHandler = v;
        }
    }

    property onPointerPressed(v)
    {
        get return this._onPointerPressedHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[Button.onClick]");
             this._onPointerPressedHandler = v;
        }
    }
}