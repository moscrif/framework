include "lib://uix/base/component.ms"


/**
@package uix
@location uix/control/image.ms

Image Control.
It defines bittmap or vector image.
*/
class Image : Component
{
    /**
    Init Image controls
    */
    function init() {

        super.init();
        this._image = null;
        this._paint = null;
        this.native.name = "Image";

        /**
        On draw Handler, it render on canvas either Bitmab or vector
        @param Image seder
        @param Canvas canvas
        */
        this._onDrawHandler = function (sender, canvas)
        {
            if (this._image == null)
                throw NullPointer("[Image._doDraw] Image does not exist.");
            else if (this._image instanceof Bitmap) {

                canvas.drawBitmap(this._image, 0, 0);
            } else if (this._image instanceof Path){
                if (this._paint == null)
                    throw new NullPointer("[Image._doDraw] Paint does not exist.");
                else
                    canvas.drawPath(this._image, this._paint);
            } else if(this._image instanceof SVG) {
                this._image.draw(canvas);
            }
        }
    }

    /**
    Source of the image.
    It allows instane of bitmap or instance of Path. If string is given, it tries to create bitmap
    from string location.

    @param String|Bitmap|Path v
    @return Image

    */
    property source(v)
    {
        get return this._image;
        set {
            if (v instanceof Bitmap || v instanceof Path)
                this._image = v;
            else if (typeof v == #string)
                if (System.isFile(v))
                {
                    if(v.indexOf(".svg") > 0)
                        this._image = SVG.fromFile(v);
                    else
                        this._image = Bitmap.fromFile(v);
                }
                else
                    throw new IOException("[Image] File does not exist.");
            else
                throw new InvalidArgument("[Image.image]");
            // move vector to 0, 0 coordinates
            if (this._image instanceof Path) {
                var (l, t, r, b) = this._image.getBounds();
                this._image.offset(-1*l, -1*t);
            }
            this._setSize();
        }
    }

    /**
    Paint property to decorate Image
    @param Paint v
    @return Paint
    */
    property paint(v)
    {
        get {
            if(this._paint == null)
                this._paint = new Paint();

            return this._paint;
        }
        set {

            if (!(v instanceof Paint))
                throw new InvalidArgument("[Image.paint]");
            else
                this._paint = v;
        }
    }

    /**
    Width of the Image (in pixels). Size of picture is
    recalculated based on the size of container(Moscrif view)
    @param Integer v
    @return Integer
    */
    property width(v)
    {
        get return this.native.width;
        set {
            this._setImageWidth(v);
            this.invalidate();
        }
    }

     /**
    Height of the Image (in pixels). Size of picture is
    recalculated based on the size of container(Moscrif view)
    @param Integer v
    @return Integer
    */
    property height(v)
    {
        get return this.native.height;
        set {
            this._setImageHeight(v);
            this.invalidate();
        }
    }

    /**
    Drawing of image to canvas
    @param Canvas canvas
    @param Integer left X Image view coordinate
    @param Integer top Y Image view coordinate
    @param Paint paint
    */
    function drawImage(canvas, left = 0, top = 0, paint = this._paint)
    {
        if (this._image == null)
             throw new NullPointer("[Image.drawImage] Image does not exist.");
        else if (this._image instanceof Bitmap)
            canvas.drawBitmap(this._image, left, top);
        else if (this._image instanceof Path)
            if (paint == null)
                throw new NullPointer("[Image.drawImage] Paint does not exist.");
            else {
                var (l, t, r, b) = this._image.getBounds();
                this._image.offset(-l+left, -t+top);
                canvas.drawPath(this._image, paint);
            }
        else if(this._image instanceof SVG)
            this._image.draw(canvas,left,top);    

    }

    /**
    change image dimensions (do not keep aspect ratio)
    */
    function resize(w, h)
    {
        // resize bitmap
        if (this._image instanceof Bitmap) {
            // resize image if it is needed
            if (w != this._image.width && h != this._image.height)
                this._image = this._image.resize(w, h);
        } else if (this._image instanceof Path) {
            // get vectors coordinates
            var (l, t, r, b) = this._image.getBounds();
            var matrix = new Matrix();
            // set scale
            matrix.setScale(1.0*w / Math.abs(r - l), 1.0*h / Math.abs(b - t));
            // apply scale to vector
            this._image.transform(matrix);
            // get new image dimensions
            (l, t, r, b) = this._image.getBounds();
            // move image
            this._image.offset(-1*l, -1*t);
        }
        this._setSize();
    }
    
    /**
    @visibility private
    Resize of the picture base on Image container
    */
    function _setSize()
    {
        if (this._image instanceof Bitmap){
            this.native.width = this._image.width;
            this.native.height = this._image.height;
        } else if (this._image instanceof Path) {
            var (lx, ly, rx, ry) = this._image.getBounds();
            this.native.width = (rx-lx).toInteger();
            this.native.height = (ry-ly).toInteger();
        }
    }

    /**
    @visibility private
    change image width (keep aspect ratio)
    */
    function _setImageWidth(v)
    {
        if (this._image instanceof Bitmap) {
            if (this._image.width != v) {
                var ratio = 1.0*this._image.height/this._image.width;
                this._image = this._image.resize(v, (v*ratio).toInteger());
            }
        } else if (this._image instanceof Path) {
            var (lx, ly, rx, ry) = this._image.getBounds();
            var matrix = new Matrix();
            var ratio = 1.0*v/(rx - lx);
            matrix.setScale(ratio, ratio);
            this._image.transform(matrix);

            (lx, ly, rx, ry) = this._image.getBounds();
            this._image.offset(-lx, -ly);
        }
        this._setSize();
    }

    /**
    @visibility private
    change image width (keep aspect ratio)
    */
    function _setImageHeight(v)
    {
        if (this._image instanceof Bitmap) {
            if (this._image.height != v) {
                var ratio = 1.0*this._image.width/this._image.height;
                this._image = this._image.resize((v*ratio).toInteger(), v);
            }
        }
        else if (this._image instanceof Path) {
            var (lx, ly, rx, ry) = this._image.getBounds();
            var matrix = new Matrix();
            var ratio = 1.0 * v /Math.abs(rx - lx);
            matrix.setScale(ratio, ratio);
            this._image.transform(matrix);
            (lx, ly, rx, ry) = this._image.getBounds();
            this._image.offset(-lx, -ly);
        }
        this._setSize();
    }


}