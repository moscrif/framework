include "lib://uix/control/item.ms"

/**
@package uix
@location uix/control/tile/tileItem.ms

TitleItem class definition.
Apperance of Tittle control can be changed per application, it can be styled separately in application theme.

*/
class TileItem : Item
{
    function init()
    {
        super.init();
        //this._select = null;

       this._onPointerPressedHandler = function(sender, x, y)
        {
            this._clickedPossible = true;
            // lastX and lastY variable is used by drawing function on tileView (it may be used also in other controls inherited from this class)
            this._lastX = x;
            this._lastY = y;
            //this.invalidate();

           /* this._select = new Timer(25, false);
            this._select.onTick = function(sender) {
                var self = this super;
                self._clicked = true;
                self._select.dispose();
                self._select = null;
                self.invalidate();
            }
            this._select.start(400);*/
        }

        /*this._onPointerReleasedHandler = function(sender, x, y)
        {
           if (this._select != null) {
                this._select.dispose();
                this._select = null;
                this._clicked = true;
                this.invalidate();

                var deselect = new Timer(25, false);
                deselect.onTick = function(sender) {
                    var self = this super;
                    self._clickedPossible = self._clicked = false;
                    self.invalidate();
                    deselect.dispose();
                    if (self._onClickHandler != null)
                        return self._onClickHandler(sender, x, y);
                }
                deselect.start(40);
           } else {
                if (this._clicked) {
                    this._clicked = false;
                    this.invalidate();
                }
                if (this._onClickHandler != null)
                    return this._onClickHandler(sender, x, y);
            }
        }

        this._view.onParentScroll = function(sender, parent)
        {
            var self = this super;
            logI("scroll");
            if (self._select != null) {
                logI("stop");
                self._select.stop();
                self._select.dispose();
            }
            if (self._clicked) {
                self._clicked = false;
                self.invalidate();
            }
        }*/

    }
}