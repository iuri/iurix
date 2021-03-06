ns_log Notice "Running script poeple-report"

if {[ix_rest::jwt::validation_p] eq 0} {
    ad_return_complaint 1 "Bad HTTP Request: Invalid Token!"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."
    ad_script_abort
}



proc formatTimeInterval {intervalSeconds} {
    # *Assume* that the interval is positive
    set s [expr {$intervalSeconds % 60}]
    set i [expr {$intervalSeconds / 60}]
    set m [expr {$i % 60}]
    set i [expr {$i / 60}]
    set h [expr {$i % 24}]
    set d [expr {$i / 24}]
    return [format "%+d:%02d:%02d:%02d" $d $h $m $s]
}





if {[ns_conn method] eq "GET"} {
    set i 1
    db_foreach select_faces {
	SELECT ci.item_id, ci.name, cr.description, cr.title
	FROM cr_items ci, cr_revisions cr
	WHERE ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = 'qt_face'
    } {
	set epoch [lindex $description [expr [lsearch $description timestamp] + 1]]	
	set creation_date [db_string select_timestamp {
	    SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :epoch * INTERVAL '1 second';

	}]
	ns_log Notice "CREATION DATE $creation_date"
	set creation_timestamp [clock scan [lindex [split $creation_date "."] 0]]

	set cur_date [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	set cur_timestamp [clock scan $cur_date]
	ns_log Notice "CUR DATE $cur_date"
	
	set date1 [clock scan [lindex [split $creation_timestamp "."] 0]]
	set date2 [clock scan $cur_timestamp]
	ns_log Notice "DATES $date1 $date2"
	set diff [expr $date2 - $date1]
	set t [formatTimeInterval $diff]
       
	set t [qt::util::interval_ymdhs $date2 $date1]
	ns_log Notice "$item_id $name \n $title \n $description \n timestamp $t"
	
	append data ""
    	incr i
	
    }

    append data "\"total\": $i"
    
    

    set result "\{
	\"data\": {$data},
	\"errors\": \"cTree does not exist!\",
	\"meta\": \{
	    \"copyright\": \"Copyright 2019 Collaboration Tree http://www.innovativefuture.org/collaboration-tree/ \",
	    \"application\": \"CTree Rest API\",
	    \"version\": \"0.1d\",
	    \"id\": \"HTTP/1.1 200 Authorized\",
	    \"status\": \"true\",
	    \"message\": \"Successfull request. No data!\"
	\}
    \}"


    
	set result "ok"
	set status 200
	# doc_return 200 "application/json" $result    
	# ns_return -binary $status "application/json;" -header $headers result
	ns_respond -status $status -type "application/json" -string $result  


} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort

