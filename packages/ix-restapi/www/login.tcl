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
	ns_log Notice "EMAIL $arr(email) \n PWD  $arr(password) \n"

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
		
		acs_user::get -user_id $auth_info(user_id) -array user

		ns_log Notice "[parray user] "

		## Begin ad_proc jwt
		
		set header "{\"alg\": \"HS256\", \"typ\": \"JWT\"}"
		set enc_header [ns_base64encode $header]
		ns_log Notice "HEADER $header"
		
		# set payload "\{\"iss\": \"26973410000102\", \"aud\": \"iurix.com/REST\", \"sub\": \"$user(user_id)\", \"name\": \"$user(name)\", \"iat\": [ns_time], \"exp\": [ns_time incr [ns_time] 6000]\}"
		set payload "{'sub': '$user(user_id)', 'iat': [ns_time]}"
		ns_log Notice "Payload $payload"
		set enc_payload [ns_base64encode $payload]

		set secret [ns_crypto::hmac string -digest sha256 "Abracadabra" ""]
		ns_log Notice "CRYPTO $secret"

		set token "${enc_header}.${enc_payload}.${secret}"
		ns_log Notice "TOIKEN $token"	

		## Finish ADproc from ix-jwt
		
		set err_msg ""
		set status 200
		set header [ns_set new]
		ns_set put $header "Authorization" "Bearer $token"
		set result "\{
		    \"token\": \"$token\",
		    \"user\": \{
		        \"isVerified\": \"$user(email_verified_p)\",
		        \"_id\": $user(user_id),
			\"firstName\": \"$user(first_names)\",
			\"lastName\": \"$user(last_name)\",
			\"email\": \"$user(email)\",
                        \"password\": \"$token\", 
			\"createdAt\": \"$user(creation_date)\",
			\"updatedAt\": \"$user(last_visit)\",
			\"__v\": 0
		    \}
		\}"
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

    # doc_return 200 "application/json" $result    
    # ns_return -binary $status "application/json;" -header $headers result
    ns_respond -status $status -type "application/json" -headers $header -string $result  
    ad_script_abort



} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}
