/**
@package uix
@lacation uix/paging/paginator.ms

Class to define current form page, keeps information about number of pages per displaing list,
calculate current offest. Define displaying spliter by default is set "..".
*/
class Paginator
{
    //constants
    const DEFAULT_PAGE = 1;
    const DEFAULT_PAGESIZE = 20;
    const DEFAULT_SPLITER = "..";

    /**
    Constructor
    @param String name
    */
    function this(name)
    {
        this._name = name;
        this._page = DEFAULT_PAGE;
        this._pageSize = DEFAULT_PAGESIZE;
        this._offset = DEFAULT_PAGESIZE;

        this._length = 0;
        this._partialData = true;
        this._pages = new Array(); //visited pages

    }

    /**
    Name of the paginator
    @param String name
    @return String
    */
    property name(v)
    {
        get return this._name;
        set this._name = v;
    }

    /**
    Current paginator page.
    @param Integer v
    @return Integer
    */
    property page(v)
    {
        get return this._page;
        set this._page = v;
    }

    /**
    Number of displaying items per page
    @param Integer v
    @return Integer
    */
    property pageSize(v)
    {
        get return this._pageSize;
        set this._pageSize = this.offset = v;

    }

    /**
    Calculated offset based on current page and current page Size
    @param Integer v
    @return Integer
    */
    property offset(v)
    {
        get return this._offset;
        set this._offset = v;
    }

    /**
    Partial data flag.
    @param Boolean v
        true - data lenght is not know, each time data are received,
        it add received datasize to paginator data lenght property
        false - data lenght is known and set
    @return Boolean
    */
    property partialData(v)
    {
        get return this._partialData;
        set this._partialData = v;
    }

    /**
    Data lenght, to calculate number of totoal pages
    @param Integer v
    @return Integer
    */
    property length(v)
    {
        get return this._length;
        set
        {
            //add data Size only if page has not been visited previously
            if(this.partialData === true && this._existsPage() === false)
            {
                //received data length are same as paginator length
                if(v == this.pageSize)
                    this._length = this._length + this.pageSize + v;
                else
                    this._length = this._length + v;
            }
            else if(this.partialData === false)
                this._length = v;  //set total length

        }
    }

    /**
    Get next page number based on current page.
    If next page is not availaible it return false
    @param Integer|false v
        False if next page is not availaible
    @return Integer
    */
    function getNextPage()
    {
        var ret = false;

        if(this.isPage(this.page+1) === true)
        {
            this.page += 1
            ret = this.page;
        }

        return ret;
    }

    /**
    Get Previous page number based on current page.
    If next page is not availaible it return false
    @param Integer|false v
        False if previouse page is not availaible
    @return Integer
    */
    function getPrevPage()
    {
        var ret = false;

        if(this.page > 1 &&
            this.isPage(this.page - 1) === true)
        {
            this.page -=1;
            ret = this.page;
        }

        return ret;
    }

    /**
    Return label of page. Label is based by page parameter and number of items per page, or dala lenght if last page.
    Number of current item and last item on the page is split by spliter.
    @param Integer page
    @return String
    */
    function getLabel(page)
    {
        var label = false;

        if(page !== false)
            label = this.begin(page) + DEFAULT_SPLITER + this.end(page);

        return label;

    }

    /**
    Index of data where current list begins
    @param Integer Page
        If page is not present it takes current (last) page
    @return Integer
    */
    function begin(page = null)
    {
        if(page === null) page = this.page;
        return ((page * this.pageSize) - this.pageSize) + 1;
    }

    /**
    Index of data where current list ends
    @param Integer page
        If page is not set ot takes current (last) page
    */
    function end(page = null)
    {
        if(page===null) page = this.page;
        return (page * this.pageSize) > this.length ? this.length : (page * this.pageSize);
    }

    /**
    Check if current page exists. return false, if page does not exists.
    @param Integer page
    @return Boolean
        true - page does exist
        false - page does not exist
    */
    function isPage(page)
    {
        var ret = false;
        if(this.length.toFloat() / (this.pageSize * page) >= 1)
            ret = true;

        return ret;
    }

    /**
    Reset paginator to default settings
    */
    function reset()
    {
        this.page = DEFAULT_PAGE;
        this.pageSize = DEFAULT_PAGESIZE;
        this.offset = DEFAULT_PAGESIZE;

    }

    /**
    @visibility private
    Check if current page exist.
    @return Boolean
        true  - page does exist
        false - page does not exist
    */
    function _existsPage()
    {
        var found = false;

        for(var i=0;i<this._pages.length;i++)
        {
            if(this._pages[i] == this.page){
                found = true;
                break;
            }
        }

        if(found === false)
            this._pages.push(this.page);

        return found;
    }

}