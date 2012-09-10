include "lib://uix/control/navigation/barBase.ms";
include "lib://uix/layout/horizontalLayout.ms";

/**
@package uix
@location uix/control/navigation/toolBar.ms

ToolBar definition.
*/
class ToolBar : BarBase
{
    /**
    Init ToolBar controls
    */
    function init()
    {
        super.init();
        this.position = #bottom;
         // set layout
        this.layout = new HorizontalLayout();
    }

    /**
    Own toolbar add functionality. Each time new Control is added ot tool bar , width of controls is recalculated
    @param Control v
    */
    function add(v)
    {
        this._elements.push(v);
        for (var i in this._elements)
            i.width = this.width / this._elements.length;
        this.native.add(v);
        if (v.height > this.height)
            this.height = v.height + this._marginY;
    }
}