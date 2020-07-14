ns_log Notice "Running TCL script user/login"

if {[ns_conn method] eq "POST"} {
    package req json


    set header [ns_conn header]
    ns_log Notice "HEADER \n $header"
    set h [ns_set size $header]
    ns_log Notice "HEADERS $h"
    set req [ns_set array $header]
    ns_log Notice "$req"
    
    set dict [json::json2dict [ns_getcontent -as_file false]]
    #
    # Do something with the dict
    #
    ns_log Notice "DICT $dict"

    array set arr $dict
    if {[array exists arr] && [array size arr] > 0} {
	ns_log Notice "EMAIL $arr(email) \n"

	if {$email_p} {
	    
	 
	    set err_msg ""
	    set status 200
	    set header [ns_set new]
	    ns_set put $header "Authorization" "Bearer $token"
	    
	    
	    
	    # display error if the subsite doesn't allow recovery of passwords
	    set subsite_id [subsite::get_element -element object_id]
	    
	    set email_forgotten_password_p [parameter::get \
						-parameter EmailForgottenPasswordP \
						-package_id $subsite_id \
						-default 1]
	    # Display form to collect username and authority
	    set authority_options [auth::authority::get_authority_options]
	    
	    if { (![info exists authority_id] || $authority_id eq "") } {
		set authority_id [lindex $authority_options 0 1]
	    }
	    
	    set email_p [db_0or1row select_email "
	       SELECT email FROM parties WHERE email = $arr(email)
	    "]

	    if {$email_forgotten_password_p} {
		array set recover_info [auth::password::recover_password \
					    -authority_id $authority_id \
					    -username $username \
					    -email $email]
	    }
	}
	
	
	
	
	
	
	set result "\{\}"
    } else {
	set err_msg "AUTH FAILED. Unauthorized"
	set status 401
	set result "\{
              \"data\": \"\",
              \"errors\":\"$err_msg\","
	#break
	
    }

    # doc_return 200 "application/json" $result    
    # ns_return -binary $status "application/json;" -header $headers result
    ns_respond -status $status -type "application/json" -headers $header -string $result  
    ad_script_abort



} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}
