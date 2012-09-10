include "lib://uix/base/staticContainer.ms";
include "lib://uix/layout/verticalLayout.ms";
/**
@package uix
@location uix/view.ms
*/
class View : StaticContainer
{
    /**
        Init form controls, it sets width, height to system variables
    */
    function init()
    {
        super.init();
        this.native.width = System.width;
        this.native.height = System.height;

        this.layout = new VerticalLayout();

        this._controller = null;

    }


    property controller(v)
    {
        get return this._controller;
        set {
            this._controller = v;
        }
    }

}
