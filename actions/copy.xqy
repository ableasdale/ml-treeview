xquery version "1.0-ml";

(:~  Copy a resource

Checks
1) "from" must be specified and longer then 3 characters
2) "to" must be specified and longer then 3 characters
3) "to" must not be a subcollection of "from"

TODO:
Warn the user if the "to" collection does not exist
Warn the user if the current user does not have write privileges

xmldb:copy($from as xs:string, $to as xs:string) empty()
Copy from collection $from to the collection $to.
The collections can be specified either as a
simple collection path or an XMLDB URI.
:)

declare variable $from as xs:string := xdmp:get-request-field('from', '');
declare variable $to as xs:string := xdmp:get-request-field('to', '');
 

(: taken from http://www.xqueryfunctions.com/xq/functx_escape-for-regex.html :)
declare function local:escape-for-regex($arg as xs:string?) as xs:string {
   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
};

(: Return the string after the last occurance of the delim.
taken from http://www.xqueryfunctions.com/xq/functx_substring-after-last.html :)
declare function local:substring-after-last($arg as xs:string?, $delim as xs:string) as xs:string {
   replace ($arg,concat('^.*', local:escape-for-regex($delim)),'')
};


(: Return the string before the last occurance of the delim.
taken from http://www.xqueryfunctions.com/xq/functx_substring-before-last.html :)
declare function local:substring-before-last($arg as xs:string?, $delim as xs:string ) as xs:string {
   if (matches($arg, local:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', local:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 };


declare function local:resource-exists($res as xs:string) as xs:boolean {
    (xdmp:log(concat("Checking whether ", $res, " exists")),
    (: is it a real dir or doc :)
    not(empty(xdmp:document-properties(concat($res,'/'))/*:properties/*:directory)
        (: not(empty(xdmp:directory-properties($res)) or doc-available($res) :)    
    )
    )
};

(: now do basic error checking an return a meaninful error message to the user :)
(xdmp:set-response-content-type("text/html"),
if (string-length($from) < 3)
then
<error>
       <message>from={$from} must be longer than 3 characters.</message>
    </error>
else

if (string-length($to) < 3)
then
<error>
       <message>to={$to} must be longer than 3 characters.</message>
    </error>
else

if (contains($from, $to))
then
    <span class="issue">The destination collection (to={$to}) may not be a subcollection of the source collection (from={$from}).</span>
else
<span class="okay">
    {
   
    (: this is where the copy gets executed
     collection-available will return true if the source is a valid collection.  :)
 
    if (local:resource-exists(local:substring-before-last($from, '/')))
        then
           (: copy from collection into to collection :)
           (: xmldb:copy($from, $to) :)
           (xdmp:log(concat("Dir exists; about to copy resource to: ", $to)), xdmp:document-insert(concat($to, local:substring-after-last($from, '/')), doc($from)))
        else
            let $source-base := local:substring-before-last($from, '/')
            let $resource := local:substring-after-last($from, '/')
            return
            xdmp:log("dir does not exist; need to do something here")
            (: copy the resource to the target :)
            (: return xmldb:copy($source-base, $to, $resource) :)
            
    }
         <strong>{$from}</strong><br />successfully copied to<br /><strong>{$to}</strong>
    </span>)