include "lib://uix/base/staticContainer.ms";

/**
@package uix
@location uix/dialog/overlay.ms
Overlay definition class. Usually used in dialog
*/
class Overlay : StaticContainer
{
    /**
    Show modal window. Current dialog becomes a dialog window
    @param Dialog dialog
    */
    function showModal(dialog = null)
    {
        if (dialog != null) {
            try {
                this.add(dialog)
            } catch(ex) {
                dialog.visible = true
            }
        }
        try {
            Application.instance.showModal(this);
        } catch(ex) {
            this.visible = true
        }
    }

    /**
    Close dialog, change visibility to false
    */
    function close()
    {
        this.visible = false;
    }
}