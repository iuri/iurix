ns_log Notice "Running TCL script user/login"

if {[ns_conn method] eq "POST"} {
    package req json


    set header [ns_conn header]
    # ns_log Notice "HEADER \n $header"
    set h [ns_set size $header]
    # ns_log Notice "HEADERS $h"
    set req [ns_set array $header]
    # ns_log Notice "$req"
    
    set dict [json::json2dict [ns_getcontent -as_file false]]
    #
    # Do something with the dict
    #
    # ns_log Notice "DICT $dict"

    array set arr $dict
    if {[array exists arr] && [array size arr] > 0} {
	
	# USER photo https://lh3.googleusercontent.com/a-/AOh14Gi3nN2uAObzfEkG1uCZttA3-PfyPC7BsdDMOXpEWg=s96-c email iuri.sampaio@gmail.com familyName Sampaio givenName Iuri name {Iuri Sampaio} id 110822063113186028142
	
	array set arr_user $arr(user)
	set user_id [party::get_by_email -email $arr_user(email)]

	set registered_p 0
	
	if { $user_id eq ""} {
	    # If user doesn't exists, then register it


	    # Pre-generate user_id for double-click protection
	    set user_id [db_nextval acs_object_id_seq]
	    set password [ad_generate_random_string]
	    array set creation_info [auth::create_user \
					 -user_id $user_id \
					 -username $arr_user(email) \
					 -email $arr_user(email) \
					 -first_names $arr_user(givenName) \
					 -last_name $arr_user(familyName) \
					 -password $password]


	    
	    
	    # Handle registration problems
	    switch $creation_info(creation_status) {
		ok {	    
		    #logs user in
		    # Add Google info $arr_user(id)
		    ad_user_login $user_id
		}
		default {}
	    }
	} else {
	    ad_user_login $user_id
	    set registered_p 1
	}

	if { $registered_p eq 1 } { 
	    acs_user::get -user_id $user_id -array user
	    
	    # ns_log Notice "[parray user] "
	    
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
		\"token\": \"$token\",
		\"user\": \{
		\"isVerified\": \"$user(email_verified_p)\",
		\"_id\": $user(user_id),
		\"firstName\": \"$user(first_names)\",
		\"lastName\": \"$user(last_name)\",
		\"email\": \"$user(email)\",
		\"password\": \"$token\", 
		\"phonenumber\": \"76543234567\", 
		\"country\": \"Brasil\", 
		\"city\": \"Salvador\",
		\"createdAt\": \"$user(creation_date)\",
		\"updatedAt\": \"$user(last_visit)\",
		\"__v\": 0
		\}
	    \}"

	} else {
	    set err_msg "Registration Error! Forbidden"
	    set status 403
	    set result "\{
              \"data\": \"\",
              \"errors\":\"$err_msg\","

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
