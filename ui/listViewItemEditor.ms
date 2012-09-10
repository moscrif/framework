include "code://ui/listView.ms"
include "code://ui/label.ms"
include "code://ui/textBox.ms"

class ListViewItemEditor : ListViewItem
{
    var counter = 0; // static!
    function this(name = null, text = null, value = null)
    {
        super(name || String.printf("listViewItemEditor#%d", ListViewItemEditor.counter++), null, null);
        this.clickable = false;
        
        //events handlers
        this._onKeyboardRequest = null;
        
        var skin = Application.instance.skin;
        
        this._textBox = new TextBox(this._view.name + ".textBox", false, value);
        this._textBox.onChanged = :sender, text :this super._onTextChanged(text);
        this._textBox.onFocusChanged = :sender, gainFocus {var self = this super; if (gainFocus) if (typeof self._onKeyboardRequestHandler == #function) self._onKeyboardRequestHandler(self);};
        this._label = new Label(this._view.name + ".label", text, false);
        
        this.add(this._textBox);
        this.add(this._label);
        
        skin.initListViewItemEditor(this);
    }
    //@event #onKeyboardRequest; // (sender)
     property onKeyboardRequest(v)
    {
        get { return this._onKeyboardRequestHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onKeyboardRequestHandler = v;
        }
    }
    property value(v) {
        get return this._textBox.text;
        set this._textBox.text = v;
    }
    property label(v) { get return this._label; }
    property textBox(v) { get return this._textBox; }
    function _onTextChanged(text)
    {
        text = text||"";
        this._drawHint = (text.length == 0);
        this.native.invalidate();
    }
}
