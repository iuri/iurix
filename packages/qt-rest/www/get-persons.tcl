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

    db_0or1row select_today_total {
	select COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
	FROM cr_items ci, cr_revisions cr, acs_objects o
	WHERE ci.item_id = o.object_id
        AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	AND o.creation_date::date = (now() - INTERVAL '5 hour')::date
    } -column_array today

    db_0or1row select_yesterday_total {
	select COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
	FROM cr_items ci, cr_revisions cr, acs_objects o
	WHERE ci.item_id = o.object_id
        AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	AND o.creation_date::date >= (now() - INTERVAL '5 hour')::date - INTERVAL '48 hour'
	AND o.creation_date::date < (now() - INTERVAL '5 hour')::date - INTERVAL '24 hour'
    } -column_array yesterday

    db_0or1row select_week_total {
	select COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
	FROM cr_items ci, cr_revisions cr, acs_objects o
	WHERE ci.item_id = o.object_id
        AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	AND o.creation_date BETWEEN (now() - INTERVAL '5 hour')::date - INTERVAL '6 day' AND (now() - INTERVAL '5 hour')::date + INTERVAL '1 day'
    } -column_array week


    append result "\{
	\"today\": \{\"total\": $today(total), \"female\": $today(female), \"male\": $today(male)\},
	\"yesterday\": \{\"total\": $yesterday(total), \"female\": $yesterday(female), \"male\": $yesterday(male)\},
	\"week\": \{\"total\": $week(total), \"female\": $week(female), \"male\": $week(male)\}
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
