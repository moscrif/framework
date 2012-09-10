include "lib://core/log.ms"
include "lib://game2d/imageButton.ms"

/**
Implements game button functionality. This class is __obsolete__, please use {{#crossLink "ImageButton"}}{{/crossLink}} or {{#crossLink "TextButton"}}{{/crossLink}}.
@class GameButton
@extends ImageButton
@deprecated
@module game2d
*/
class GameButton : ImageButton
{
    /**
    Draw warning message
    @method init
    */
    function init()
    {
        super.init();
        logW("Obsolete class! Please use ImageButton instead");
    }
}
