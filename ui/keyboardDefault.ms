include "code://ui/keyboard.ms"

class KeyboardDefault
{
    function this(owner)
    {
        assert owner instanceof Keyboard;
        this._owner = owner;
        this._shift = 0;
        this._buttons = new Array();
        this._map = this._getMap();
        this._build();
    }
    function _getMap()
    {
        return [
            [ // 0 - #altABC
                ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                [#shift, "z", "x", "c", "v", "b", "n", "m", #backspace],
                [#alt123, ".", #space, ","/*, #enter*/]
            ],
            [ // 1 - #alt123
                ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                ["+", "-", "/", ":", ";", "(", ")", "%"],
                [#altSYM, "@", "#", ";", "?", "!", "\"", "'", #backspace],
                [#altABC, ".", #space, ","/*, #enter*/]
            ],
            [ // 2 - #altSYM
                ["[", "]", "{", "}", "#", "+", "-", "*", "/", "="],
                ["_", "\\", "|", "~", "<", ">", "^", "%"],
                [#alt123, "\u20AC" /*euro*/, "$", "\u00A3" /*libra*/, "\u00A5" /*yen*/, "\u00A9" /*(c)*/, "\u00AE" /*(R)*/, "\u2122" /*TM*/, #backspace],
                [#altABC, ".", #space, ","/*, #enter*/]
            ]
        ];
    }
    function _build(index = 0)
    {
        var layout, native = this._owner.native;
        var existing, altRow, alt = this._map[index];
        var rows = alt.length;
        for(var r = 0; r < rows; r++) {
            var name = this._owner.name + String.printf(".row[%d]", r);
            existing = native.find(name);
            var row = existing || new Moscrif.View(name);

            var cols = alt[r].length;
            altRow = alt[r];
            for(var c = 0; c < cols; c++)
                this._buildButton(row, c, altRow[c]);
            if (!existing) {
                row.width = System.width;
                row.visible = true;
                
                native.add(row, #front);
                layout = new Moscrif.StackLayout();
                layout.orientation = #horz;
                layout.align = #center;
                layout.pack = #center;
                row.layout = layout;
            }
        }
        layout = new Moscrif.StackLayout();
        layout.orientation = #vert;
        layout.align = #center;
        layout.pack = #center;
        native.layout = layout;
    }
    function _buildButton(row, index, text)
    {
        var name = row.name + String.printf(".cell[%d]", index);
        //var existing = row.find(name); // this returns View not custom script method!!!
        var existing = this._buttons.filter(:x :x.name == name);
        existing = existing.length > 0 ? existing[0] : null;
        var btn = existing || new KeyboardButton(name);
        //logI(name, index, text);
        btn.text = text;
        if (!existing) {
            btn.onKey = :sender, key :this super._handleKey(key);
            row.height = btn.height;
            row.add(btn.native, #front);
            this._buttons.push(btn);
        }
    }
    function _changeCase(toUpper = true)
    {
        var buttons = this._buttons;
        for (var i = buttons.length - 1; i >= 0; i--)
            if (buttons[i] != undefined && typeof buttons[i].text == #string) {
                if (toUpper)
                    buttons[i].text = buttons[i].text.toUpperCase();
                else
                    buttons[i].text = buttons[i].text.toLowerCase();
                //buttons[i].invalidate();
            }
    }
    function _handleKey(key)
    {
        switch(key) {
            case #alt123:
                this._shift = 0;
                //this._buttons = this._getButtons(1);
                this._build(1);
                return false;
            case #altABC:
                this._shift = 0;
                //this._buttons = this._getButtons(0);
                this._build(0);
                return false;
            case #altSYM:
                this._shift = 0;
                //this._buttons = this._getButtons(2);
                this._build(2);
                return false;
            case #shift:
                this._shift++;
                if (this._shift > 2) this._shift = 0;
                this._changeCase(this._shift > 0);
                return false;
        }
        if (typeof key == #string && this._shift > 0) key = key.toUpperCase();

       // this._owner.notify_onKey(key);
        if (typeof this._owner._onKeyHandler == #function)
                    this._owner._onKeyHandler(this._owner, key);

        if (this._shift == 1) {
            this._shift = 0;
            this._changeCase(false);
            //this._container.invalidate();
        }

        return true;
    }

}
