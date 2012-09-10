include "lib://uix/layout/layout.ms"

/**
Class HorizontalLayout flows controls horizontaly.
By default it flows from left to right.

*/
class HorizontalLayout : Layout
{
    function init()
    {
        super.init();

        this._native.pack = #start;
        this._native.align = #stretch;
        this._native.orientation = #horz;

    }

    /**
    Horizontal alignment
    @param Symbol v
        #right,#center,#left,#fill
    */
    property align(v)
    {
        set {

            switch(v)
            {
                case #left :
                    this._native.pack = #start;
                    break;
                case #right :
                    this._native.pack = #end;
                    break;
                case #fill :
                    this._native.pack = #stretch;
                    break;
                default :
                     this._native.pack = v;
            }

        }
    }
}



