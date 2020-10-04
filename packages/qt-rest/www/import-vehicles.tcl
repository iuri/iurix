
ns_log Notice "Running TCL script import-vehicle.tcl"

if { [ns_conn method] eq "POST"} {
    set header [ns_conn header]
    ns_log Notice "HEADER \n $header"
    set h [ns_set size $header]
    ns_log Notice "HEADERS $h"
    set req [ns_set array $header]
    ns_log Notice "$req"

    qt::rest::jwt::validation_p
    
    set token [lindex [ns_set get $header Authorization] 1]
    if {$token eq ""} {
	set token [lindex [ns_set get $header authorization] 1]
    }
    ns_log Notice "TOKEN $token"
    
    set content [ns_getcontent -as_file false]
    if {$content eq ""} {
	# ad_return_complaint 1 "HTTP ERROR 422: Unprocessable Entity"
	ns_respond -status 422 -type "text/html" -string "HTTP ERROR 422: Unprocessable Entity"	
    } else {	
	# ns_log Notice "NEWCONTENT $content"	
	package req json
	set dict [json::json2dict [ns_getcontent -as_file false]]
	# ns_log Notice "DICT $dict"
	
	if {[lindex $dict 0] eq "request" || [lindex $dict 1] eq "true"} {
	    set latest_date [db_string select_max_date {
		SELECT MAX(o.creation_date::timestamp) FROM cr_items ci, acs_objects o WHERE ci.item_id = o.object_id AND ci.content_type = 'qt_vehicle'
	    } -default ""]
	    
	    
	    
	    ns_respond -status 200 -type "text/plain" -string "$latest_date"
	} else {
	    #ns_log Notice "NEWCONTENT $content"
	    ns_log Notice "ADD VEHICLES"
	    qt::dashboard::vehicle::import_new
	}
    }
} else {
    #ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "HTML ERROR  405: Method not allowed/supported."
}


ad_script_abort
    
