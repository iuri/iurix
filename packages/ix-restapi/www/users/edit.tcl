ad_page_contract {
}

ns_log Notice "Running TCL script users/edit"


ns_log Notice " METHOD [ns_conn method]"
set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"
set token [lindex [ns_set get $header authorization] 1]
ns_log Notice "TOKEN $token"

set token [split $token "."]
set header1 [ns_base64decode [lindex $token 0]]
set payload [ns_base64decode [lindex $token 1]]
set hmac_secret [lindex $token 2]
ns_log Notice "TOKEN $token \n
HEADER $header1 \n
PAYLOAD $payload \n
SECRET $hmac_secret \n"

#
# VErifying HMAC, one needs the key and data as well
#
set hmac_verified_p 0

set hmac_vrf [ns_crypto::hmac string -digest sha256 "Abracadabra" "What is the magic word?"]
ns_log Notice "VRF $hmac_vrf"
if {$hmac_secret eq $hmac_vrf} {
    set hmac_verified_p 1
}

ns_log Notice "VERYF $hmac_verified_p"
set dict [json::json2dict [ns_getcontent -as_file false]]
#
# Do something with the dict
#
 #   ns_log Notice "DICT $dict"
# ambiguous option "file": must be acceptedcompression, auth, authpassword, authuser, channel, clientdata, close, compress, content, contentfile,    
array set arr $dict


set content [ns_getcontent -as_file false]
ns_log notice "CONTENT $content"


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


if {[exists_and_not_null token]} {
    set content [split $content ","]
    foreach elem $content {
	set elem [split $elem ":"]
	set var [lindex $elem 0]
	set val [lindex $elem 1]
#	ns_log Notice "ELEM $var | $val"
    }
    
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
    
    
# if {[ns_conn method] eq "PULL"} {}
# ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
# ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
# ad_script_abort

   