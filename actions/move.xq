xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

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
 } ;




(:  The RESTful implementation of a move colleciton or move resource.

Checks
1) "from" must be specified and longer then 3 characters
2) "to" must be specified and longer then 3 characters
3) "to" must not be a subcollection of "from"

TODO:
Warn the user if the "to" collection does not exist
Warn the user if the current user does not have write privileges

   xmldb:move($from as xs:string, $to as xs:string) empty()

Move from collection $from to the collection $to.
The collections can be specified either as a
simple collection path or an XMLDB URI.
:)

let $from := request:get-parameter('from', '')
let $to := request:get-parameter('to', '')


(: TODO fix this so it is not hard-coded!!! :)
let $login := xmldb:login('/db', 'admin', 'admin123')

return

(: now do basic error checking an return a meaninful error message to the user :)

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
   
    (: this is where the move gets executed
     collection-available will return true if the source is a valid collection.  :)
 
    if (xmldb:collection-available($from))
        then
           (: move from collection into to collection :)
           xmldb:move($from, $to)
        else
            let $source-base := local:substring-before-last($from, '/')
            let $resource := local:substring-after-last($from, '/')
            (: move the resource to the target :)
            return xmldb:move($source-base, $to, $resource)
    }
         <strong>{$from}</strong><br />successfully moved to<br /><strong>{$to}</strong>
    </span>
