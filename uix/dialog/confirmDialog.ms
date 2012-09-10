include "lib://uix/dialog/dialog.ms";
include "lib://uix/control/button.ms";
include "lib://uix/control/row.ms";

/**
@package uix
@location uix/dialog/confirmDialog.ms

Confirmation dialog, displays text dialog nad ok and cancel button
*/
class ConfirmDialog : Dialog
{
    /**
    Confirm Dialog init controls
    */
    function init()
    {
        super.init();
        this._label = new Label({ stretch: #both, horzAlign: #center});
        this.add(this._label);

        this._quit = true;

        this._onOkHandler = null;
        this._onCancelHandler = null;

        this._okButton = new Button({text: "Ok", stretch: #both, style : { bg: {color: 0xff0e8e45}}});
        this._cancelButton = new Button({text: "Cancel", stretch: #both});

        this._okButton.onClick = function (sender, x, y)
        {
            this super.close();
            if (this super._onOkHandler != null)
                this super._onOkHandler(sender);

        }
        this._cancelButton.onClick = function (sender, x, y)
        {
            if (this super._onCancelHandler != null)
                this super._onCancelHandler(sender);
            this super.close();
        }

        this._row = new Row({stretch: #both});
        this.add(this._row)

        this._row.add(this._okButton);
        this._row.add(this._cancelButton);

    }

    /**
    Text property
    @param String v
    @return String
    */
    property text(v)
    {
        get return this._label.text;
        set this._label.text = v;
    }

    /**
    Foreground drawing of label
    @param Foreground v
    @return Foreground
    */
    property fg(v)
    {
        get return this._label.fg;
        set this._label.fg = v;
    }

    /**
    Dialog label
    @param String v
    @return String
    */
    property label(v)
    {
        get return this._label;
    }

    /**
    OK Button
    @param Button v
    @return Button
    */
    property okButton(v)
    {
        get return this._okButton;
    }

    /**
    Cancel Button
    @param Button v
    @retrun Button
    */
    property cancelButton(v)
    {
        get return this._cancelButton;
    }

    /**
    On OK event

    @event
    @param Object sender Object what caused this event
    @return Funciotn
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

    /**
    On cancel event

    @event
    @param Object sender Object what caused this event

    @return Function
    */
    property onCancel(v)
    {
        get return this._onCancelHandler;
        set {
            if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[InfoDialog.onCancel]");
            this._onCancelHandler = v;
        }
    }
}