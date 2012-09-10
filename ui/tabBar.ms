include "code://ui/tools.ms"

class TabBarItem
{
    var counter = 0; // static!

    function this(name = null, text = null)
    {
        var skin = Application.instance.skin;
        this._text = text || "";
        this.pressed = 0;
        this._view = new View(name || String.printf("tabBarItem#%d", TabBarItem.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = this._view.height = 32;
        this._view.onDraw = :sender, canvas :skin.drawTabBarItem(canvas, sender._script);
        this._view.onPointerPressed = :sender, x, y {
            var self = this super;
            self.pressed = System.tick;
            self._view.invalidate();
        }
        this._view.onPointerReleased = :sender, x, y {
            var self = this super;
            self.pressed = 0;
            try {
                //self.notify_onClick(x, y);
                if (typeof self._onClickHandler == #function)
                    self._onClickHandler(self);
            } finally {
                self._view.invalidate();
            }
        }
        _addViewProperties(this);
        skin.initTabBarItem(this);
    }

    property text(v)
    {
        get return this._text;
        set {
            if (this._text == v) return;
            this._text = v;
            this._view.invalidate();
        }
    }

    property selected(v)
    {
        get return this._selected;
        set {
            if (this._selected == v) return;
            this._selected = v;
            this._view.invalidate();
        }
    }

    //@event #onClick; // (sender)
    property onClick(v)
    {
        get { return this._onClickHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onClickHandler = v;
        }
    }

    function add(view)
    {
        assert view != null && view.native != null;
        this._view.add(view.native);
    }
}

class TabBar
{
    var counter = 0; // static!

    function this(name = null)
    {
        var skin = Application.instance.skin;
        this._tabs = new Array();
        this._view = new View(name || String.printf("tabBar#%d", TabBar.counter++));
        this._view._script = this;
        this._view.focusable = false;
        this._view.left = this._view.top = 0;
        this._view.width = System.width;
        this._view.height = 70;
        this._view.onDraw = :sender, canvas :skin.drawTabBar(canvas, sender._script);
        _addViewProperties(this);
        skin.initTabBar(this);
    }

    function add(item, onClick = null)
    {
        assert item != null;
        assert item instanceof TabBarItem;
        if (onClick) item.onClick.push(:sender :onClick(sender));
//        item.onClick.push(:sender :this super._selectChanged(sender));
        if (this._tabs.length == 0) {
            item.selected = true;
            //this.notify_onSelectedChanged(item);
            this._raiseOnSelectedChanged(item);
        }
        this._tabs.push(item);
        for(var t in this._tabs) t.width = System.width / this._tabs.length;
        this._view.add(item.native, #front);
    }

    function _selectChanged(tab)
    {
        for(var t in this._tabs)
            if (tab != t) t.selected = false;
        tab.selected = true;
        //this.notify_onSelectedChanged(tab);
        this._raiseOnSelectedChanged(tab);
    }

    function _raiseOnSelectedChanged(tab)
    {
        var self = this;
        if (typeof self._onSelectedChangedHandler == #function)
            self._onSelectedChangedHandler(tab);
    }

    //@event #onSelectedChanged; // (sender)
    property onSelectedChanged(v)
    {
        get { return this._onSelectedChangedHandler; }
        set
        {
            assert (typeof v == #function) || (v == null);
            this._onSelectedChangedHandler = v;
        }
    }

}
