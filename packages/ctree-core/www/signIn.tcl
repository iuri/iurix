ad_page_contract {
    Login webservice API method, form-data format
} {
    {email}
    {password}
}

ns_log Notice "Running TCL script signIn.tcl"

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

if {[ns_conn method] eq "POST"} {
    if {[exists_and_not_null email] && [exists_and_not_null password]} {
	ns_log Notice "EMAIL $email \n PWD  $password \n"

	set authority_options [auth::authority::get_authority_options]
	set authority_id [lindex $authority_options 0 1]
	array set auth_info [auth::authenticate \
				 -authority_id $authority_id \
				 -email [string trim $email] \
				 -password $password]


	# Handle authentication problems
	switch $auth_info(auth_status) {
	    ok {
		# set token "[ns_base64encode ${email}:${password}]"
		# set token [parameter::get_global_value -package_key "tt-rest" -parameter "WebAppAccessToken" -default ""]
		
		acs_user::get -user_id $auth_info(user_id) -array user

		ns_log Notice "[parray user] "

		## Begin ad_proc jwt
		
		set header "{\"alg\": \"HS256\", \"typ\": \"JWT\"}"
		set enc_header [ns_base64encode $header]
		ns_log Notice "HEADER $header"
		
		# set payload "\{\"iss\": \"26973410000102\", \"aud\": \"iurix.com/REST\", \"sub\": \"$user(user_id)\", \"name\": \"$user(name)\", \"iat\": [ns_time], \"exp\": [ns_time incr [ns_time] 6000]\}"
		# set payload "{'iss': '26973410000102', 'aud': 'iurix.com/REST', 'sub': '$user(user_id)', 'iat': [ns_time]}"
		set payload "{'sub': '$user(user_id)', 'iat': [ns_time]}"
		ns_log Notice "Payload $payload"
		set enc_payload [ns_base64encode $payload]

		set hmac_secret [ns_crypto::hmac string -digest sha256 "Abracadabra" "What is the magic word?"]
		ns_log Notice "CRYPTO $hmac_secret"

		set token "${enc_header}.${enc_payload}.${hmac_secret}"
		ns_log Notice "TOIKEN $token"	

		## Finish ADproc from ix-jwt
		
		set err_msg ""
		set status 200
		set header [ns_set new]
		ns_set put $header "Authorization" "Bearer $token"
		set result "\{
 		    \"user\": \{
		        \"isVerified\": \"$user(email_verified_p)\",
		        \"id\": $user(user_id),
			\"email\": \"$user(email)\",
			\"createdAt\": \"$user(creation_date)\",
			\"updatedAt\": \"$user(last_visit)\"
		    \},"
	    }
	    bad_password {
		set err_msg "BAD PASSWORD"
		set status 401
		set result "\{
		    \"data\": \"\",
		    \"errors\":\"$err_msg\","
		    #break
	    }
	    default {
		set err_msg "AUTH FAILED"
		set status 403
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


    append result "\"meta\": \{ 
	    \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
	    \"application\": \"CTree Rest API\",
	    \"version\": \"0.1d\",
	    \"id\": \"HTTP/1.1 $status HTML\",
	    \"status\": \"true\",
	    \"message\": \"$err_msg\"
	\}
    \}"
	
	

    
    # doc_return 200 "application/json" $result    
    # ns_return -binary $status "application/json;" -header $headers result
    ns_respond -status $status -type "application/json" -headers $header -string $result  
    ad_script_abort



} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}
