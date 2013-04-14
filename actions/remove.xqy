xquery version "1.0-ml";

(:~  Remove collection or resource.

  remove($collection-uri as xs:string) empty()
  remove($collection-uri as xs:string, $resource as xs:string) empty()

Remove collection $id or resource $id

The collections can be specified as a simple collection path.
:)

import module namespace lib-treeview = "http://www.xmlmachines.com/ml-treeview" at "/actions/lib-treeview.xqy";

let $id := xdmp:get-request-field('id', '')

return (xdmp:set-response-content-type("text/html"),

if (string-length($id) < 3)
then
<error>
       <message>id={$id} must be longer than 3 characters.</message>
    </error>
else
    <span class="okay">
    {
   
    (: this is where the move gets executed
     collection-available will return true if the source is a valid collection.  :)
 
    if (lib-treeview:resource-exists($id))
        then
           (: If the id is a collection then just remove it :)
           xdmp:document-delete($id)
        else
            (: let $source-base := local:substring-before-last($id, '/')
            let $resource := local:substring-after-last($id, '/') :)
            xdmp:log("handle remove case here!") 
    }
         <strong>{$id}</strong><br />successfully removed.
    </span>
)