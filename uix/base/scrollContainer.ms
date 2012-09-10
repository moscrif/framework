include "lib://uix/base/container.ms";

/**
    @package uix
    @location uix/base/scrollCOntainer.ms

    ScrollContainer instance is used to carry moscrif control.
    Scroll means, that objects are display on the screen and scrolling is availaible
*/
class ScrollContainer : Container
{
    /**
        Initialisation of controls. Native object is ScrollView.
    */
    function init()
    {
        //define view & instance of current object
        this._view = UIFactory.createScrollView(this);
        this._view.dockContent = #top;

        this.scrollMode = #vert;

        super.init();
    }

    /**
        Scroll Mode of Scroll View
        @param Symbol   #horz
                        #vert
                        #both
        @return Symbol
    */
    property scrollMode(v)
    {
        get return this.native.scrollMode;
        set this.native.scrollMode = v;
    }

    /**
    Function scrolls elements to coordinates (dx and dy).
    However, this function scrolls only in adjusted set
    scroll mode (horizontal or vertical).

    @param Integer dx horizontal coordinates
    @param Integer dy vertical coordinates

    @return ScrollView

    */
    function scrollBy(dx,dy)
    {
        return this.native.scrollBy(dx,dy);

    }

    /**
    Gets horizontal scroll.

    @return Integer
    */

    property scrollX(v)
    {
        get return this.native.scrollX;
    }

    /**
    Gets vertical scroll.

    @return Integer
    */

    property scrollY(v)
    {
        get return this.native.scrollY;
    }

     /**
    Function scrolls elements to coordinates (dx and dy).
    However, this function scrolls only in adjusted
    set scroll mode (horizontal or vertical).
    @param Integer x horizontal coordinates
    @param Integer y vertical coordinates
    @return ScrollView
    */

    function scrollTo(x,y)
    {
        return this.native.scrollTo(x,y);
    }


    /**
    @return Symbol
    */

    property dockContnet(v)
    {
       get return this.native.dockContnet;
    }

    /**
    Returns true if scroll is in progress.
    @return Boolean
    */
    property isScrolling(v)
    {
        get return this.native.isScrolling;
    }




}