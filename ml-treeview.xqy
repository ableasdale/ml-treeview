xquery version "1.0-ml";
xdmp:set-response-content-type("text/html; charset=utf-8"),
'<!DOCTYPE html>',
<html lang="en">
    <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js">{" "}</script>
        <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/jstree/3.3.3/themes/default/style.min.css" />
        <script src="//cdnjs.cloudflare.com/ajax/libs/jstree/3.3.3/jstree.min.js">{" "}</script>
        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>
        <!-- Optional theme -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous">{" "}</script>
        <script><![CDATA[$(function() {$('#container').jstree();});]]></script>
    </head>
    <body>
    <div id="container">
  <ul>
    {
        for $i in xdmp:filesystem-directory(xdmp:install-directory())/dir:entry
        return if ($i/dir:type eq "file")
        then (element li { attribute data-jstree {'{"icon" : "glyphicon glyphicon-file"}'}, xs:string($i/dir:filename)})
        else (element li { attribute data-jstree {'{"icon" : "glyphicon glyphicon-folder-close"}'}, xs:string($i/dir:filename)})
        (: , "selected" : true, "opened" : true  :)
    }
  </ul>
</div>
    </body>
</html>