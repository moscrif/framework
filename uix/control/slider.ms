include "lib://uix/base/scrollContainer.ms"
include "lib://uix/control/switchButton.ms"

class Slider : ScrollContainer
{
    function init()
    {
        super.init();

        this.scrollMode = #horz;

        this._sliderButton = new SwitchButton();
        this._sliderButton.top = 0;
        this.add(this._sliderButton);

        this._onPointerPressedHandler = function (sender, x, y)
        {
            //logI(this super.native.scrollX);
            //this super.native.scrollX = x - this._sliderButton.left - sender.left - this._sliderButton.width / 2;//(x - this super.native.scrollX, 0);// = 50;//To(x - this super._sliderButton.width / 2, 0);//(50, 20);
            //this super.performLayout();// = 20;
        }

        this._onPointerReleasedHandler = function (sender, x, y)
        {
            /*sender.suspendLayout();
            logI(this super.native.scrollX, x - this super.native.scrollX);
           */ //this super.native.scrollX = 200;//(x - this super.native.scrollX, 0);// = 50;//To(x - this super._sliderButton.width / 2, 0);//(50, 20);
            sender.scrollTo(50, 0);// = #none;
           // sss
           /* this super.performLayout();*/
        }


    }
}

