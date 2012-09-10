include "lib://core/baseClass.ms";

/**
@package uix
@location uix/keyboard/keyboardMap.ms

KeyboardMap class definitio.
The class loads keaboard map from json object and provides information about t to the Keyboard class

*/

class KeyboardMap : BaseClass
{
    /**
    KeyboardMap init controls
    */
    function init()
    {
        this._source = null;
    }

    /**
    source file
    @param String location of source *.mso file
    @return String location of source *.mso file
    */
    property source (v)
    {
        get return this._source;
        set {
            if(v instanceof String) {
                this._source = v;
                this._parseJson(this._loadMap(v));
            } else
                 throw new InvalidArgument("[KeyboardMap.source] Accepts instance of String");
        }
    }

    /**
    LoadMap - load json object
    @param String location of source *.mso file
    @return Object parsed json object
    */
    function _loadMap(filename)
    {
        //check if file exists
        if (!System.isFile(filename)) {
            var msg = String.printf("Cannot load theme file!");
            System.messageBox(msg);
            throw msg;
        }

        //read data from file
        var file = Stream.openFile(filename, "r8");
        if (!file)
            throw String.printf("Cannot load %s!", filename);

        var data = parseData(file);

        file.close();

        this._parseJson(data);
        return data;
    }

    /**
    ParseJson sets all objects from json object to curent instance of this (keyboardMap) class
    @param Object
    */
    function _parseJson(obj)
    {
        for (var p in obj) {
            this[p] = obj.propertyAt(p);
        }
    }
}