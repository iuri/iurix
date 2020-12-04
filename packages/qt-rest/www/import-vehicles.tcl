
ns_log Notice "Running TCL script import-vehicle.tcl"

if { [ns_conn method] eq "POST"} {
    
    qt::rest::jwt::validation_p

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
	    set latest_date [lindex [split [db_string select_max_date {
		SELECT (creation_date - INTERVAL '5 hours')::timestamp FROM qt_vehicle_ti ORDER BY creation_date DESC LIMIT 1
		-- SELECT MAX((creation_date - INTERVAL '5 hours')::timestamp) FROM qt_vehicle_ti
	    } -default ""] "."] 0]
	    
	    
	    
	    ns_respond -status 200 -type "text/plain" -string "$latest_date"
	} else {
	    # ns_log Notice "NEWCONTENT $content"
	    # ns_log Notice "ADD VEHICLES"
	    qt::dashboard::vehicle::import_new
	}
    }
} else {
    #ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "HTML ERROR  405: Method not allowed/supported."
}


ad_script_abort
    
