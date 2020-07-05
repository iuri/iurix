#/packages/ctree-core/www/get.tcl
ad_page_contract {
    Get data based on parameters set for URL.

    @author Iuri de Araujo (iuri@iurix.com)
    @creation_date 4 Jul 2020
} {    
    {cTree:optional}
    {cTreeName:boolean,optional}
    {description:optional}
    {feeback:optional}
    {post:optional}
    {postType:optional}
    {query:optional}
    {segmentType:optional}
    {segmentVariation:optional}
    
    {pageSize ""}
    {pageOffset ""}	
}

if {[ctree::jwt::validation_p] eq 0} {
    ad_return_complaint 1 "Bad HTTP Request: Invalid Token!"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."
    ad_script_abort
}



if {[ns_conn method] eq "GET"} {

    set myform [ns_getform]
    if {[string equal "" $myform]} {
	ns_log Notice "No Form was submited"
    } else {
	ns_log Notice "FORM"
	ns_set print $myform
	for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	    set varname [ns_set key $myform $i]
	    set varvalue [ns_set value $myform $i]
	    
	    ns_log Notice " $varname - $varvalue"
	}
    }

    ns_log Notice "BODY \n  [ns_getcontent -as_file false]"
    
    if {[info exists cTree]} {
	#Tree's in the argument
	ns_log  Notice "cTree $cTree"
	
	set parent_id [ad_conn package_id]
	ns_log Notice "PARENT $parent_id"
	if {[db_0or1row item_exists {
	    SELECT item_id FROM cr_items WHERE name = :cTree AND parent_id = :parent_id
	}]} {
	    ns_log Notice "ITEMID $item_id"

	    append json_request "\"cTree\": \"$cTree\","
	    
	    content::item::get -item_id $item_id -revision latest -array_name item
	    append json_data "\"$item(name)\": \{"
	    
	    if {[info exists cTreeName]} {
		append json_request "\"cTreeName\": true,"
		append json_data "\"cTreeName\": \"$item(title)\""
	    }
	    
	    # If a ctree_post is required, then return post's data
	    ### listDataKeys
	    #### BEGIN

	    ##
	    ##### postType
	    ##
	    if {[info exists postType]} {
		append json_request "\"postType\": \"id\","
		append json_data ",\"postType\": \["

		# Gets all postTypes
		db_foreach select_posts {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_post'
		    AND ci.parent_id = :item_id
		} {
		    ns_log Notice "POSTID $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"name\": \"$title\",
			\"parentsRequired\": false,
			\"parentsMax\": 0,
			\"iconUrl\": \"/images/post_type_icon.png\",
			\"color\": \"#FF7700\", 
			\"description\": \"Sample of description\",
			\"prompt\": \"Button label to add post with type\"
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\]"
	    }	    

	    ##
	    ##### segmentType
	    ##
	    if {[info exists segmentType]} {
		append json_request "\"segmentType\": \"id\","
		append json_data ",\"segmentType\": \["

		# Gets all postTypes
		db_foreach select_segment_type {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_segmenttype'
		    AND ci.parent_id = :item_id
		} {
		    ns_log Notice "SEgmentType $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"componentName\": \"example-type-component\",
			\"canBeThumbnail\": true
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\]"		
	    }


	    ##
	    ##### segmentType
	    ##
	    if {[info exists segmentType]} {
		append json_request "\"segmentType\": \"id\","
		append json_data ",\"segmentType\": \["

		# Gets all postTypes
		db_foreach select_segment_type {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_segmenttype'
		    AND ci.parent_id = :item_id
		} {
		    ns_log Notice "SEgmentType $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"componentName\": \"example-type-component\",
			\"canBeThumbnail\": true
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\]"	       
	    }


















	    

	    set json_request [string trimright $json_request ","]
	    set json_data [string trimright $json_data ","]
	    
	    set result "\{
		\"request\": \{$json_request\},
		\"cTrees\": \{
		    $json_data
		\},
		\"errors\":\{\},
		\"meta\": \{
		    \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
		    \"application\": \"CTree Rest API\",
		    \"version\": \"0.1d\",
		    \"id\": \"HTTP/1.1 200 Authorized\",
		    \"status\": \"true\",
		    \"message\": \"Successfull request. Access allowed\"
		\}
	    \}"
		
		doc_return 200 "application/json" $result
		ad_script_abort
		
	}
    }
    #	set json "\"cTrees\": \["
    
    #db_foreach select_trees {
    #    SELECT item_id, name FROM cr_items WHERE content_type = 'ctree'
    #} {
    #    set title [content::item::get_title -item_id $item_id]
    #    
    #    append json "\{\"name\":\"$title\"\},"
    #}
    #set json [string trimright $json ","]
    #append json "\]"
    
    set result "\{
	\"request\": \{
	    \"cTree\": \"$cTree\"	    
	\},
	\"data\": null,
	\"errors\": \"cTree does not exist!\",
	\"meta\": \{
	    \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
	    \"application\": \"CTree Rest API\",
	    \"version\": \"0.1d\",
	    \"id\": \"HTTP/1.1 200 Authorized\",
	    \"status\": \"true\",
	    \"message\": \"Successfull request. No data!\"
	\}
    \}"
	    
    doc_return 200 "application/json" $result
    ad_script_abort
	
    
} else {
    
    set result "\{
	\"data\": \{
	    \"status\":false
	\},
	\"errors\": \{
	    \"id\": \"401 Unauthorized\",
	    \"status\": \"HTTP/1.1 401 Access Denied\",
	    \"title\": \"Invalid Token.\",
	    \"detail\": \"The token sent does not relate to any data in the system. Please correct token and try again! \",
	    \"source\": \"filename: /packages/ctree/www/get.tcl \"
	\},
	\"meta\": \{
	    \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
	    \"application\": \"CTree Rest API\",
	    \"version\": \"0.1d\",
	    \"id\": \"HTTP/1.1 401 Unauthorized\",
	    \"status\": \"false\",
	    \"message\": \"Invalid Token. Access denied.\"
	\}      
    \}"
    
    
    doc_return 401 "application/json" $result
    ad_return_complaint 1 "Item URL Invalid"
    ad_script_abort
}
