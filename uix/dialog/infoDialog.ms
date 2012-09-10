include "lib://uix/dialog/dialog.ms";
include "lib://uix/control/button.ms";
include "lib://uix/control/label.ms";

/**
@package uix
@location uix/dialog/infoDialog.ms

Info dialog, displays modal window with message and button OK
*/
class InfoDialog : Dialog
{
    /**
    Info Dialog controls init
    */
    function init()
    {
        super.init();
        this._label = new Label({ stretch: #both, horzAlign: #center});
        this.add(this._label);

        this._okBtn = new Button({text: "OK"})
        this.add(this._okBtn);
        this._okBtn.onClick = function(sender)
        {
            if (this super._onOkHandler)
                this super._onOkHandler(sender);
            this super.close();
        }

        // handlers
        this._onOkHandler = null;
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
    On OK Event. What application should do when ok button is pressed

    @event
    @param Object sender Object what caused this event
    @return Function
    */
    property onOk(v)
    {
        get return this._onOkHandler;
        set {
            if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[InfoDialog.onOk]");
            this._onOkHandler = v;
        }
    }

}
