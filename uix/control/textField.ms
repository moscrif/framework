include "lib://uix/control/textBox.ms";
include "lib://core/log.ms";
/**
@package uix
@location uix/control/textField.ms

Control to define label and textBox in one role
*/
class TextField : TextBox
{
    /**
    Init textdield controls
    */
    function init()
    {
        super.init();

        this._label = null;
        this._labelAlign = #left;
        this._change = false;
    }

    /**
    Definition of Label
    @param Label v
    @return Label
    */
    property label(v)
    {
        get {
            if (this._label == null) {
                this._label = new Label();
                this.add(this._label);
                this._change = true;
            }
            return this._label;
        }
        set {
            if (v instanceof Label)
                this.label.text = v.text;
            else  try{
                this.label.text = v;
            }
            catch (ex) {
                throw new Exception("[TextField.label]", ex);
            }
            this._setSize();
        }
    }

    /**
    Label align
    @param Symbol
    @return Symbol
    */
    property labelAlign(v)
    {
        get return this._labelAlign;
        set {
            this._labelAlign = v;
            this._setSize();
        }
    }


}