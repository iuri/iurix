ad_page_contract {} {}

qt::rest::jwt::validation_p

set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"

if {[ns_conn method] eq "POST"} {
    
#    ns_log Notice "BODY \n  [ns_getcontent -as_file false]"
    package req json
    set dict [json::json2dict [ns_getcontent -as_file false]]
    ns_log Notice "*** ***** *** ** \n DICT \n $dict"
    
    lassign $dict p photo_id u user_id
    ns_log Notice "PHOTO $photo_id"
    if {$photo_id > 0 && $user_id > 0 } {
	
	# to delete a photo need delete on photo and write on parent album 
	set album_id [db_string get_parent_album "select parent_id from cr_items where item_id = :photo_id"]

	permission::require_permission -party_id $user_id -object_id $photo_id -privilege delete
	permission::require_permission -party_id $user_id -object_id $album_id -privilege write
	
	db_transaction {
	    db_exec_plsql drop_image {
		select pa_photo__delete(:photo_id);
	    }
	}
	
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
