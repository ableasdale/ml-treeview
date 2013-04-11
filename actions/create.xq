xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";


let $uri := request:get-parameter('uri', '')
let $name := request:get-parameter('name', '')

let $new-collection := xmldb:create-collection($uri, $name)

return 
<span class="okay"><strong>{$new-collection}</strong><br />created successfully.</span>