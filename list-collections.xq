xquery version "1.0-ml";

(: declare variable $collection := xdmp:get-request-field('id', '/a/') :)

(: This returns true if there are not files or subcollections in this collection :)
declare function local:is-empty-collection($collection as xs:string) as xs:boolean {
    empty(local:get-child-resources($collection)) and empty(local:get-child-directories($collection))
};


(: TODO - make this get-child-directories :)
declare function local:get-child-directories($collection as xs:string) as xs:string* {
    (: TODO - fix this later :)
    let $collection := if (string-length($collection) eq 1)
    (: if it's a zero :)
    then ("/a/")
    else($collection)
    return
    (: end todo :)
    (xdmp:log(concat("local:get-child-collections() :: ", $collection)),
    for $x in xdmp:directory-properties($collection, "1")
    let $t := tokenize(xdmp:node-uri($x), "/")
    return $t[last() -1])  
};

declare function local:get-child-resources($collection as xs:string) as xs:string* {
    
    (: TODO - fix this later :)
    let $collection := if (string-length($collection) eq 1 )
    (: if it's a zero :)
    then ("/a/")
    else($collection)
    return
    (: end todo :)
    (xdmp:log(concat("local:get-child-resources() :: ", $collection)),
    (: TODO - cts:uris! :)
    for $x in cts:search(doc(), cts:directory-query($collection, "1"))
    return xdmp:node-uri($x)) 
};

(: This xquery returns a list of all the files and sub-collections in jsTree format of a given collection.
   It takes a single parameter "collection" and if none is supplied it will defualt to "/db"
   See the http://www.jsTree.com library "flat XML" standard.  Note that flat is used
   since we only are fetching a single level at a time.  :)
let $_ := xdmp:log(" ******************** START *********************************** ")

let $title := "List Collections"

let $_ := xdmp:log(concat("Module has been passed the request field: ", xdmp:get-request-field('id')))
let $collection := xdmp:get-request-field('id', '/a')
(: TODO - can this go?? :)
let $dbroot := '/a'

(: note that the IDs we pass to the http://www.jsTree.com library can not start with a '/' :)
let $new-collection := if (starts-with($collection, 'xml_'))
then (substring-after($collection, 'xml_'))
else (concat($dbroot, "/"))
 
(: let $new-collection := replace($collection, "///", "/") :)
(: let $new-collection := replace($collection,"//", "/") :)


(: Todo use subsequence($in, 1, 100) to limit the number of values in a subcollection :)

let $sub-collections := 
   for $child in local:get-child-directories($new-collection)
   return $child

let $resources :=
   for $child in local:get-child-resources($new-collection)
   return $child
   
let $all :=
   for $child in ($sub-collections, $resources)
   order by $child
   return $child

return
<root>
   {
   for $child at $count in $all
      let $full-collection-path :=
        if (starts-with($new-collection, "/a"))
        then ($new-collection)
        else concat("/a", $new-collection)
      return
      let $full-collection-path := fn:replace($full-collection-path, "//", "/")
      let $_ := xdmp:log(concat("Full collection path: ", $full-collection-path))
      let $full-collection-path := concat($new-collection, $child)
      (: fixme - to a test to see if we have subcollections :)
      let $_ := xdmp:log(concat("ITEM : ", " POS : ", $child))
      let $is-a-file := fn:doc-available($child)
        
   return
     <item parent_id="0" id="xml_{$full-collection-path}/">
     {if ($is-a-file)
               then attribute {'rel'} {'file'} 
               else () 
               }
      {if ( not($is-a-file) and not(local:is-empty-collection(concat($full-collection-path,"/"))))
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