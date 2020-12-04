ns_log Notice "Running REST upload-image"

# Validate and Authenticate JWT
# qt::rest::jwt::validation_p

set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

ns_log Notice "[ns_getcontent -as_file false]"

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
	#puts $fd [base64::decode $data]
	puts $fd [ns_base64decode -binary $data]
	close $fd
	
	set user_id $arr(user_id)
	set album_id [qt::rest::album::get_id -user_id $user_id -name "SharedImages"]

	# Retrieves album_id 
	#set album_id 4648
		
	#check permission
	permission::require_permission -party_id $user_id -object_id $album_id -privilege "pa_create_photo"
	set photo_id [pa_load_images \
			  -remove 1 \
			  -client_name "" \
			  -description "" \
			  -story "" \
			  -package_id [apm_package_id_from_key "photo-album"] \
			  -caption "" \
			  ${filename} $album_id $user_id]


	
	pa_flush_photo_in_album_cache $album_id
	permission::grant -party_id -1 -object_id $photo_id -privilege read
	
	photo_album::photo::get -photo_id $photo_id -array photo
	ns_log Notice "[parray photo]"
	
	
	set result "\{\"url\": \"https://dashboard.qonteo.com/photo-album/images/$photo(base_image_id)\"\}"
	
	ns_return 200 "application/json;" $result  
	ad_script_abort
	
    }

    
    ad_return_complaint 1 "Bad HTTP Request: [ns_conn method]"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."

} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort
