/** Simple helper class that allows to schedule delayed action.
@class Delay
@module core
*/
class Delay
{
    /** Schedules given function to be executed in delayed time.
    @method run
    @param delay {Integer} Delay interval in miliseconds
    @param fun {Function} The function to be executed
    @static
    @example

        Delay.run(1500, function() {
            logI("I have been delayed...");
        });
    */
    function run(delay, fun) {
        assert typeof delay == #integer && delay > 0;
        assert typeof fun == #function;
        var timer = new Timer(1, 1);
        timer.onTick = function() {
            fun();
            timer.dispose();
        }
        timer.start(delay);
    }
}
