/**
This class implements simple cache for {{#crossLink "Typeface"}}{{/crossLink}}.
@class TypefaceCache
@module graphics
*/
class TypefaceCache
{

    /**
    Construct cache object.
    @method this
    */
    function this()
    {
        //this._typefaces = [];
    }

    /**
    Returns {{#crossLink "Typeface"}}{{/crossLink}} object from the cache or loads it and store to this cache.
    @method getTypeface
    @param name {String} Typeface name.
    @param style=#normal {Symbol} Typeface style.
    @return {Bitmap}
    */
    function getTypeface(name, style = #normal)
    {
        // object-notation can be used as first argument
        if (typeof name == #object) {
            var descr = name;
            name = descr.name.toLowerCase();
            style = descr.style || #normal;
        }

        return Typeface.fromName(name, style);
        // TODO: typeface nema name, ma len uniqueId a to vieme az je typeface vytvoreny, takze cache sa neda spravit
        /*
        if (name == "") face = "freesans";
        var found = null;
        for (var f in this._typefaces)
            if (f.name.toLowerCase() === name && f.style == style)
                return f;
        found = Typeface.fromName(name, style);
        this._typefaces.push(found);
        return found;
        */
    }
}