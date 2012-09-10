/**
Following functions and variables that "live" in global namespace so they accessible in script without any class designator.
@class Log
@module core
*/

/**
Global switch to enable/disable logging
@attribute enableLogging
@type Boolean
@default false
*/
var enableLogging = true;

/**
Global switch to enable/disable logging with detailed stack trace
@attribute enableLoggingWithStackTrace
@type Boolean
@default false
*/
var enableLoggingWithStackTrace = false;

/**
Log into console without any severity level
@method log
@param [x]* {Array} An array of object to be logged into console.
@example
    log(x);
    log("x =", x);
    log(this);
*/
function log(x..)
{
    logI(x);
}

/**
Log with severity level Info
@method logI
@param [x]* {Array} An array of object to be logged into console.
@example
    logI(x);
    logI(true, [1, 2, 3]);
*/
function logI(x..)
{
    _log("Log-I", x);
}

/**
Log with severity level Warning
@method logW
@param [x]* {Array} An array of object to be logged into console.
*/
function logW(x..)
{
    _log("Log-W", x);
}

/**
Log with severity level Error
@method logE
@param [x]* {Array} An array of object to be logged into console.
*/
function logE(x..)
{
    _log("Log-E", x);
}

/**
Log with severity level Info and returning the first argument
@method logRI
@param ret {Object} A value to be returned
@param [x]* {Array} An array of object to be logged into console.
@return {Object} The first argument passed to this function
@example
    function test(a) {
        return logRI(a > 0, a);
    }
*/
function logRI(ret, x..)
{
    _log("Log-I", x);
    return ret;
}

/**
Log with severity level Warning and returning the first argument
@method logRW
@param ret {Object} A value to be returned
@param [x]* {Array} An array of object to be logged into console.
@return {Object} The first argument passed to this function
@example
    function test(a) {
        return logRW(a > 0, a);
    }
*/
function logRW(ret, x..)
{
    _log("Log-W", x);
    return ret;
}

/**
Log with severity level Error and returning the first argument
@method logRE
@param ret {Object} A value to be returned
@param [x]* {Array} An array of object to be logged into console.
@return {Object} The first argument passed to this function
@example
    function test(a) {
        return logRI(a > 0, a);
    }
*/
function logRE(ret, x..)
{
    _log("Log-E", x);
    return ret;
}

function dlogI(x..)
{
    if (System.IS_DEBUG)
        logI(x);
}

function dlogW(x..)
{
    if (System.IS_DEBUG)
        logW(x);
}

function dlogE(x..)
{
    if (System.IS_DEBUG)
        logE(x);
}

/**
Log into monitor.
@method logM
@param category {String} Category of this log entry.
@param [message]* {Array} An array of messages to be logged.
@example
    logM("MyCategory", "successfull");
*/
function logM(category, message..)
{
    if (!System.IS_DEBUG)
        return;
    console << "Log-M:\t" << category << "\t";
    for(var i = 0; i < message.length; i++)
        console << message[i];
    console << "\n";
}

function logGC(message)
{
    if (!System.IS_DEBUG)
        return;
    console << "Log-GC:\t";
    console << message;
    console << "\n";
}


/**
Loging all passed arguments with severity level
@method _log
@private
*/
function _log(severity, x)
{
    if (!enableLogging)
        return;
    var date = new Date();
    console.printf("%s:\t%02d:%02d.%03d\t", severity, date.minute, date.second, date.millisecond);
    const sep = " ";
    var i, len = x.length;
    if (!len) return;
    function dumpView(o)
    {
        console << "name=" << o.name << (o.visible ? " (visible)" : " (hidden)") << ", left=" << o.left << ", top=" << o.top << ", width=" << o.width << ", height=" << o.height;
    }
    function dump(o)
    {
        var t = typeof o;
        if (o === null) console << "null";
        else if (o === undefined) console << "undefined";
        else if (o === nothing) console << "nothing";
        else if (t == #object) { console << ">>> "; o.debugShow(); }
        else if (o instanceof Moscrif.View) { console << o << ", "; dumpView(o); }
        else console << o;
        return console;
    }
    for(i = 0; i < len - 1; i++) {
        dump(x[i]) << sep;
    }
    dump(x[len - 1]);
    if (System.IS_DEBUG && enableLoggingWithStackTrace)
        debug stacktrace;
    console << "\n\n";
}

/**
Class to log duration
@class LogDuration
*/
class LogDuration
{
    /**
    Constructor
    @class LogDuration
    @constructor
    */
    function this(x..)
    {
        this.start(x);
    }

    /**
    Start point with logging information. See {{#crossLink "Log/logI"}}{{/crossLink}}.
    @method start
    @param [x]* {Array} An array to be logged
    */
    function start(x..)
    {
        this._start = System.tick;
        this._args = x;
        logI(x);
    }

    /**
    End of logging
    @method end
    */
    function end()
    {
        logI(this._args, "Elapsed time: ", System.tick - this._start, "milis");
        this._start = 0;
        this._args = null;
    }
}

// eof
