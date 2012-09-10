include "lib://uix/base/staticContainer.ms"

/**
@package uix
@location uix/control/navigation/barBase.ms

Base class for all navigation UI control
*/
class BarBase : StaticContainer
{
    /**
    Init BarBase Controls
    */
    function init()
    {
        super.init();
        this._elements = [];
        this._alignH = #center;
        this._alignV = #center;
        this._marginX = 0;
        this._marginY = 0;
        this._position = #bottom;
        this.width  = System.width;
        this.height = System.height/8;
       

    }

    /**
    Number of elements in navigation bar
    @param Control v
    @return Array
    */
    property elements(v)
    {
        get return this._elements;
        set {
            this._elements = v;
            //this._setLayout();
        }
    }

    /**
    Height of the Navigation bar (in pixels).
    @param Integer v
    @return Integer
    */
    property height(v)
    {
        get return this.native.height;
        set {
            this.native.height = v;
            this._setPosition();
        }
    }

    /**
    Position of navigation bar
    @param Symbol v #top - possition of navigation bar is on the top of the screen
                    #bottom - possition of the navigation bar is on the bottom of the screen
    @return Symbol
    */
    property position(v)
    {
        get return this._position;
        set {
            this._position = v;
            this._setPosition();
        }
    }


    /**
    @visibility private
    Setting of position of navigation bar
    @throw InvalidArgument expects #top or #bottom"
    */
    function _setPosition()
    {
        if(this._position == #top){
            this.native.top = 0;
        }else if(this._position == #bottom){
            this.native.top = System.height - this.height;
        }else throw new InvalidArgument("[barBase._setPosition] expects #top or #bottom");
    }


}