xquery version "1.0-ml";

(:~  Move collections or resources.
 : move($from as xs:string, $to as xs:string) empty()
 :
 : Move from collection $from to the collection $to.
 : Collections can be specified either as a simple collection path.
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
   
    (: this is where the copy gets executed
     collection-available will return true if the source is a valid collection.  :)
 
    if (lib-treeview:resource-exists(functx:substring-before-last($from, '/')))
        then
           (: copy from collection into to collection :)
           (: xmldb:copy($from, $to) :)
           (xdmp:log(concat("Dir exists; about to move resource to: ", $to)), 
            xdmp:document-insert(concat($to, functx:substring-after-last($from, '/')), doc($from)),
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
         <strong>{$from}</strong><br />successfully moved to<br /><strong>{$to}</strong>
    </span>)
 else (lib-treeview:generate-errormsg($from, $to))