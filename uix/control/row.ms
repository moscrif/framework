include "lib://uix/layout/horizontalLayout.ms";

/**
@package uix
@location uix/control/row.ms
Container holds controls in horizontal align, used in form, list item, etc
*/
class Row : StaticContainer
{
    /**
    Init of Row control.
    Add stack layout with horizontal orientation
    */
    function init()
    {
        super.init();
        this.layout = new HorizontalLayout();
    }
}