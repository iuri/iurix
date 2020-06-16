# /packages/ix-restapi/tcl/ix-rest-procs.tcl
#
# Copyright (C) 2020 IURIX
#
# All rights reserved. Please check
# https:/iurix.com for details

ad_library {
    REST Webservice API
    Utility functions - Library to support IURIX WS API

    @author Iuri de Araujo [iuri@iurix.com]
    @creation-date Sat May 23 17:16:42 2020 
}

namespace eval ix_rest {}
namespace eval ix_rest::user {}

ad_proc ix_rest::user::edit {} {
    Updates user data

    @return
    @author Iuri de Araujo
} {
    
    ns_log Notice "Running ad_proc ix_rest::user::edit"

    if {[ns_conn method] eq "PUT"} {
	
	set header [ns_conn header]
	ns_log Notice "HEADER \n $header"
	set h [ns_set size $header]
	ns_log Notice "HEADERS $h"
	set req [ns_set array $header]
	ns_log Notice "$req"

	set myform [ns_getform]

	if {[string equal "" $myform]} {
	    #    ns_log Notice "No Form was submited"
	} else {
	    #    ns_log Notice "FORM"
	    ns_set print $myform
	    for {set i 0} {$i < [ns_set size $myform]} {incr i} {
		set varname [ns_set key $myform $i]
		set varvalue [ns_set value $myform $i]
		ns_log Notice " $varname - $varvalue"
	    }
	}
	
	ns_log Notice " METHOD [ns_conn method]"

	set token [lindex [ns_set get $header authorization] 1]
	ns_log Notice "TOKEN $token"
	set token [split $token "."]
	set header1 [ns_base64decode [lindex $token 0]]
	set payload [ns_base64decode [lindex $token 1]]
	set secret [lindex $token 2]

	set vfy [ns_crypto::hmac string -digest sha256 "Abracadabra" $secret]
	
	ns_log Notice "HEADER $header1 \n PAYLOAD $payload \n $secret \n VFY $vfy"

	
	if {[exists_and_not_null token]} {
	    #ns_log Notice "EMAIL [parray arr] \n"
	    set status 200
	    set result "\{
              \"data\": \"\",
              \"errors\":\"\","
       
	    # Handle authentication problems
	} else {
	    set err_msg "AUTH FAILED. Unauthorized"
	    set status 401
	    set result "\{
              \"data\": \"\",
              \"errors\":\"$err_msg\","
	    #break
	    
	}

	append result "
	    \"meta\": \{ 
	  	  \"copyright\": \"Copyright 2020 Qonteo\",
		  \"application\": \"Qonteo Rest API\",
		  \"version\": \"0.1d\",
		  \"id\": \"HTTP/1.1 200 HTML\",
		  \"status\": \"true\",
		  \"message\": \"User successfully updated\"
	    \}
        \}"  


	
	# doc_return 200 "application/json" $result    
	# ns_return -binary $status "application/json;" -header $headers result
	ns_respond -status $status -type "application/json" -headers $header -string $result  
	
	
	
    } else {
	ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
	ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
	ad_script_abort

    }    

    return 
}





ad_proc ix_rest::user::edit_form {} {
    Updates user data

    Body format JSON
    @return
    @author Iuri de Araujo
} {
    
    ns_log Notice "Running ad_proc ix_rest::user::edit"

    if {[ns_conn method] eq "PUT"} {
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
	    ns_log Notice "EMAIL [parray arr] \n"
	    set status 200
	    set result "\{
              \"data\": \"\",
              \"errors\":\"\","
       
	    # Handle authentication problems
	} else {
	    set err_msg "AUTH FAILED. Unauthorized"
	    set status 401
	    set result "\{
              \"data\": \"\",
              \"errors\":\"$err_msg\","
	    #break
	    
	}

	append result "
	    \"meta\": \{ 
	  	  \"copyright\": \"Copyright 2020 Qonteo\",
		  \"application\": \"Qonteo Rest API\",
		  \"version\": \"0.1d\",
		  \"id\": \"HTTP/1.1 200 HTML\",
		  \"status\": \"true\",
		  \"message\": \"User successfully updated\"
	    \}
        \}"  


	
	# doc_return 200 "application/json" $result    
	# ns_return -binary $status "application/json;" -header $headers result
	ns_respond -status $status -type "application/json" -headers $header -string $result  
	
	
	
    } else {
	ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
	ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
	ad_script_abort

    }    

    return 
}
