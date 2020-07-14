ad_page_contract {} {    
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

if {[ix_rest::jwt::validation_p] eq 0} {
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

	    content::item::get -item_id $item_id -revision latest -array_name item
	    
	    if {[info exists cTreeName]} {
		set cTreeName $item(title)
	    }
	    	   	    
	    # If a ctree_post is required, then return post's data 
	    if {[info exists postType]} {
		set parent_id $item_id
		if {[db_0or1row item_exists {
		    SELECT item_id FROM cr_items WHERE name = :post AND parent_id = :parent_id
		}]} {		    
		    ns_log Notice "ITEMID $item_id"		
		}
		
		if {[info exists description]} {
		    set item_id [db_string select_desc { SELECT ci.item_id
			FROM cr_items ci,cr_revisions cr
			WHERE cr.revision_id = ci.latest_revision
			AND ci.content_type = 'ctree_description'
		    } -default ""]
		    ns_log Notice "ITEMID $item_id"
		    # set item_id [ctree::get_description -description $description -post $post -tree $tree]
		}		
	    }	    
	    
	    # If a ctree_type is required, then return post's data 
	    if {[info exists type]} {
		ns_log Notice "GET TYPE $type"
		set parent_id $item_id
		if {[db_0or1row item_exists {
		    SELECT item_id FROM cr_items WHERE name = :type AND parent_id = :parent_id
		}]} {
		    ns_log Notice "ITEMID $item_id"		
		}
	    }
	    
	    content::item::get -item_id $item_id -array_name item -revision latest
	    #ns_log Notice "[parray item]"
	    
	    if {[info exists post] && [info exists description]} {	    
		set i [lsearch $item(description) $post]
		set j [lsearch $item(description) [lindex $item(description) [expr $i +1]]]
		set nm [lindex $item(description) $i] 
		set desc [lindex [lindex $item(description) $j] [expr $i + 1]]
		set json "\"$nm\":\"[list $desc]\""
		set json "\"$item(content_type)\":\{$json\}"
		
	    } else {
		#  set json "\"$item(name)\":\"[list $item(description)]\""
		set json "\"$item(content_type)\":\"$item(title)\""
		
	    }
	    #set item(content_type) [lindex [split $item(content_type) "_"] 1]
	    
	    if {[array exists item]} {
		set result "\{
		    \"request\": \{
			\"cTree\": \"$cTree\"	    
		    \},		    
		    \"data\": \{
			\"status\": true,          
			$json
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

	set result "{
                  \"data\": {
                               \"status\":false
                  },
                  \"errors\":{
                               \"id\": \"401 Unauthorized\",
                               \"status\": \"HTTP/1.1 401 Access Denied\",
                               \"title\": \"Invalid Token.\",
                               \"detail\": \"The token sent does not relate to any data in the system. Please correct token and try again! \",
                               \"source\": \"filename: /packages/ctree/www/get.tcl \"
                  },
                  \"meta\": {
                         \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
                         \"application\": \"CTree Rest API\",
                               \"version\": \"0.1d\",
                               \"id\": \"HTTP/1.1 401 Unauthorized\",
                               \"status\": \"false\",
                               \"message\": \"Invalid Token. Access denied.\"
                  }                                                                                                 
        }"


	doc_return 401 "application/json" $result
	ad_return_complaint 1 "Item URL Invalid"
	ad_script_abort
}
