include "lib://uix/layout/layout.ms"

/**
@class VerticalLayout
Vercical layout flows controls vertically.
By default flows controls from top to the bottom.
*/
class VerticalLayout : Layout
{
    function init()
    {
        super.init();

        this._valign = this.options.valign || #top;

        this._native.orientation = #vert;
        this._native.pack = #start;
        this._native.align = #stretch;

    }

    /*
    Setting vertical alignment
    @param Symbol v
        #top,#center,#bottom
    */
    property valign(v)
    {
        set {

            switch (symbol(v))
            {
                case #top:
                    this._native.pack = #start;
                    break;
                case #bottom:
                    this._native.pack = #end;
                    break;
                default :
                    this._native.pack = v;
            }
        }
    }


}
