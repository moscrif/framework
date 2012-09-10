include "lib://uix/base/scrollContainer.ms"
include "lib://uix/layout/verticalLayout.ms";

/**
@package uix
@location uix/control/tile/tile.ms

Class creates tile object, which should be filled with instances of TileItem later
*/
class Tile : ScrollContainer
{
    /**
    Init Tile controls
    */
    function init()
    {
        super.init();
        this.layout = new VerticalLayout();
    }

}