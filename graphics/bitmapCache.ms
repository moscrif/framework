/**
This class implements simple cache for {{#crossLink "Bitmap"}}{{/crossLink}}.
@class BitmapCache
@module graphics
*/
class BitmapCache
{
    /**
    Construct cache object.
    @method this
    */
    function this()
    {
        this._bitmaps = [];
    }

    /**
    Returns {{#crossLink "Bitmap"}}{{/crossLink}} object from the cache or loads it and store to this cache.
    @method getBitmap
    @param fileName {String} File name of the bitmap.
    @return {Bitmap}
    */
    function getBitmap(fileName)
    {
        var existing = this._bitmaps.filter(:x :x.fileName == fileName);
        if (existing.length == 1)
            return existing[0].image;
        assert System.isFile(fileName);
        var image = Bitmap.fromFile(fileName);
        assert image != null;
        this._bitmaps.push({fileName: fileName, image: image});
        return image;
    }
}