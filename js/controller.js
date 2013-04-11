/**
*  Tree Editor v0.5
*  @author Alex Bleasdale
*/

// global XQuery Resources:
var LIST_COLLECTIONS_XQUERY = "list-collections.xqy";

var RESOURCE_COPY_URI = "actions/copy.xq";
var RESOURCE_MOVE_URI = "actions/move.xq";
var RESOURCE_CREATE_COLLECTION_URI = "actions/create.xqy";
var RESOURCE_REMOVE_URI = "actions/remove.xq";
var RESOURCE_RENAME_URI = "actions/rename.xq";

// TODO - can this be removed - was eXist specific, I think?
var OVERRIDE_BASE_HREF = "";

/**
* jQuery TreeEditor Controller v0.5
*/
$(function () {
    // a flag to catch the event of a collection being created - used by the createCollection event
    var createCollection = false;
    var createCollectionContext = "";
    
    // a flag to catch the event of a user deleting an item
    var deleteConfirmation = false;
    
    /**
    * Rules for managing both Tree Views
    */
    $(".treeeditor").tree({
        types: {
            /**
            * Manages the concept of a "file" leaf node.
            */
            "file": {
                valid_children: "none",
                max_children: 0,
                max_depth: 0,
                icon: {
                    image: "themes/default/file.png"
                }
            }
        },
        
        plugins: {
            contextmenu: {
                items: {
                    /*
                    * Standard actions - (default) Create action disabled
                    */
                    create: false,
                    
                    /*
                    * Custom action <strong>Create Collection</strong> defined below:
                    */
                    createCollection: {
                        label: "Create Directory",
                        icon: "create", // a classname defined in the css (currently in style.css)
                        visible: function (NODE, TREE_OBJ) {
                            // this action will be disabled if more than one node is selected
                            if (NODE.length != 1) return 0;
                            // this action will not be in the list if the selected resource is a FILE
                            if ($(NODE).attr('rel') == "file") return - 1;
                            // otherwise - OK
                            return 1;
                        },
                        action: function (NODE, TREE_OBJ) {
                            createCollection = true;
                            createCollectionContext = $(NODE[0].innerHTML).attr('rel');
                            TREE_OBJ.create(false, TREE_OBJ.get_node(NODE[0]));
                        },
                        separator_before: true
                    },
                    
                    /*
                    * Custom action <strong>Download Locally</strong> defined below:
                    */
                    download: {
                        label: "Download Locally",
                        icon: "download-icon", // a classname defined in the css (currently in style.css)
                        visible: function (NODE, TREE_OBJ) {
                            // this action will be disabled if more than one node is selected
                            if (NODE.length != 1) return 0;
                            // this action will not be in the list unless the resource is a FILE
                            if ($(NODE).attr('rel') != "file") return - 1;
                            // otherwise - OK
                            return 1;
                        },
                        action: function (NODE, TREE_OBJ) {
                            /*
                            *  For this version, you're only going to be able to download individual files
                            */
                            var baseUrl;
                            
                            if (OVERRIDE_BASE_HREF != "") {
                                console.info("custom base href detected");
                                baseUrl = OVERRIDE_BASE_HREF;
                            } else {
                                baseUrl = location.href.substring(0, location.href.lastIndexOf("/rest"));
                            }
                            // build baseUrl from tree
                            baseUrl += "/webdav/db" + $(NODE).attr('id').substring(4);
                            
                            ajaxManager1.add({
                                success: function (html) {
                                    html = html.replace(/</g, "&lt;");
                                    html = html.replace(/>/g, "&gt;");
                                    $('#output').replaceWith('<div id="output"><pre id="content"><code>' + html + '</code></pre></div>');
                                    $('#content').beautifyCode('xml');
                                },
                                url: baseUrl
                            });
                        }
                    }
                }
            }
        },
        
        
        /**
        *  Both tree views are managed by a single XQuery resource
        */
        data: {
            type: "xml_flat",
            async: true,
            opts: {
                url: LIST_COLLECTIONS_XQUERY 
            }
        },
        
        rules: {
            /* Multiple selection works, although the queries don't support it */
            /*multiple: "on",*/
            draggable: "all",
            dragrules:[ "file inside folder", "folder inside folder", "file after file"],
            drag_copy: "ctrl",
            multitree: "all"
        },
        
        /**
        *  Handling the COPY and MOVE methods using a callback
        */
        callback: {
            
            /**
            * Custom hook for "hover" events; not being used
            onhover: function (NODE, TREE_OBJ) {
            if ($(NODE.innerHTML).attr('icon') != null) {
            console.log("can't drag here");
            }
            },*/
            
            /*
            ondrop: function (NODE, REF_NODE, TYPE, TREE_OBJ) {
            console.log("DROP HAPPENED");
            },  */
            
            /**
            *   Manage the copy (collection or resource)
            */
            oncopy: function (NODE, REF_NODE, TYPE, TREE_OBJ, RB) {
                var dest;
                var src = $(NODE.innerHTML).attr('rel');
                var destAttr = $(REF_NODE.innerHTML).attr('rel');
                //console.debug("copying to ", destAttr);
                if (destAttr.indexOf(".") >= 0) {
                    //console.log("ref node appears to be a file: " + destAttr);
                    dest = destAttr.substring(0, destAttr.lastIndexOf("/"));
                    // console.log("dest will be ", dest);
                } else {
                    //console.log("ref node does not appear to be a file");
                    dest = destAttr;
                }
                ajaxManager1.add({
                    success: function (html) {
                        growl(html);
                    },
                    url: RESOURCE_COPY_URI + "?from=" + src + "&to=" + dest
                });
            },
            
            /**
            *   Manage the move (collection or resource)
            */
            onmove: function (NODE, REF_NODE, TYPE, TREE_OBJ, RB) {
                var dest;
                var src = $(NODE.innerHTML).attr('rel');
                var destAttr = $(REF_NODE.innerHTML).attr('rel');
                //console.debug("copying to ", destAttr);
                if (destAttr.indexOf(".") >= 0) {
                    //console.log("ref node appears to be a file: " + destAttr);
                    dest = destAttr.substring(0, destAttr.lastIndexOf("/"));
                    // console.log("dest will be ", dest);
                } else {
                    //console.log("ref node does not appear to be a file");
                    dest = destAttr;
                }
                ajaxManager1.add({
                    success: function (html) {
                        growl(html);
                    },
                    url: RESOURCE_MOVE_URI + "?from=" + src + "&to=" + dest
                });
            },
            
            
            /**
            *  Pre-delete hook to manage the deletion (via a UI dialogue box)
            */
            beforedelete: function (NODE, TREE_OBJ) {
                var src = $(NODE.innerHTML).attr('rel');
                
                if (deleteConfirmation == true) {
                    // reset the confirmation flag
                    deleteConfirmation = false;
                    return true;
                } else {
                    var dialogueBox = $('<p>Are you <strong>sure</strong> you want to delete <strong>' + src + '</strong>?</p>').dialog({
                        buttons: {
                            "Delete": function () {
                                $(this).dialog("close");
                                $(this).dialog("destroy");
                                deleteConfirmation = true;
                                TREE_OBJ.remove(NODE);
                            },
                            "Cancel": function () {
                                $(this).dialog("close");
                                $(this).dialog("destroy");
                            }
                        },
                        title: 'Delete Confirmation',
                        modal: true
                    });
                }
                return false;
            },
            
            /**
            *   Manage the delete (collection or resource)
            */
            ondelete: function (NODE, TREE_OBJ, RB) {
                var src = $(NODE.innerHTML).attr('rel');
                //console.log("DELETE approved for : ", src);
                
                ajaxManager1.add({
                    success: function (html) {
                        growl(html);
                    },
                    url: RESOURCE_REMOVE_URI + "?id=" + src
                });
            },
            
            /**
            *   Manage the rename (collection or resource)
            */
            onrename: function (NODE, TREE_OBJ, RB) {
                /*
                *   The top part of the if statement creates a new Collection in the db
                */
                if (createCollection === true) {
                    //console.log(NODE.textContent, " will be created in ..." + createCollectionContext);
                    ajaxManager1.add({
                        success: function (html) {
                            growl(html);
                        },
                        url: RESOURCE_CREATE_COLLECTION_URI + "?uri=" + createCollectionContext + "&name=" + NODE.textContent.substring(1)
                    });
                    
                    /*
                    * when complete, reset custom values for safety
                    */
                    createCollection = false;
                    createCollectionContext = "";
                } else {
                    /*
                    * Hook for renaming a resource
                    */
                    var id = $(NODE.innerHTML).attr('rel');
                    var newName = NODE.textContent.substring(1);
                    
                    //console.log("about to rename file... ", id, " to ", newName);
                    
                    ajaxManager1.add({
                        success: function (html) {
                            growl(html);
                        },
                        url: RESOURCE_RENAME_URI + "?id=" + id + "&newname=" + newName
                    });
                }
            },
            
            /**
            *   Manage the creation (collection or resource)
            */
            oncreate: function (NODE, REF_NODE, TYPE, TREE_OBJ, RB) {
                console.log("file create upload dialogue here...");
            },
        }
    });
    
    /**
    * Display XQuery HTTP response in a Growl style notification
    */
    function growl(html) {
        console.log("About to Growl an html response ... "),
        console.dir(html)
        jQuery.noticeAdd({
            text: html,
            stay: false
        });
    }
    
    /**
    *  Manage Application Key Bindings - Ctrl bound to COPY mode when dragging
    */
    $(document).keydown(function (e) {
        if (e.ctrlKey) {
            $(".mode").html("COPY");
        }
    });
    
    $(document).keyup(function (e) {
        if (e.keyCode === 17) {
            $(".mode").html("MOVE");
        }
    });
    
    /**
    * Set up XHR manager and queue
    */
    var ajaxManager1 = $.manageAjax.create({
        manageType: 'queue', maxReq: 0
    });
    
    /**
    * Set up code formatter
    */
    $.beautyOfCode.init({
        brushes:[ 'Xml', 'JScript'],
        ready: function () {
        }
    });
});