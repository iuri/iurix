ad_page_contract {} {
    data
    file
    {file.tmpfile}
}

ns_log Notice "Running REST upload-photo"
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
    
    set header [ns_conn header]
    ns_log Notice "HEADER \n $header"
    set h [ns_set size $header]
    ns_log Notice "HEADERS $h"
    set req [ns_set array $header]
    ns_log Notice "$req"
    
    #    ns_log Notice "BODY \n  [ns_getcontent -as_file false]"
    package req json
    #set dict [json::json2dict [ns_getcontent -as_file false]]
    set dict [json::json2dict $data]    
    #   ns_log Notice "*** ***** *** ** \n DICT \n $dict"
    
    array set arr $dict
    ns_log Notice "BODY \n [parray arr]"
    if {[array exists arr] && [array size arr] > 0} {
	
	ns_log Notice "USERID $arr(user_id)"
	ns_log Notice "$arr(mime_type)"
	ns_log Notice "[lindex $arr(person_name) 1]"
	ns_log Notice ""
	
	#check permission
	set album_id 4648
	set user_id 704
	permission::require_permission -party_id $user_id -object_id $album_id -privilege "pa_create_photo"
	set new_photo_ids [pa_load_images \
			       -remove 1 \
			       -client_name $file \
			       -description "[array get arr]" \
			       -story "" \
			       -package_id [apm_package_id_from_key "photo-album"] \
			       -caption [lindex $arr(person_name) 1] \
			       ${file.tmpfile} $album_id $user_id]
	
	pa_flush_photo_in_album_cache $album_id

	
	
	
	set result "ok"
	set status 200
	# doc_return 200 "application/json" $result    
	# ns_return -binary $status "application/json;" -header $headers result
	ns_respond -status $status -type "application/json" -string $result  

    }

    
    ad_return_complaint 1 "Bad HTTP Request: [ns_conn method]"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."

} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort
