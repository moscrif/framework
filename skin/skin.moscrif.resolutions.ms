class MoscrifSkinResulutions
{
    // e01f2f
    // 58585a
    function this(root)
    {
        this._variant = "";
        switch (System.width) {
            case 800: this._variant = "vxga"; break;
            case 768: this._variant = "xga"; break;
            case 640: this._variant = "dvga"; break;
            case 600:
                switch(System.height) {
                    case 800: this._variant = "svga"; break;
                    case 1024: this._variant = "wsvga"; break;
                }
                break;
            case 480:
                switch(System.height) {
                    case 800: this._variant = "wvga"; break;
                    case 854: this._variant = "wvga"; break;
                    case 640: this._variant = "vga"; break;
                    default: assert false : String.printf("Unsupported resolution for 480pixels wide screen! Height is %d pixels", System.height);
                }
                break;
            case 320: this._variant = "hvga"; break;
            case 360: this._variant = "nhd"; break;
            case 240: this._variant = "qvga";
                switch(System.height) {
                    case 320: this._variant = "qvga"; break;
                    case 400: this._variant = "wqvga"; break;
                    default: assert false : String.printf("Unsupported resolution for 480pixels wide screen! Height is %d pixels", System.height);
                }
                break;
            default: assert false : String.printf("Unsupported resolution for screen width of %d pixels", System.width);
        }
        var mso = root + "skin.moscrif." + this._variant + ".mso";
        if (!System.isFile(mso)) {
            var msg = String.printf("Cannot find %s!", mso);
            System.messageBox(msg);
            throw msg;
        }
        var f = Stream.openFile(mso, "r8");
        if (!f) throw String.printf("Cannot load %s!", mso);
        this._data = parseData(f);
        f.close();
    }
    property variant(v) { get return this._variant; }
    property data(v) { get return this._data; }
}
