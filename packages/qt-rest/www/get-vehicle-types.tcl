# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
}
ns_log Notice "Running TCL script get-vehicle-graphics.tcl"


# Validate and Authenticate JWT
qt::rest::jwt::validation_p

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type "qt_vehicle"
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	append where_clauses " AND o.creation_date::date >= :date_from::date "	
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {   
    if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	append where_clauses " AND o.creation_date::date <= :date_to::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}



set datasource [db_list_of_lists  select_types_count "
    SELECT o.creation_date::date AS date, split_part(cr.description, ' ', 25) AS type, COUNT(1) AS total FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id AND ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle' $where_clauses GROUP BY date, type, 1 ORDER BY date;
"]


append result "\{\"types\":\["



foreach {datetime type total} $datasource {
    ns_log Notice "$datetime $type $total"
    switch $type {
	"car"
	""
    }
}


set result [string trimright $result ","]
append result "\]\}"







# ns_log Notice "INSTANTDATA $datasource "

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
