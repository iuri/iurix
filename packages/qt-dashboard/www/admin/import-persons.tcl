ad_page_contract {}


ns_log Notice "Running TCL script import_persons.tcl"

set fp [open "/tmp/candidates.csv" r]
set i 0
while {![eof $fp]} {
    # set line [read $fp]
    set line [gets $fp]
    ns_log Notice "LINE $i $line"
    
    set face [split $line ","]
    # ns_log Notice "FACE $face"
    if {[llength $face] > 0 } {
	ns_log Notice "LENGTH [llength $face]"
	
	foreach {field value} $face {
	    #ns_log Notice "$field $value"
	    lappend data [lindex $field 0] [lindex $value 0]
	}

	set creation_date [dict get $data creation_date]
	if {[catch { set timestamp [clock scan $creation_date]} errmsg]} {
	    ns_log Warning "Timestamp Error: $errmsg"
	    set timestamp [clock scan "[lindex [split [lindex $creation_date 0] " "] 0] 18:15:00"]
	    
	}
	
	set json "result {face {{attributes {age [dict get $data age] eyeglasses 0 gender [dict get $data gender] emotions {estimations {anger [dict get $data anger] disgust [dict get $data disgust] fear [dict get $data fear] happiness [dict get $data happiness] neutral [dict get $data neutral] sadness [dict get $data sadness] surprise [dict get $data surprise]} predominant_emotion [dict get $data predominant_emotion]}} id [dict get $data id] score [dict get $data score]}}} timestamp $timestamp source descriptors event_type extract authorization {token_id df498422-6331-4580-ac63-aac5746eacab token_data PRIMAX}"
	#ns_log Notice "JSON \n $json"
	
	qt::dashboard::person::import -json_text $json

	incr i
    }    
}


set item [db_list select_item {
    SELECT cr.item_id, SPLIT_PART(cr.description, ' ', 4) as desc FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id AND ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_face' AND EXTRACT(MONTH FROM o.creation_date) = EXTRACT(MONTH FROM '2020-08-08'::date) LIMIT 1 ;
}]

if {[lindex $item 1] eq "N"} {
    content::item::delete -item_d [lindex $item 0]
}

close $fp
