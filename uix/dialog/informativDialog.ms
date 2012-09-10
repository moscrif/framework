include "lib://uix/dialog/dialog.ms";
include "lib://uix/control/button.ms";
include "lib://uix/control/label.ms";

/**
@package uix
@location uix/dialog/informativDialog.ms

    Dialog which shows and then disappear automatically
*/
class InformativDialog : Dialog
{
    /**
    Info Dialog controls init
    */
    function init()
    {
        super.init();
        this._label = new Label({ stretch: #both, horzAlign: #center});
        this.add(this._label);

        /*this.native.onDraw = function(s, c)
        {
            logI("kreslim");
            c.clear(0xffff0000);
        }*/

        this._overlay = null;
    }

    /**
    Text of Dialog
    @param String v
    @return String
    */
    property text(v)
    {
        get return this._label.text;
        set this._label.text = v;
    }

    /**
    Foreground drawing of Label
    @param Foreground
    @return Foreground
    */
    property fg(v)
    {
        get return this._label.fg;
        set this._label.fg = v;
    }

    /**
    Dialog label
    @return String
    */
    property label(v)
    {
        get return this._label;
    }

    /**
    Displays dialog as modal window
    */
    function showModal()
    {
        super.showModal();
        // auto hide dialog
        var hideTimer = new Timer(25, false);
        hideTimer.onTick = function(sender) {
            var self = this super;
            this super.close();
            hideTimer.dispose();
        }
        hideTimer.start(2500);
    }
}