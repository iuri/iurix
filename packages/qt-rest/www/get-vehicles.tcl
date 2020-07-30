ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {limit:integer 20}
    {offset:integer 0}
    {date_from ""}
    {date_to ""}
    {where_clauses ""}
}
    


if {$date_from ne "" && [catch { set timestamp [clock scan $date_from] } errmsg]} {   
    ns_respond -status 400 -type "text/plain" -string $errmsg
    ad_script_abort   
} else {
        #        AND cr.creation_date > now() - INTERVAL '2 day'
    append where_clauses "AND o.creation_date >= '${date_from}'"
}

if {$date_to ne "" && [catch { set timestamp [clock scan $date_to] } errmsg]} {   
    ns_respond -status 400 -type "text/plain" -string $errmsg
    ad_script_abort    
} else {
    #    AND cr.creation_date < now() - INTERVAL '1 day'
    append where_clauses "AND o.creation_date <= '${date_to}'"
}


set result "\{\"vehicles\": \["

db_foreach select_vehicles "
    SELECT ci.name, cr.description, o.creation_date
    FROM cr_items ci, cr_revisions cr, acs_objects o
    WHERE ci.item_id = cr.item_id
    AND ci.item_id = o.object_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_vehicle'
    $where_clauses
    ORDER BY o.creation_date ASC
    LIMIT $limit OFFSET $offset
    
" {


    append result "\{\"name\": \"$name\", \"creation_date\": \"$creation_date\", \"description\": \"$description\"\},"
}


set result [string trimright $result ","]
append result "\]\}"

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
