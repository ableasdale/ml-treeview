xquery version "1.0-ml";

(:
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes"; :)

(: TODO - kill this process if URI and NAME are empty :)
declare variable $uri := xdmp:get-request-field('uri', '');
declare variable $name := xdmp:get-request-field('name', '');

(: TODO - this is a hack - so stop this from being needed.. :)
let $uri := replace($uri, "//", "/")
let $dir := concat($uri, $name,"/")
let $_ := xdmp:log(concat("About to create a new directory: ", $dir))
let $new-collection := xdmp:directory-create($dir)

return 
<span class="okay"><strong>{$new-collection}</strong><br />created successfully.</span>