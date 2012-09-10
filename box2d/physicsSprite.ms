include "lib://game2d/sprite.ms";

/**
The physics sprite represents rigid body in the physics simulation. The sprite's behaviour can be customized by several properties like density, friction or bounce. Three types of sprites are supported: #dynamic, #static, #kinematic. Every body type have different behaviour. Instances of this class are usually created by {{#crossLink "PhysicsScene/addCircleBody"}}{{/crossLink}} or {{#crossLink "PhysicsScene/addPolygonBody"}}{{/crossLink}}methods.
@module box2d
@class PhysicsSprite
@example
    // create a physics sprite
    var puck = physicsScene.addCircleBody(res.images.puck, #dynamic, density, friction, bounce,  res.images.puck.width / 2);
    // place puck to center of the table
    puck.setPosition(System.width / 2, System.height / 2);
*/
class PhysicsSprite : Sprite
{
    /**
    Init of the PhysicsSprite instance. It sets default values for density, friction, bounce and body type.
        An instance of PhysicsSprite is usually not created by a keyword new. It is usually created using methods: {{#crossLink "PhysicsScene/addCircleBody"}}{{/crossLink}} or {{#crossLink "PhysicsScene/addPolygonBody"}}{{/crossLink}}
    @method init
    @protected
    */
    function init()
    {
        super.init();

        this._bodyType = #static;
        this._density = 1.0;
        this._friction = 0.3;
        this._bounce = 0.2;
    }

    /**
    Create Physics Body into current PhysicsWorld.
    @method create
    @param scene {PhysicsScene}  instance of scene into which should be sprite added
    @param image {Bitmap} Image drawen in the body
    @param shape {b2CircleShape|b2PolygonShape}  Shape of new object.
    @param bodyType {Symbol} BodyType's type
        #static - A static body has does not move under simulation and behaves as if it has infinite mass. Internally, Box2D stores zero for the mass and the inverse mass. Static bodies can be moved manually by the user. A static body has zero velocity. Static bodies do not collide with other static or kinematic bodies.
        #dynamic - A dynamic body is fully simulated. They can be moved manually by the user, but normally they move according to forces. A dynamic body can collide with all body types. A dynamic body always has finite, non-zero mass. If you try to set the mass of a dynamic body to zero, it will automatically acquire a mass of one kilogram.
        #kinematic - A kinematic body moves under simulation according to its velocity. Kinematic bodies do not respond to forces. They can be moved manually by the user, but normally a kinematic body is moved by setting its velocity. A kinematic body behaves as if it has infinite mass, however, Box2D stores zero for the mass and the inverse mass. Kinematic bodies do not collide with other static or kinematic bodies
    @param density {Float} Density of the sprite.
    @param friction {Float}  Friction of the sprite, affects the body adhesion.
    @param bounce {Float} Bounce number from 0 to 1. The zero means non bounce -> one means full bounce.
    @param calledClass = null {Class} Class to create a sprite. It should be class extended from PhysicsSprite..
    @return PhysicsSprite
    */
    function create(scene, image, shape, bodyTypeSym, density, friction, bounce, calledClass = null)
    {
        if(calledClass == null)
            calledClass = PhysicsSprite;

        var o = new calledClass({ scene:scene, image:image, shape:shape, bodyType:bodyTypeSym, density:density, friction:friction, bounce:bounce});
        o._createBody();

        return o;
    }

    /*
    Instance of the image
    @param Bitmap image Instance of bitmap
    @return Bitmap
    */
    /*property image(v)
    {
        get return this._image;
        set this._image = v;
    }*/

    /**
    Instance of b2world into which is added this sprite.
    @property world
    @type b2world
    */
    property world(v)
    {
        get return this._scene.native;
    }

    /**
    Instance of PhysicsScene into which is added this sprite
    @property scene
    @type PhysicsScene
    */
    property scene(v)
    {
        get return this._scene;
        set {
            assert v instanceof PhysicsScene;
            this._scene = v;
        }
    }

    /*
    Probably not needed
    Type of the shape of the body.
    @param Symbol
        #polygon Polygon shape
        #circle  Circle shape
    @return Symbol
    */
    /*property shapeType(v)
    {
        get return this._shapeType;
        set this._shapeType = v;
    }*/

    /**
    Enable / disable rotation of the body. True to enable rotation, false to disbable.
    @type Boolean
    @property fixedRotation
    */
    property fixedRotation(v)
    {
        get return this._b2body.fixedRotation;
        set this._b2body.fixedRotation = v;
    }

    /**
    Current body rotation angle in radians.
    @property angle
    @type Float
    */
    property angle(v)
    {
        get return this._b2body.getAngle();
        set this._b2body.setAngle(v);
    }

    /**
    Flag to treat sprite like a bullet for continuous collision detection (CCD). If the sprite is set as a bullet CCD detect colisions also with dynamic bodies, otherwise it detect colisions only with static bodies.
    What is CCD?
    Continuous collision detection (also called CCD), is a box2d feature which ensures correct simulation of fast moving objects.
    Some older physical engines do not supports CCD, what means that they calculate positions and colisions of bodies for every time step, what is called discrete simulation. However in discrete simulation rigid body can move long distance in time step. (If the body has sufficiently high speed, it can be  before time step few meters in front of the barrier and after time step it can be few meters behind the barrier.)  It caused that the fast moving body can move throw another body without detection of collision between these two bodies. This effect is called tunneling.
    By default box2d uses CCD to prevent tunneling effect. CCD looks for all collisions between the position before and after time step. For every collision it calculates time of impact (TOI). On the next time step the body moves only to the next TOI and then wait for the rest of time step and does not move anymore during the time step. To ensure the best performace the CCD calculates contacts only between dynamic and static bodies (not between the dynamic bodies each other). However, onto dynamic bodies can be set CCD separately. If there is fast moving body, which hit other dynamic bodies, you can set the fast moving body’s property bullet to true to allows CCD onto it.
    True to enable CCD on this body, false to disable it
    @property bullet
    @type Boolean
    */
    property bullet(v)
    {
        get return this._b2body.bullet;
        set this._b2body.bullet = v;
    }

    /**
    Set to true to put body to sleep, false to wake it.
    A sleeping sprite has very low CPU cost.
    @property awake
    @type Boolean
    */
    property awake(v)
    {
        get return this._b2body.awake;
        set this._b2body.awake = v;
    }

    /**
    Set the active state of the body. Inactive bodies are added in the scene, but do not interacts in the physical simulation.
    @property active
    @type Boolean
    */
    property active(v)
    {
        get return this._b2body.active;
        set this._b2body.active = v;
    }

    /**
    You can disable sleeping on this body.
    If you disable sleeping on actualy sleeping body, the body will be woken.

    @property sleepingAllowed
    @type Boolean
    */
    property sleepingAllowed(v)
    {
        get return this._b2body.sleepingAllowed;
        set this._b2body.sleepingAllowed = v;
    }

    /**
    Native instance of b2Body contained in the PhysicsSprite object.

    @property native
    @type Boolean
    */
    property native(v)
    {
        get return this._b2body;
    }

    /**
    Method to be executed when PhysicsSprite going to be drawn. The draw method can draw onto whole canvas, also outside the sprite. To ensure correct drawing sprite's image should have same dimensions as the sprite.
    @method draw
    @protected
    @param canvas {Canvas} Canvas used for drawing.
    */
    function draw(canvas)
    {
        //set coordination
        var (x,y) = this.getPosition();
        this.x = x;
        this.y = y;

        if(this.image instanceof Bitmap)
            super.draw(canvas);
    }

    /**
    Get type of body. The body type affects its behaviour in the simulation.
    Three body types are supported:
    #static - A static body has does not move under simulation and behaves as if it has infinite mass. Internally, Box2D stores zero for the mass and the inverse mass. Static bodies can be moved manually by the user. A static body has zero velocity. Static bodies do not collide with other static or kinematic bodies.
    #dynamic - A dynamic body is fully simulated. They can be moved manually by the user, but normally they move according to forces. A dynamic body can collide with all body types. A dynamic body always has finite, non-zero mass. If you try to set the mass of a dynamic body to zero, it will automatically acquire a mass of one kilogram.
    #kinematic - A kinematic body moves under simulation according to its velocity. Kinematic bodies do not respond to forces. They can be moved manually by the user, but normally a kinematic body is moved by setting its velocity. A kinematic body behaves as if it has infinite mass, however, Box2D stores zero for the mass and the inverse mass. Kinematic bodies do not collide with other static or kinematic bodies

    @method getBodyType;
    @return Symbol type of the body: #static, #kinematic or #dynamic
    */
    function getBodyType()
    {
        return this._b2body.getBodyType();
    }

    /**
    Get the global gravity. The gravity is a base feature of the physics scene and is same for all bodies
    @method getGravity;
    @return Multivalue Pair of float values. First is gravity one x axis and second one y axis.
    */
    function getGravity()
    {
        return this._scene.getGravity();
    }

    /**
    Set world’s gravity (separately for x and y axis). The gravity is a base feature of the physics scene and is same for all bodies
    @method setGravity
    @param Float gx Gravity on x axis.
    @param Float gy Gravity on y axis.
    @example
        // create sensor
        var sensor = new Sensor(#acceleration, 40);
        // setup handler for receiving data
        sensor.onDataReceived = function(sender, timestamp, params) {
            var (x, y, z) = (params[0], params[1], params[2]);
            app.world.setGravity(-x * 5., -y * 5.);
        };
        // start receiving data
        sensor.start();
    */
    function setGravity(gx, gy)
    {
        return this._scene.setGravity(gx, gy);
    }

    /**
    Get the world position of the center of mass in screen coordinates -> pixels from left top corner of the screen.
    @method getWorldCenter
    @return Multivalue Pair of values: x and y world coordinate.
    */
    function getWorldCenter()
    {
        var (x, y) = this._b2body.getWorldCenter();
        var realX = (x*this._scene.scale);
        var realY = System.height - (y*this._scene.scale);
        return (Math.floor(realX), Math.floor(realY));
    }

    /**
    Get the local position of the center of mass in screen coordinates -> pixels from left top corner of the screen.
    @method getLocalCenter
    @return Multivalue Pair of float values: x,y.
    */
    function getLocalCenter()
    {
        var (x, y) = this._b2body.getLocalCenter();
        var realX = (x * this._scene.scale);
        var realY = System.height - (y * this._scene.scale);
        return (Math.floor(realX), Math.floor(realY));
    }

    /**
    Gets a local point relative to the body's origin given a world point in screen coordinates -> pixels from left top corner of the screen.
    @method getLocalPoint
    @param worldPointX {Float} X coordinate of point in world coordinates.
    @param worldPointY {Float} Y coordinate of point in world coordinates.
    @return {Multivalue} Pair of float values: the corresponding local point relative to the body's origin.
    */
    function getLocalPoint(worldPointX, worldPointY)
    {
        var (x, y) = this._b2body.getLocalPoint(worldPointX/this._scene.scale, (System.height - worldPointY)/this._scene.scale);
        var realX = (x*this._scene.scale);
        var realY = System.height - (y*this._scene.scale);
        return (Math.floor(realX), Math.floor(realY));
    }

    /**
    Get the world coordinates of a point given by the local coordinates in screen coordinates -> pixels from left top corner of the screen..
    @method getWorldPoint
    @param localPointX {Float} A point x coordinate on the body measured relative the the body's origin.
    @param localPointY {Float} A point x coordinate on the body measured relative the the body's origin.
    @return {Multivalue} Pair of values: x and y coordinate of the same point expressed in world coordinates.
    */
    function getWorldPoint(localPointX, localPointY)
    {
        var (x, y) = this._b2body.getLocalPoint(localPointX/this._scene.scale, (System.height - localPointY)/this._scene.scale);
        var realX = (x*this._scene.scale);
        var realY = System.height - (y*this._scene.scale);
        return (Math.floor(realX), Math.floor(realY));
    }

    /**
    Gets a local vector's x and y from given world vector's x and y coordinates in screen coordinates -> pixels from left top corner of the screen..
    @method getLocalVector
    @param localPointX {Float} A world vector's x component.
    @param localPointY {Float} A world vector's y component.
    @return {Multivalue} The corresponding local vector's x and y components.
    */
    function getLocalVector(worldVectorX, worldVectorY)
    {
        var (x, y) = this._b2body.getLocalPoint(worldVectorX, worldVectorY);
        return (x, y);
    }

    /**
    Convert local vector's x and y component to world vector's components in screen coordinates -> pixels from left top corner of the screen..
    @method getWorldVector
    @param localVectorX {Float} X component of vector fixed in the body.
    @param localVectorY {Float} Y component of vector fixed in the body.
    @return {Multivalue} The same vector x and y component expressed in world coordinates.
    */
    function getWorldVector(localVectorX, localVectorY)
    {
        var (x, y) = this._b2body.getLocalPoint(localVectorX, localVectorY);
        return (x, y);
    }

    /**
    Get the total mass of the body in kilograms. The mass is calculated as a density*volume. Because of the the box2d does not support the third dimension the volume is calculated like: volume = width*height (width and height in box2d coordinates -> (width in pixels) / (scene scale) - same for width)
    @method getMass
    @return {Float} Total mass of the body in kilograms.
    @example
        var jointDef = {
            ...
            maxMotorForce       : this._body.getMass() * 8.5,
        }
    */
    function getMass()
    {
        return this._b2body.getMass();
    }

    /**
    Get the rotational inertia of the body about the local origin.
    @method getInertia()
    @return {Float} The rotational inertia, usually in kg-m^2.
    */
    function getInertia()
    {
        return this._b2body.getInertia();
    }

    /**
    Place sprite to x, y. When the sprite is moving using setPosition function it does not interacts with other sprites in the scene.
    @method setPosition
    @param x {Float} The world position (x) of the body's local origin in pixels from left top corner.
    @param Y {Float} The world position (y) of the body's local origin in pixels from left top corner..
    */
    function setPosition(x, y)
    {
        this.x = x;
        this.y = y;
        this._b2body.setPosition(x/this._scene.scale, (System.height - y)/this._scene.scale);
    }

    /**
    Get the body's origin position in pixels from left top corner of the device's screen.
    @method getPosition
    @return {Multivalue} Pair of float values: x, y - the world position of the body's origin.
    */
    function getPosition()
    {
        var (x, y) = this._b2body.getPosition();
        var realX = (x*this._scene.scale);
        var realY = System.height - (y*this._scene.scale);
        return (realX, realY);
    }

    /**
    Get the world linear velocity of a world point attached to this body.
    @method getLinearVelocityFromLocalPoint
    @param lx {Float} X coordinate of point in world coordinates.
    @param ly {Float} Y coordinate of point in world coordinates.
    @return {Multivalue} Pair of float values: the world velocity on x and y axis of a point.
    */
    function getLinearVelocityFromLocalPoint(lx, ly)
    {
        var(x, y) = this._b2body.getLinearVelocityFromLocalPoint(lx, ly);
        return (x, y);
    }

    /**
    Get the world velocity of a local point.
    @method getLinearVelocityFromWorldPoint
    @param wx {Float} X coordinate of point in local coordinates.
    @param wy {Float} Y coordinate of point in local coordinates.
    @return {Multivalue} Pair of float values: the world velocity on x and y axis of a point.
    */
    function getLinearVelocityFromWorldPoint( wx, wy )
    {
        var(x, y) = this._b2body.getLinearVelocityFromWorldPoint(wx, wy);
        return (x, y);
    }

    /**
    Get linear velocity of the center of mass.
    @method getLinearVelocity
    @return {Multivalue} Pair of float values: linear velocity of the center of mass on x and y axis
    @example
        var (vX, vY) = this._character.getLinearVelocity();
    */
    function getLinearVelocity()
    {
        var(x, y) = this._b2body.getLinearVelocity();
        return (x, y);
    }

    /**
    Set linear velocity of the center of mass.
    @method setLinearVelocity
    @param x {Float} The new linear velocity on x axis of the center of mass.
    @param y {Float} The new linear velocity on y axis of the center of mass.
    @example
        var (vX, vY) = this._character.getLinearVelocity();
        // if character only slows -> speed it up
        if (vX >  2.0 && this.vX < 4.7)
            this._character.setLinearVelocity(5.0, vY);
    */
    function setLinearVelocity( x, y )
    {
        this._b2body.setLinearVelocity(x, y);
    }

    /**
    Get linear damping of the body. Damping is used to reduce the bodies' velocity. Damping is different than friction because friction only occurs with contact. Damping is not a replacement for friction and these two effects should be used together.
    @method getLinearDamping
    @return {Float} Linear damping of the body.
    */
    function getLinearDamping()
    {
        return this._b2body.getLinearDamping();
    }

    /**
    Set linear damping of the body. Damping is used to reduce the bodies' velocity. Damping is different than friction because friction only occurs with contact. Damping is not a replacement for friction and these two effects should be used together.
    Damping parameters should be between 0 and infinity, with 0 meaning no damping, and infinity meaning full damping. Normally you will use a damping value between 0 and 0.5.
    @method setLinearDamping
    @param damping {Float} linear damping
    @example
        sprite.setLinearDamping(0.3);
    */
    function setLinearDamping( damping ){
        this._b2body.setLinearDamping(damping);
    }

    /**
    Apply an impulse at a point. This immediately modifies the velocity.
    It also modifies the angular velocity if the point of application is not at the center of mass.
    If the body is sleeping, this wakes up it.
    @method applyLinearImpulse
    @param impulseX {Float} The world impulse on x axis, usually in N-seconds or kg-m/s.
    @param impulseY {Float} The world impulse on y axis, usually in N-seconds or kg-m/s.
    @param pointX {Float} The world x position of the point of application.
    @param pointY {Float} The world y position of the point of application.

    */
    function applyLinearImpulse( impulseX, impulseY, pointX, pointY )
    {
        this._b2body.applyLinearImpulse(
            impulseX,
            impulseY,
            pointX/this._scene.scale,
            (System.height - pointY)/this._scene.scale);
    }

    /**
    Apply an angular impulse.
    @method applyAngularImpulse
    @param impulse {Float} impulse
    */
    function applyAngularImpulse( impulse )
    {
        this._b2body.applyAngularImpulse(impulse);
    }

    /**
    Get angular damping of the body. Damping is used to reduce the bodies' velocity. Damping is different than friction because friction only occurs with contact. Damping is not a replacement for friction and these two effects should be used together.
    @method getAngularDamping
    @return {Float} Angular damping of the body.
    */
    function getAngularDamping()
    {
        return this._b2body.getAngularDamping();
    }

    /**
    Set angular damping of the body. Damping is used to reduce the bodies' velocity. Damping is different than friction because friction only occurs with contact. Damping is not a replacement for friction and these two effects should be used together.
    @method setAngularDamping
    @param damping {Float} Angular damping.
    */
    function setAngularDamping(damping)
    {
        this._b2body.setAngularDamping(damping);
    }

    /**
    Apply a force at a world point.
    If the force is not applied at the center of mass, it will generate a torque and affect the angular velocity This wakes up sleeping body.
    @method applyForce
    @param forceX {Float} The world force on x axis, usually in Newtons
    @param forceY {Float} The world force on y axis, usually in Newtons
    @param pointX {Float} The world x coordinate of the point of force application
    @param pointY {Float} The world y coordinate of the point of force application
    */
    function applyForce( forceX/*Newton*/, forceY/*Newton*/, pointX, pointY )
    {
        this._b2body.applyForce(forceX, forceY, pointX/this._scene.scale, (System.height - pointY)/this._scene.scale);
    }

    /**
    Apply a torque. This affects the angular velocity without affecting the linear velocity of the center of mass.
    This wakes up the body.
    @method applyTorque
    @param torque {Float} torque
    */
    function applyTorque(torque)
    {
        this._b2body.applyTorque(torque);
    }

    /**
    Set the position of the body's origin and rotation. This breaks any contacts and wakes the other bodies.
    Manipulating a body's transform may cause non-physical behavior.
    @method setTransform
    @param x {Float} The world x position of the body's local origin.
    @param y {Float} The world y position of the body's local origin.
    @param angle {Float} The world rotation in radians.
    */
    function setTransform(x, y, angle = 0)
    {
        this._b2body.setTransform( x/this._scene.scale, (System.height - y)/this._scene.scale, angle);
    }

    /*
    NOT SUPPORTED
    On Draw event fired when physics body going to be drawn

    */
   /* property onDraw(v)
    {
        get return this._onDraw;
        set {
            assert (v == null) || (typeof v == #function);
            this._onDraw = v;
        }
    }*/

    /**
    Private function, which is used to create create shape of the sprite.
    @method _createShape
    @private
    @param shapeType {Symbol} shapeType
        #polygon
        #circle
    */
    function _createShape(shapeType){

        assert this.scene instanceof PhysicsScene;

        switch(shapeType){
            case #polygon:
                assert this.frameWidth != null;
                assert this.frameHeight != null;
                this.shape = b2PolygonShape.fromRect((this.frameWidth/2)/this.scene.scale, (this.frameHeight/2)/this.scene.scale)
                break;
            case #circle :
                assert this.radius != null;
                this.shape = new b2CircleShape( this.radius / this.scene.scale);
                break;
        }
    }

    /**
    Create box2d body
    @private
    @method _createBody
    */
    function _createBody()
    {
        if(this.shape == null)
            this._createShape(this.shapeType);

        this._b2body = this.world.createBody(this.shape, this.bodyType, this.density, this.friction, this.bounce);
        this._b2body.onDraw = function(sender, canvas) {
            if(this super.onDrawHandler != null)
                this super.onDrawHandler(canvas)
        }

        this.scene.add(this);
    }
}