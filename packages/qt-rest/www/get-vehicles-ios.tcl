ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {limit:integer 20}
    {offset:integer 0}
    {date_from ""}
    {date_to ""}
    {where_clauses ""}
    {order "DESC"}
    {count:boolean true}
    {content_type "qt_vehicle"}
}


ns_log Notice "Running TCL script get-vehicles.tcl"

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
    db_0or1row select_count_vehicles "
	SELECT COUNT(*) AS total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = 'qt_vehicle'
	$where_clauses
    "

    db_0or1row select_vehicles_today_total {
	select COUNT(1) AS today_total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = :content_type
	AND o.creation_date::date = (now() - INTERVAL '5 hour')::date
    }

    db_0or1row select_vehicles_yesterday_total {
	select COUNT(1) AS yesterday_total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = :content_type
	AND o.creation_date::date >= (now() - INTERVAL '5 hour')::date - INTERVAL '48 hour'
	AND o.creation_date::date < (now() - INTERVAL '5 hour')::date - INTERVAL '24 hour'
    }

    db_0or1row select_vehicles_week_total {
	select COUNT(1) AS week_total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = :content_type
	AND o.creation_date BETWEEN (now() - INTERVAL '5 hour')::date - INTERVAL '6 day' AND (now() - INTERVAL '5 hour')::date + INTERVAL '1 day'
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
