xquery version "1.0-ml";

(: Setup script - create a usable structure from clean :)
(
xdmp:directory-create("/src/"),
xdmp:directory-create("/src/css/"),
xdmp:directory-create("/src/xml/"),
xdmp:directory-create("/src/js/"),
xdmp:directory-create("/target/"),
xdmp:directory-create("/target/stuff/"),
xdmp:document-insert("/src/xml/test.xml", <test>ok</test>),
xdmp:document-insert("/src/css/test.css", <css>ok</css>)
)