xquery version "1.0-ml";

(: Setup script - create a usable structure from clean :)
(
xdmp:directory-create("/a/"),
xdmp:directory-create("/a/css/"),
xdmp:directory-create("/a/xml/"),
xdmp:directory-create("/a/js/"),
xdmp:document-insert("/a/xml/test.xml", <test>ok</test>),
xdmp:document-insert("/a/css/test.css", <css>ok</css>)
)
