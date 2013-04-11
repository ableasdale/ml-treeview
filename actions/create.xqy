xquery version "1.0-ml";

(: TODO - kill this process if URI and NAME are empty :)
declare variable $uri := xdmp:get-request-field('uri', '');
declare variable $name := xdmp:get-request-field('name', '');

(: TODO - this is a hack - so stop this from being needed.. :)
let $uri := replace($uri, "//", "/")
let $dir := concat($uri, $name,"/")
let $_ := xdmp:log(concat("About to create a new directory: ", $dir))
let $new-collection := xdmp:directory-create($dir)

return 
(xdmp:set-response-content-type("text/html"),
<span class="okay"><strong>{$name}</strong><br />created successfully.</span>)