include "app://ui/paging/paginator.ms"

/**
@package uix
@location uix/paging/paginator.ms

Class to manage multiple forms with pagination
*/
class PaginatorManager
{
    /**
    Contructor, init array of paginators
    */
    function this()
    {
        //array of paginator objects
        this._paginators = new Array();
    }

    /**
    Get paginator by name. Name of the paginator is same as name of the Form or
    unique name set by user
    @param String name
    @return Paginator
    */
    function getPaginator(name)
    {
        var found = false;
        for(var paginator in this._paginators)
        {
            if(paginator.name == name)
            {
                found = paginator;
            }
        }

        if(found === false)
        {
            found = new Paginator(name);
            this.add(found);
        }

        return found;
    }

    /**
    Add paginator to queue
    @param Paginator paginator
    */
    function add(paginator)
    {
        this._paginators.push(paginator);
    }

    /**
    Remove Paginator from queue
    @param String name Name of the paginator
    */
    function remove(name)
    {
        var k = 0;
        for(var paginator in this._paginators)
        {
            if(paginator.name == name)
            {
                this._paginators.remove(k);
            }

            k++;
        }

    }

}