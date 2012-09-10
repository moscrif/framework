include "lib://core/log.ms";
include "lib://game2d/scene.ms";
include "lib://box2d/physicsSprite.ms";
include "lib://box2d/physicsContact.ms";

/**
This class manages creates background for all physical entities like physical sprites, joints or contacts. It also sets basic hysical properties properties like gravity and provides time steps in simulation. The class contains an instance of native b2World class, which provides all calculations on background.
@class PhysicsScene
@module box2d
@example
    // create instance of physics scene (create method aoutomatically create an instance of b2World class)
    var scene = PhysicsScene.create(0.0, -0.5);
    
    // OR
    
    // create an instance of b2World class manually in init function of extended class
    class GameScene : PhysicsScene
    {
        function init()
        {
            super.init();
    
            // create physics world
            this.world = new b2World(0.0, -9.8, true, false);
            ...
        }
        ...
    }
    // then instance of GameScene can be creates simply by key word new
    var scene = new GameScene();
*/
class PhysicsScene : Scene
{

    /**
    Create an instance of box2d body. Using the create function ensures that native b2World object will be automatically created and it is not needed to create it manually in init method.
    @method create
    @param gx {Float} component of the world gravity vector on the x-axis
    @param gy {Float} component of the world gravity vector on the y-axis
    @param options {Object}
        sleep Boolean  If the sleeping is allowed inactive bodies are not simulated, what improves performance. Default is sleeping disabled.
        enableCollisions Boolean  Enable collisions between bodies. By defeault they are allowed.
        calledClass Class The called class, default is PhysicsScene.
    @example
        // create instance of physics scene (create method aoutomatically create an instance of b2World class)
        var scene = PhysicsScene.create(0.0, -0.5, { calledClass: GameScene } );
    */
    function create(gx, gy, options = {})
    {
        var calledClass = (options.calledClass == undefined ? PhysicsScene : options.calledClass);
        var sleep = (options.sleep == undefined ? false : options.sleep);
        var enableCollisions = (options.enableCollisions == undefined ? true : options.enableCollisions);
        var o = new calledClass({world:new b2World(gx, gy, sleep, enableCollisions)});
        return o;
    }

    /**
    An instance of native b2World class used in physics scene for physical simulation. This property can be used to manually set world, if PhysicsScene is not created by create method.
    @property world
    @type b2World
    @example
        // create an instance of b2World class manually in init function of extended class
        class GameScene : PhysicsScene
        {
            function init()
            {
                super.init();
        
                // create physics world
                this.world = new b2World(0.0, -9.8, true, false);
                ...
            }
            ...
        }
        // then instance of GameScene can be creates simply by key word new
        var scene = new GameScene();
    */
    property world(v)
    {
        get return this._world;
        set {
            assert v instanceof b2World;
            this._world = v;
            this._world.onBeginContact = function(sender, contact)
            {
                var self = this super;

                if (self.beginContact != null)
                    self.beginContact.call(self, new PhysicsContact(self, contact));
            }
            
            this._world.onEndContact = function(sender, contact)
            {
                var self = this super;

                if (self.endContact != null)
                    self.endContact.call(self, new PhysicsContact(self, contact));
            }
        }
    }

    /**
    The width of the ohysics world is always 10 meters. I means that on different displays the world is scaled diferently. The scale property says how meny pixels on the screens represents one meter in physical simulation.
    It helps to convert screen coordinates to box2d coordinates, which also do not start from the left top corner as a screen pixels coordinates, but from the left bottom corner of the screen.
    @property scale
    @type Float
    @example
        // converts x-coord from screen to box2d
        function x2box2d(x)
        {
            return x / this._world.scale;
        }
    
        // converts y-coord from screen to box2d
        function y2box2d(y)
        {
            return (System.height - y) / this._world.scale;
        }
    */
    property scale(v)
    {
        get return this._world.scale;
    }

    /**
    Flag to control automatic clearing of forces after each time step. By default it is set to true.
    @property autoClearForces
    @type Boolean
    */
    property autoClearForces(v)
    {
        get return this._world.autoClearForces;
        set this._world.autoClearForces = v
    }

    /**
    An instance of native b2World class used in physics scene for physical simulation. The value of this property is same as a value of {{#crossLink "PhysicsScene/world"}}{{/crossLink}}. This property is get only. To set the native world use {{#crossLink "PhysicsScene/world"}}{{/crossLink}}.
    @property native
    @type b2World
    */
    property native(v)
    {
        get return this._world;
    }

    /**
    Get the global gravity. The gravity affects all dynamic bodies (sprites) in the scene.
    @method getGravity
    @return {Multivalue} Pair of float values. First is gravity one x axis and second one y axis.
    @example
        var (gx, gy) = scene.getGravity();
    */
    function getGravity()
    {
        return this._world.getGravity();
    }

    /**
    Set the global gravity. The gravity affects all dynamic bodies (sprites) in the scene.
    @method setGravity
    @param gx {Float} Gravity on x-axis
    @param gy {Float} Gravity on y-axis
    @example
        scene.setGravity(0.0, -9.8);
    */
    function setGravity(gx, gy)
    {
        return this._world.setGravity(gx, gy);
    }

    /**
    Initialize basic properties, like debugDraw
    @method init
    */
    function init()
    {
        super.init();

        this._debugDraw = false;
    }

    /**
    Get body from bodies array.
    @method getBody
    @param body {b2Body}
    @return {PhysicsSprite} Object instance or null
    */
    function getBody(body)
    {
        for (var sprite in this._objects)
            if (sprite.native === body)
                return sprite;
        return null;
    }

    /**
    Take a time step. This performs collision detection, integration, and constraint solution. This functin is usually called from process method every about 25 miliseconds.
    @method step
    @param [timeStep=1.0/40.0] {Float} The amount of time to simulate.
    @param [velocityIterations=4] {Integer} For the velocity constraint solver.
    @param [positionIterations=8] {Integer} For the position constraint solver.
    @example
        function process()
        {
            // call parents process method
            super.process();
        
            // do physics math
            this.step(1.0 / 40.0, 4, 8);
            // redraw window
            game.invalidate();
        }
    */
    function step(timeStep = 1.0/40.0, velocityIterations = 4, positionIterations = 8)
    {
        this._world.step(timeStep, velocityIterations, positionIterations);
    }

    /**
    Manually clear the force buffer on all bodies.
    By default, forces are cleared automatically after each call to {{#crossLink "PhysicsScene/step"}}{{/crossLink}} method.
    @method clearForces
    */
    function clearForces()
    {
        this._world.clearForces();
    }

    /**
    Enable/disable warm starting. If the warm starting is enabled some box2d solvers uses resoul from previous time step, what improves performance.
    @method setWarmStarting
    @param flag {Boolean} Ture / false to enable / disable warm starting
    */
    function setWarmStarting(flag)
    {
        this._world.setWarmStarting(flag);
    }

    /**
    Enable/disable continuous physics.
    Continuous collision detection (also called CCD), is a box2d feature which ensures correct simulation of fast moving objects.
    Some older physical engines do not supports CCD, what means that they calculate positions and colisions of bodies for every time step, what is called discrete simulation. However in discrete simulation rigid body can move long distance in time step. (If the body has sufficiently high speed, it can be  before time step few meters in front of the barrier and after time step it can be few meters behind the barrier.)  It caused that the fast moving body can move throw another body without detection of collision between these two bodies. This effect is called tunneling.
    By default box2d uses CCD to prevent tunneling effect. CCD looks for all collisions between the position before and after time step. For every collision it calculates time of impact (TOI). On the next time step the body moves only to the next TOI and then wait for the rest of time step and does not move anymore during the time step. To ensure the best performace the CCD calculates contacts only between dynamic and static bodies (not between the dynamic bodies each other). However, onto dynamic bodies can be set CCD separately. If there is fast moving body, which hit other dynamic bodies, you can set the fast moving body’s property bullet to true to allows CCD onto it.
    @method setContinuousPhysics
    @param Boolean flag
    */
    function setContinuousPhysics(flag)
    {
        this._world.setContinuousPhysics(flag);
    }

    /**
    Get the number of broad-phase proxies.
    @method getProxyCount
    @return {Integer} number of proxy
    */
    function getProxyCount()
    {
        return this._world.getProxyCount();
    }

    /**
    Get the number of bodies in the scene.
    @method getBodyCount
    @return {Integer} number of bodies
    */
    function getBodyCount()
    {
        return this._world.getBodyCount();
    }

    /**
    Get the number of joints in the scene.
    @method getJointCount
    @return {Integer} number of joints
    */
    function getJointCount()
    {
        return this._world.getJointCount();
    }

    /**
    Get the number of contacts (each may have 0 or more contact points).
    @method getContactCount
    @return {Integer} number of contacts
    */
    function getContactCount()
    {
        return this._world.getContactCount();
    }

    /**
    Add edge physics sprite into scene. Edge shapes are line segments. These are provided to assist in making a free-form static environment. Edge shapes can collide with circles and polygons bodies but not with themselves. Edge bodies have no volume.
    @method addEdgeBody
    @param image {Bitmap} Image drawn in the body
    @param bodyTypeSym {Symbol}
        #static - A static body has does not move under simulation and behaves as if it has infinite mass. Internally, Box2D stores zero for the mass and the inverse mass. Static bodies can be moved manually by the user. A static body has zero velocity. Static bodies do not collide with other static or kinematic bodies.
        #dynamic - A dynamic body is fully simulated. They can be moved manually by the user, but normally they move according to forces. A dynamic body can collide with all body types. A dynamic body always has finite, non-zero mass. If you try to set the mass of a dynamic body to zero, it will automatically acquire a mass of one kilogram.
        #kinematic - A kinematic body moves under simulation according to its velocity. Kinematic bodies do not respond to forces. They can be moved manually by the user, but normally a kinematic body is moved by setting its velocity. A kinematic body behaves as if it has infinite mass, however, Box2D stores zero for the mass and the inverse mass. Kinematic bodies do not collide with other static or kinematic bodies
    @param density {Float} Density of the sprite.
    @param friction {Float}  Friction of the sprite, affects the body adhesion.
    @param bounce {Float} The bounce value is usually set to be between 0 and 1. Consider dropping a ball on a table. A value of zero means the ball won't bounce. This is called an inelastic collision. A value of one means the ball's velocity will be exactly reflected. This is called a perfectly elastic collision.
    If collide two bodies with different bounce the box2d uses larger value to simulate the bounce.
    @param v1x {Float} X coordinate of the first point of the body. The coordinate are in pixels, from the centre of the shape. The positive values are in right and top directions.
    @param v1y {Float} Y coordinate of the first point of the body. The coordinate are in pixels, from the centre of the shape. The positive values are in right and top directions.
    @param v2x {Float} X coordinate of the second point of the body. The coordinate are in pixels, from the centre of the shape. The positive values are in right and top directions.
    @param v2y {Float} Y coordinate of the second point of the body. The coordinate are in pixels, from the centre of the shape. The positive values are in right and top directions.
    @return PhysicsSprite
    @example
        var ground = Bitmap.fromFile("app://ground.png");
        var sprite = this.addEdgeBody(ground, #static, 0.0, 0.0, 0.0, ground.width / -2, 1, ground.width / 2, 10)
        sprite.setPosition(System.width / 2, System.height/2);
    */
    function addEdgeBody(image, bodyTypeSym, density, friction, bounce, v1x, v1y, v2x, v2y)
    {
        assert this._world != null;
        assert image instanceof Bitmap || image == null;
        assert bodyTypeSym == #static || bodyTypeSym == #dynamic || bodyTypeSym == #kinematic;
        var shape = b2PolygonShape.fromEdge(v1x*this.scale, v1y*this.scale, v2x*this.scale, v2y*this.scale);
        var body = PhysicsSprite.create(this, image, shape, bodyTypeSym, density, friction, bounce);
        body.fixedRotation = false;
        body.width = v2x - v1x;
        body.height = v2y - v1y;
        return body;
    }

    /**
    Add polygon physics sprite into scene.
    @method addPolygonBody
    @param image {Bitmap} Image drawn in the body
    @param bodyTypeSym {Symbol}
        #static - A static body has does not move under simulation and behaves as if it has infinite mass. Internally, Box2D stores zero for the mass and the inverse mass. Static bodies can be moved manually by the user. A static body has zero velocity. Static bodies do not collide with other static or kinematic bodies.
        #dynamic - A dynamic body is fully simulated. They can be moved manually by the user, but normally they move according to forces. A dynamic body can collide with all body types. A dynamic body always has finite, non-zero mass. If you try to set the mass of a dynamic body to zero, it will automatically acquire a mass of one kilogram.
        #kinematic - A kinematic body moves under simulation according to its velocity. Kinematic bodies do not respond to forces. They can be moved manually by the user, but normally a kinematic body is moved by setting its velocity. A kinematic body behaves as if it has infinite mass, however, Box2D stores zero for the mass and the inverse mass. Kinematic bodies do not collide with other static or kinematic bodies
    @param density {Float} Density of the sprite.
    @param friction {Float}  Friction of the sprite, affects the body adhesion.
    @param bounce {Float} The bounce value is usually set to be between 0 and 1. Consider dropping a ball on a table. A value of zero means the ball won't bounce. This is called an inelastic collision. A value of one means the ball's velocity will be exactly reflected. This is called a perfectly elastic collision.
    If collide two bodies with different bounce the box2d uses larger value to simulate the bounce.
    @param width/array {Integer/Array} Width of polygon body in pixels or array of vectors. If the value is integer typical rectangle body is created. If it is an array a polygon body is created and last parameter is ignored. The array should contains objects with two values: x and y -> distance from center in pixels (positive values are located up and right). Points in array should by in CCW order. Minimum number of vertex are 3 maximum (ussally) 8.
    @param height {Integer} Height of polygon body in pixels. The sprite height should be same as a height of image, otherwise the image will be drawen outside (or innear) real body shape. The image is not limited by sprite width or height.
    @return PhysicsSprite
    @example
        // create rectangle body
        var ramp = Bitmap.fromFile("app://ramp.png");
        var body = this.addPolygonBody(ramp, #static, 1.0, 1.0, 0.0, ramp.width, ramp.height);
        body.setPosition(System.width / 2, System.height);
        // create triangle body
        var shape = new Array(
            // top - left
            {x : width /-2, y : height / 2},
            // bottom - left
            {x : width /-2, y : height / -2},
            // bottom - right
            {x : width /2, y : height / -2}
        )
        // create triangle body
        var body = this._world.addPolygonBody(imgBox, #dynamic, 0.9 , 0.0, 0.0, shape);
    */
    function addPolygonBody(image, bodyTypeSym, density, friction, bounce, width, height = -1)
    {
        assert this._world != null;
        assert image instanceof Bitmap || image == null;
        assert bodyTypeSym == #static || bodyTypeSym == #dynamic || bodyTypeSym == #kinematic;
        // if width and height is integer -> create rectangle body
        var shape = 0;
        var vertex = 0;
        var pxWidth;
        var pxHeight;
        if (height != -1) {
            shape = b2PolygonShape.fromRect((width/2)/this._world.scale, (height/2)/this._world.scale);
            pxWidth = width;
            pxHeight = height;
        } else {
            vertex = width;
            // if width is an array -> create polygon body
            if (vertex instanceof Array) {
                var top = #undefined;
                var left = #undefined;
                var bottom = #undefined;
                var right = #undefined;
                // convert all coordinates
                if (vertex.length > 8)
                    logI("[PhysicsScene.addPolygonBody] Maximum vertex count is usally 8!");
                for (var i = 0; i<width.length; i++) {
                    if (vertex[i].x < left || left === #undefined)
                        left = vertex[i].x;
                    if (vertex[i].x > right || right === #undefined)
                        right = vertex[i].x;
                    if (vertex[i].y < top || top === #undefined)
                        top = vertex[i].y;
                    if (vertex[i].y > bottom || bottom === #undefined)
                        bottom = vertex[i].y;
                    vertex[i].x = vertex[i].x/this.scale;
                    vertex[i].y = vertex[i].y/this.scale;
                }

                pxWidth = Math.abs(right - left);
                pxHeight = Math.abs(top - bottom);
                shape = b2PolygonShape.fromPoly(vertex);
            }
        }
        var body = PhysicsSprite.create(this, image, shape, bodyTypeSym, density, friction, bounce);
        body.fixedRotation = false;
        body.width = pxWidth;
        body.height = pxHeight;
        return body;
    }

    /**
    Add circle physics sprite.
    @method addCircleBody
    @param image {Bitmap}
    @param bodyTypeSym {Symbol}
        #static - A static body has does not move under simulation and behaves as if it has infinite mass. Internally, Box2D stores zero for the mass and the inverse mass. Static bodies can be moved manually by the user. A static body has zero velocity. Static bodies do not collide with other static or kinematic bodies.
        #dynamic - A dynamic body is fully simulated. They can be moved manually by the user, but normally they move according to forces. A dynamic body can collide with all body types. A dynamic body always has finite, non-zero mass. If you try to set the mass of a dynamic body to zero, it will automatically acquire a mass of one kilogram.
        #kinematic - A kinematic body moves under simulation according to its velocity. Kinematic bodies do not respond to forces. They can be moved manually by the user, but normally a kinematic body is moved by setting its velocity. A kinematic body behaves as if it has infinite mass, however, Box2D stores zero for the mass and the inverse mass. Kinematic bodies do not collide with other static or kinematic bodies
    @param density {Float} Density of the sprite.
    @param friction {Float}  Friction of the sprite, affects the body adhesion.
    @param bounce {Float} The bounce value is usually set to be between 0 and 1. Consider dropping a ball on a table. A value of zero means the ball won't bounce. This is called an inelastic collision. A value of one means the ball's velocity will be exactly reflected. This is called a perfectly elastic collision.
    If collide two bodies with different bounce the box2d uses larger value to simulate the bounce.
    @param radius {Float} Radius of circle body. The radius should be same as a radious of an image, because the image drawen in the body is not limited by the sprites's shape.
    @return PhysicsSprite
    @example
        var puck = this.addCircleBody(res.images.puck, #dynamic, density, friction, bounce,  res.images.puck.width / 2);
        // place puck to center of the table
        puck.setPosition(System.width / 2, System.height / 2);
    */
    function addCircleBody(image, bodyTypeSym, density, friction, bounce, radius)
    {
        assert this._world != null;
        assert image instanceof Bitmap || image == null;
        assert bodyTypeSym == #static || bodyTypeSym == #dynamic || bodyTypeSym == #kinematic;
        var shape = new b2CircleShape( radius / this._world.scale);
        var body = PhysicsSprite.create(this, image, shape, bodyTypeSym, density, friction, bounce);
        body.fixedRotation = false;
        body.radius = radius;
       // this.add(body);
        return body;
    }

    /**
    Destroy body and remove it from bodies array.
    CAUTION: bodies should not be removed in the call back functions (onBeginContact or onEndContact). The better way is push all sprites to remove to an array and then remove it in onProcess event.
    @method destroyBody
    @param body {PhysicsBody}
    @example
        function process()
        {
            // remove sprites from the scene
            for (var i in this._bodiesToDestory)
                this.destroyBody(i);
        }
    */
    function destroyBody(body)
    {
        assert this._world != null;
        assert body != null && body instanceof PhysicsSprite;
        this._world.destroyBody(body.native);
        this._childs.removeByValue(body);
    }

    /**
    A mouse joint is used to make a point on a body track a specified world point. It is usually used to track user finger on the screen.
    @method createMouseJoint
    @param PhysicsBody First body in joint, also called as a ground body. This body is is not important it can be also body with zero width and height placed anywhere in the scene.
    @param PhysicsBody Body, which chould track a pointer
    @param Array jointDef
        Other joints properties:
            maxForce - The maximum constraint force that can be exerted to move the candidate body.
                   Usually you will express as some multiple of the weight (multiplier * mass * gravity).
            frequencyHz - The response speed.
            dampingRatio - The damping ratio. 0 = no damping, 1 = critical damping.
            targetX - X coordinate of initial world target point. This is assumed to coincide with the body anchor initially.
            targetY - Y coordinate of initial world target point. This is assumed to coincide with the body anchor initially.
    @param Boolean collideConnected
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return {b2MouseJoint}
    @example
        // mouse joint definition
        var mouseJointDef = {
            maxForce : 10000,
            frequencyHz : 1000,
            dampingRatio : 0.0,
            targetX : table.x2box2d(x), // specified in box2d coords
            targetY : table.y2box2d(y)  // specified in box2d coords
        };
        this.joint = table.createMouseJoint(table.ground, this.paddle, mouseJointDef, true);
    */
    function createMouseJoint(bodyA, bodyB, jointDef, collideConnected)
    {
        return this._world.createMouseJoint(bodyA.native, bodyB.native, jointDef, collideConnected);
    }

    /**
    The revolute joint can be thought of as a hinge, a pin, or an axle.
        Revolute joints can be given limits so that the bodies can rotate only to a certain point.
    @method createRevoluteJoint
    @param bodyA {PhysicsSprite} first body in the joint
    @param bodyB {PhysicsSprite} second body in the joint
    @param x {Float}
        X position of anchor point. Anchor point is point around which bodies are rotated.
    @param y {Float}
        Y position of anchor point. Anchor point is point around which bodies are rotated.
    @param jointDef {Object]
        Other joints properties (A joint limit forces the joint angle to remain between a lower and upper bound.
        The limit range should include zero, otherwise the joint will lurch when the simulation begins. Angle is positive when rotates CCW.)
            lowerAngle - The lower angle for the joint limit (radians).
            upperAngle - The upper angle for the joint limit (radians).
            enableLimit - True/false to enable joint limits.
            maxMotorTorque - The maximum motor torque used to achieve the desired motor speed. Usually in N-m.
            motorSpeed - The desired motor speed  in radians per second.
            enableMotor- True / false to enable the joint motor
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2RevoluteJoint
    @example
        // joint's options
        var jointSet = {
            enableMotor : true,             // enable motor
            motorSpeed  : (- 2 * Math.PI / 3) * (800.0 / System.width), // final speed is linearly depends on radius (screen resolution)
            maxMotorTorque : 2100000000,    // maximum torque
        
        }
        // create joint
        var joint = this.createRevoluteJoint(obj.bodyA, obj.bodyB, x, y, jointSet, true);
    */
    function createRevoluteJoint(bodyA, bodyB, x, y, jointDef, collideConnected)
    {
        var b2X = x / this._world.scale;
        var b2Y = (System.height - y) / this._world.scale;
        return this._world.createRevoluteJoint(bodyA.native, bodyB.native, b2X, b2Y, jointDef, collideConnected);
    }

    /**
    Create distance joint between two objects.
    Distance joints says that the distance between two points on two bodies must be constant.
    @method createDistanceJoint
    @param bodyA {PhysicsBody} first connected body
    @param bodyB {PhysicsBody} second connected body
    @param anchorAx {Float}
         X position of anchor point on the first body. Anchor point is point on the body, which is conected with the second body.
    @param anchorAy {Float}
        Y position of anchor point on the first body. Anchor point is point on the body, which is conected with the second body.
    @param Float anchorBx
        X position of anchor point on the second body. Anchor point is point on the body, which is conected with the first body.
    @param anchorBy {Float}
         Y position of anchor point on the second body. Anchor point is point on the body, which is conected with the first body.
    @param jointDef {Object}
         Other joints properties:
            distanceLength - Default length between bodies (between anchor points).
            frequencyHz - The mass-spring-damper frequency in Hertz. A value of 0 disables softness.
            dampingRatio - The damping ratio from 0 to 1.
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2DistanceJoint
    @example
        // create the distance joint
        var jointDef = {
            frequencyHz     : 100,
            dampingRatio    : 0.0,
           // distanceLength  : use default distance (distance which was between the bodies when they were created
        }
        this._distanceJoint = this.createDistanceJoint(this._rect1, this._rect2, System.width / 2,System.height / 2,System.width / 2,3*System.height / 4, jointDef, false)
    */
    function createDistanceJoint( bodyA, bodyB, anchorAx, anchorAy, anchorBx, anchorBy, jointDef, collideConnected)
    {
        var b2anchorAx = anchorAx/this._world.scale;
        var b2anchorAy = (System.height - anchorAy)/this._world.scale;
        var b2anchorBx = anchorBx/this._world.scale;
        var b2anchorBy = (System.height - anchorBy)/this._world.scale;
        return this._world.createDistanceJoint(bodyA.native, bodyB.native, b2anchorAx, b2anchorAy, b2anchorBx, b2anchorBy, jointDef, collideConnected);
    }

    /**
    The friction joint is used for top-down friction.
    The joint provides 2D translational friction and angular friction.
    @method  createFrictionJoint
    @param bodyA {PhysicsBody} first connected body
    @param bpdyB {PhysicsBody} second connected body
    @param x {Float}
         X position of anchor point.
    @param y {Float}
         Y position of anchor point.
    @param jointDef {Object}
         Other joints properties:
            maxForce  - The maximum friction force in N.
            maxTorque - The maximum friction torque in N-m.
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2FrictionJoint
    */
    function createFrictionJoint(bodyA, bodyB, x, y, jointDef, collideConnected)
    {
        var b2x = x/this._world.scale;
        var b2y = (System.height - y)/this._world.scale;
        return this._world.createFrictionJoint(bodyA.native, bodyB.native, b2x, b2y, jointDef, collideConnected );
    }

    /**
    If you want to create a sophisticated mechanical contraption you might want to use gears.
    Gear joint connects two other types of joints and move them with set ratio.
    @method createGearJoint
    @param bodyA {PhysicsBody} first connected body
    @param bodyB {PhysicsBody} second connected body
    @param joint1 {b2Joint} First connected joint
    @param joint2 {b2Joint} Second connected joint
    @param ratio {Float] Ratio between the joints motion. Ratio 1.0 means that both joint move same distance (speed).
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2GearJoint
    @example
        // create the prismatic joint
        // set limits
        var jointDef = {
            ...
        }
        var prismaticJoint = this.createPrismaticJoint(this._leftWall, this._rect2, System.width / 2, System.height / 5, 0.0, 1.0, 0.0, jointDef, true)
        
        // create the revolute joint
        jointDef = {
           ...
        }
        // create joint
        var revoluteJoint = this.createRevoluteJoint(this._ground, this._rect1, System.width / 2, System.height / 5, jointDef, true);
    
        // connect bodies with gear joint
        this._gearJoint = this.createGearJoint(this._rect1, this._rect2, prismaticJoint, revoluteJoint, 0.8, true);
    */
    function createGearJoint(bodyA, bodyB, joint1, joint2, ratio, collideConnected)
    {
        assert joint1 != null && joint2 != null;
        return this._world.createGearJoint(bodyA.native, bodyB.native, joint1, joint2, ratio, collideConnected);
    }

    /**
    A prismatic joint allows for relative translation of two bodies along a specified axis.
    @method createPrismaticJoint
    @param bodyA {PhysicsBody} first connected body
    @param bodyB {PhysicsBody} second connected body
    @param anchorX {Float}
        X position of anchor point. Anchor point is point on the body, which is conected with the second body.
    @param anchorY {Float}
        Y position of anchor point. Anchor point is point on the body, which is conected with the second body.
    @param axisX {Float}
        X coordinate of axis
    @param axisY {Float}
        Y coordinate of axis
    @param referenceAngle {Float} reference Angle
    @param jointDef {Object}
        Other joints properties:
            lowerTranslation - The lower translation limit, usually in meters.
            upperTranslation - The upper translation limit, usually in meters.
            enableLimit - Enable/disable the joint limit.
            maxMotorForce - The maximum motor torque, usually in N-m.
            motorSpeed - The desired motor speed in radians per second.
            enableMotor - Enable/disable the joint motor.
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2PrismaticJoint
    @example
        // create the prismatic joint
        // set joint
        var jointDef = {
            lowerTranslation    : -3.0, // meters
            upperTranslation    : 5.0,  // meters
            enableLimit         : true,
            enableMotor         : true,
            motorSpeed          : 1.0,
            maxMotorForce       : 100.0,
        }
        this._prismaticJoint = this.createPrismaticJoint(this._ground, this._rect1, System.width / 2, System.height / 2, 0.0, 1.0, 0.0, jointDef, true)
    */
    function createPrismaticJoint(bodyA, bodyB, anchorX, anchorY , axisX, axisY, referenceAngle, jointDef, collideConnected)
    {
        var b2anchorX = anchorX/this._world.scale;
        var b2anchorY = (System.height - anchorY)/this._world.scale;
        var b2axisX = axisX;
        var b2axisY = axisY;
        return this._world.createPrismaticJoint(bodyA.native, bodyB.native, b2anchorX, b2anchorY , b2axisX, b2axisY, referenceAngle, jointDef, collideConnected);
    }

    /**

    This joint provides two degrees of freedom: translation along an axis fixed in body1 and rotation in the plane.
    @method createLineJoint
    @param bodyA {PhysicsBody} first connected body
    @param bodyB {PhysicsBody} second connected body
    @param anchorX {Float}
        X position of anchor point. Anchor point is point on the body, which is conected with the second body.
    @param anchorY {Float}
        Y position of anchor point. Anchor point is point on the body, which is conected with the second body.
    @param axisX {Float}
        X coordinate of axis
    @param axisY {Float}
        Y coordinate of axis
    @param referenceAngle {Float} reference Angle
    @param jointDef {Object}
        Other joints properties:
            lowerTranslation - The lower translation limit, usually in meters.
            upperTranslation - The upper translation limit, usually in meters.
            enableLimit - Enable/disable the joint limit.
            maxMotorForce - The maximum motor torque, usually in N-m.
            motorSpeed - The desired motor speed in radians per second.
            enableMotor - Enable/disable the joint motor.
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2LineJoint
    */
    function createLineJoint(bodyA, bodyB, anchorX, anchorY , axisX, axisY, jointDef , collideConnected)
    {
        var b2anchorX = anchorX/this._world.scale;
        var b2anchorY = (System.height - anchorY)/this._world.scale;
        var b2axisX = axisX/this._world.scale;
        var b2axisY = (System.height - axisY)/this._world.scale;
        return this._world.createLineJoint(bodyA.native, bodyB.native, b2anchorX, b2anchorY , b2axisX, b2axisY, jointDef, collideConnected );
    }

    /**
    The pulley joint is connection of two bodies and two fixed ground points. It looks like the body are connected with a rope, which comes throw the specified fixed ground points.
    @method createPulleyJoint
    @param bodyA {PhysicsBody} first connected body
    @param bodyB {PhysicsBody} second connected body
    @param groundAnchorAX {Float}
        X coordinatesof of the first ground anchor.
    @param groundAnchorAY {Float}
        Y coordinatesof of the first ground anchor.
    @param groundAnchorBX {Float}
        X coordinatesof of the second ground anchor.
    @param groundAnchorBY {Float}
        Y coordinatesof of the second ground anchor.
    @param anchorAX {Float}
        X world coordinate of the anchor point on bodyA.
    @param anchorAY {Float}
        Y world coordinate of the anchor point on bodyA.
    @param anchorBX {Float}
        X world coordinate of the anchor point on bodyB.
    @param anchorBY {Float}
        Y world coordinate of the anchor point on bodyB.
    @param ratio {Float}
        The pulley ratio.
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2PulleyJoint
    @example
        // create the pulley joint
        this._pulleyJoint = this.createPulleyJoint(this._rect1, this._rect2, System.width / 4, System.height / 8, 3 * System.width / 4, System.height / 8, System.width / 4, System.height / 2, 3 * System.width / 4, System.height / 2, 1.0 , true)
    */
    function createPulleyJoint( bodyA, bodyB, groundAnchorAX, groundAnchorAY, groundAnchorBX, groundAnchorBY, anchorAX, anchorAY, anchorBX, anchorBY, ratio , collideConnected ){
        var b2anchorAX = anchorAX/this._world.scale;
        var b2anchorAY = (System.height - anchorAY)/this._world.scale;
        var b2anchorBX = anchorBX/this._world.scale;
        var b2anchorBY = (System.height - anchorBY)/this._world.scale;
        
        var b2groundAnchorAX = groundAnchorAX/this._world.scale;
        var b2groundAnchorAY = (System.height - groundAnchorAY)/this._world.scale;
        var b2groundAnchorBX = groundAnchorBX/this._world.scale;
        var b2groundAnchorBY = (System.height - groundAnchorBY)/this._world.scale;
        return this._world.createPulleyJoint(bodyA.native, bodyB.native, b2groundAnchorAX, b2groundAnchorAY, b2groundAnchorBX, b2groundAnchorBY, b2anchorAX, b2anchorAY, b2anchorBX, b2anchorBY, ratio, collideConnected );
    }

    /**
    A weld joint essentially glues two bodies together.
    It may distort somewhat because the island constraint solver is approximate.
    @method createWeldJoint
    @param bodyA {PhysicsBody} first connected body
    @param bodyB {PhysicsBody} second connected body
    @param anchorX {Float}
        X position of anchor point.
    @param anchorY {Float}
        Y position of anchor point.
    @param collideConnected {Boolean}
        If this param is true colisions between connected bodies are allowed, otherwise their are denied.
        By default is set to false.

    @return b2WeldJoint
    @example
        // create the weld joint
        this._weldJoint = this.createWeldJoint(this._rect1, this._rect2, System.width / 2,System.height / 2, true)
    */
    function createWeldJoint( bodyA, bodyB, anchorX, anchorY, collideConnected ){
        var b2anchorX = anchorX/this._world.scale;
        var b2anchorY = (System.height - anchorY)/this._world.scale;
        return this._world.createWeldJoint(bodyA.native, bodyB.native, b2anchorX, b2anchorY, collideConnected );
    }

    /**
    Destroy existing joint.
    CAUTION: Joints should not be removed in the call back functions (like onBeginContact or onEndContact). The better way is push all joints to remove to an array and then remove it in onProcess event.
    @method destroyJoint
    @param joint {b2Joint} Joint to destroy
    @example
        function process()
        {
            // remove joints from the scene
            for (var i in this._jointsToDestory)
                this.destroyJoint(i);
        }
    */
    function destroyJoint(joint)
    {
        assert this._world != null;
        assert joint != null;
        this._world.destroyJoint(joint);
    }

    /**
    Draw physics scene. This function draws all sprites included in the scene. The function is called automatically as a reaction onto onDraw event. To customize scene appearance can be this function extended, but it can is neede to call also parent's draw method to ensure correct drawing of all objects in the scene.
    @method draw
    @param canvas {Canvas} Current scene canvas
    @example
        function draw(canvas)
        {
            // draw background
            canvas.drawRect(0, 0, System.width, System.height, this._bg);
            // draw all other elements in the scene
            super.draw(canvas);
        }
    */
    function draw(canvas)
    {
        assert this._world != null;
        //this._world.doDraw(canvas);
        super.draw(canvas);
        if (this.debugDraw)
            this._world.doDebugDraw(canvas);
    }

    /**
    Draw physics scene, in debug mode
    @method doDebugDraw
    @param Canvas canvas
    */
    function doDebugDraw(canvas){
        assert this._world != null;
        this._world.doDebugDraw(canvas);
        super.draw(canvas);
    }

    /**
    beginContact function is called as a reaction on the onBeginContact event. This event is called when two bodies collide.
    @method beginContact
    @protected
    @param PhysicsContact List of all contacts which appeared in last time step.
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
                // get the next contact (they can be more contacts during the one step)
                current = current.getNext();
            }
        }
    */
    function beginContact(contact)
    {
    }

    /**
    endContact function is called as a reaction on the onEndContact event. This event is called when contact ends.
    @method endContact
    @protected
    @param PhysicsContact List of all contacts which appeared in last time step.
    @example
        function endContact(contact)
        {
            // get the first contact
            var current = contact;
            while (current) {
                // get the bodies in the contact
                var bodyA = current.getBodyA();
                var bodyB = current.getBodyB();
                ...
                // get the next contact (they can be more contacts during the one step)
                current = current.getNext();
            }
        }
    */
    function endContact(contact)
    {
    }

    /**
    Event to be called, when two bodies collide.
    @event onBeginContact
    @example
        this.onBeginContact = function(contact)
        {
            // get the first contact
            var current = contact;
            while (current) {
                // get the bodies in the contact
                var bodyA = current.getBodyA();
                var bodyB = current.getBodyB();
                ...
                // get the next contact (they can be more contacts during the one step)
                current = current.getNext();
            }
        }
    */
    property onBeginContact(v)
    {
        get return this.beginContact;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[PhysicsScene.onBeginContact] Expects type of function");
             this.beginContact = v;
        }
    }

    /**
    Event to be called, when contact ends.
    @event onEndContact
    @example
        this.onEndContact = function(contact)
        {
            // get the first contact
            var current = contact;
            while (current) {
                // get the bodies in the contact
                var bodyA = current.getBodyA();
                var bodyB = current.getBodyB();
                ...
                // get the next contact (they can be more contacts during the one step)
                current = current.getNext();
            }
        }
    */
    property onEndContact(v)
    {
        get return this.endContact;
        set {
             if (!(typeof v == #function || v == null))
                throw new InvalidArgument("[PhysicsScene.onEndContact] Expects type of function");
             this.endContact = v;
        }
    }

    /**
    Allow do draw box2d debug data, like real bodies borders.
    @property debugDraw
    @type Boolean
    */
    property debugDraw(v)
    {
        get return this._debugDraw;
        set this._debugDraw = v;
    }

}