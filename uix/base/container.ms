include "lib://uix/base/control.ms";
/**
@package uix
@location uix/base/container.ms

Base class for container controls
*/
class Container : Control
{

    /**
    Add Control to container
    @param view e element
    @parem integer o order of element
    */
    function add(control,order = #front)
    {
       this._view.add(control, order);
       this._view.focusable = true;
    }

    /**
    Search for child Controls, which name is same as name from function's param.
    @param String name
    @return Control
    */
    function find(name)
    {
        return this._view.find(name);
    }

    /**
    Remove all child controls from container
    */
    function removeAll()
    {
        this._view.removeAll();
    }


}