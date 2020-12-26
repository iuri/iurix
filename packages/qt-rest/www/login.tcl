ns_log Notice "Running TCL script user/login"

if {[ns_conn method] eq "POST"} {
    package req json
    # ns_log Notice "[ns_getcontent -as_file false]"
    set dict [json::json2dict [ns_getcontent -as_file false]]
    #
    # Do something with the dict
    #
    #ns_log Notice "DICT $dict"
    array set arr $dict
    if {[array exists arr] && [array size arr] > 0} {

	set authority_options [auth::authority::get_authority_options]
	set authority_id [lindex $authority_options 0 1]
	array set auth_info [auth::authenticate \
				 -authority_id $authority_id \
				 -email [string trim $arr(email)] \
				 -password $arr(password)]

	# Handle authentication problems
	switch $auth_info(auth_status) {
	    ok {
		# set token "[ns_base64encode ${email}:${password}]"
		# set token [parameter::get_global_value -package_key "tt-rest" -parameter "WebAppAccessToken" -default ""]
		set user_id $auth_info(user_id)
		
		acs_user::get -user_id $user_id -array user

		## Begin ad_proc jwt
		
		set header "{\"alg\": \"HS256\", \"typ\": \"JWT\"}"
		set enc_header [ns_base64encode $header]		
		# set payload "\{\"iss\": \"26973410000102\", \"aud\": \"iurix.com/REST\", \"sub\": \"$user(user_id)\", \"name\": \"$user(name)\", \"iat\": [ns_time], \"exp\": [ns_time incr [ns_time] 6000]\}"
		# set payload "{'iss': '26973410000102', 'aud': 'iurix.com/REST', 'sub': '$user(user_id)', 'iat': [ns_time]}"
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
		    SELECT DISTINCT(g.group_id), g.group_name FROM groups g, group_member_map gm WHERE g.group_id = gm.group_id AND g.group_id NOT IN (-1, -2, 12169343) AND gm.member_id = :user_id ORDER BY g.group_name
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
			\"firstNames\": \"$user(first_names)\",
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
	    bad_password {
		set err_msg "BAD PASSWORD"
		set status 401
		set header [ns_set new]
		ns_set put $header "Authorization" "Bearer none"

		set result "\{
		    \"data\": \"\",
		    \"errors\":\"$err_msg\","
		    #break
	    }
	    default {
		set err_msg "AUTH FAILED"
		set status 403
		set header [ns_set new]
		ns_set put $header "Authorization" "Bearer none"

		set result "\{
		    \"data\": \"\",
		    \"errors\":\"$err_msg\","
		#break
	    }
	}
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
    #    ns_log Notice "$status | $header | $result"
    ns_respond -status $status -type "application/json" -headers $header -string $result  
    ad_script_abort



} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}
