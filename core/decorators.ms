// decorator '@params' - verification of parameters passed to the function
function @params(func, param_types..)
{
    return function(params..)
    {
        var n = 0;
        for(var p in params)
        if(typeof p != param_types[n++])
            throw String.printf("parameter '%s', expected %s but got %s", func.arguments[n-1], param_types[n-1], typeof p);
        return func.apply(this,params);
    }
}

// decorator '@returns' - verification of returned value of the function
function @returns(func, return_type)
{
    return function(params..)
    {
        var rv = func.apply(this,params);
        if( typeof rv != return_type )
            throw String.printf("expected to return %s but got %s", return_type, typeof rv);
        return rv;
    }
}

/*

    @returns #integer    
    @params #integer #integer
    function SumInt(a,b)
    {
      return a + b;  
    }
    
    stdout << SumInt(2,2) << "\n"; // should pass
    try 
    {
      stdout << SumInt(2,2.0) << "\n"; // should throw an error: "parameter 'b', expected integer but got float"
    }
    catch(e)
    {
      stdout << "OK:" << e << "\n";
    }

*/

// decorator '@this' - defines ctor that initializes instance by copying fields from proto object.
//                     see sample below.     
function @this(func, proto)
{
    this[#this] = // this is the class in decorators, cls this[#this] = function(){} is equivalent of function this(){} inside the class declaration.  
        func
        ?
            function(params..)
            {
                for(var n in proto) this[n] = proto[n];
                func.apply(this, params);
            }
        :
            function()
            {
                for(var n in proto) this[n] = proto[n];
            }
}

/*

    class Foo
    {
      // Declaration of ctor plus two predefined fields for the instance. 
      // Notation is a bit unusual but works.
      
      @this { one:1, two:2 } :{} 
      // ^  ^                ^ 
      // |  |                | lambda function declaration (empty here) - body of the ctor. 
      // |  |
      // |  | object literal used for instance initialization
      // |
      // | name of our function-decorator (above).
    }

    class Bar
    {
      // Declaration of empty ctor - just predefined fields for the instance. 
      @this { three:3, four:4 };  // ';' at the end designates an empty decorator
    }
    
    var foo = new Foo();
    var bar = new Bar();

    stdout << foo.one << "\n"; // should print '1'
    stdout << foo.two << "\n"; // should print '2'

    //debug;    
    stdout << bar.three << "\n"; // should print '3'
    stdout << bar.four << "\n"; // should print '4'

*/

function @event(dummy, eventName)
{
    var notify_sym = symbol("notify_" + eventName.toString());
    var list_sym = symbol("_" + eventName.toString());
    var prop_sym = eventName;

    // 'this' here is a class being decorated
    this[notify_sym] = function(params..) {
        // 'this' here is an instance of the class
        var list = this[list_sym];
        if(typeof list == #array) {
            for (var f in list)
                f.apply(this, this, params); // always pass 'this' in the first param - source element
        }
    }

    // 'this' here is a class being decorated, generating computable property for it.
    this [prop_sym] = property(v) {
        get { return this[list_sym] || (this[list_sym] = []); }
        set { debug stacktrace; throw String.printf("Use object.%s.push(func) to subscribe on this event", list_sym); }
    }
}

function @property(dummy, args..)
{
    assert args.length > 0;
    var propName = args[0];
    var prop_sym = symbol("_" + propName);
    this[prop_sym] = args.length > 1 ? args[1] : null;
    this[propName] = property(v) {
        get return this super[prop_sym];
        set this super[prop_sym] = v;
    }
    //stdout<<"R/W > "; this.show();
}

function @readonly(dummy, args..)
{
    assert args.length == 2;
    var propName = args[0];
    var prop_sym = symbol("_" + propName);
    //if (args.length > 1) stdout <<"XXXXXX " << prop_sym << " " << args[0] << "="  << args[1] << " \n";
    this[prop_sym] = args[1];
    //stdout << "\t > " << this[prop_sym] << "\n";
    this[propName] = property(v) {
        get return this super[prop_sym];
        set throw String.printf("Cannot set readonly property '%s'", propName);
    }
    //stdout<<"R/O > "; this.show();
}

function delegate(that, thatMethod) {
    return function(params..)
    {
        return thatMethod.apply(that, params);
    }
}