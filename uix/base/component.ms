include "lib://uix/base/control.ms";
include "lib://core/exception.ms"

/**
@package uix
@location uix/base/component.ms

Base class for single control
*/
class Component : Control
{

    /**
    Init controls, native is Moscrif View
    */
    function init()
    {
         //define view
        this._view = UIFactory.createView(this);
        this._view.focusable = true;

        super.init();
    }

    /**
        On validate event, executed for each control
        @event
        @return Function
    */
    property onValidate(v)
    {
        get return this._onValidateHandler;
        set {
            assert (typeof v == #function) || (v == null);
            this._onValidateHandler = v;
        }
    }

   /**
   Invoke validation handler
   @param Function v
   @return Function
   @throw Exception Validation handler does not exists
   */
   function invokeValidator(sender){

        if(typeof this._onValidateHandler === #function )
            this._onValidateHandler(sender);
        else
            throw new Exception("Validation handler does not exists");
   }

   /**
   Add child is not permitted in component.
   @throw add control to Component is bot allowed
   */
   function add(control,order = #front)
   {
        throw new Exception("[Component.add] add control to Component is bot allowed");
   }
}