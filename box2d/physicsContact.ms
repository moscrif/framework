include "lib://core/baseClass.ms";
include "lib://box2d/physicsSprite.ms";
include "lib://box2d/physicsScene.ms";

/**
The class manages contact between two shapes. A contact exists for each overlapping AABB in the broad-phase (except if filtered).
Therefore a contact object may exist that has no contact points.
One instance of the PhysicsContact class can contains information about more contacts. An instanco of this class is usally created automatically, and pushed as a parameter onto functino, which react onto {{#crossLink "PhysicsScene/onBeginContact"}}{{/crossLink}} and {{#crossLink "PhysicsScene/onEndContact"}}{{/crossLink}} events.
@module box2d
@class PhysicsContact
@example
    function beginContact(contact)
    {
        // get the first contact
        var current = contact;
        while (current) {
            // get the bodies in the contact
            var bodyA = current.getBodyA();
            var bodyB = current.getBodyB();
            ...
            // get the next contact (there can be more contacts)
            current = current.getNext();
        }
    }

*/
class PhysicsContact //: BaseClass
{
    /**
    Class constructor. Create an instance of physics contact. The PhysicsContact class is usually made automatically.
    @method this
    @param world {PhysicsScene} Instance of physics scene
    @param nativeContact {b2Contact} Moscrif native instance of b2Contact
    */
    function this(world, nativeContact)
    {
        assert world instanceof PhysicsScene;
        assert nativeContact instanceof b2Contact;

        //var o = new PhysicsContact();
        this._world = world;
        this._nativeContact = nativeContact;

        //return o;
    }

    /**
    Moscrif native instance of b2Contact contained in the object of PhysicsContact class.
    @property native
    @type b2Contact
    */
    property native(v)
    {
        get return this._nativeContact;
    }

    /**
    Enable/disable this contact. This can be used inside the pre-solve contact listener.
    The contact is only disabled for the current time step (or sub-step in continuous collisions).
    @property enabled
    @type Boolean
    */
    property enabled(v)
    {
        get return this.native.enabled;
        set this.native.enabled = v;
    }

    /**
    Is this contact touching?
    @property isTouching
    @type Boolean
    */
    property isTouching(v)
    {
        get return this.native.isTouching;
    }

    /**
    Density of the first body in contact.
    @property densityA
    @type Float
    */
    property densityA(v)
    {
        get return this.native.densityA;
        set this.native.densityA = v;
    }

    /**
    Friction of the first body in contact..
    @property frictionA
    @type Float
    */
    property frictionA(v)
    {
        get return this.native.frictionA;
        set this.native.frictionA = v;
    }

    /**
    Bounce value of first object. The bounce value is usually set to be between 0 and 1. Consider dropping a ball on a table. A value of zero means the ball won't bounce. This is called an inelastic collision. A value of one means the ball's velocity will be exactly reflected. This is called a perfectly elastic collision.
    If collide two bodies with different bounce the box2d uses larger value to simulate the bounce.
    @property bounceA
    @type Float
    */
    property bounceA(v)
    {
        get return this.native.restitutionA;
        set this.native.restitutionA = v;
    }

    /**
    Density of the second body in contact.
    @property densityB
    @type Float
    */
    property densityB(v)
    {
        get return this.native.densityB;
        set this.native.densityB = v;
    }

    /**
    Friction of the second body in contact.

    @property frictionB
    @type Float
    */
    property frictionB(v)
    {
        get return this.native.frictionB;
        set this.native.frictionB = v;
    }

    /**
    Bounce value of second object. The bounce value is usually set to be between 0 and 1. Consider dropping a ball on a table. A value of zero means the ball won't bounce. This is called an inelastic collision. A value of one means the ball's velocity will be exactly reflected. This is called a perfectly elastic collision.
    If collide two bodies with different bounce the box2d uses larger value to simulate the bounce.
    @property bounceB
    @type Float
    */
    property bounceB(v)
    {
        get return this.native.restitutionB;
        set this.native.restitutionB = v;
    }

    /**
    Get the first body in the contact.
    @method getBodyA
    @return PhysicsSprite the first body in the contact
    @example
        function beginContact(contact)
        {
            // get the first contact
            var current = contact;
            while (current) {
                // get the bodies in the contact
                var bodyA = current.getBodyA();
                var bodyB = current.getBodyB();
                ...
                // get the next contact (there can be more contacts)
                current = current.getNext();
            }
        }
    */
    function getBodyA()
    {
        var nativeBodyA = this.native.getBodyA();
        var bodyA = this._world.getBody( nativeBodyA );
        return bodyA;
    }

    /**
    Get the second body in the contact.
    @method getBodyB
    @return PhysicsSprite The second body in the contact.
    @example
        function beginContact(contact)
        {
            // get the first contact
            var current = contact;
            while (current) {
                // get the bodies in the contact
                var bodyA = current.getBodyA();
                var bodyB = current.getBodyB();
                ...
                // get the next contact (there can be more contacts)
                current = current.getNext();
            }
        }
    */
    function getBodyB()
    {
        var nativeBodyB = this.native.getBodyB();
        var bodyB = this._world.getBody( nativeBodyB );
        return bodyB;
    }

    /**
    Get the next contact in the contact list.
    @method getNext
    @return b2Contact Next contact in the list or null if no other is available.
    @example
        function beginContact(contact)
        {
            // get the first contact
            var current = contact;
            while (current) {
                // get the bodies in the contact
                var bodyA = current.getBodyA();
                var bodyB = current.getBodyB();
                ...
                // get the next contact (there can be more contacts)
                current = current.getNext();
            }
        }
    */
    function getNext()
    {
        var nextNative = this.native.getNext();
        if (nextNative == null)
            return null;
        var contact = new PhysicsContact(this._world, nextNative);
        return contact;
    }
}