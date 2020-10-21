ad_page_contract {
    API REST method to return organizations
}

ns_log Notice "Running TCL script organization/get"


if {[ns_conn method] eq "GET"} {
    #qt::rest::jwt::validation_p

    set header [ns_conn header]
    set token [ns_set get $header authorization]
    ns_log Notice "TOKEN $token"
    
    #set content [ns_conn content]
    set content [ns_getcontent -as_file false]
    
    ns_log Notice "CONTENT $content"

    if {[info exists user_id]} { 
	
	#ns_log Notice "USERID $user_id"
	set status 200
	ns_respond -status $status -type "application/json" -string $result  
	ad_script_abort
	
	
    } else {
	ad_return_complaint 1 "Input Error: [ns_conn method]"
	ns_respond -status 406 -type "text/html" -string "No content in the payload. You must send userId"
	ad_script_abort
	
    }    
} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}






