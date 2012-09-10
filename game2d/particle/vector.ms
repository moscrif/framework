include "lib://core/baseClass.ms"

/**
Vector contains two values x and y, which determines direction in particle systems' classes
@module game2d
@class Vector
@example
    new Emitter({
        position        : new Vector({x:System.width/2, y:System.height/2}),
        velocity        : new Vector({x:5, y:0}),
        .....
    })
*/
class Vector : BaseClass
{
    /**
    Init instance. The init method sets all needed emiter properties acording to developer requirements or to default values (default: [0, 0]).
    @method init
    @protected
    */
    function init()
    {
        super.init();
        this.x = this.options.x || 0;
        this.y = this.options.y || 0;
    }

    /**
    Get Magnitude of the vector
    @method getMagnitude
    @return Float
    */
    function getMagnitude()
    {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }

    /**
    Multyply vector coordinates by scaleFactor
    @method multiply
    @param scaleFactor {Integer} scale factor
    */
    function multiply(scaleFactor)
    {
        this.x *= scaleFactor;
        this.y *= scaleFactor;
    }

    /**
    Add vector coordinates to current vector
    @method add
    @param {vector} new vector
    */
    function add(vector)
    {
        this.x += vector.x;
        this.y += vector.y;
    }

    /**
    Create new vector based on vector passed as parameter
    @method vectorTo
    @param vector {Vector} vector
    @return Vector
    */
    function vectorTo(vector)
    {
        var self = this;
        return new Vector({x: vector.x - self.x, y: vector.y - self.y});
    }

    /**
    Calculate if point with size is in vector bounds
    @method withinBounds
    @param point {Vector} point
    @param size {Integer} size
    @return Boolean
    */
    function withinBounds(point, size)
    {
       return this.x >= point.x - size/2 && this.x <= point.x + size/2 && this.y >= point.y - size/2 && this.y <= point.y+size/2;
    }

    /**
    Return vector angle in radians
    @method getAngle
    @return Float vector angle
    */
    function getAngle()
    {
       var ratio = 0;
       var offset = 0;
       if (this.x > 0) {
          if (this.y > 0) {
             offset = 0;
             ratio = this.y / this.x;
          } else if (this.y != 0) {
             offset = (3 * Math.PI)/2;
             ratio = this.x / this.y;
          }
       } else {
          if (this.y > 0) {
             offset = Math.PI / 2;
             ratio = this.x / this.y;
          } else if (this.x != 0) {
             offset = Math.PI;
             ratio = this.y / this.x;
          }
       }
       var angle = Math.atan(Math.abs(ratio)) + offset;
       return angle;
    }

    /**
    Return vector angle degree
    @method getAngleDegrees
    @return Float
    */
    function getAngleDegrees()
    {
       return this.getAngle() * 180 / Math.PI;
    }

    /**
    Create new vector based on jitter amount
    @method jitter
    @param jitterAmount {Integer} jitterAmount
    @return Vector
    */
    function jitter(jitterAmount)
    {
        var self = this;
        return new Vector({
            x: self.x + self.x * jitterAmount * rand(),
            y: self.y + self.y * jitterAmount * rand()
        });
    }

    /**
    Create copy of the current vector
    @method copy
    @return Vector
    */
    function copy()
    {
        var self = this;
        return new Vector({x:self.x, y:self.y});
    }

    /**
    Create new vector basd on an angle and a magnitude
    @method fromAngle
    @param angle {Float} angle
    @param magnitude {Integer} magnitude
    @return Vector
    */
    function fromAngle(angle, magnitude)
    {
        return new Vector({x:magnitude*Math.cos(angle), y:magnitude*Math.sin(angle)});
    }

}
