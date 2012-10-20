include "lib://game2d/base/gameObject.ms"
include "lib://graphics/colorPaint.ms"

/**
TiledLayer is used to render background and other visual components. It divides scene into regular grid, which is fill by small images. It allows simple and fast creation of scene, because exists many external tools to create and edit such scenes. This type of background is often used in mobile RPG games.
@class TiledLayer
@module game2d
@example
    // create tiled layer
    var tiled = new TiledLayer({
        columns     : columns,
        rows        : rows,
        image       : "app://tmw_desert_spacing.png",
        tileWidth   : tileWidth,
        tileHeight  : tileHeight,
    });
    // fill cells
    var cells = data["layers"][0]["data"];
    for (var i = 0; i < cells.length; i++) {
        tiled.setCellDirect(i, cells[i] - 1);
    }
*/
class TiledLayer : GameControl
{

    /**
    Init funtion of object instance. This method should be used as a class constructor.
    @protected
    @method init
    @example
        class MyLayer : TiledLayer
        {
            function init()
            {
                super.init();
    
                ...
            }
        }
    */
    function init() // columns, rows, image, tileWidth, tileHeight
    {
        super.init();

        this.initialized = false;

        this._columns = #undefined;
        this._rows = #undefined;
        this._margin = #undefined;
        this._tileHeight = #undefined;
        this._tileWidth = #undefined;
        this._viewH = #undefined;
        this._viewW = #undefined;
        this._viewX = #undefined;
        this._viewY = #undefined;
        this._image = #undefined;
        this._x = #undefined;
        this._y = #undefined;

        this.visible = true;

        this._map = [];
        this._animatedTiles = [];

        this._onProcessHandler = null;
    }

    /**
    After init method fills layer by tiles.
    @method afterInit
    @protected
    */
    function afterInit()
    {
        super.afterInit();

        // needed parameters
        if (this._columns == #undefined)
            throw logW("[TiledLayer] It is needed to set number of columns in the layer!");

        if (this._rows == #undefined)
            throw logW("[TiledLayer] It is needed to set number of rows in the layer!");

        if (this._image == #undefined)
            throw logW("[TiledLayer] It is needed to set image with at least one tile!");

        // optional parameters
        if (this._margin == #undefined)
            this._margin = 0;

        if (this._tileHeight == #undefined)
            this._tileHeight = this._image.height;
        else if (this._tileHeight > this._image.height)
            throw logW("[TiledLayer] Tile tileHeight can not be larger then image height!");

        if (this._tileWidth == #undefined)
            this._tileWidth = this._image.width;
        else if (this._tileWidth > this._image.width)
            throw logW("[TiledLayer] Tile tileWidth can not be larger then image width!");

        this._width = this._columns * this._tileWidth;
        this._height = this._rows * this._tileHeight;

        if (this._viewH == #undefined)
            this._viewH = Integer.min(this._height, System.height);

        if (this._viewW == #undefined)
            this._viewW = Integer.min(this._width, System.width);

        if (this._viewX == #undefined)
        this._viewX = 0;
        
        if (this._viewY == #undefined)
        this._viewY = 0;

        if (this._x == #undefined)
            this._x = this._viewW / 2;

         if (this._y == #undefined)
            this._y = this._viewH / 2;

        this.initialized = true;
        this._precalc();
        if (this._map.length == 0)
            this.setStaticTileSet(this._image, this._tileWidth, this._tileHeight);
    }

    /**
    Width of one tile in pixels. The tile dimensions are same on the screen and in source image file.
    @property tileWidth
    @type Integer
    @example
        // create tiled layer
        var tiled = new TiledLayer({
            tileWidth   : 45,
            tileHeight  : 45,
        });
    */
    property tileWidth(v)
    {
        get return this._tileWidth;
        set {
            this._tileWidth = v;
            if (!this.initialized)
                return;
            this._width = this._columns * this._tileWidth;
            this._precalc();
        }
    }

    /**
    Height of one tile in pixels. The tile dimensions are same on the screen and in source image file.
    @property tileHeight
    @type Integer
    @example
        // create tiled layer
        var tiled = new TiledLayer({
            tileWidth   : 45,
            tileHeight  : 45,
        });
    */
    property tileHeight(v)
    {
        get return this._tileHeight;
        set {
            this._tileHeight = v;
            if (!this.initialized)
                return;
            this._height = this._rows * this._tileHeight;
            this._precalc();
        }
    }

    /**
    Number of columns in the layer.
    @property columns
    @type Integer
    */
    property columns(v) {
        get return this._columns;
        set {
            this._columns = v;
            if (!this.initialized)
                return;
            this._width = this._columns * this._tileWidth;
            this._precalc();
        }
    }

    /**
    Number of rows in the layer.
    @property rows
    @type Integer
    */
    property rows(v) {
        get return this._rows;
        set {
            this._rows = v;
            if (!this.initialized)
                return;
            this._height = this._rows * this._tileHeight;
            this._precalc();
        }
    }

    /**
    Width of the layer. The width is calculated automatically as (number of columns) * (tile width)
    @property width
    @readOnly
    @type Integer
    */
    property width(v) {
        get return this._width;
    }


    /**
    Height of the layer. The height is calculated automatically as (number of rows) * (tile height)
    @property height
    @readOnly
    @type Integer
    */
    property height(v) {
        get return this._height;
    }

    /**
    Gap around the tiles in pixels.
    @property margin
    @type Integer
    */
    property margin(v) {
        get return this._margin;
        set this._margin = v;
    }
    // TODO: spacing - Spacing is how many pixels should advance (for both width and height) after it reads the actual tile pixels to get to the next tile data.

    /**
    Tile layer is usally larger then device screen. The viewX property specifies horizontal position of the displayed part of the layer.
    @property viewX
    @type Integer
    @example
        // set tiled view
        self._tiled.viewX = x - System.width/2;
        self._tiled.viewY = y - System.height/2;
    */
    property viewX(v)
    {
        get return this._viewX;
        set {
            this._viewX = v;
            if (!this.initialized)
                return;
            this._precalc();
        }
    }

    /**
    Tile layer is usally larger then device screen. The viewY property specifies the vertical position of the displayed part of the layer.
    @property viewY
    @type Integer
    @example
        // set tiled view
        self._tiled.viewX = x - System.width/2;
        self._tiled.viewY = y - System.height/2;
    */
    property viewY(v)
    {
        get  return this._viewY;
        set {
            this._viewY = v;
            if (!this.initialized)
                return;
            this._precalc();
        }
    }

    /**
    Tile layer is usally larger then device screen. The viewW property specifies the width of the displayed part of the layer.
        By default it is width of the device's screen.
    @property viewW
    @type Integer
    */
    property viewW(v)
    {
        get  return this._viewW;
        set {
            this._viewW = v;
            if (!this.initialized)
                return;
            this._precalc();
        }
    }

    /**
    Tile layer is usally larger then device screen. The viewH property specifies the height of the displayed part of the layer.
        By default it is height of the device's screen.
    @property viewH
    @type Integer
    */
    property viewH(v)
    {
        get return this._viewH;
        set {
            this._viewH = v;

            if (!this.initialized)
                return;
            this._precalc();
        }
    }

    /**
    Image with all tiles used in the layer.
    @property image
    @type Bitmap|String
    */
    property image(v)
    {
        get return this._image;
        set {
            /*if (v == null) {
                this._width = 0;
                this._height = 0;
                this._image = 0;
                return;
            }*/
            assert v instanceof Bitmap || typeof v ==  #string;
            if (typeof v == #string)
                v = Bitmap.fromFile(v);
            this._image = v;
        }
    }

    /**
    Process executes on process handler.
    @method process
    @protected
    */
   /* function process()
    {
        //calculate current row and current column
        this._precalc();
    }*/

    /**
    Event on process handler. It defines what suppose to be done on game process.
    @event onProcess
    */
    property onProcess(v) {
        get return this.process;
        set {
            assert typeof v == #function;
            this.process = v;
        }
    }

    /**
    Set static tile. This method is called automatically from afterInit method.
    @method setStaticTileSet
    @param image {Bitmap} image
    @param tileWidth {Integer} width of one tile
    @param tileHeight {Integer} height of one tile
    @chainable
    */
    function setStaticTileSet(image, tileWidth, tileHeight)
    {
        if (typeof image == #string)
            image = Bitmap.fromFile(image);
        assert image instanceof Bitmap;

        this._image = image;
        this._tileWidth = tileWidth;
        this._tileHeight = tileWidth;

        this._width = this._columns * this._tileWidth;
        this._height = this._rows * this._tileHeight;

        this._precalc();

        this.fillCells(0, 0, this._columns, this._rows, 0);

        return this;
    }

    /**
    Fill cells with a tile image.
    @method fillCells
    @chainable
    @param col {Integer} Fill from column
    @param row {Integer} fill from row
    @param numCols {Integer} number of collumns
    @param numRows {Integer} number of rows
    @param index {Integer} index of tile image used for cells
    @example
        // fill 100 tiles with second tile image
        tiled.fillCells(0, 0, 10, 10, 1);
    */
    function fillCells(col, row, numCols, numRows, index)
    {
        assert col > -1 && col < this._columns;
        assert col + numCols <= this._columns;
        assert row > -1 && row < this._rows;
        assert row + numRows <= this._rows;

        for(var c = col; c < col + numCols; c++)
            for(var r = row; r < row + numRows; r++)
                this._map[r * this._columns + c] = index;
        return this;
    }

    /**
    Fill one cell with image.
    @method setCell
    @chainable
    @param col {Integer} column in which the cell is situated
    @param row {Integer} row in which the cell is situated
    @param index {Integer} index of tile used for cell
    */
    function setCell(col, row, index)
    {
        this._map[row * this._columns + col] = index;
        return this;
    }

    /**
    Fill one cell with image.
    @method setCellDirect
    @chainable
    @param cell {Integer} cell index
    @param index {Integer} image index
    @example
        for (var i = 0; i < cells.length; i++) {
            tiled.setCellDirect(i, cells[i] - 1);
        }
    */
    function setCellDirect(cell, index)
    {
        this._map[cell] = index;
        return this;
    }

    /**
    Get cell index
    @method getCell
    @param col {Integer} column in which the cell is situated
    @param row {Integer} row in which the cell is situated
    @return {Integer} index
    */
    function getCell(col, row)
    {
        return this._map[row * this._columns + col];
    }

    /**
    Mark tile as a animated tile.
    @method createAnimatedTile
    @param staticTileIndex {Integer} tile index
    @return {Integer} number of animated tiles
    */
    function createAnimatedTile(staticTileIndex)
    {
        if (this._animatedTiles.length == 0)
            this._animatedTiles.push(0);
        this._animatedTiles.push(staticTileIndex);
        return -this._animatedTiles.length+1;
    }

    /**
    Get animated tike
    @method getAnimatedTile
    @param animatedTileIndex {Integer} tile index
    @return {Integer}
    */
    function getAnimatedTile(animatedTileIndex)
    {
        animatedTileIndex *= -1;
        assert animatedTileIndex >= 0;
        assert animatedTileIndex < this._animatedTiles.length;
        return this._animatedTiles[animatedTileIndex];
    }

    /**
    Set animated tile
    @method setAnimatedTile
    @param animatedTileIndex {Integer}
    @param staticTileIndex {Integer}
    */
    function setAnimatedTile(animatedTileIndex, staticTileIndex)
    {
        animatedTileIndex *= -1;
        assert animatedTileIndex >= 0 : String.printf("Invalid animated index %d", animatedTileIndex);
        assert animatedTileIndex <= this._animatedTiles.length;
        this._animatedTiles[animatedTileIndex] = staticTileIndex;
    }

    /**
    Draw method draws all tiles on theirs right positions.
    @method draw
    @protected
    @param canvas {Canvas} Canvas used to draw graphics
    */
    function draw(canvas)
    {
        assert canvas instanceof Canvas;
        assert this._image instanceof Bitmap;

        var slices = this._image.width / this._tileWidth;
        var index, animatedIndex, r, c;

        canvas.save();

        canvas.clipRect(this._x - this._viewW / 2, this._y - this._viewH / 2, this._x + this._viewW / 2, this._y + this._viewH / 2, #intersect );
        canvas.translate(this._x - this._viewW / 2, this._y - this._viewH / 2);
        canvas.translate(-this._viewX, -this._viewY);
        for (r = this._firstRow; r <= this._lastRow; r++) {
            for (c = this._firstCol; c <= this._lastCol; c++) {
                animatedIndex = -1;
                index = r * this._columns + c;
                if (index > this._map.length - 1)
                    continue;
                index = this._map[index];
                if (index < 0) {
                    animatedIndex = -index - 1;
                    if (animatedIndex > 0)
                    index = this._animatedTiles[animatedIndex]; // else index--;
                }
                var frameX = (index % slices) * (this._tileWidth + this._margin);
                var frameY = (index / slices) * (this._tileHeight + this._margin);
                var sl = c * this._tileWidth;
                var st = r * this._tileHeight;
                 canvas.drawBitmapRect(this._image,
                    frameX + this._margin, frameY + this._margin, frameX + this._tileWidth, frameY + this._tileHeight,
                    sl, st, sl + this._tileWidth, st + this._tileHeight);
            }
        }

        canvas.restore();
    }

    /**
    Pre calculate
    @method _precalc
    @private
    */
    function _precalc()
    {
        this._firstCol = Integer.max(this._viewX, 0) / this._tileWidth;
        this._firstRow = Integer.max(this._viewY, 0) / this._tileHeight;

        this._lastCol = Integer.min(this._columns-1, this._firstCol + ((this._viewW + this._tileWidth) / this._tileWidth));

        if (this._viewX < 0)
            this._lastCol -= (-this.viewX / this._tileWidth);

        this._lastRow = Integer.min(this._rows-1, this._firstRow + ((this.viewH + this._tileHeight) / this._tileHeight));

        if (this._viewY < 0)
            this._lastRow -= (-this.viewY / this._tileHeight);
    }
}
