include "lib://uix/validation/validation.ms";

/**
@package uix
@location uix/validation/emailValidation.ms
Email validator.
Check if string in control is valid email address.
*/
class EmailValidation : Validation
{
     /**
    Invoke validation method
    @param Control sender
    @return Boolean
        true  - Control is valid
        false - Control is not valid
    */
    function invoke(sender)
    {
        var parts = sender.value.split("@", 2);

        if (parts.length == 1)
            return false;

        if (parts[0] == "")
            return false;

        var local = parts[0].split(".");

        for (var i in local)
            if (i == "")
                return false;

        for (var i = 0; i < parts[0].length; ++i)
            if (parts[0][i] == ' ')
                return false;

        for (var i = 0; i < parts[1].length; ++i)
            if (parts[1][i] == ' ')
                return false;

        var domain = parts[1].split(".");

        if (domain.length == 1)
            return false;

        for (var i in domain)
            if (i == "")
                return false;

        return true;
    }
}