include "code://ui/titleBar.ms"
include "code://ui/titleBarButton.ms"

class CalendarNavBar : TitleBar
{
    var counter = 0; // static!
    function this(name = null, calendarView = null)
    {
        super(name, "");
        this._calendarView = calendarView;
        //this._calendarView.onDayClicked = :sender, day: this super._updateTitle(day);
        this._calendarView.onMonthClicked = :sender, day {
            var self = this super;
            self._calendarView.currentDay = day;
            self._calendarView.kind = #day;
            self._updateTitle(day);
        };
        this._calendarView.onYearClicked=:sender, day {
            var self = this super;
            self._calendarView.currentDay = day;
            self._calendarView.kind = #month;
            self._updateTitle(day);
        };

        this._backButton = new TitleBarButton(name + ".backButton", #back, "Back");
        this._backButton.onClick = :sender :this super._onBack(sender);
        this.add(this._backButton);

        this._restButton = new TitleBarButton(null, #space);
        this._restButton.onClick  =:sender {
            var cv = this super._calendarView;
            if (cv.kind == #day)
                cv.kind = #month;
            else if (cv.kind == #month)
                cv.kind = #year;
            this super._updateTitle(cv.currentDay);
        };
        this.add(this._restButton);

        this._nextButton = new TitleBarButton(name + ".nextButton", #next, "Next");
        this._nextButton.onClick=:sender : this super._onNext(sender);
        this.add(this._nextButton);

        this._updateTitle(this._calendarView.currentDay);
    }

    function _updateTitle(day)
    {
        var cv = this._calendarView;
        if (cv.kind == #day) {
            var month = cv.currentDay.month;// - 1;
            this.text = String.printf("%s %d", cv.getMonthName(month), day.year);
            this._backButton.text = cv.getMonthName(cv._prevMonth(cv.currentDay).month); // cv.getMonthName(month > 1 ? month - 1 : 12);
            this._nextButton.text = cv.getMonthName(cv._nextMonth(cv.currentDay).month); //cv.getMonthName(month < 11 ? month + 1 : 0);
        }
        else if (cv.kind == #month) {
            var year = cv.currentDay.year;
            this.text = year.toString();
            this._backButton.text = (year - 1).toString();
            this._nextButton.text = (year + 1).toString();
        } else if (cv.kind == #year) {
            var year = cv.currentDay.year;
            this.text = year.toString();
            this._backButton.text = (year - 7).toString();
            this._nextButton.text = (year + 6).toString();
        }
    }
    
    function _onBack(sender)
    {
        this._calendarView.back();
        this._updateTitle(this._calendarView.currentDay);
    }
    
    function _onNext(sender)
    {
        this._calendarView.next();
        this._updateTitle(this._calendarView.currentDay);
    }

}
