
ns_log Notice "Running REST upload-image"

# Validate and Authenticate JWT
qt::rest::jwt::validation_p


if {[ns_conn method] eq "POST"} {

    

    
    #    ns_log Notice "BODY \n  [ns_getcontent -as_file false]"
    package req json
    set dict [json::json2dict [ns_getcontent -as_file false]]
#    ns_log Notice "*** ***** *** ** \n DICT \n $dict"

    
    # set dict [json::json2dict $data]    
    
    array set arr $dict
    # ns_log Notice "BODY \n [parray arr]"
    if {[array exists arr] && [array size arr] > 0} {

	
	array set arr $arr(data)


	ns_log Notice "USER ID $arr(user_id) \n FROM $arr(date_from) \n TO $arr(date_to) "

	lassign [split $arr(image) ","] header data
	## NOTE: Much better data validation is required here
	switch -exact $header {
	    "data:image/png;base64" {
		set mime_type "image/png"
	    }
	    default {
		error "unsupported type"
	    }
	}

	set filename [ns_mktemp /tmp/base64-image-XXXXXX]

	set fd [open $filename w]
	fconfigure $fd -translation binary
	package require base64
	puts $fd [base64::decode $data]
	close $fd

	ns_returnfile 200 $mime_type $filename


	
#	ns_log Notice "TMPFILE $tmp_file"


	
	
#	set result "https://dashboard.qonteo.com/photo-album/base-photo?photo_id=951463"
#	set status 200
	# doc_return 200 "application/json" $result    
	# ns_return -binary $status "application/json;" -header $headers result
#	ns_respond -status $status -type "application/json" -string $result  

    }

    
    ad_return_complaint 1 "Bad HTTP Request: [ns_conn method]"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."

} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort
