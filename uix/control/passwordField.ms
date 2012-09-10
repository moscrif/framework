include "lib://uix/control/textField.ms";

class PasswordField : TextField
{

    function init()
    {
        super.init();
        this._text;
        this._timer = 0;
        this._lastTick = 0;
    }

    property value(v)
    {
        get return this._editor.text;
        set {
            this._editor.text = v;
            this._text = v;
        }
    }

    function processKey(key)
    {
        switch (key) {
            case #space:
                key = " ";
                break;
            case #left:
            case #right:
            case #up:
            case #down:
            case #home:
            case #end:
            case #enter:
                return this._editor.doCursorKey(key);
            case #backspace:
                return this._editor.backspace();
        }
        if (typeof key == #string) {
            if (this._editor.text.length > 0 && this._editor.text[this._editor.cursorPos-1] != '\u2022') {
                var newText = this._editor.text;
                newText[this._editor.cursorPos-1] = '\u2022';
                this._text = this._editor.text;
                this._editor.text = newText;
                this._editor.invalidate();
            }

            key = key.charCodeAt(0);
            if (this.mode == #insert)
                this._editor.insert(key);
            else
                this._editor.replace(key);
            this._text = this._editor.text;
            this._timer = 0;
            this._isEmpty = (this._editor.text == ""?true:false);
        }
    }

    function _onProcess(sender)
    {
        if (this._timer == 0)
            this._lastTick = System.tick + 1;

        this._timer = System.tick - this._lastTick;

        if (this._timer > 800 && !this._isEmpty) {
            if (this._editor.text.length > 0 && this._editor.text[this._editor.cursorPos-1] != '\u2022') {
                var newText = this._editor.text;
                newText[this._editor.cursorPos-1] = '\u2022';
                this._text = this._editor.text;
                this._editor.text = newText;
                this._editor.invalidate();
            }
        }
    }

}