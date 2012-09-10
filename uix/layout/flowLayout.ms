include "lib://uix/layout/layout.ms"

/**
Flow layout flows controls on its horizontal and vercical.
If controls width fits owner width they stays in one line.
In the case controls width is greater than owner with,
controls start to pack horizontally and vertically.
*/
class FlowLayout : Layout
{

    function init()
    {
        this._native = null;
        this._valign = #top;
        this._align = #left;
    }

    /**
    Setting vertical alignment
    @param Symbol v
        #top,#center,#bottom
    */
    property valign(v)
    {
        get return this._valign;
        set {
            this._valign = v;
        }

    }

    /**
    Horizontal alignment
    @param Symbol v
        #right,#center,#left,#fill
    */
    property align(v)
    {
        get return this._align;
        set {
            this._align = v;
        }
    }

    function performLayout()
    {
        //do not perform layout if layout is suspended
        if(this._suspend) return false;

        var parent = this.owner;
        var horzPadding = (parent.paddingLeft + parent.paddingRight);
        var vertPadding = (parent.paddingTop + parent.paddingBottom);
        var curTopLine = parent.paddingTop;
        var curLeftLine = this._align == #left ? parent.paddingLeft : parent.width - horzPadding;
        var curBottomLine = this._valign == #top ? 0 : parent.height - vertPadding;

        for (var child in this.owner) {

            if (this._align == #left && curLeftLine + child.width > parent.width) {
                curTopLine  =  curBottomLine + vertPadding;
                curLeftLine = horzPadding;
            }

            if (this._align == #right && curLeftLine < horzPadding) {
                curTopLine = curBottomLine + vertPadding;
                curLeftLine = parent.width - horzPadding;
            }

            child.setPosition(curLeftLine - (this._align == #left ? 0 : child.width), curTopLine);

            curLeftLine = this._align == #left ? curLeftLine + child.width + horzPadding : curLeftLine - child.width - horzPadding;

            if (curBottomLine < curTopLine + child.height)
                curBottomLine = curTopLine + child.height;

        }
    }

}