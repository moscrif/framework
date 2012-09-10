/**
Chains several Animator objects together
@class AnimatorChain
@module core
*/
class AnimatorChain
{
    /**
    Construction od Animator Chain instance
    @method this
    @param animators {Array} An array of Animators to be chained.
    @param [options={}] {Object} An object of default options.
    */
    function this(animators, options = {})
    {
        this.animators = animators;
        this.setOptions(options);
        for (var i=0; i<this.animators.length; i++)
            this.listenTo(this.animators[i]);
        this.forwards = false;
        this.current = 0;
        this.invalid = false;
    }

    /**
    Apply defaults
    @method setOptions
    @param options {Options} An options object.
    */
    function setOptions(options)
    {
        this.options = Animator.applyDefaults({
            // by default, each call to AnimatorChain.play() calls jumpTo(0) of each animator
            // before playing, which can cause flickering if you have multiple animators all
            // targeting the same element. Set this to false to avoid this.
            resetOnPlay: true,
            repeat: false,
            onComplete: function(chain) {}
        }, options);
    }

    /**
    Play each animator in turn
    @method play
    */
    function play()
    {
        if (this.invalid)
            return;
        this.forwards = true;
        this.current = -1;
        if (this.options.resetOnPlay)
            for (var i=0; i<this.animators.length; i++)
                this.animators[i].jumpTo(0, false);
        this.advance();
    }

    /**
    Play all animators backwards
    @method reverse
    */
    function reverse()
    {
        if (this.invalid)
            return;
        this.forwards = false;
        this.current = this.animators.length;
        if (this.options.resetOnPlay)
            for (var i=0; i<this.animators.length; i++)
                this.animators[i].jumpTo(1);
        this.advance();
    }

    /**
    Stops and disposes all objects
    @method stop
    */
    function stop() {
        this.invalid = true;
        for (var i=0; i<this.animators.length; i++) {
            this.animators[i].stop();
            this.animators[i] = null;
        }
    }

    /**
    If we have just play()'d, then call reverse(), and vice versa
    @method toggle
    */
    function toggle()
    {
        this.seekTo(this.forwards ? 0 : 1);
    }

    /**
    Internal: install an event listener on an animator's onComplete option
    to trigger the next animator
    @method listenTo
    @param animator {Animator}
    */
    function listenTo(animator)
    {
        var oldOnComplete = animator.options.onComplete;
        animator.options.onComplete = function() {
            if (oldOnComplete)
                oldOnComplete.call(animator);
            this super.advance();
        }
    }

    /**
    Play the next animator
    @method advance
    */
    function advance()
    {
        if (this.invalid)
            return;
        if (this.forwards) {
            if (this.current >= this.animators.length - 1) {
                if (this.options.onComplete)
                    this.options.onComplete(this);
                if (this.options.repeat)
                    this.play();
                return;
            }
            this.current++;
            this.animators[this.current].play();
        } else {
            if (this.current <= 0) {
                if (this.options.onComplete)
                    this.options.onComplete(this);
                if (this.options.repeat)
                    this.reverse();
                return;
            }
            this.current--;
            this.animators[this.current].reverse();
        }
    }

    /**
    This function is provided for drop-in compatibility with Animator objects,
    but only accepts 0 and 1 as target values
    @method seekTo
    @param target {Float}
    */
    function seekTo(target)
    {
        if (target <= 0) {
            this.forwards = false;
            this.animators[this.current].seekTo(0);
        } else {
            this.forwards = true;
            this.animators[this.current].seekTo(1);
        }
    }

    /**
    By default, each call to AnimatorChain.play() calls jumpTo(0) of each animator before playing,
        which can cause flickering if you have multiple animators all targeting the same element.
        Set this to false to avoid this.
    @property resetOnPlay
    */
    property resetOnPlay(v)
    {
        get return this.options.resetOnPlay;
        set this.options.resetOnPlay = v;
    }
}