include "lib://graphics/patterns/boxPattern.ms";
include "lib://uix/control/item.ms";

class ComboItem : Item
{
    function init()
    {
        super.init();

        this._checkable = false;
        this._on = null;
        this._off = null;
        this._activeImage = null;
        this._box = null;
        this._active = false;
        this._parent = null;
        this._id = 0;
        this._align = #left;
        this._boxAlign = #right;
        this._enabled = true;
        this._checked = false;

        this._onPointerReleasedHandler = function (sender, x, y)
        {
            var self = this super;
            this.clicked = false;
            this.invalidate();
            if (this._parent == null)
                throw new NullPointer("[ComboItem._onPointerReleased]");
            if (this._parent._dragged)
                this._parent._dragged = false;
            else {
                if (this._parent._multi) {
                    this.active = !this.active;
                    this._parent._elements[this._id].active = this.active;
                }
                else {
                    for (var e in this._parent._elements)
                        e.active = false;
                    this.active = true;

                    this._parent.text = this._text;
                    this.dialog.close();
                }
            }
    
            if (this._onClickHandler)
                this._onClickHandler(self, x, y);
        }

        this.native.onParentScroll = function(sender, parent)
        {
            if (parent == null)
                throw new NullPointer("[ComboItem._onPointerReleased]");
            this super._parent._dragged = true;
        }
    }

    property box(v)
    {
        get
        {
            if(this._box == null)
              this._box = BoxPattern.create(BoxPattern,this,"box");

            return this._box;
        }
    }

    property text(v)
    {
        get return this._text;
        set this._text = v;
    }

    property checkable(v)
    {
        get return this._checkable;
        set {
            this._checkable = v;
            if (this._checkable) {
               // this.align = #right;
               /* this.imageOn = this.style.imageOn;
                this.imageOff = this.style.imageOff;*/
                this._activeImage = this._off;
            }
        }
    }


    property checked(v)
    {
        get return this._active;
        set {
            this._active = v;
            this.invalidate();
            
        }
    }

    property active(v)
    {
        get return this._active;
        set {
            this._active = v;
            if (this._active)
                this._activeImage = this._on;
            else
                this._activeImage = this._off;
            this.invalidate();
        }
    }

    property textAlign(v)
    {
        get return this._align;
        set {
            this._align = v;
            this.invalidate();
        }
    }

    property boxAlign(v)
    {
        get return this._boxAlign;
        set {
            this._boxAlign = v;
            this.invalidate();
        }
    }

    property parent(v)
    {
        get return this._parent;
        set this._parent = v;
    }

    property onClick(v)
    {
        get return this._onClickHandler;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[ComboItem.onClick]");
             this._onClickHandler = v;
        }
    }

    property enabled(v)
    {
        get return this._enabled;
        set {
            this._enabled = v;
        }
    }


    function _onPointerDragged(sender, x, y)
    {
        this._dragged = true;
    }

    function copy()
    {
        var _copy = new ComboItem();
        _copy._checkable = this._checkable;
        _copy._on = this._on;
        _copy._off = this._off;
       // _copy._off = this._off;
        _copy.width = this.width;
        _copy.height = this.height;

        _copy.active = this.active;
        _copy._parent = this._parent;
        _copy._id = this._id;
        _copy.dialog = this.dialog;

        _copy._text = this._text;
        _copy._icon = this._icon;
        _copy._background = this._background;
        _copy._value = this._value;
        _copy._badge = this._badge;
        _copy._pressed = this._pressed;

        _copy._textPaint = this._textPaint;
        _copy._textWidth = this._textWidth;
        _copy._textHeight = this._textHeight;

        _copy._marginX = this._marginX;
        _copy._marginY = this._marginY;
        //_copy._align = this._align;

       // _copy._onPointerPressedHandler = this._onPointerPressedHandler;
        _copy._onClickHandler = this._onClickHandler;
        _copy._onPointerReleasedHandler = this._onPointerReleasedHandler;
        _copy._onDrawHandler = this._onDrawHandler;

        return _copy;
    }
}