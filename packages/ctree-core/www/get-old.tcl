ad_page_contract {} {    
    {type:optional}
    {post:optional}
    {description:optional}
    {tree}
    {token}
}


set access_token "GHERFEIFGEG765434567NEIGrghreuighe"

if {[string equal $token $access_token]} {
    
    if {[info exists tree]} {
	#Tree's in the argument
	set parent_id [ad_conn package_id]
	if {[db_0or1row item_exists {
	    SELECT item_id FROM cr_items WHERE name = :tree AND parent_id = :parent_id
	}]} {
	    # If a c_post is required, then return post's data 
	    if {[info exists post]} {
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
			AND ci.content_type = 'c_description'
		    } -default ""]
		    ns_log Notice "ITEMID $item_id"
		    # set item_id [ctree::get_description -description $description -post $post -tree $tree]
		}		
	    }
		
	}
	
	
	# If a c_type is required, then return post's data 
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
	} else {
	    set json "\"$item(name)\":\"[list $item(description)]\""
	}
	set json "\"$item(content_type)\":\{$json\}"
	
	if {[array exists item]} {
	    set result "{
                  \"data\": {
                    \"status\": true,          
                    $json
                  },
                  \"errors\":{},
                  \"meta\": {
                         \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
                         \"application\": \"CTree Rest API\",
                         \"version\": \"0.1d\",
                         \"id\": \"HTTP/1.1 200 Authorized\",
                         \"status\": \"true\",
                         \"message\": \"Successfull request. Access allowed\"
                  }
            }"
	    
	    doc_return 200 "application/json" $result
	    ad_script_abort
	    
	    
	}
	
    } else {
	
	
	set result "{
                  \"data\": {
                               \"status\":false
                  },
                  \"errors\":{
                               \"id\": \"401 Unauthorized\",
                               \"status\": \"HTTP/1.1 401 Access Denied\",
                               \"title\": \"Item not found!\",
                               \"detail\": \"The item does not relate to any data in the system. Please register!\",
                               \"source\": \"filename: /packages/ctree/www/get.tcl \"
                  },
                  \"meta\": {
                         \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
                         \"application\": \"CTree Rest API\",
                               \"version\": \"0.1d\",
                               \"id\": \"HTTP/1.1 401 Unauthorized\",
                               \"status\": \"false\",
                               \"message\": \"login failed. Access denied.\"
                  }                                                                                                 
        }"


	doc_return 401 "application/json" $result
	ad_return_complaint 1 "Item URL Invalid"
	ad_script_abort
    }
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
