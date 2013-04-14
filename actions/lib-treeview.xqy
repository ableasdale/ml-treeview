xquery version "1.0-ml";

module namespace lib-treeview="http://www.xmlmachines.com/ml-treeview";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function lib-treeview:resource-exists($res as xs:string) as xs:boolean {
    (xdmp:log(concat("lib-treeview:resource-exists : Checking whether ", $res, " exists")),
    (: is it a real dir or doc :)
    not(empty(xdmp:document-properties(concat($res,'/'))/*:properties/*:directory)
        (: not(empty(xdmp:directory-properties($res)) or doc-available($res) :)    
    )
    )
};

declare function lib-treeview:safetycheck($from as xs:string, $to as xs:string) as xs:boolean {
    if (
        some $val in ( (string-length($from) > 3) || (string-length($to) > 3) || (not(contains($from, $to))) )
        satisfies false()
    )
    then (xdmp:log("lib-treeview:safetycheck : Safety Check Failure Encountered", "error"),false())
    else (xdmp:log("lib-treeview:safetycheck : Pass"),true())    
};

(:
Checks
1) "from" must be specified and longer then 3 characters
2) "to" must be specified and longer then 3 characters
3) "to" must not be a subcollection of "from"

TODO:
Warn the user if the "to" collection does not exist
Warn the user if the current user does not have write privileges
:)
declare function lib-treeview:generate-errormsg($from as xs:string, $to as xs:string) {
let $msg := 
    if (string-length($from) < 3)
        then (concat("from={",$from,"} must be longer than 3 characters."))
    else if (string-length($to) < 3)
        then (concat("to={",$to,"} must be longer than 3 characters."))
    else if (contains($from, $to))
        then ("from to") (: (concat("The destination collection (to={",$to,"}) may not be a subcollection of the source collection (from={",$from"}).")) :)
    else ("An unknown error occurred.")
return (xdmp:set-response-content-type("text/html"),
element error {
    element message {element strong {"ERROR: "}, $msg}
})
};
