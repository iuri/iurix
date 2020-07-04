
if {[ns_conn method] eq "POST"} {
    # set header [ns_conn header]
    # set header_size [ns_set size $header]
    # set req [ns_set array $header]
    # set content [ns_conn content]
    # set content2 [ns_getcontent -as_file false]
    package req json
    set dict [json::json2dict [ns_getcontent -as_file false]]
    
    array set arr $dict 
    if {[array exists arr] && [array size arr] > 0} {
	
	# Register User
	ns_log Notice "USER \n [parray arr]"
	
	# Add user
	set user_id [party::get_by_email -email $arr(email)]
	
	if {![exists_and_not_null user_id]  } {
	    db_transaction {
		set user_id [db_nextval acs_object_id_seq]
		array set creation_info [auth::create_user \
					     -user_id $user_id \
					     -verify_password_confirm \
					     -username $arr(email) \
					     -email $arr(email) \
					     -first_names $arr(firstNames) \
					     -last_name $arr(lastName) \
					     -password $arr(password) \
					     -password_confirm $arr(password)]
		
		if { $creation_info(creation_status) eq "ok" && [exists_and_not_null rel_group_id] } {
		    group::add_member \
			-group_id $rel_group_id \
			-user_id $user_id \
			-rel_type "membership_rel"
		}
	    }
	    
	    # Handle registration problems
	    
	    switch $creation_info(creation_status) {
		ok {
		    # Continue below
		}
		default {
		    # Adding the error to the first element, but only if there are no element messages
		    if { [llength $creation_info(element_messages)] == 0 } {
			array set reg_elms [auth::get_registration_elements]
			set first_elm [lindex [concat $reg_elms(required) $reg_elms(optional)] 0]
			form set_error register $first_elm $creation_info(creation_message)
		    }
		    
		    # Element messages
		    foreach { elm_name elm_error } $creation_info(element_messages) {
			form set_error register $elm_name $elm_error
		    }
		    break
		}
	    }
	    
	    switch $creation_info(account_status) {
		ok {
		    # Continue below
		}
		default {
		    
		    if {[parameter::get -parameter RegistrationRequiresEmailVerificationP -default 0] &&
			$creation_info(account_status) eq "closed"} {
			ad_return_warning "Email Validation is required" $creation_info(account_message)
			ad_script_abort
		    }
		    if {[parameter::get -parameter RegistrationRequiresApprovalP -default 0] &&
			$creation_info(account_status) eq "closed"} {
			ad_return_warning "Account approval is required" $creation_info(account_message)
			ad_script_abort
		    }
		    
		    ad_script_abort
		}
	    }
	}
	
	append result "\{
		\"data\": \{  \},
		\"errors\":\[\],
		\"meta\": \{ 
                  \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
		  \"application\": \"CTree Rest API\",
		  \"version\": \"0.1d\",
		  \"id\": \"HTTP/1.1 200 HTML\",
		  \"status\": \"true\",
		  \"message\": \"New User successfully created\"
		\}  
	\}"
	    
	#doc_return 200 "application/json; access-control-allow-origin:*" $result
	# ns_return 200 "application/json;" $result
	
	set status 200
	ns_respond -status $status -type "application/json" -string $result  
	ad_script_abort
    } else {
	ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
	ns_respond -status 406 -type "text/html" -string "No content in the payload"
	ad_script_abort
	
    }    
} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}

