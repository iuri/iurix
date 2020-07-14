#/packages/ctree-core/www/put.tcl
ad_page_contract {
    Add/update stored data based on provided JSON, treated as a single transaction (i.e. no partial updates).

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
}

if {[ctree::jwt::validation_p] eq 0} {
    ad_return_complaint 1 "Bad HTTP Request: Invalid Token!"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."
    ad_script_abort
}


if {[ns_conn method] eq "POST"} {

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


} else {
    
    set result "\{
	\"data\": \{
	    \"status\": false
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
