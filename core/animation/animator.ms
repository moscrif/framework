include "lib://core/animation/animatorChain.ms"

/*
    Animator.js 1.1.11
    
    This library is released under the BSD license:

    Copyright (c) 2006, Bernard Sumption. All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer. Redistributions in binary
    form must reproduce the above copyright notice, this list of conditions and
    the following disclaimer in the documentation and/or other materials
    provided with the distribution. Neither the name BernieCode nor
    the names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
    DAMAGE.
*/
/*
    Source: http://berniesumption.com/software/animator/
    Ported to Moscrif by Jozef Pridavok
    Copyright (c) 2011, Jozef Pridavok. All right reserved.
*/

/**
Animator
@class Animator
@module core
*/
class Animator {

    /**
    Constructs animator objects
    @class Animator
    @constructor
    @param [options={}] {Object} Options to construct animator object. The default options are:
    @example
        // create animator
        var animator = new Animator({
            interval: 1,  // time between animation frames
            duration: 400, // length of animation
            onComplete: function(){},
            onStep: function(){},
            transition: Animator.Transition.easeInOut
        });
        animator.addSubject(function(state) {            // state starts from 1.0 to 0.0
            var self = this super;
            self.alpha = (state*255).toInteger();
        })
        // play animator
        animator.play();
    */
    function this(options = {})
    {
        this.setOptions(options);
        this.timerDelegate = ::this super.onTimerEvent();
        this.subjects = [];
        this.target = 0;
        this.state = 0;
        this.lastTime = 0;
    }

    /**
    Apply default options
    @method setOptions
    @param options {Object} Configuration object ot be applied to the Animator default options
    */
    function setOptions(options)
    {
        this.options = Animator.applyDefaults({
            interval: 1,  // time between animation frames
            duration: 400, // length of animation
            onComplete: function(){},
            onStep: function(){},
            transition: Animator.Transition.easeInOut
        }, options);
    }

    /**
    Animate from the current state to provided value
    @method seekTo
    @param to {Float} Defines end point
    */
    function seekTo(to)
    {
        this.seekFromTo(this.state, to);
    }

    /**
    Animate from the current state to provided value
    @method seekFromTo
    @param from {Float} Defines start point
    @param to {Float} Defines end point
    */
    function seekFromTo(from, to)
    {
        this.target = Float.max(0, Float.min(1, to));
        this.state = Float.max(0, Float.min(1, from));
        this.lastTime = System.tick;
        if (!this.intervalId) {
            //this.intervalId = window.setInterval(this.timerDelegate, this.options.interval);
            this.intervalId = new Timer(this.options.interval);
            this.intervalId.onTick = this.timerDelegate;
            this.intervalId.start();
        }
    }

    /**
    Animate from the current state to provided value
    @method jumpTo
    @param to {Float} Defines start point
    @param [propagate=true] {Boolean} If true, the current state of to the animation subjects will be forwarded. False it jump to the target only.
    */
    function jumpTo(to, propagate = true)
    {
        this.target = this.state = Float.max(0.0, Float.min(1.0, to));
        if (propagate)
            this.propagate();
    }

    /**
    Seek to the opposite of the current target
    @method toggle
    */
    function toggle()
    {
        this.seekTo(1 - this.target);
    }

    /*
    Add a function or an object with a method setState(state) that will be called with a number
    between 0 and 1 on each frame of the animation
    @method addSubject
    @param subject {Array}
    @return {Animator}
    @chainable
    */
    function addSubject(subject)
    {
        this.subjects[this.subjects.length] = subject;
        return this;
    }

    /**
    Remove all subjects
    @method clearSubjects
    */
    function clearSubjects()
    {
        this.subjects = [];
    }

    /*
    Forward the current state to the animation subjects
    @method propagate
    */
    function propagate()
    {
        var value = this.options.transition(this.state);
        for (var i=0; i<this.subjects.length; i++) {
            if (this.subjects[i].setState)
                this.subjects[i].setState(value);
            else
                this.subjects[i](value);
        }
    }

    /**
    Called once per frame to update the current state
    @method onTimerEvent
    */
    function onTimerEvent()
    {
        var now = System.tick;
        var timePassed = now - this.lastTime;
        this.lastTime = now;
        var movement = (timePassed / (this.options.duration * 1.0)) * (this.state < this.target ? 1.0 : -1.0);
        if (Math.abs(movement) >= Math.abs(this.state - this.target))
            this.state = this.target;
        else
            this.state += movement;

        try {
            this.propagate();
        } finally {
            this.options.onStep.call(this);
            if (this.target == this.state)
                this.stop();
        }
    }

    /**
    Stop animation
    @method stop
    */
    function stop()
    {
        if (!this.intervalId)
            return;
        this.intervalId.dispose();
        this.intervalId = null;
        this.options.onComplete.call(this);
    }

    /**
    Play animation
    @method play
    */
    function play()
    {
        if (typeof this.onStart == #function)
            this.onStart();
        this.seekFromTo(0, 1);
    }

    /**
    Reverse animation
    @method reverse
    */
    function reverse()
    {
        this.seekFromTo(1, 0);
    }

    /**
    Merge the properties of two objects
    @method applyDefaults
    @static
    @param defaults {Object} Configuration object with animator defaults
    @param prefs {Object} Custom configuration object
    */
    function applyDefaults(defaults, prefs)
    {
        prefs = prefs || {};
        var prop, result = {};
        for (prop in defaults)
            result[prop] = prefs[prop] !== undefined ? prefs[prop] : defaults[prop];
        return result;
    }

    /**
    Make a transition function that gradually accelerates. pass a=1 for smooth
    gravitational acceleration, higher values for an exaggerated effect.
    @method makeEaseIn
    @static
    @param a {Integer}
    @return {Function}
    */
    function makeEaseIn(a)
    {
        return function(state)
        {
            return Math.pow(state, a*2);
        }
    }
    
    /**
    As makeEaseIn but for deceleration
    @method makeEaseOut
    @static
    @param a {Integer}
    @return {Function}
    */
    function makeEaseOut(a)
    {
        return function(state)
        {
            return 1 - Math.pow(1 - state, a*2);
        }
    }

    /**
    Make a transition function that, like an object with momentum being attracted to a point,
    goes past the target then returns
    @static
    @method makeElastic
    @param bounces {Integer}
    */
    function makeElastic(bounces)
    {
        return function(state)
        {
            state = Animator.Transition.easeInOut(state);
            return ((1-Math.cos(state * Math.PI * bounces)) * (1 - state)) + state;
        }
    }
    
    /**
    Make an Attack Decay Sustain Release envelope that starts and finishes on the same level
    @method makeADSR
    @static
    @return {Function}
    */
    function makeADSR(attackEnd, decayEnd, sustainEnd, sustainLevel)
    {
        if (sustainLevel == null)
            sustainLevel = 0.5;
        return function(state)
        {
            if (state < attackEnd)
                return state / (attackEnd * 1.0);
            if (state < decayEnd)
                return 1 - ((state - attackEnd) / (decayEnd - attackEnd) * (1.0 - sustainLevel));
            if (state < sustainEnd)
                return sustainLevel;
            return sustainLevel * (1.0 - ((state - sustainEnd) / (1.0 - sustainEnd)));
        }
    }
    
    /**
    Make a transition function that, like a ball falling to floor, reaches the target and
    bounces back again
    @static
    @method makeBounce
    @param bounces {Integer}
    */
    function makeBounce(bounces)
    {
        var fn = Animator.makeElastic(bounces);
        return function(state)
        {
            state = fn(state);
            return state <= 1 ? state : 2-state;
        }
    }

    /**
    Time between animation frames in miliseconds
    @property interval
    @type {Integer}
    */
    property interval (v)
    {
        get return this.options.interval;
        set {
            if (typeof v == #integer)
                this.options.interval = v;
        }
    }

    /**
    Length of animation  in miliseconds
    @property duration
    @type {Integer}
    */
    property duration (v)
    {
        get return this.options.duration;
        set {
            if (typeof v == #integer)
                this.options.duration = v;
        }
    }

    /**
    Transition
    @property transition
    @type {transition}
    */
    property transition (v)
    {
        get return this.options.transition;
        set this.options.transition = v;
    }

    /**
    Call-back function. This function is called when application ends.
    @event onComplete
    */
    property onComplete (v)
    {
        get return this.options.onComplete;
        set {
            if (typeof v == #function)
                this.options.onComplete = v;
        }
    }

    /**
    Call-back function. This function is called when animation frame is changed.
    @event onStep
    */
    property onStep (v)
    {
        get return this.options.onStep;
        set {
            if (typeof v == #function)
                this.options.onStep = v;
        }
    }
}

/**
Pre-made transition functions to use with the 'transition' option
@class Animator.Transition
@static
*/
Animator.Transition =
{
    /**
    @attribute easeInOut
    @type {Function}
    */
    easeInOut: :pos :((-Math.cos(pos*Math.PI)/2) + 0.5),

    /**
    @attribute linear
    @type {Function}
    */
    linear: :x :x,

    /**
    Make a transition function that gradually accelerates. pass a=1 for smooth
        gravitational acceleration, higher values for an exaggerated effect. See method {{#crossLink "Animator/makeEaseIn"}}{{/crossLink}} of {{#crossLink "Animator"}}{{/crossLink}} class.
    @attribute easeIn
    @type {Function}
    */
    easeIn: Animator.makeEaseIn(1.5),

    /**
    @attribute easeOut
    @type {Function}
    */
    easeOut: Animator.makeEaseOut(1.5),

    /**
    @attribute strongEaseIn
    @type {Function}
    */
    strongEaseIn: Animator.makeEaseIn(2.5),

    /**
    @attribute strongEaseOut
    @type {Function}
    */
    strongEaseOut: Animator.makeEaseOut(2.5),

    /**
    @attribute elastic
    @type {Function}
    */
    elastic: Animator.makeElastic(1),

    /**
    @attribute veryElastic
    @type {Function}
    */
    veryElastic: Animator.makeElastic(3),

    /**
    @attribute bouncy
    @type {Function}
    */
    bouncy: Animator.makeBounce(1),

    /**
    @attribute veryBouncy
    @type {Function}
    */
    veryBouncy: Animator.makeBounce(3)
}

