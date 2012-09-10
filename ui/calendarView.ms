#include "code://ui/tools.ms"

class CalendarView
{
    var counter = 0; // static!
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    function this(name = null, kind = #day, date = null)
    {
        var skin = Application.instance.skin;
        name = name || String.printf("calendarView[%d]", CalendarView.counter++);
        this._kind = kind; // #day #month #year
        this._date = date || new Date();
        this._first = this._date;
        //events handlers
        this._onDayClickedHandler = null;
        this._onMonthClickedHandler = null;
        this._onYearClickedHandler = null;
        
        this._view = new Moscrif.View(name);
        this._view.suspendLayout();
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = 0; this._view.top = 0;
        this._view.width = this._view.height = 500;
        this._view.onDraw = :sender, canvas :skin.drawCalendarView(canvas, sender._script);
        
        this._title = new Moscrif.View(name + ".title");
        this._title.suspendLayout();
        this._title._script = this;
        this._title.focusable = false;
        this._title.onDraw = :sender, canvas :skin.drawCalendarViewTitle(canvas, sender._script);
        
        this._content = new Moscrif.View(name + ".contet");
        this._content.suspendLayout();
        this._content._script = this;
        this._content.focusable = false;
        this._content.onDraw = :sender, canvas :skin.drawCalendarViewContent(canvas, sender._script);
        
        this._view.add(this._title, #front);
        this._view.add(this._content, #front);
        this._buildTitle();
        this._buildContent();
        
        var layout = new Moscrif.StackLayout();
        layout.orientation = #vert;
        layout.pack = #start;
        layout.align = #stretch;
        this._view.layout = layout; // layout is suspended!
        this._view.resumeLayout();
        
        _addViewProperties(this);
        skin.initCalendarView(this);
    }
    property name(v) { get return this._view.name; }
    property kind(v) {
        get return this._kind;
        set {
            if (this._kind == v) return;
            this._kind = v;
            this._content.removeAll();
            this._buildContent();
        }
    }
    property title(v) { get return this._title; }
    property content(v) { get return this._content; }

    // vrati aktualny datum
    property currentDay(v) {
        get return this._date;
        set {
            if (this._date == v) return;
            this._date = v;
            this._buildContent();
        }
    }
    
    // vrati prvy zobrazeny den
    property firstDay(v) { get return this._getFirstDay(this._date); }
    
    //@event #onDayClicked; // (sender, day)
    property onDayClicked(v)
    {
        get { return this._onDayClickedHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onDayClickedHandler = v;
        }
    }
    //@event #onMonthClicked; // (sender, month)
    property onMonthClicked(v)
    {
        get { return this._onMonthClickedHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onMonthClickedHandler = v;
        }
    }
    //@event #onYearClicked; // (sender, day)
    property onYearClicked(v)
    {
        get { return this._onYearClickedHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onYearClickedHandler = v;
        }
    }
    
    function getMonthName(month = null)
    {
        var m = (month === null) ? (this._date.month - 1) : month - 1;
        return CalendarView.months[m];
    }
    
    function back()
    {
        switch(this._kind) {
            case #day: this._date = this._prevMonth(this._date); break;
            case #month: this._date = this._prevYear(this._date); break;
            case #year: this._date = this._prevYear(this._date, 12); break;
            default: assert false;
        }
        //this._content.removeAll();
        this._buildContent();
    }
    
    function next()
    {
        switch(this._kind) {
            case #day: this._date = this._nextMonth(this._date); break;
            case #month: this._date = this._nextYear(this._date); break;
            case #year: this._date = this._nextYear(this._date, 12); break;
            default: assert false;
        }
        //this._content.removeAll();
        this._buildContent();
    }
    
    function _buildTitle()
    {
        var day;
        var skin = Application.instance.skin;
        if (this._kind == #day) {
            for(var i=0; i<7; i++) {
                var day = new Moscrif.View(this.name + String.printf(".title.day[%d]", i));
                day.stretch = #vert;
                day.width = System.width/7;
                day.visible = true;
                day.focusable = false;
                day.text = CalendarView.days[i];
                day.onDraw = :sender, canvas :skin.drawCalendarViewTitleDay(canvas, this super, sender);
                this._title.add(day, #front);
            }
        }
        if (this._kind == #month) {
            var day = new View(this.name + ".title.year");
            //day.stretch = #both;
            day.width = System.width;
            day.visible = true;
            day.focusable = false;
            day.text = this.currentDay.year.toString();
            day.onDraw = :sender, canvas :skin.drawCalendarViewTitleDay(canvas, this super, sender);
            this._title.add(day, #front);
        }
        if (this._kind == #year) {
            var day = new View(this.name + ".title.age");
            //day.stretch = #both;
            day.width = System.width;
            day.visible = true;
            day.focusable = false;
            var year = this.currentDay.year;
            day.text = String.printf("%d - %d", year - 6, year + 5);
            day.onDraw = :sender, canvas :skin.drawCalendarViewTitleDay(canvas, this super, sender);
            this._title.add(day, #front);
        }
    }
    
    function _buildContent()
    {
        switch(this._kind) {
            case #day: this._buildDayRows(); break;
            case #month: this._buildMonthRows(); break;
            case #year: this._buildYearRows(); break;
            default: assert false;
        }
    }
    
    function _buildDayRows()
    {
        this._content.removeAll();
        this._renderDate = this._getFirstDay(this._date);
        var existing, row, name;
        var skin = Application.instance.skin;
        for(var r = 0; r < 6; r++) {
            name = this.name + String.printf(".content.row[%d]", r);
            existing = this._content.find(name);
            row = existing || new Moscrif.View(name);
            row.suspendLayout();
            row.stretch = #both;
            row.visible = true;
            row.focusable = false;
            //row.onDraw = :sender, canvas { logI(sender.name, sender.height); var p=new Paint();p.color=0xffaabbcc; canvas.drawRect(0, 0, sender.width, sender.height, p); }
            if (!existing) {
                var layout = new Moscrif.StackLayout();
                layout.align = #stretch;
                layout.pack = #start;
                layout.orientation = #horz;
                row.layout = layout;
                this._content.add(row, #front);
            }
            this._buildDayCells(row);
            row.resumeLayout();
        }
    }
    function _buildDayCells(row)
    {
        var existing, name, now = new Date();
        var skin = Application.instance.skin;
        for(var c=0; c<7; c++) {
            name = row.name + String.printf(".cell[%d]", c);
            existing = row.find(name);
            var cell = existing || new Moscrif.View(name);
            cell.suspendLayout();
            cell.date = new Date(this._renderDate.year, this._renderDate.month, this._renderDate.day);
            cell.pressed = 0;
            cell.weekend = (c == 5) || (c == 6);
            cell.actualMonth = cell.date.month == this._date.month;
            cell.selected =  (cell.date.year == now.year && cell.date.month == now.month && cell.date.day == now.day);
            cell.stretch = #both;
            cell.visible = true;
            cell.focusable = false;
            cell.text = this._renderDate.day.toString();
            //if (existing) logI("EXIST", cell.name, cell.text, cell.date.toLocaleString(), cell.onDraw);
            cell.onPointerPressed = :sender, x, y {
                sender.pressed = System.tick;
                sender.invalidate();
                return true;
            }
            cell.onPointerDragged = :sender, x, y {
                if (System.tick - sender.pressed > 50)
                    sender.pressed = 0;//System.tick;
                sender.invalidate();
                return true;
            }
            cell.onPointerReleased = :sender, x, y {
                //if (!sender.pressed) return true;
                var self = this super;
                if (typeof self._onDayClickedHandler == #function) {
                    self._onDayClickedHandler(self, sender.date);
                }
                sender.pressed = 0;
                sender.invalidate();
                return true;
            }
            cell.onDraw = :sender, canvas :skin.drawCalendarViewDay(canvas, this super, sender);
            //cell.onDraw = :sender, canvas: this super._drawCellDay(sender, canvas);
            if (!existing) row.add(cell, #front);
            else cell.invalidate();
            
            var val = this._renderDate.valueOf();
            val += 24 * 60 * 60 * 1000;
            this._renderDate.setTime(val);
        }
    }
    
    function _buildMonthRows()
    {
        var row, existing, name;
        var skin = Application.instance.skin;
        for(var r=0; r<3; r++) {
            name = this.name + String.printf(".content.row[%d]", r);
            existing = this._content.find(name);
            var row = existing || new Moscrif.View(name);
            row.stretch = #both;
            row.visible = true;
            row.focusable = false;
            if (!existing) {
                var layout = new Moscrif.StackLayout();
                layout.align = #stretch;
                layout.pack = #start;
                layout.orientation = #horz;
                row.layout = layout;
                this._content.add(row, #front);
            }
            this._buildMonthCells(r, row);
        }
    }
    function _buildMonthCells(r, row)
    {
        var existing, name, now = new Date();
        var skin = Application.instance.skin;
        for(var c=0; c<4; c++) {
            name = row.name + String.printf(".cell[%d]", c);
            existing = row.find(name);
            var cell = existing || new Moscrif.View(name);
            cell.pressed = 0;
            cell.date = new Date(this._date.year, ((r * 4) + c) + 1, this._date.day);
            cell.stretch = #both;
            cell.visible = true;
            cell.focusable = false;
            cell.text = CalendarView.months[(r * 4) + c];
            cell.onPointerPressed = :sender, x, y {
                sender.pressed = System.tick;
                sender.invalidate();
                return true;
            }
            cell.onPointerDragged = :sender, x, y {
                if (System.tick - sender.pressed > 50)
                    sender.pressed = 0;//System.tick;
                sender.invalidate();
                return true;
            }
            cell.onPointerReleased = :sender, x, y {
                var self = this super;
                if (!sender.pressed) return true;
                if (typeof self._onMonthClickedHandler == #function)
                    self._onMonthClickedHandler(self, sender.date);
                sender.pressed = 0;
                sender.invalidate();
                return true;
            }
            cell.onDraw = :sender, canvas :skin.drawCalendarViewDay(canvas, this super, sender);
            if (!existing) row.add(cell, #front);
            else cell.invalidate();
        }
    }
    
    function _buildYearRows()
    {
        this._renderDate = this._date.year - 6;
        var row, existing, name;
        var skin = Application.instance.skin;
        for(var r=0; r<3; r++) {
            name = this.name + String.printf(".content.row[%d]", r);
            existing = this._content.find(name);
            var row = existing || new Moscrif.View(name);
            row.stretch = #both;
            row.visible = true;
            row.focusable = false;
            //row.onDraw = :sender, canvas { logI(sender.name, sender.height); var p=new Paint();p.color=0xffaabbcc; canvas.drawRect(0, 0, sender.width, sender.height, p); }
            if (!existing) {
                var layout = new Moscrif.StackLayout();
                layout.align = #stretch;
                layout.pack = #start;
                layout.orientation = #horz;
                row.layout = layout;
                this._content.add(row, #front);
            }
            this._buildYearCells(r, row);
        }
    }
    function _buildYearCells(r, row)
    {
        var existing, name, now = new Date();
        var skin = Application.instance.skin;
        for(var c=0; c<4; c++) {
            var name = row.name + String.printf(".cell[%d]", c);
            existing = row.find(name);
            var cell = existing || new Moscrif.View(name);
            cell.date = new Date(this._renderDate, this._date.month, this._date.day);
            cell.pressed = 0;
            //cell.actualMonth = this._renderDate.month == now.month;
            cell.selected =  (this._renderDate.year == now.year && this._renderDate.month == now.month);
            cell.stretch = #both;
            cell.visible = true;
            cell.focusable = false;
            cell.text = this._renderDate.toString();
            cell.onPointerPressed = :sender, x, y {
                sender.pressed = System.tick;
                sender.invalidate();
                return true;
            }
            cell.onPointerDragged = :sender, x, y {
                if (System.tick - sender.pressed > 50)
                    sender.pressed = 0;//System.tick;
                sender.invalidate();
                return true;
            }
            cell.onPointerReleased = :sender, x, y {
                if (!sender.pressed) return true;
                var self = this super;
                if (typeof self._onYearClickedHandler == #function)
                    self._onYearClickedHandler(self, sender.date);
                sender.pressed = 0;
                sender.invalidate();
                return true;
            }
            cell.onDraw = :sender, canvas :skin.drawCalendarViewDay(canvas, this super, sender);
            if (!existing) row.add(cell, #front);
            else cell.invalidate();
            this._renderDate++;
        }
    }
    
    // vrati prvy den, ktory bude zobrazeny v kalendari. je to budto den v aktualnom mesiaci, alebo den z konca minuleho mesiaca
    function _getFirstDay(date)
    {
        const one_day = 24 * 60 * 60 * 1000.0;
        var first = new Date(date.year, date.month/* - 1*/, 1);
        // dokial nenajdem prvy pondelok
        while (first.dayOfWeek != 0) {
            var val = first.valueOf();
            val -= 24 * 60 * 60 * 1000.0;
            first.setTime(val);
        }
        if (first.day == 1) {
            var val = first.valueOf();
            val -= 7 * 24 * 60 * 60 * 1000.0;
            first.setTime(val);
        }
        return first;
    }
    
    function _prevYear(date, delta = 1)
    {
        var year = date.year;
        if (year - delta > 1700) year -= delta;
        return new Date(year, date.month/* - 1*/, date.day);
    }
    
    function _nextYear(date, delta = 1)
    {
        var year = date.year;
        if (year + delta < 2900) year += delta;
        return new Date(year, date.month/* - 1*/, date.day);
    }
    
    function _prevMonth(date)
    {
        var year = date.year;
        var month = date.month - 1;
        //log(month.toString() + "." + year.toString());
        if (month < 1) {
            month = 12;
            year--;
        }
        return new Date(year, month/* - 1*/, date.day);
    }
    
    function _nextMonth(date)
    {
        var year = date.year;
        var month = date.month + 1;
        //log(month.toString() + "." + year.toString());
        if (month > 12) {
            month = 1;
            year++;
        }
        return new Date(year, month/* - 1*/, date.day);
    }
}