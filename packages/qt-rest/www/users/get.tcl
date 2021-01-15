# /packages/qt-rest/www/users/get-users.tcl
ad_page_contract {
    API REST method to return cr_items qt_face
} {
    {date_from:optional}
    {date_to:optional}
    {offset:integer 0}
    {limit:integer 10}
    {type ""}
}
ns_log Notice "Running TCL script get-person-graphics.tcl"

# Validate and Authenticate JWT
qt::rest::jwt::validation_p



set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type qt_face
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {set t [clock scan $date_from]} errmsg]} {
	append where_clauses " AND o.creation_date::date >= :date_from::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {
    if {![catch {set t [clock scan $date_to]} errmsg]} {
	append where_clauses " AND o.creation_date::date <= :date_to::date "
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


append result "\["




db_foreach select_users {
    SELECT user_id, first_names, last_name, email FROM cc_users u
    limit :limit
    offset :offset
} {

    append result "\{
	\"id\": $user_id,
	\"age\":54,
	\"gender\": \"M\",
	\"date\": \"2021-01-04\",
	\"time\": \"18:03:24\",
	\"phone\": \"+ 57 320 927 8742\",
	\"email\": \"$email\",
	\"first_names\": \"$first_names\",
	\"last_name\": \"$last_name\"
    \},"

}

set result [string trimright $result ","]


append result "\]"
ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
