class PaintCache
{
    var _singleton = null;
    var _storage = {};

    function this()
    {
        assert PaintCache._singleton == null;
        PaintCache._singleton = this;
    }

    property instance(v)
    {
        get {

            if (PaintCache._singleton == null)
                new PaintCache();
            return PaintCache._singleton;
        }
    }

    property paints(v)
    {
        get return this._storage;
    }

    function hasPaint(key)
    {
        return PaintCache._storage[key] instanceof Paint ? true : false;
    }

    function getPaint(key)
    {
        if (PaintCache.hasPaint(key) === true)
            return PaintCache._storage[key];
        return null;
        //throw new Exception("[PaintCache.getPaint] undefined key:" + key);
    }

    function storePaint(key, obj)
    {
        PaintCache._storage[key] = obj;
    }

}