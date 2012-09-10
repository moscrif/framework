include "lib://uix/base/staticContainer.ms";
include "lib://uix/dialog/overlay.ms";

include "lib://uix/layout/verticalLayout.ms";

/**
@package uix
@location uix/dialog/dialog.ms
Dialog definition class
*/
class Dialog : StaticContainer
{
    var DEFAULT_GAP = System.width / 32;

    /**
    Dialog init controls
    */
    function init()
    {
        super.init();
        this._bg = null;
        this._overlay = new Overlay();
        this.layout = new VerticalLayout();
        this.layout.setMargin(DEFAULT_GAP, DEFAULT_GAP, DEFAULT_GAP, DEFAULT_GAP);
    }

    /**
    Overlay prpperty, holds instance of Overlay
    @param Overlay v
    @return Overlay
    */
    property overlay(v)
    {
        get return this._overlay;
        set {
            if (v instanceof Overlay || v == false){

                this._overlay = v;

                if (this._overlay)
                   this._overlay.invalidate();

            }else
                // report invalide type of parameter
                throw new InvalidArgument("[Dialog.overlay] Accepts instance of Overlay");

        }
    }

    /**
    Dialog width, it set dialog into middle of the screen
    @param Integer v
    @return Integer
    */
    property width(v)
    {
        get return this._view.width;
        set {
            this._view.width = v;
            this.left = System.width/2 - v/2;
        }
    }

    /**
    Displays dialog as modal window
    */
    function showModal()
    {
        if (this._overlay != null)
            this._overlay.showModal(this);
        else {
            try {
                Application.instance.add(this.native, true, #front);
            } catch (exp) {
                this.visible = true;
            }
        }
    }

    /**
    Hide dialog (modal window)
    */
    function close()
    {
        if (this._overlay != null)
            this._overlay.close();
        else 
            this._view.visible = false;
        Application.instance.invalidate();
    }
}