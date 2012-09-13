include "lib://core/baseClass.ms"

/**
@class AdBanner
@module ads
*/
class AdBanner : BaseClass
{

    function init()
    {
        super.init();
        this._provider = this.options.provider || #auto;
        this._size = this.options.size || #default;
        this._testing = this.options.testing;
        this._adId = this.options.adId;
        this._impl = null;
    }

    function afterInit()
    {
        super.afterInit();
        this._createProvider();
    }

    property provider(v)
    {
        get return this._provider;
        set {
            if (v == #auto) {
                if (System.OS_NAME == #iOS)
                    v = #iAd;
                else if (System.OS_NAME == #Android)
                    v = #AdMob;
                else
                    v = #simulate;
            }
            assert v == #AdMob || v == #iAd || v == #simulate;
            this._provider = v;
        }
    }

    function show(x, y, testing = false)
    {
        this._impl.show(x, y, this._testing);
    }

    function hide()
    {
        this._impl.hide();
    }

    function _getSize()
    {
        switch(this._size) {
            case #default: return (System.scale * 320, System.scale * 50);
            case #full: return (System.scale * 300, System.scale * 250);
            case #leaderboard: return (System.scale * 728, System.scale * 90);
            case #skyscraper: return (System.scale * 120, System.scale * 600);
            case #smartPortrait: return (System.width, System.scale * (System.IS_TABLET ? 90 : 50));
            case #smartLandscape: return (System.scale * (System.IS_TABLET ? 90 : 32), System.height);
        }
        return (System.width, System.scale * 50);
    }

    function _createProvider()
    {
        if (this._provider == #AdMob) {
            if (System.OS_NAME == #iOS || System.OS_NAME == #Android) {
                this._impl = new AdMob(this._adId, this._size);
                return;
            }
            logW("AdMob is not supported on this platform");
        }
        else if (this._provider == #iAd) {
            if (System.OS_NAME == #iOS) {
                this._impl = new iAd();
                return;
            }
            logW("iAd is not supported on this platform");
        }

        var (w, h) = this._getSize();
        this._impl = {
            window: null,
            show: function(x, y) {
                this.window = new Moscrif.View();
                this.window.left = x;
                this.window.top = y;
                this.window.width = w;
                this.window.height = h;
                this.window.onDraw = function(sender, canvas)
                {
                    canvas.drawRect(0, 0, this.width, this.height, new Paint());
                }
                Game.instance._window.add(this.window);
            },
            hide: function() {
                this.window.detach();
            }
        }
    }

}