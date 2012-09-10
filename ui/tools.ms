function _addViewProperties(script)
{
    assert (script._view instanceof Moscrif.View || script._view instanceof Moscrif.ScrollView || script._view instanceof Moscrif.TextView);
    script[#native] = property(v) {
        get return this._view;
    }
    script[#name] = property(v) {
        get return this._view.name;
        set this._view.name = v;
    }
    script[#visible] = property(v) {
        get return this._view.visible;
        set this._view.visible = v;
    }
    script[#left] = property(v) {
        get return this._view.left;
        set this._view.left = v;
    }
    script[#top] = property(v) {
        get return this._view.top;
        set this._view.top = v;
    }
    script[#width] = property(v) {
        get return this._view.width;
        set this._view.width = v;
    }
    script[#height] = property(v) {
        get return this._view.height;
        set this._view.height = v;
    }
    script[#stretch] = property (v) {
        get return this._view.stretch;
        set this._view.stretch = v;
    }
    script[#layout] = property (v) {
        get return this._view.layout;
        set this._view.layout = v;
    }
    //script[#find] = function(name) { return this._view.find(name); }
}