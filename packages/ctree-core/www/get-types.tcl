ad_page_contract {} {    
    {tree}
    {token}
}


set access_token "GHERFEIFGEG765434567NEIGrghreuighe"

if {$token eq $access_token} {
        if {[info exists tree]} {
	#Tree's in the argument
	set parent_id [ad_conn package_id]
	if {[db_0or1row item_exists {
	    SELECT item_id FROM cr_items WHERE name = :tree AND parent_id = :parent_id
	}]} {
	    set parent_id $item_id
	    set json ""
	    db_foreach select_ctree_types {
		SELECT item_id FROM cr_items WHERE content_type = 'c_type' AND parent_id = :parent_id
	    } {
		ns_log Notice "ITEMID $item_id"
		content::item::get -item_id $item_id -array_name item -revision latest
		#ns_log Notice "[parray item]"
		append json "\{\"$item(name)\":\"$item(description)\"\},"
	    }
	    set json [string trimright $json ","]
	    
      
	    set result "\{
                  \"status\": true,          
                  \"types\": \[$json\],                  
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
	
	
    } else {
	set result "\{
                  \"status\": false,
                  \"types\": null,
                  \"errors\":\{
                               \"id\": \"401 Unauthorized\",
                               \"status\": \"HTTP/1.1 401 Access Denied\",
                               \"title\": \"Item not found!\",
                               \"detail\": \"The item does not relate to any data in the system. Please register!\",
                               \"source\": \"filename: /packages/ctree/www/get.tcl \"
                  \},
                  \"meta\": \{
                         \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
                         \"application\": \"CTree Rest API\",
                               \"version\": \"0.1d\",
                               \"id\": \"HTTP/1.1 401 Unauthorized\",
                               \"status\": \"false\",
                               \"message\": \"login failed. Access denied.\"
                  \}                                                                                                 
        \}"
	
	
	doc_return 401 "application/json" $result
	ad_return_complaint 1 "Item URL Invalid"
	ad_script_abort
    }

} else {
    


	set result "\{
                  \"status\": false,
                  \"types\": null,
                  \"errors\":\{
                               \"id\": \"401 Unauthorized\",
                               \"status\": \"HTTP/1.1 401 Access Denied\",
                               \"title\": \"Item not found!\",
                               \"detail\": \"The item does not relate to any data in the system. Please register!\",
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
