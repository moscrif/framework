include "lib://graphics/patterns/switchPattern.ms";

include "lib://uix/control/button.ms"
include "lib://core/animation/animator.ms"


/**
@package uix
@location uix/control/switchControl.ms

Switch control to define two states on or off.
*/
class SwitchControl : Button
{
    /**
    Switch init controls
    */
    function init()
    {
        super.init();
        this._box = null;
        this._animationDuration = 200;

        this._boxAlign = #left;
        this._textAlign = #left;

        // create animator
        this._animator = new Animator({
            duration: this._animationDuration,
            transition: Animator.Transition.easeInOut
        });
        this._animator.addSubject(function(state){this super._animate(state);})
        this._animator.onComplete = function()
        {
            this super.ready = true;
        }


        /**
        On Pointer pressed event handler
        @param SwitchControl sender
        @param Integer x X-coordinates
        @param Integer y Y-coordinates
        */
        this._onPointerPressedHandler = function(sender, x, y)
        {
            this.clicked = true;
            if (this.enabled) {
                if (this._state == #on)
                    this._state = #off;
                else
                    this._state = #on;

                this._animator.play();
            }
        }

        this._boxButtonLeft = 0;
        this._state = #off;
    }

    /**
    Flag to indicate animation.
    If animation is in progress is set to false, if finished flag true
    @param Boolean v
    @return Boolean
    */
    property ready(v)
    {
        get return this._ready;
        set this._ready = v;
    }

    /**
    Box Align
    @param Symbol v
        #left, #right align
    @return Symbol
    */
    property boxAlign(v)
    {
        get return this._boxAlign;
        set {
            this._boxAlign = v;
            this.invalidate();
        }
    }

    /**
    Text Align
    @param Symbol v
        #left,#center, #right
    @return Symbol
    */
    property textAlign(v)
    {
        get return this._textAlign;
        set {
            this._textAlign = v;
            this.invalidate();
        }
    }

    /**
    Text property of Switch control
    @param String v
    @return String
    */
    property text(v)
    {
        get return this._text;
        set {
            this._text = v;
            this.invalidate();
        }
    }

    /**
    Box pattern drawins. This patter keeps drawings of in or off state, defines in skin theme
    @param SwitchPattern v
    @return SwitchPattern
    */
    property box(v)
    {
        get
        {
            if(this._box == null)
                this._box = SwitchPattern.create(SwitchPattern,this,"box");

            return this._box;
        }
    }

    /**
    Box pattern drawins. This patter keeps drawings of in or off state, defines in skin theme
    @param SwitchPattern v
    @return SwitchPattern
    */
    property slider(v)
    {
        get
        {
            if(this._slider == null)
                this._slider = SwitchPattern.create(SwitchPattern,this,"slider");

            return this._slider;
        }
    }

    /**
    Devine state of the control
    @param Symbol v
        #on, #off
    @return Symbol
    */
    property state(v)
    {
        set
        {
            if (v == #on || v == #off) {
                if (v != this._state) {
                    this._state = v;
                    this._animator.play();
                } else {
                    this._state = v;
                    this._ready = true;
                }
            } else
                throw new InvalidArgument("[SwithControl.state] Accepts #on ar #off");
        }
        get
        {
            return this._state;
        }
    }

    /**
    Animation of switchControl

    @visibility private
    @param Symbol state
    */
    function _animate(state)
    {
        this.ready = false;

        // set direction
        if (this.state == #on)
            this._boxButtonLeft = Math.floor((this.box.propertyAt(this.state).width - this.slider.propertyAt(this.state).width) * state);
        else
            this._boxButtonLeft = Math.floor((this.box.propertyAt(this.state).width - this.slider.propertyAt(this.state).width) * (1-state));

        this.native.invalidate();
    }
}