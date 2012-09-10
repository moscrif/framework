include "lib://graphics/drawings/drawing.ms";
include "lib://graphics/drawings/background.ms";
include "lib://graphics/drawings/foreground.ms";
include "lib://graphics/drawings/border.ms";
include "lib://graphics/svg/svg.ms";

include "lib://uix/base/screen.ms";
include "lib://uix/controller.ms";
include "lib://uix/form.ms";
include "lib://core/log.ms";

//include keyboard
include "lib://uix/keyboard/keyboard.ms"

//include base skin
include "lib://uix-skin/skin.ms"


/**
    Application is base class in Enterprise application development.
    It provides Application Forms and skin handling.
    @package uix
    @location uix/application.ms
*/
class Application : Screen
{
    //static variable
    var instance;

    /**
        Public constructor of Application class. This class is Singelton and application instance is stored
        in Application.instance variable. Once Application is constructing it check if options contains skin
        instance, if not application includes and set skin based on project settings.

        @params <Object> options
    */
    function this(options = {})
    {
        assert Application.instance == null;
        Application.instance = this;

        //check if skin instance is set maually
        //if not load it manualy based on project properties
        if(options && options.skin instanceof Skin)
            Application.instance.skin = options.skin;
        else
            this._applicationSkinHandler();

        super.init(options);

        //form name storage, until window will not return stored objects
        this._history = new Array();
        this._currForm = false;
        this._keyboard = null;
        
    }

    /**
        Skin property
        @param <Skin> v Instance of Skin
        @throw <InvalidArgument> [Application.skin] expects instance of Skin
    */
    property skin(v)
    {
        get return this._skin;
        set {
            if(v instanceof Skin)
                this._skin = v;
            else throw new InvalidArgument("[Application.skin] expects instance of Skin");
        }
    }

    /**
        Orientation of application
        @param <Symbol> v #portrait,#landscape
    */
    property orientation(v)
    {
        get return this.native.orientation;
    }



    /**
        Make form instace accesible via application instance
        If propery is undefined it looks for name of the form stored in application.
        In the case form with same name as requested property is stored in application it returns instance of the form
        @example
            Application.instance.add(new Form({name:"testForm"})).
            Application.instance.testForm returns instance of the form.
        @param <Mixed> k name of the value
        @param <Mixed> v value
        @return <Form|undefined>
    */
   property undefined(k,v)
    {
        get {

           var ret;

            if(this[k] !== undefined)
               ret = this[k];
            else if(this[k.toString()] !== undefined)
               ret = this[k.toString()];
            else if(this.exists(k, false))
               ret = this.propertyAt(k)
            else if(this.isForm(k))
               ret = this._getFormByName(k);
            else
               ret = false;

            return ret;
        }
    }

    /**
        Function checks if form with name exists in application
        @param <String> name
        @return <Boolean>
    */
    function isForm(name)
    {
        if(name instanceof Form)
            name = Form.name;

        return (this._getFormByName(name) instanceof Form) ? true : false;
    }

    /**
        Remove form from application and raise on deactivate
        @param <Form|string> Expects instance of form or form name
    */
    function remove(form)
    {
        if(typeof form === #string)
            form = this._getFormByName(form);

        if(form)
        {
            form.raiseOnDeactivate(this);
            form.detach();
        }
    }

    /**
        Function make all registered form invisible
        @return <Void>
    */
    function hideAll()
    {
        for(var form in this.native)
            form.visible = false;

    }

    /**
        Function makes current form invisible and call on deactivation method,
        and makes previous form visible and call on activation method
        @return <Form|false> If previous form exists, return instance of Form. Otherwise false
    */
    function pop()
    {
        var form = null;

        if(this._history.length > 0)
        {
            form = this._getFormByName(this._history.pop())
            if(form instanceof Form)
            {
                form.raiseOnDeactivate(this);
                form.visible = false;
            }
        }
        else
        {
            //can not pop history is empty
            return false;
        }

        form = this._getFormByName(this._history[this._history.length - 1]);
        form.raiseOnActivate(this);
        form.visible = true;

        return form;

    }

    /**
        Functiom makes form visible, register form to application and raise onActivate method.
        If form is already registered in application, it makes form visible and raise onActivate method only.

        @param <Form|String> Expects instance of Form or Form name
    */
    function push(form)
    {
        if(form instanceof Form || form instanceof String)
            this._pushForm(form);
        else if(form instanceof Controller)
            this._pushController(form);
        else
            throw new InvalidArgument("[Application.push] expects instance of form, name of the form or instance of controller");

    }

    /**
        Function shows modal window
        @param <Overlay> instance of Overlay expected
    */
    function showModal(overlay)
    {
        this.add(overlay, true, #front);
    }

    /**
        Function replace current form
        @param <Form|String> form Expects instance of Form of form name
        @param <Boolean> remove Remove form from application if true. Default is false.
    */
    function replace(form,remove=false)
    {
        if(typeof form === #string)
            form = this._getFormByName(form);

        if(this._currForm && remove)
        {
            //raiseOndeactivate and detach form
            this.remove(this._currForm)
        }
        else if(this._currForm && !remove)
        {
            //raise onDeactivate and hide form
            this.hide(this._currForm);
        }

        //Display form
        this.push(form);

    }

    /**
        Funcian add forms to application
        @param <Control> control Instanc of Moscrif control
        @param <Boolean> force default is false and expects only instances of Form
        @param <Symbol> order default is #front, position in applicaton queue
        @throw <InvalidArgument> Expects instance of Form
    */
    function add(control, force = false, order = #front)
    {

        if(force)
        {
            //add item to application, it does not metter if it is form
            super.add(control, order);
        }
        else
        {
            assert control !== null;
            assert control instanceof Form;

            //check if form is already stored
            if(this.isForm(control.name) === false){
                super.add(control, order);
            }else{
                //check if stored form is equal to passed form
                var storedForm = this._getFormByName(control.name)
                if(storedForm !== control)
                    logW("Form instance is not equal to stored form");
            }
        }
    }

    /**
        Function application init. It check if skin instance is set. It won't run without it.
        @param <Boolean> AllowFPS Displays FPS on the screen
        @throw <Exception> Instance of the skin is missing
    */
/*    function init(allowFPS = false)
    {
        //check if skin instance is set if not throw an exception
        if(! (this.skin && this.skin instanceof Skin))
            throw new Exception("Instance of the skin is missing");

        return super.init(allowFPS);;
    }
*/
    /**
        Application Keyboard handler
        @return <Keyboard> Return applicaton keyboard instance
    */
    property keyboard(v)
    {
        get {
            if(this._keyboard == null)
            {
                this._keyboard = new Keyboard();
                this.add(this._keyboard, true);
            }

            return this._keyboard;
        }
    }

    /**
        Function for request of keyboard. Application can by system one or Moscrif keyboard
        @param <Function> callback
        @param <Symbol> keyboardType
    */
    function requestKeyboard(callback, keyboardType = #default)
    {

        if(System.IS_EMULATOR === true)
        {
            this.keyboard.top = System.height - this.keyboard.height;
            this.keyboard.keyboardType = keyboardType;
            this.keyboard.visible = true;
            this.keyboard.invalidate();
            this.keyboard.onKey = function(sender,key)
            {
                callback(key);
            }

        }else if(System.IS_EMULATOR === false){

            //var fn = callback;
            System.requestKeyboard(function(sender,key)
            {  callback(key) }, keyboardType)

        }
    }

    /**
        Function makes keyboard invisible
    */
    function hideKeyboard()
    {
        if(System.IS_EMULATOR === true)
            this.keyboard.visible = false;
        else
            System.hideKeyboard();
    }

    /**
        Application skin handler. If appliaction is emulated, it tooks skin form project settings
        If application is running on the real device it includes existing skin
        @private
    */
    function _applicationSkinHandler()
    {
        if(System.IS_EMULATOR == true)
        {
            //load curent emulator skin
            this._loadSkin(System.emulator("skin"));
        }else{
            //scan for device skin
            System.scanFiles("lib://uix-skin/*", function(skinName,flag){
                if(! (System.isDir(skinName) && (skinName == "." || skinName == ".." || skinName.substr(0,1) == ".")))
                {
                    this super._loadSkin(skinName)
                    return false;
                }
                return true;
            })
        }

    }

    /**
        Load skin instance
        @param <String> skinName
        @throw <Exception> Skin (skinLocation) does not exists
        @throw <Exception> Unknow skin (skinName), or incorrect project settings
    */
    function _loadSkin(skinName)
    {
        if(skinName)
        {

          var skinLocation = "lib://uix-skin/" + skinName + "/skin." + skinName + ".ms";
          var skinClassName = skinName.substr(0,1).toUpperCase() + skinName.substr(1,skinName.length) + "Skin";

          if (!System.isFile(skinLocation)) {
            throw new Exception("Skin (" + skinLocation + ") does not exists");
          }

          //include skin class
          load(skinLocation);
          //create skin instance and assign it to application skin
          this.skin = eval(" new " + skinClassName + "()");


        }
        else
         throw new Exception("[Applicaion.skinHandler] Unknow skin ("+skin+"), or incorrect project settings");
    }

    /**
        Function search for registered form by its name
        @private
        @param <String> name
        @return <Form|undefined> Return instance of form or undefined
    */
    function _getFormByName(name)
    {
        if(name)
        {
            var ret = this.native.find(name.toString());

            if(ret instanceof Form)
                return ret;
        }

        return undefined;
    }

    /**
        Resize handler
        @private
        @param <Control> sender
        @param <Integer> w width
        @param <Integer> h height
    */
    function _onResizeHandler(sender,w,h)
    {
        if(System.width < System.height)
            this.orientation = #portrait;
        else
            this.orientation = #lanscape;
    }


    function _pushForm(form)
    {
        if(typeof form === #string)
            form = this._getFormByName(form);

        //hide all stored forms
        this.hideAll();

        //add form to the container
        this.add(form);

        //make current form visible
        form.raiseOnActivate(this);
        form.visible = true;

        this._history.push(form.name);
    }

    function _pushController(controller)
    {
        var form;
        if (this.isForm(controller.name) === false) {
            form = new Form({name : controller.name})
            if (controller.top)
                form.add(controller.top);
            if (controller.content)
                form.add(controller.content);
            if (controller.bottom)
                form.add(controller.bottom);
        } else {
            form = this._getFormByName(controller.name);
        }
        this._pushForm(form);
    }
   



}