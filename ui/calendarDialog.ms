include "code://ui/tools.ms"
include "code://ui/calendarView.ms"
include "code://ui/calendarNavBar.ms"

class CalendarDialog
{
    var counter = 0; // static!
    function this(name = null, value = null)
    {
        var skin = Application.instance.skin;
        name = name || String.printf("calendarDialog[%d]", CalendarDialog.counter++);
        this._value = value;
        this._clickable = true;
             
        this._overlay = new Moscrif.View(name + ".overlay");
        this._overlay._script = this;
        this._overlay.focusable = false;
        this._overlay.left = this._overlay.top = 0;
        this._overlay.width = System.width;
        this._overlay.height = System.height;
        this._overlay.onDraw = :sender, canvas :skin.drawCalendarDialogOverlay(canvas, sender._script);
        this._overlay.onPointerReleased = :sender, x, y {
            var self = this super;
            if (typeof self._onCloseHandler == #function)
                    self._onCloseHandler(self,null);
            self.close();
        }
        
        this._view = new Moscrif.View(name);
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = System.height;
        
        this._calendarView = new CalendarView(name + ".calendarView", #day, value);
        this._calendarView.onDayClicked = function(sender, day) {
        
            var self = this super;
            if (typeof self._onCloseHandler == #function)
                    self._onCloseHandler(self,day);
            self.close();
        };
        this._calendarNavBar = new CalendarNavBar(name + "calendarNavBar", this._calendarView);
        
        this._view.add(this._calendarView.native);
        this._view.add(this._calendarNavBar.native);
        
        this._overlay.add(this._view);
        
        _addViewProperties(this);
        skin.initCalendarDialog(this);
    }
    property name(v) { get return this._view.name; }
    //@event #onClose; //(sender, day)
    property onClose(v)
    {
        get { return this._onCloseHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onCloseHandler = v;
        }
    }
    
    function showModal()
    {
        var app = Application.instance;
        assert app != null && app instanceof Application;
        this.left = (System.width - this.width) / 2;
        this.top = (System.height - this.height);
        app.add(this._overlay, #front);
    }
    function close()
    {
        this._overlay.detach();
    }
}
