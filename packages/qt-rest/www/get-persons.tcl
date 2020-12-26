ad_page_contract {
    API REST method to return cr_items qt_face
} {
    {limit:integer 20}
    {offset:integer 0}
    {date_from:optional}
    {date_to:optional}
    {order "DESC"}
    {count:boolean true}
}


ns_log Notice "Running TCL script get-persons.tcl"
ns_log Notice "GROUPID $group_id "

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type qt_face
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {set t [clock scan $date_from]} errmsg]} {
	append where_clauses " AND o.creation_date::date >= :date_from::date "
	
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {
    if {![catch {set t [clock scan $date_to]} errmsg]} {
	append where_clauses " AND o.creation_date::date <= :date_to::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
} else {
    	append where_clauses " AND o.creation_date::date <= :creation_date::date "
}


if {$count eq true} {   

    set instant_data [db_list_of_lists select_instant_data {
	SELECT date_trunc('hour', o.creation_date) AS hour,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
	FROM cr_items ci, acs_objects o, cr_revisions cr
	WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	AND date_trunc('month', o.creation_date::date) = date_trunc('month', :creation_date::date)
	GROUP BY 1 ORDER BY hour;
    }]
    
    set today_total 0
    set today_female 0
    set today_male 0
    set yesterday_total 0
    set yesterday_female 0
    set yesterday_male 0
    
    set today $creation_date
    set yesterday [db_string select_yesterday { SELECT (:creation_date::timestamp - INTERVAL '1 day')::date FROM dual}]
    set i [expr [llength $instant_data] - 1]
    while {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today || [lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today} {
	    set today_total [expr $today_total + [lindex [lindex $instant_data $i] 1]]							     
	    set today_female [expr $today_female + [lindex [lindex $instant_data $i] 2]]
	    set today_male [expr $today_male + [lindex [lindex $instant_data $i] 3]]
	}
	if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	    set yesterday_total [expr $yesterday_total + [lindex [lindex $instant_data $i] 1]]
	    set yesterday_female [expr $yesterday_female + [lindex [lindex $instant_data $i] 2]]
	    set yesterday_male [expr $yesterday_male + [lindex [lindex $instant_data $i] 3]]
	}
	set i [expr $i - 1]
    }  
    
    # To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
    set week_female 0
    set week_male 0
    set week_total 0
    set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
    set i $dow
    set j 0
    while {$i>-1} {
	set elem [lindex $instant_data [expr [llength $instant_data] - $j -1]]
	set aux $elem
	while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	    set week_total [expr $week_total + [lindex $aux 1]]
	    set week_female [expr $week_female + [lindex $aux 2]]
	    set week_male [expr $week_male + [lindex $aux 3]]
	    
	    incr j
	    set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]
	    
	}
	set i [expr $i - 1]    
    }
    
    append result "\{
	\"today\": \{\"total\": $today_total, \"female\": $today_female, \"male\": $today_male\},
	\"yesterday\": \{\"total\": $yesterday_total, \"female\": $yesterday_female, \"male\": $yesterday_male\},
	\"week\": \{\"total\": $week_total, \"female\": $week_female, \"male\": $week_male\}
    \}"
    
  
} else {
    

    set result "\{\"persons\": \["

    db_foreach select_persons_data "
	SELECT ci.name, cr.description, o.creation_date
	FROM cr_items ci, cr_revisions cr, acs_objects o
	WHERE ci.item_id = cr.item_id
	AND ci.item_id = o.object_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = 'qt_face'
	$where_clauses
	ORDER BY o.creation_date $order
	LIMIT $limit OFFSET $offset	
    " {
	
	
	append result "\{\"name\": \"$name\", \"creation_date\": \"$creation_date\", \"description\": \"$description\"\},"
    }       


    set result [string trimright $result ","]
    append result "\]\}"
}



ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
