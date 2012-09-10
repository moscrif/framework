include "lib://uix/base/scrollContainer.ms"

include "lib://uix/layout/verticalLayout.ms";

/**
@package uix
@location uix/control/list/list.ms

Class creates list object, which should be filled with instances of ListItem
*/

class List : ScrollContainer
{
    /**
    Init Control
    */
    function init()
    {
        super.init();

        this.scrollMode = #vert;

        this.layout = new VerticalLayout();


    }




}