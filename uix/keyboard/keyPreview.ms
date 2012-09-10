include "lib://uix/base/staticContainer.ms"
/**
@package uix
@location uix/keyboard/keyPreview.ms

KeyPreview class definitio.
Instance of this function shows key preview, when user click on some key.

*/

class KeyPreview : StaticContainer
{
    /**
    Button init controls
    */
    function init()
    {
        super.init();
       
        this._symbol = null;
        this._textPaint = new Paint();

        // set default position, this is not important, because item is hide
        this.left = 100;
        this.top = 50;
        this.visible = false;
    }
}