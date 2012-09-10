include "code://ui/listView.ms"
include "code://ui/label.ms"
include "code://ui/listViewItemButton.ms"

class ListViewItemPicker : ListViewItem
{
    var counter = 0;
    function this(name = null, text = null, value = null)
    {
    
        super(name || String.printf("listViewItemEditor#%d", ListViewItemPicker.counter++), null, null);
        
        var skin = Application.instance.skin;
        
         //events handlers
        this._onClickHandler = null;
        
        this._textBox = new TextBox(this._view.name + ".textBox", false, value);
        this._label = new Label(this._view.name + ".label", text, false);
        this._picker = new ListViewItemButton(this._view.name + ".button");
        this._picker.onClick = function(sender) {var self = this super; if (typeof self._onClickHandler == #function) self._onClickHandler(self); self._pressed = 0; self._view.invalidate();};
        
        this.add(this._picker);
        this.add(this._textBox);
        this.add(this._label);
        
        //this._textBox.text = value||"";
        
        skin.initListViewItemPicker(this);
        
        //logI(this._picker, "\n", this._picker.left, this._picker.top, this._picker.width, this._picker.height);

    }
    property label(v) { get return this._label; }
    property value(v) {
        get return this._textBox.text;
        set {
            //if (this._textBox.text == v) return;
            this._textBox.text = v;
            //this._textBox.invalidate();
        }
    }
    property textBox(v) { get return this._textBox; }
    property button(v) { get return this._picker; }
    //@event #onClick; // (sender)
    property onClick(v)
    {
        get { return this._onClickHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onClickHandler = v;
        }
    }
}
