include "lib://uix/validation/validation.ms";

/**
@package uix
@location uix/validation/floatValidation.ms

Validate if value of current control is valid float value
*/
class FloatValidation : Validation
{
// -2147483647
    function this(min = -214748364, max = Float.MAX)
    {
        this._min = min;
        this._max = max;
    }

     /**
    Invoke validation method
    @param Control sender
    @return Boolean
        true  - Control is valid
        false - Control is not valid
    */
    function invoke(sender)
    {
        var value = sender.value.toFloat();

        if (value === undefined)
            return false;
        else
            if (value >= this._min && value <= this._max)
                return true;
            else
                return false;
    }
}