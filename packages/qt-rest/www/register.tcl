
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
	ns_log Notice "USERID $user_id"
	if {![exists_and_not_null user_id]  } {
	    db_transaction {
		set user_id [db_nextval acs_object_id_seq]
		array set creation_info [auth::create_user \
					     -user_id $user_id \
					     -verify_password_confirm \
					     -username $arr(email) \
					     -email $arr(email) \
					     -first_names $arr(firstName) \
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
	    ns_log Notice " [parray creation_info] \n $creation_info(creation_status)"
	    
	    switch $creation_info(creation_status) {
		ok {
		    # Continue below
		        
		    acs_user::get -user_id $user_id -array user
		    
		    ## Begin ad_proc jwt		    
		    set header "{\"alg\": \"HS256\", \"typ\": \"JWT\"}"
		    set enc_header [ns_base64encode $header]		
		    set payload "{'sub': '$user(user_id)', 'iat': [ns_time]}"
		    set enc_payload [ns_base64encode $payload]
		    
		    set hmac_secret [ns_crypto::hmac string -digest sha256 "Abracadabra" "What is the magic word?"]
		    
		    set token "${enc_header}.${enc_payload}.${hmac_secret}"
		    
		    ## Finish ADproc from ix-jwt
		    set admin_p false 
		    if {[acs_user::site_wide_admin_p -user_id $user_id] eq 1} {
			set admin_p true
		    }
		    
		    set json_groups ""
		    set groups [db_list_of_lists select_groups {
			SELECT DISTINCT(g.group_id), g.group_name FROM groups g, group_member_map gm WHERE g.group_id = gm.group_id AND g.group_id NOT IN (-1, -2) AND gm.member_id = :user_id ORDER BY g.group_name
		    }]
		    
		    if {[llength $groups] eq 1} {		    
			append json_groups "\"group\": \{\"label\": \"[lindex [lindex $groups 0] 1]\",\"value\": [lindex [lindex $groups 0] 0]\}"
		    } else {		    
			append json_groups "\"group\": \"\",\"groups\": \["
			foreach group $groups {
			    append json_groups "\{\"label\": \"[lindex $group 1]\",\"value\": [lindex $group 0]\},"
			}
			set json_groups [string trimright $json_groups ","]
			append json_groups "\]"
			
		    }		   		    
		    
		    set portrait_id [acs_user::get_portrait_id -user_id $user_id]
		    if {$portrait_id != 0} {
			set portrait_url "https://dashboard.qonteo.com/shared/portrait-bits.tcl?user_id=$user_id"		    
		    } else {
			set portrait_url ""
		    }
		    		    
		    set err_msg ""
		    set status 200
		    set header [ns_set new]
		    ns_set put $header "Authorization" "Bearer $token"
		    set result "\{
		      \"token\": \"$token\",
		      \"user\": \{
		        \"isVerified\": \"$user(email_verified_p)\",
		        \"isAdmin\": $admin_p,
		        \"_id\": $user(user_id),
			\"firstName\": \"$user(first_names)\",
			\"lastName\": \"$user(last_name)\",
			\"email\": \"$user(email)\",
                        \"phonenumber\": \"\",
                        \"portrait_url\": \"$portrait_url\",
                        \"country\": \"\", 
                        \"city\": \"\",
                        $json_groups,
			\"createdAt\": \"$user(creation_date)\",
			\"updatedAt\": \"$user(last_visit)\",
			\"__v\": 0
		      \}
		    \}"  		    
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
	} else {
	    set status 401
	    append result "\{
		\"data\": \{\"HTML 401 Error! User already exists!\"\},
		\"errors\":\{\"HTML 401 Error! User already exists!\"\},
		\"meta\": \{ 
		\"copyright\": \"Copyright 2020 Qonteo\",
		\"application\": \"Qonteo Rest API\",
		\"version\": \"0.1d\",
		\"id\": \"HTTP/1.1 401 HTML\",
		\"status\": \"true\",
		\"message\": \"Unauthorized! Emails exists\"
		\}  
	    \}"

	    
	}
	
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

