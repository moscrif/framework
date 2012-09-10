include "lib://uix/base/scrollContainer.ms";
include "lib://uix/control/list/list.ms";
include "lib://uix/dialog/dialog.ms"

class ComboBox : ScrollContainer
{
    function init()
    {
        super.init();

        //Init painters
        this._border = new Paint();
        this._border.style = #stroke;

        this.native.scrollMode = #horz;
        this.native.focusable = false;

       /* this._editor = new TextView();
        this._editor.focusable = true;
        this._editor.readOnly = true;
        this._editor.left = this._editor.top = 0;*/

        //Init text and text separator
        this._text = "";
        this._separator = " ";
        this._align = #left;

        //Init containers
        this._elements = [];
        this._active = [];
        this._multi = false;

        //Init event states
        this._pressed = false;
        this._dragged = false;
        this._hideEnable = true;
        this._index = 0;

        this._elementsWidth = System.width - 20;
        this._editHeight = 0;
        this._marginX = 10;
        this._marginY = 10;

        this._clicked = false;

        this._onPointerPressedHandler = function (sender, x, y)
        {
            this._clicked = true;
            this.invalidate();
        }

        this._onPointerReleasedHandler = function (sender, x, y)
        {
            var self = this super;
            var dialog = new Dialog({width: System.width, height: System.height / 3 , bg : { color : 0xc8000000}});
            dialog.layout.spacer = dialog.height / 15;
            dialog.height = 4 * System.height / 10;
            dialog.top = System.height - dialog.height;

    
            //Create button
            var okButton = new Button();
            okButton.height = System.height / 12;
            okButton.dialog = dialog;
    
            if (this._multi) {
                okButton.text = "Ok";
                okButton.onClick = function ()
                {
                    self.text = "";
                    for (var i in self._elements) {
                        if (i.active)
                            self.text = self.text + i.text + (self._multi?self._separator:"");
                    }
                    this.dialog.close();
                };
            } else {
                okButton.text = "Cancel";
                okButton.onClick = function () {this.dialog.close();};
            }

            //Create List
            var list = new List({stretch : #both});
            list.onPointerReleased = function(self, x, y) {if (self._multi)   self._hideEnable = false;}
            list.onDraw = function (self, canvas) {canvas.clear(0x00000000);}

            //Add elements to the list
            for (var e in this._elements) {
                e.dialog = dialog;
                e.checkable = this._multi;
                list.add(e.copy());
                list.invalidate();
            }

            //Add components
            dialog.add(okButton);
            dialog.add(list);
            dialog.showModal();


            this._clicked = false;
            this.invalidate();
        }
    }

    property width(v)
    {
        get return this.native.width;
        set this.native.width = v;
    }

    property height(v)
    {
        get return this.native.height;
        set this.native.height = v;
    }

    property text(v)
    {
        get return this._text;
        set {
            this._text = v;
            this.invalidate();
        }
    }

    property elementsWidth(v)
    {
        get return this._elementsWidth;
        set this._elementsWidth = v;
    }

    property multi(v)
    {
        get return this._multi;
        set this._multi = v;
    }

    property elements(v)
    {
        get return this._elements;
    }

    property align(v)
    {
        get return this._align;
        set this._align = v;
    }

    property active(v)
    {
        get return (this._multi?this._active:(this._active.length>0)?this._active[0]:null);
        set {
            if (this._multi)
                for (var i in v) {
                    var index = this._elements.indexOf(i);
                    if (index == -1)
                        this.add(i);

                    i.active = true;
                    index = this._active.indexOf(i);
                    if (index == -1)
                        this._active.push(i);
                }
            else {
                this._cleanActive();
                v.checkable = false;
                this._active.push(v);
            }

            this.text = "";
            for (var i in this._active) {
                this.text = this._text + i.text + (this._multi?"; ":"");
            }
            this.invalidate();
        }
    }

    property separator(v)
    {
        get return this._separator;
        set this._separator = v;
    }

    property clicked(v)
    {
        get return this._clicked;
        set this._clicked = v;
    }

    property pressed(v)
    {
        get
        {
            if(this._pressed == null)
                this._pressed = Pattern.create(Pattern,this,"pressed");

            return this._pressed;
        }
        set
        {
            if(v instanceof Pattern)
                this._pressed = v
            else
                 throw new InvalidArgument("[Button.pressed] Accepts instance of Pattern");

        }
    }


    function add(e)
    {
        this._elements.push(e);

        e.parent = this;
        e._id = this._index++;
    }

    function _elementsHeight()
    {
        var height = 0;
        for (var i in this._elements)
            height += i.height;
        return height;
    }

    function _cleanActive()
    {
        for (var i = this._active.length-1; i >= 0; --i)
            this._active.remove(i);
    }
}