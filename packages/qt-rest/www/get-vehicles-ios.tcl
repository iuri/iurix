ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {limit:integer 20}
    {offset:integer 0}
    {date_from ""}
    {date_to ""}
    {order "DESC"}
    {count:boolean true}
}


ns_log Notice "Running TCL script get-vehicles.tcl"
set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type qt_vehicle
set where_clauses ""


if {[exists_and_not_null date_from] } {
    if {[catch { set timestamp [clock scan $date_from] } errmsg]} {   
	ns_respond -status 400 -type "text/plain" -string $errmsg
	ad_script_abort   
    } else {
        #        AND cr.creation_date > now() - INTERVAL '2 day'
	append where_clauses " AND o.creation_date >= '${date_from}' "
    }
}

if {[exists_and_not_null date_to]} {
    if {[catch { set timestamp [clock scan $date_to] } errmsg]} {   
	ns_respond -status 400 -type "text/plain" -string $errmsg
	ad_script_abort    
    } else {
	#    AND cr.creation_date < now() - INTERVAL '1 day'
	append where_clauses " AND o.creation_date <= '${date_to}' "
    }
}


if {$count eq true} {
    set instant_data [db_list_of_lists select_instant_data {
	SELECT
	date_trunc('hour', o.creation_date) AS hour,
	COUNT(1) AS total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = :content_type
	AND date_trunc('month', o.creation_date::date) = date_trunc('month',:creation_date::date)
	GROUP BY 1 ORDER BY hour;
    }]

    set total 0
    set today_total 0
    set yesterday_total 0
    
    set today $creation_date
    set yesterday [db_string select_yesterday { SELECT (:creation_date::timestamp - INTERVAL '1 day')::date FROM dual}]
    set i [expr [llength $instant_data] - 1]
    while {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today || [lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today} {
	    set today_total [expr $today_total + [lindex [lindex $instant_data $i] 1]]							     
	}
	if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	    set yesterday_total [expr $yesterday_total + [lindex [lindex $instant_data $i] 1]]
	}
	set i [expr $i - 1]
    }
    
    if {$yesterday_total eq "" || $yesterday_total eq 0} {
	set yesterday_total [db_string select_yesterday {
	    SELECT COUNT(1) AS total
	    FROM cr_items ci, acs_objects o
	    WHERE ci.item_id = o.object_id
	    AND ci.content_type = :content_type
	    AND o.creation_date::date = :creation_date::date - INTERVAL '1 day'
	} -default 1]
    }
    
    # To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
    set week_total 0
    set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
    set i $dow
    set j 0
    while {$i>-1} {
	set elem [lindex $instant_data [expr [llength $instant_data] - $j -1]]
	set aux $elem
	while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	    set week_total [expr $week_total + [lindex $aux 1]]	
	    incr j
	    set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]      
	}
	set i [expr $i - 1]    
    }
    	  

    
    
    
    
    append result "\{\"total\": $total, \"today\": $today_total, \"yesterday\": $yesterday_total, \"week\": $week_total\}"

} else {
    set result "\{\"vehicles\": \["

    db_foreach select_vehicles "
	SELECT ci.name, cr.description, o.creation_date
	FROM cr_items ci, cr_revisions cr, acs_objects o
	WHERE ci.item_id = cr.item_id
	AND ci.item_id = o.object_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = 'qt_vehicle'
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
