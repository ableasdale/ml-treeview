xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";


(:  The RESTful implementation of a remove colleciton or remove resource.

Checks
1) "id" must be specified and longer then 3 characters

TODO:
Warn the user if the "id" collection does not exist
Warn the user if the current user does not have write privileges

  xmldb:remove($collection-uri as xs:string) empty()
  xmldb:remove($collection-uri as xs:string, $resource as xs:string) empty()

Remove collection $id or resource $id

The collections can be specified either as a
simple collection path or an XMLDB URI.
:)

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


let $id := request:get-parameter('id', '')

(: TODO fix this so it is not hard-coded!!! :)
let $login := xmldb:login('/db', 'admin', 'admin123')

return

(: now do basic error checking an return a meaninful error message to the user :)

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
 
    if (xmldb:collection-available($id))
        then
           (: If the id is a collection then just remove it :)
           xmldb:remove($id)
        else
            let $source-base := local:substring-before-last($id, '/')
            let $resource := local:substring-after-last($id, '/')
            (: move the resource to the target :)
            return xmldb:remove($source-base, $resource)
    }
         <strong>{$id}</strong><br />successfully removed.
    </span>
