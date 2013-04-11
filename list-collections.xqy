xquery version "1.0-ml";

(:~ 
 :   Returns a list of all the files and sub-collections in jsTree format of a given collection.
 :  It takes a single parameter "collection" and if none is supplied it will defualt to "/db"
 :  See the http://www.jsTree.com library "flat XML" standard.  Note that flat is used
 :  since we only are fetching a single level at a time.
 :  
 : @author Alex Bleasdale
 : @version 0.1
 :)

declare variable $dbroot as xs:string := "/a/";
declare variable $collection as xs:string := xdmp:get-request-field('id', $dbroot); 

(: This returns true if there are not files or subcollections in this collection :)
declare function local:is-empty-collection($collection as xs:string) as xs:boolean {
    empty(local:get-child-resources($collection)) and empty(local:get-child-directories($collection))
};

declare function local:get-child-directories($path as xs:string) as xs:string* {
    (xdmp:log(concat("local:get-child-collections() :: ", $path)),
    for $x in xdmp:directory-properties($path, "1")
    let $t := tokenize(xdmp:node-uri($x), "/")
    return $t[last() -1])  
};

declare function local:get-child-resources($path as xs:string) as xs:string* {
    (xdmp:log(concat("local:get-child-resources() :: ", $path)),
    (: TODO - cts:uris! :)
    for $x in cts:search(doc(), cts:directory-query($path, "1"))
    return xdmp:node-uri($x)) 
};

(: TODO - add sort order (ascending, desc, datetime etc.. :)
declare function local:get-directories-and-resources($path as xs:string) as item()* {
(: TODO use subsequence($in, 1, 100) to limit the number of values in a subcollection :)
   for $child in (local:get-child-directories($path), local:get-child-resources($path))
   order by $child
   return $child
};

let $_ := xdmp:log(" ******************** START *********************************** ")
let $_ := xdmp:log(concat("Module has been passed the request field: ", xdmp:get-request-field('id')))
let $title := "List Collections"


(: note that the IDs we pass to the http://www.jsTree.com library can not start with a '/' :)
let $new-collection := 
    if (starts-with($collection, 'xml_'))
    then substring-after($collection, 'xml_')
    else $dbroot

return
<root>
   {
   for $child in local:get-directories-and-resources($new-collection)
      let $full-collection-path := concat($new-collection, $child, "/")
      (: fixme - to a test to see if we have subcollections :)
      let $is-a-file := fn:doc-available($child)
        
   return
     <item parent_id="0" id="xml_{$full-collection-path}">
     {if ($is-a-file)
               then attribute {'rel'} {'file'} 
               else () 
               }
      {if (not($is-a-file) and not(local:is-empty-collection($full-collection-path)))
               then attribute {'state'} {'closed'} 
               else () 
               }
        <content>
           <name rel="{$full-collection-path}/">
            {tokenize($child,"/")[last()]}
           </name>
        </content>
     </item>
    }
</root>