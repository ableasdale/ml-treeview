xquery version "1.0-ml";

(:  Rename a colleciton or rename resource.

Collection Rename:
   Usage $ACTIONSHOME/rename.xq?id=/db/foo&newname=bar

File Rename:
   Usage: $ACTIONSHOME/rename.xq?id=/db/a/myoldname.xml&newname=newname.xml

Checks
1) "id" must be specified and longer then 3 characters

TODO:
Warn the user if the "id" collection does not exist
Warn the user if the current user does not have write privileges

  xmldb:rename($collection-uri as xs:string) empty()
  xmldb:rename($collection-uri as xs:string, $resource as xs:string) empty()

Remove collection $id or resource $id

The collections can be specified either as a
simple collection path or an XMLDB URI.
:)


import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace lib-treeview = "http://www.xmlmachines.com/ml-treeview" at "/actions/lib-treeview.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $from as xs:string := xdmp:get-request-field('from', '');
declare variable $to as xs:string := xdmp:get-request-field('to', '');

if (lib-treeview:safetycheck($from, $to))
then
(xdmp:set-response-content-type("text/html"),
<span class="okay">
    {
    if (lib-treeview:resource-exists(functx:substring-before-last($from, '/')))
        then
           
           (xdmp:log(concat("Dir exists; about to rename resource to: ", $to)), 
           xdmp:log(concat("URI for renamed document: ", functx:substring-before-last($from, '/'), '/', $to )),
           xdmp:document-insert(concat( functx:substring-before-last($from, '/'), '/', $to  ), doc($from)),
           xdmp:document-delete($from)
           )
        else
            let $source-base := functx:substring-before-last($from, '/')
            let $resource := functx:substring-after-last($from, '/')
            return
            xdmp:log("dir does not exist; need to do something here")
            (: copy the resource to the target :)
            (: return xmldb:copy($source-base, $to, $resource) :)
            
    }
         <strong>{$from}</strong><br />successfully renamed as<br /><strong>{$to}</strong>
    </span>)
 else (lib-treeview:generate-errormsg($from, $to))
 