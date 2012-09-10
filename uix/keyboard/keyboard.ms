include "lib://uix/base/staticContainer.ms"
include "lib://uix/control/row.ms"
include "lib://uix/keyboard/keyboardButton.ms"
include "lib://uix/keyboard/keyboardMap.ms"
include "lib://uix/keyboard/keyPreview.ms";

include "lib://uix/layout/layout.ms";

/**
@package uix
@location uix\keyboard\keyboard.ms

Keyboard class definition. Keyboard class provides all operations with keyboard.
The class defines onKey event, which occurs when user click on a key.
Class provides various maps of keyboards, which may be set by map property. Every map can supports various keyboards, what is specified by keyboardType property.

*/

class Keyboard : StaticContainer
{
    /**
    Keyboard init controls
    */
    function init()
    {
        super.init();

        //do not focus on keyboard
        this.native.focusable = false;
        this.focusable = false;

        //do not focuse on keyboard
        this.focusable = false;
        this.layout = new Layout();
        this._buttons = new Array();
        this._rows = new Array();
        this._keyboardStyle = null;

        // create dialog for key preview
        this._preview = null;
        // load default map
        this.map = new KeyboardMap({source : "lib://uix/keyboard/defaultKeyboard.mso"});
        // shift state (0 for low cases, 1 for one upper case, 2 for all upper case)
        this._shiftState = 0;
    }

    /**
    Keyboard after init controls
    */
    function afterInit()
    {
        super.afterInit();
        this._state = #letters;
        this.keyboardType = #default;
    }

    /**
    Instance of KeyboardPreview, which is used for key symbol preview.
    @return instance of KeyboardPreview
    @see-also KeyboardPreview class
    */
    property preview(v)
    {
        return this._preview;
    }

    /**
    Number of rows in the keyboard
    @return Integer
    @param Integer
    */
    property rows(v)
    {
        get return this._rows;
        set this._rows = v;
    }

    /**
    Keyboard map
    @param KeyboardMap
    @return KeyboardMap
    */
    property map(v)
    {
        get return this._map;
        set {
            if (v instanceof KeyboardMap)
                this._map = v;
            else
                throw new InvalidArgument("[Keyboard.map] Accepts instance of KeyboardMap class");
        }
    }

    /**
    Keyboard style (setting is mainly used by skin)
    @param Object
    @return Object
    */
    property keyboardStyle (v)
    {
        get return this._keyboardStyle;
        set this._keyboardStyle = v;
    }

    /**
    Keyboard type
    @param Symbol By default #default, #web, #email, #pin and #phone are supported, but diferent keyboard maps may be also other supported types
    @return Symbol
    */
    property keyboardType(v)
    {
        get return this._keyboardType;
        set {
             switch (v) {
                case #default:
                    this.switchKeyboard(#defaultType, this._state);
                    this._type = #defaultType;
                break;
                case #web:
                    this.switchKeyboard(#webType, this._state);
                    this._type = #webType;
                break;
                case #email:
                    this.switchKeyboard(#emailType, this._state);
                    this._type = #emailType;
                break;
                case #pin:
                    this.switchKeyboard(#pinType, #letters);
                    this._type = #pinType;
                break;
                case #phone:
                    this.switchKeyboard(#phoneType, #letters);
                    this._type = #phoneType;
                break;
                default:
                    if (!this.switchKeyboard(v, this._state))
                        throw new InvalidArgument("[Keyboard.keyboardType] Supported types are: #defaultKeyboard, #numberPunctuationKeyboard, #numberSymbolsKeyboard, #webKeyboard and #emailKeyboard");
                break;
            }
            this._keyboardType = v;

        }
    }

    /**
    Keyboard state
    @param Symbol By default #letters, #symbols and #numbers are supported, but diferent keyboard maps may support also other states
    @return Symbol
    */
    property keyboardState(v)
    {
        get return this._state;
        set
            if (v instanceof Symbol) {
                if (!this.switchKeyboard(this._type, v))
                        throw new InvalidArgument("[Keyboard.keyboardState] These keyboard state is not supported by current keyboard map");
                this._state = v;
            } else
                throw new InvalidArgument("[Keyboard.keyboardState] Accepts instance of Symbol");
    }

    /**
    On key event
    @event
    @param Object sender Object what caused this event
    @param Symbol|Char key value
    @return Function
    */
    property onKey(v)
    {
        get { return this._onKeyHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onKeyHandler = v;
        }
    }

    /**
    Switch Keyboard switch cirent keyboard to new keyboard acording to reguired type and state
    @param Symbol keyboard type
    @param Symbol keyboard state
    @return Boolean true - succes
                    false - required type or state is not supported by map
    */
    function switchKeyboard(keyboardType, state)
    {
        // get map (if exists)
        var map;
        try {
            map = this._map.propertyAt(keyboardType).propertyAt(state);
            if (!map)
                return false;
        } catch(err) {
            return false;
        }

        // create required number of rows for keyboard (acording to current map)
        this._createRows(map.length);

        // go throw rows
        for (var i = 0; i < map.length; i++) {
            //add all buttons to the row
            this._fillRow(map[i], keyboardType, state, i);
        }
        if (this._shiftState == 1 || this._shiftState == 2)
            this._toUpperCase();

        this._applyStyles(keyboardType, state);
        return true;
    }

    /**
    Fill Row adds buttons to one keyboard row
    @param map of the row
    @param kyboard type
    @param kyboard state
    @param Integer index of row
    */
    function _fillRow(map, keyboardType, state, i)
    {
         for (var q = 0; q < map.length; q++) {
            // check if extsts array for this row
            if (q > this._buttons[i].length - 1) {
                this._buttons[i].push(new KeyboardButton({symbol: map[q][0].symbol}));
                this._buttons[i][q].row = i;
                this._buttons[i][q].highlight = map[q][0].highlight ? map[q][0].highlight : false;
                this._buttons[i][q].onPointerReleased = function(sender, x, y) {this super._reportRelease(sender, x, y);}
                this._buttons[i][q].onPointerPressed = function(sender, x, y) {this super._reportPressed(sender, x, y);}

                this._rows[i].add(this._buttons[i][q], #front);
            } else {
                this._buttons[i][q].symbol = map[q][0].symbol;
                this._buttons[i][q].onPointerReleased = function(sender, x, y) {this super._reportRelease(sender, x, y);}
                this._buttons[i][q].highlight = map[q][0].highlight ? map[q][0].highlight : false;
            }


            //apply diferent style for special buttons
            var buttonStyle = null;
            var symbol = this._buttons[i][q].symbol;
            if(typeof symbol == #string) continue;

            if (this.specialButtons[keyboardType][state] && this.specialButtons[keyboardType][state].exists(symbol))
                buttonStyle = this.specialButtons[keyboardType][state][symbol];
            else if (this.specialButtons[keyboardType] && this.specialButtons[keyboardType].exists(symbol))
                buttonStyle = this.specialButtons[keyboardType][symbol];
            else if (this.specialButtons && this.specialButtons.exists(symbol))
                buttonStyle = this.specialButtons[symbol];

            if (buttonStyle && buttonStyle!=null){
                this._buttons[i][q]._setDefaults(buttonStyle);
            }

        }

        // dolete buttons if needed
        for (var q = map.length; q<this._buttons[i].length; q) {
            this._buttons[i][q]._view.detach();
            this._buttons[i].remove(q);
        }
        this._rows[i].performLayout();

    }

    /**
    Create rows
    @param Integer number of rows required by current leyboard
    */
    function _createRows(length)
    {
        // create rows if needed
        for (var i = this._rows.length; i<length; i++) {
            this._buttons.push(new Array());
            this.add(this._rows.push(new Row()));
        }
        // delete rows if needed
        for (var i = length; i<this._rows.length; i) {
            this._rows[i]._view.detach();
            this._rows.remove(i);
            this._buttons.remove(i);
        }
    }

    /**
    Change symbols on buttons to lower case
    */
    function _toLowerCase()
    {
        // go throw all buttons
        for (var i = 0; i < this._buttons.length; i++) {
            for (var q = 0; q < this._buttons[i].length; q++) {
                // check if symbol is one character to resize
                if (this._buttons[i][q].symbol instanceof String && this._buttons[i][q].symbol.length == 1) {
                    // if symbol is large char (in ansci from 65 to 91
                   this._buttons[i][q].symbol = this._buttons[i][q].symbol.toLowerCase();
               }
            }
        }
    }

    /**
    Change symbols on buttons to upper case
    */
    function _toUpperCase()
    {
        var buttons = this._buttons;
        // go throw all buttons
        for (var i = 0; i < this._buttons.length; i++) {
            for (var q = 0; q < this._buttons[i].length; q++) {
                // check if symbol is one character to resize
                if (this._buttons[i][q].symbol instanceof String && this._buttons[i][q].symbol.length == 1) {
                    // if symbol is large char (in ansci from 65 to 91
                   this._buttons[i][q].symbol = this._buttons[i][q].symbol.toUpperCase();
               }
            }
        }
    }

    /**
    Report pressed shows keyboard preview and do other operations after key pressed
    @param pressed button
    @param Integer x-coordinate
    @param Integer y-coordinate
    */
    function _reportPressed(item, x, y)
    {
        if (typeof item.symbol != #symbol && this._typeNumber != 5 && this._typeNumber != 6) {
            if (this._preview == null) {
                this._preview = new KeyPreview({visible : true});
                Application.instance.add(this._preview, true, #front);
            } else {
                this._preview.visible = true;
            }
            // calculate position for review
            this._preview.left = item.left - (this._preview.width - item.width) / 2;
            // check if part of view does not lay outside of screen
            if (this._preview.left < 0)
                this._preview.left = this._preview.width / 10;
            
            if (this._preview.left > System.width - this._preview.width)
                this._preview.left = System.width - 11 * this._preview.width / 10;
            
            this._preview.symbol = item.symbol;
            this._preview.top = item.top + this.top + item.row * this._rows[0].height - 11 * this._preview.height / 10;
        }
    }

    /**
    Report pressed do operations after key pressed and call onKey event
    @param pressed button
    @param Integer x-coordinate
    @param Integer y-coordinate
    */
    function _reportRelease(item, x, y)
    {
        if (this._preview != null)
            this._preview.visible = false;
        // call some specified functions special buttons
        switch (item.symbol) {
            case #alt123:
                this._state = #numbers;
                this.switchKeyboard(this._type, #numbers);
            break;
            case #altABC:
                this._state = #letters;
                this.switchKeyboard(this._type, #letters);
            break;
            case #altSymbols:
                this._state = #symbols;
                this.switchKeyboard(this._type, #symbols);
            break;
            case #shift:
                switch (this._shiftState) {
                    // there are low cases change to upeer
                    case 0:
                        this._toUpperCase();
                        item.value = 1;
                        this._shiftState = 1;
                    break;
                    // there are upper cases only change to pernamently upper
                    case 1:
                        item.value = 2;
                        this._shiftState = 2;
                    break;
                    // change to upper cases
                    case 2:
                        this._toLowerCase();
                        item.value = 0;
                        this._shiftState = 0;
                    break;
                }
            break;
            default:
                if (this._onKeyHandler != null) {
                    var s = item.symbol;
                    if (s == #space)
                        s = " ";
                    this._onKeyHandler(this, s);
                }
                // if one upper key was pressed change keyboard to lower case
                if (this._shiftState == 1) {
                    this._toLowerCase();
                    this._shiftState = 0;
                }
            break;
        }
    }

    /**
    Apply styles
    @param keyboard type
    @param keyboard state
    */
    function _applyStyles(keyboardType, state)
    {
        if(this.keyboardStyle != null && this.keyboardStyle.exists(keyboardType)){

            for (var i = 0; i <this.rows.length; i++) {
                this.rows[i].layout.align = this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].align ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].align : #stretch;
                this.rows[i].stretch = this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].stretch ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].stretch : #both;
                this.rows[i].height = this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].height ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].height : 10;

                this.rows[i].layout.pack = #start;
                this.rows[i].layout.spacer = this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].spacer ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].spacer : 0;
                this.rows[i].layout.setMargin(this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginX ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginX : 0, this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginY ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginY : 0, this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginX ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginX : 0, this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginY ? this.keyboardStyle.propertyAt(keyboardType).propertyAt(state)[i].marginY : 0);
                this.performLayout();
            }

       }else{
            logW("Unsupported keyboard type :",keyboardType);
       }
    }
}