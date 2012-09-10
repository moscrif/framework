class Theme
{
    var instance = null;

    function this(fileName)
    {
        assert fileName !== null : "Theme name must be specified";
        Theme.instance = this;

        this._fileName = fileName;
        this._theme = {};
        this._load();
    }

    function isStyle(name)
    {
        return this._theme.exists(symbol(name));
    }

    function getStyle(name)
    {
        return this._theme[symbol(name)];
    }

    function _load()
    {
        //check if file exists
        if (!System.isFile(this._fileName)) {
            var msg = String.printf("Cannot load theme file!");
            System.messageBox(msg);
            throw msg;
        }

        //read data from file
        var file = Stream.openFile(this._fileName, "r8");
        if (!file)
            throw String.printf("Cannot load %s!", this._fileName);

        this._theme = parseData(file);

        file.close();

    }
}