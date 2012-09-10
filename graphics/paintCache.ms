include "lib://graphics/drawings/drawing.ms";

class PaintCache
{
    function this()
    {
        this._storage = {};
    }

    property instance(v)
    {
        get {

            if( PaintCache.instace === undefined)
                PaintCache.instace = new PaintCache();

            return PaintCache.instace
        }
    }

    property storage(v)
    {
        get return this._storage;
    }

    function hasDrawing(key)
    {
        return this.storage[key] instanceof Paint ? true : false;
    }


    function getDrawing(key)
    {
        if(this.hasDrawing(key) === true)
            return this.storage[key];

        throw new Exception("[DrawingCache.getDrawing] undefined key:" + key);
    }

    function storeDrawing(key,obj)
    {
        this.storage[key] = obj;
    }

}