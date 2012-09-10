/**
Global function to parse XML
@method parseXML
@module core
@param Stream|String streamOrString Data which containing XML.
@param Function callbacks Definition of Callback function
*/
function parseXML(streamOrString, callbacks)
{
    assert streamOrString;

    var stream = null;

    if( streamOrString instanceof String)
        stream = Stream.openString(streamOrString);
    else if( streamOrString instanceof Stream)
        stream = streamOrString;
    else
        throw String.printf("Unexpected type of input %s", typeof streamOrString);

    var scanner = new XMLScanner( stream );
    var token, path = "";

    /*
    Scan Node
    */
    function scanNode()
    {
        var saved_path = path; 
        path = String.printf("%s/%s", path, scanner.tag); // make a path
        var cb = callbacks[path];
        var atts = {};
        var tag = scanner.tag;

        while:loop(token = scanner.token())
        switch (token){
            case XMLScanner.EOF:            return;
            case XMLScanner.ERROR:          throw String.prntf("XML error at line %d", scanner.lineNo);
            case XMLScanner.TEXT:           if(cb && cb.text) cb.text(scanner.value); continue; 
            case XMLScanner.CDATA:          if(cb && cb.data) cb.data(scanner.value); continue; 
            case XMLScanner.HEAD_END:       if(cb && cb.start) cb.start(atts); continue; 
            case XMLScanner.EMPTY_HEAD_END: if(cb) { if(cb.start) cb.start(atts); if(cb.end) cb.end(atts); }
                                            break loop; 
            case XMLScanner.ATTR:           atts[symbol(scanner.attribute)] = scanner.value; continue;
            case XMLScanner.TAIL:           if (scanner.tag == tag) {
                                                if(cb && cb.end) cb.end(atts);
                                                break loop;
                                            }
                                            else
                                                throw String.printf("(Unexpected tail of %s at line %d", scanner.tag, scanner.lineNo);
            case XMLScanner.HEAD:           scanNode(); continue; // note: recursive call
        }
        path = saved_path;
    }

    while (token = scanner.token()) {
        switch(token) {
            case XMLScanner.HEAD_END:       if (preprocessor) { stdout << scanner.tag << "\n"; if (scanner.tag == "?xml") preprocessor = false; } continue; 
            case XMLScanner.EOF:            return;
            case XMLScanner.ERROR:          throw String.printf("XML error at line %d", scanner.lineNo);
            case XMLScanner.HEAD:           scanNode(); break;
            default:                        continue;
        }
    }
}
