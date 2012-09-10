include "code://core/log.ms";
include "code://uix-skin/theme.ms"
include "code://uix-skin/skin.ms";

class MoscrifSkin : Skin
{
    var instance = null;
    
    function this(options = {})
    {
        super(options);

        this._options = options;
        // TODO: this should be changed to only system.home after framework publish,and application id should be moved to this-optional theme
        this._root = System.home();
        this._defaultTheme = "uix-skin/moscrif/themes/default/theme.moscrif." + this._getVariant() + ".mso";

        this._theme = new Theme(this._root + (this._options.theme ? this._options.theme : this._defaultTheme));
        // get access to theme object
        var theme = this._theme.getStyle("general");
        // visual variables
        this._gap = theme.gap?theme.gap:10;


    }

    function _getVariant()
    {
        // this skin is resolution-independent
        return "uni"
    }

}

include "code://uix-skin/moscrif/skin.moscrif.vectors.ms";
include "code://uix-skin/moscrif/controls/skin.moscrif.tileItem.ms";