include "lib://uix/base/container.ms";

/**
    @package uix
    @location uix/base/staticContainer.ms

    StaticContainer instance is used to carry moscrif control.
    Static means, that objects are display on the screen and scrolling is not availaible
*/
class StaticContainer : Container
{
    /**
        Initialisation of controls. Native object is View.
    */
    function init()
    {
        //define view
        this._view = UIFactory.createView(this);
        super.init();
    }
    /**
        Set/Get if the view is not clipped to its bounds.
        @param Boolean v
        @return Boolean
        @throw InvalidArgument Expects type of function
    */
    property clipToBounds(v)
    {
        get return this._clipToBounds;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[StaticContainer.clipToBounds] Expects type of function");
             this._clipToBounds = v;
        }

    }

     /**
     Remove this view form it's parent.
     @return View
    */
    function detach()
    {
        return this._view.detach();
    }

}