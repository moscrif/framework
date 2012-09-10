class MetroSkinResulutions
{
    function this(root)
    {
        this._variant = "uni";
        var mso = root + "skin.metro.uni.mso";
        if (!System.isFile(mso)) {
            var msg = String.printf("Cannot find %s!", mso);
            System.messageBox(msg);
            throw msg;
        }
        var f = Stream.openFile(mso, "r8");
        if (!f)
            throw String.printf("Cannot load %s!", mso);
        this._data = parseData(f);
        f.close();
    }
    property variant(v) { get return this._variant; }
    property data(v) { get return this._data; }
}

// eof
