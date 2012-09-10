/**
Exception definition class.
@class Exception
@module core
*/
class Exception
{
    /**
    Construct of exception instance
    @class Exception
    @constructor
    @param arg1 {String|Exception} Error string or an instance of Exception
    @param arg2 {Exception} Instance of Exception
    */
    function this(arg1 = null, arg2 = null)
    {
        this._object = null;
        this._what = "";
        if (typeof arg1 == #string) {
            this._what = arg1;
            if (arg2 instanceof Exception)
                this._object = arg2;
            }
        else if (arg1 instanceof Exception)
            this._object = arg1;
    }

    /**
    Convert Exception to string
    @method toString
    @return {String} String representation of this exception.
    */
    function toString()
    {
        if (this._object == null)
            return this.className + ": " + this._what;
        else
            return this.className + ": " + this._what + " (Cause " + this._object.toString() + ")";
    }
}

/**
Invalid Argument Exception
@class InvalidArgument
@extends Exception
*/
class InvalidArgument : Exception {}

/**
Null pointer Exception
@class NullPointer
@extends Exception
*/
class NullPointer : Exception {}

/**
Input/Oputput Exception
@class IOException
@extends Exception
*/
class IOException : Exception {}

/**
Parse Exception
@class ParseException
@extends Exception
*/
class ParseException : Exception {}