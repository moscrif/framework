include "lib://core/baseClass.ms"

class Layout : BaseClass
{
    function init()
    {
        super.init();
        this._native = new Moscrif.StackLayout();
        this._owner = null;
        this._suspend = false;
    }

    property native(v)
    {
        get {
            assert this._native instanceof Moscrif.StackLayout;
            return this._native;
        }
    }

    property owner(v)
    {
        get return this._owner;
        set this._owner = v;
    }

    function setMargin(left,top,right,bottom)
    {
        assert this._native instanceof Moscrif.StackLayout;
        this._native.setMargin(left,top,right,bottom);
    }

    function performLayout()
    {
        ;
    }

    function resumeLayout()
    {
        this._suspend = false;
    }

    function suspendLayout()
    {
        this._suspend = true;
    }
}
