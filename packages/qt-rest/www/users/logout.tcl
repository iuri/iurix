ns_log Notice "Running TCL script user/login"

if {[ns_conn method] eq "POST"} {
    package req json
    ns_log Notice "[ns_getcontent -as_file false]"
    set dict [json::json2dict [ns_getcontent -as_file false]]
    #
    # Do something with the dict
    #
    ns_log Notice "DICT $dict"
    array set arr $dict
    if {[array exists arr] && [array size arr] > 0} {

	
	set err_msg ""
	set status 200
	set result "ok"

    } else {
	set err_msg "AUTH FAILED. Unauthorized"
	set status 401
	set result "\{\"data\": \"\", \"errors\":\"$err_msg\"\}"
    }

    
    ns_respond -status $status -type "application/json" -string $result  


} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
}

ad_script_abort
