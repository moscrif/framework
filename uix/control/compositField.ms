include "lib://uix/navigation/barBase.ms";

class CompositField : BarBase
{
    function init()
    {
        super.init();
        this.width = this.height = 0;
    }

    function add(v)
    {
        this._elements.push(v);
        this.native.add(v.native);
        //this._setLayout();
    }
}