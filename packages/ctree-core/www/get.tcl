#/packages/ctree-core/www/get.tcl
ad_page_contract {
    Get data based on parameters set for URL.

    @author Iuri de Araujo (iuri@iurix.com)
    @creation_date 4 Jul 2020
} {    
    {cTree:optional}
    {cTreeId:optional}
    {cTreeName:boolean,optional}
    {description:optional}
    {feedback:optional}
    {post:optional}
    {postType:optional}
    {query:optional}
    {segmentType:optional}
    {segmentVariation:optional}
    
    {pageSize "20"}
    {pageOffset "0"}	
}

#ctree::jwt::validation_p
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
    
    if { [info exists cTree] } {
	
	#Tree's in the argument
	ns_log  Notice "cTree $cTree"
	
	set parent_id [ad_conn package_id]
	ns_log Notice "PARENT $parent_id"
	if {[db_0or1row item_exists {
	    SELECT item_id FROM cr_items WHERE name = :cTree AND parent_id = :parent_id
	}]} {
	    ns_log Notice "ITEMID $item_id"

	    append json_request "\"id\": \"$cTree\","
	    
	    content::item::get -item_id $item_id -revision latest -array_name item
	    append json_data "\{\"id\": \"$item(name)\","
	    
	    if {[info exists cTreeName]} {
		append json_request "\"cTreeName\": true,"
		append json_data "\"cTreeName\": \"$item(title)\","
	    }
	    
	    # If a ctree_post is required, then return post's data
	    ### listDataKeys
	    #### BEGIN

	    ##
	    ##### postType
	    ##
	    if {[info exists postType]} {
		append json_request "\"postType\": \"id\","
		append json_data "\"postType\": \["

		# Gets all postTypes
		db_foreach select_posts {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description AS desc
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_type'
		    AND ci.parent_id = :item_id
		    LIMIT :pageSize OFFSET :pageOffset
		} {
		    ns_log Notice "POSTID $id"	    
		    
		    append json_data "\{
			\"id\": \"$name\",
			\"name\": \"$title\",
			\"color\": \"[lindex $desc 1]\", 
			\"description\": \"[lindex $desc 3]\",
			\"iconUrl\": \"[lindex $desc 5]\",
			\"parentsMax\": \"[lindex $desc 11]\",
			\"parentsRequired\": \"[lindex $desc 13]\",
			\"prompt\": \"[lindex $desc 15]\"
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\],"
	    }	    




	    ##
	    ##### post  (same as element)
	    ##
	    if {[info exists post]} {
		append json_request "\"post\": \"id\","
		append json_data "\"post\": \["

		# Gets all postTypes
		db_foreach select_posts {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description AS desc
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_post'
		    AND ci.parent_id = :item_id
		    LIMIT :pageSize OFFSET :pageOffset
		} {
		    ns_log Notice "POSTID $id"
		    array set arr $desc
		    append json_data "\{
			\"id\": \"$name\",
			\"name\": \"$arr(title)\",
			\"rating\": $arr(rating),
			\"childCount\": $arr(childCount),
			\"description\": \"$desc\"
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\],"
	    }	    













	    
	    ##
	    ##### segmentType
	    ##
	    if {[info exists segmentType]} {
		append json_request "\"segmentType\": \"id\","
		append json_data "\"segmentType\": \["

		# Gets all segmentType Types
		db_foreach select_segment_type {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description AS desc
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_segmenttype'
		    AND ci.parent_id = :item_id
		    LIMIT :pageSize OFFSET :pageOffset
		} {
		    ns_log Notice "SEgmentType $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"componentName\": \"[lindex $desc 3]\",
			\"canBeThumbnail\": [lindex $desc 1]
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\],"		
	    }


	    ##
	    ##### segmentVariation
	    ##
	    if {[info exists segmentVariation]} {
		append json_request "\"segmentVariation\": \"id\","
		append json_data "\"segmentVariation\": \["

		# Gets all segmentVariation Types
		db_foreach select_segment_variation {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description AS desc
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_segmentvariation'
		    AND ci.parent_id = :item_id
		    LIMIT :pageSize OFFSET :pageOffset
		} {
		    ns_log Notice "SegmentVaiation $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"description\": \"$desc\"
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\],"	       
	    }




	    ##
	    ##### feedback
	    ##
	    if {[info exists feedback]} {
		append json_request "\"feedback\": \"id\","
		append json_data "\"feedback\": \["

		# Gets all feedback types
		db_foreach select_feedback {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description AS desc
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_feedback'
		    AND ci.parent_id = :item_id
		    LIMIT :pageSize OFFSET :pageOffset
		} {
		    ns_log Notice "Feedback $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"description\": \"$desc\"
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\],"	       
	    }



	    ##
	    ##### description
	    ##
	    if {[info exists description]} {
		append json_request "\"description\": \"id\","
		append json_data "\"description\": \["

		# Gets all Descriptions types
		db_foreach select_description {
		    SELECT ci.item_id AS id, ci.name, cr.title, cr.description
		    FROM cr_items ci, cr_revisions cr
		    WHERE ci.item_id = cr.item_id
		    AND ci.latest_revision = cr.revision_id
		    AND ci.content_type = 'ctree_description'
		    AND ci.parent_id = :item_id
		    LIMIT :pageSize OFFSET :pageOffset
		} {
		    ns_log Notice "Description $id"
		    append json_data "\{
			\"id\": \"$name\",
			\"description\": \"$description\"
		    \},"		    
		}
		
		set json_data [string trimright $json_data ","]
		append json_data "\],"	       
	    }


















	    

	    set json_request [string trimright $json_request ","]
	    set json_data [string trimright $json_data ","]
	    append json_data "\}"
	    set result "\{
		\"request\": \{$json_request\},
		\"cTrees\": \[
		    $json_data
		\],
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
    set json "\"cTrees\": \["
    
    db_foreach select_trees {
        SELECT item_id, name FROM cr_items WHERE content_type = 'ctree'
	LIMIT :pageSize OFFSET :pageOffset
    } {
        set title [content::item::get_title -item_id $item_id]
        
        append json "\{\"id\":\"$name\", \"name\": \"$title\"\},"
    }
    set json [string trimright $json ","]
    append json "\]"
    
    set result "\{
	\"request\": null,
        $json,
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
