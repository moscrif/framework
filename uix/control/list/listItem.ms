include "lib://uix/control/item.ms"

/**
@package uix
@location uix/control/list/listItem.ms

List item class definition.
*/
class ListItem : Item
{
    /**
    Init listItem Control
    */
    function init()
    {
        super.init();
        // handlers
        this._onClickHandler = null;

        // text and icon align
        this._iconAlign = #left;
        this._horzAlign = #left;
        this._marginX = 3;

    }



}