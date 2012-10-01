include "lib://core/baseClass.ms"

/**
This class encapsulated banner ads (iAd for iPhone, iPod and iPad, AdMob for Android devices).
@class AdBanner
@extends BaseClass
@module ads
@example
    var banner = new AdBanner({provider:#simulate, testing:true});
    banner.show(0, 0);
*/
class AdBanner : BaseClass
{

    /**
    Initializes banner ads.
    @method init
    @example
        var banner = new AdBanner({
            provider:#auto,
            adId:"a1504f8e07e325a",     // AdMob ID for AdMob system
            size:#smartPortrait,
            testing:true
        });
    */
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

    /** Specified used provider for banner ads (iAd or AdMob).

    * #auto - automatically detects the best provider (iAd for iOS, AdMob for Android, otherwise simlulate banner ads)
    * #AdMob - use AdMob (on both, iOS and Android)
    * #iAd - use iAd (iOS only)
    * #simulate - just simulate banner ads
    @property provider
    @type {Symbol}
    */
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

    /**
    This method creates and shows ad banner at specified position on screen.
    @method show
    @param x {Integer} x coordinate of screen's position.
    @param y {Integer} y coordinate of screen's position.
    @param [testing=false] {Boolean} You have to set to true when testing.
    @example
        var banner = new AdBanner({provider:#auto, adId:"a1504f8e07e325a", size:#smartPortrait, testing:true});
        banner.show(0, 0);
    */
    function show(x, y, testing = false)
    {
        this._impl.show(x, y, this._testing);
    }

    /**
    This method hides ad banner.
    @method hide
    */
    function hide()
    {
        this._impl.hide();
    }

    function _getMainWindow()
    {
        return Game.instance._window;
    }

    function _getSize()
    {
        if (this._provider == #AdMob) {
            switch(this._size) {
                case #default: return (System.scale * 320, System.scale * 50);
                case #full: return (System.scale * 300, System.scale * 250);
                case #leaderboard: return (System.scale * 728, System.scale * 90);
                case #skyscraper: return (System.scale * 120, System.scale * 600);
                case #smartPortrait: return (System.width, System.scale * (System.IS_TABLET ? 90 : 50));
                case #smartLandscape: return (System.scale * (System.IS_TABLET ? 90 : 32), System.height);
            }
        }
        if (this._provider == #iAd) {
            var mainWindow = this._getMainWindow();
            // portrait
            return (System.width, System.scale * (System.IS_TABLET ? 66 : 50));
            // landscape
            return (System.width, System.scale * (System.IS_TABLET ? 32 : 50));
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
        var mainWindow = this._getMainWindow();
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
                mainWindow.add(this.window);
            },
            hide: function() {
                this.window.detach();
            }
        }
    }

}