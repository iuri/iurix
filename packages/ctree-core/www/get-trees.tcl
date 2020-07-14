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

ns_log Notice "Running method get-trees"
if {[ix_rest::jwt::validation_p] eq 0} {
    ad_return_complaint 1 "Bad HTTP Request: Invalid Token!"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."
    ad_script_abort
}


if {[ns_conn method] eq "GET"} {
    
    set parent_id [ad_conn package_id]
    ns_log Notice "PARENT $parent_id"
    if {[db_0or1row item_exists {
	SELECT item_id FROM cr_items WHERE parent_id = :parent_id LIMIT 1
    }]} {
	set items [db_list select_item_id {
	    SELECT item_id FROM cr_items WHERE parent_id = :parent_id
	}]
	ns_log Notice "ITEMIDs $items"

	set json "\"ctrees\": \["
	foreach item_id $items {	    
	    content::item::get -item_id $item_id -revision latest -array_name item	    
	    if {[array exists item]} {
		ns_log Notice "[parray item]"
		append json "\{\"$item(name), $item(title)\"\},"
	    }
	}
	set json [string trimright $json ","]
	append json "\]"
	
	
	set result "\{
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
