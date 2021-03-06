xquery version "1.0-ml";
 
 
(: compare with 

http://localhost:8080/exist/rest//db/stuff/index.xq
:) 
declare default element namespace "http://www.w3.org/1999/xhtml";

let $title := 'MarkLogic Tree View'

return
<html lang="en">
    <head>
        <title>{$title}</title>
        <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
        
        <!-- jQuery UI Specific Components -->
        <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js"></script>

        <!-- Third Party plugins -->
        <script type="text/javascript" src="js/jquery.notice.js"></script> 
        <script type="text/javascript" src="js/jquery.ajaxmanager.js"></script>
        <script type="text/javascript" src="js/jquery.beautyOfCode.js"></script>
        
        <!-- JSTree -->
        <script type="text/javascript" src="jquery.tree.min.js"></script>
        <script type="text/javascript" src="lib/sarissa.js"></script>
        <script type="text/javascript" src="plugins/jquery.tree.contextmenu.js"></script>
        <script type="text/javascript" src="plugins/jquery.tree.xml_flat.js"></script>
        
        <!-- Application Controller -->
        <script type="text/javascript" src="js/controller.js"></script>
        
        <!-- Stylesheets -->
        <link rel="stylesheet" href="themes/base/ui.all.css" type="text/css" media="screen, projection" />
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, projection" />
        <link rel="stylesheet" href="css/jquery.notice.css" type="text/css" media="screen, projection" />
        <link rel="stylesheet" href="css/editor.css" type="text/css" media="screen, projection" />
    </head>
    <body>
        <div class="container">
           <h2>{$title}</h2>
           <p>Currently logged in as: <strong>{xdmp:get-current-user()}</strong>. Hold down the Control key while dragging to copy the file</p>
           <p>You are currently in <span class="mode">MOVE</span> mode</p>
           <div id="left">
           <!-- TARGET -->
             <h3>Source Tree</h3>
             <div id="source-tree" class="treeeditor">
             
             </div>
           </div>
          
           <div id="right">
           <!-- TARGET -->
                <h3>Target Tree</h3>
                <div id="target-tree" class="treeeditor">
          
                </div>
           </div>
           
           <br class="clearboth" />
           
           <div id="output">
                <pre id="content"><code /></pre>
           </div>
           
        </div>
    </body>
</html>
