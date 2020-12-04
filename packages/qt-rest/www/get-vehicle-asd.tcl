# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
    {plate:optional}
}


# Validate and Authenticate JWT
# qt::rest::jwt::validation_p

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	append where_clauses " AND creation_date::date >= :date_from::date "	
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {   
    if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	append where_clauses " AND creation_date::date <= :date_to::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}



set total_entries [db_string select_count_exits {
     SELECT COUNT(revision_id) FROM qt_vehicle_ti WHERE SPLIT_PART(description, ' ', 21) = 'Cam14'
} -default 0]

set total_exits [db_string select_count_exits {
    SELECT COUNT(revision_id) FROM qt_vehicle_ti  WHERE SPLIT_PART(description, ' ', 21) = 'Cam11'
} -default 0]


db_multirow avg_types select_avg_interval_per_type {
    WITH
    cte1 AS (
	     SELECT v1.title,
	     SPLIT_PART(v1.description, ' ', 25) AS type,
	     MIN(v1.creation_date::timestamp) AS min_entry
	     FROM qt_vehicle_ti v1
	     WHERE v1.creation_date::date > '2020-09-30'
	     AND v1.title != 'UNKNOWN'
	     AND SPLIT_PART(v1.description, ' ', 21) = 'Cam14'
	     GROUP BY v1.title, type
	     ORDER BY min_entry ASC
    ),
    cte2 AS (
	     SELECT v2.title,
	     SPLIT_PART(v2.description, ' ', 25) AS type,
	     MAX(v2.creation_date::timestamp) AS max_exit
	     FROM qt_vehicle_ti v2
	     WHERE v2.creation_date::date > '2020-09-30'
	     AND SPLIT_PART(v2.description, ' ', 21) = 'Cam11'
	     AND v2.title != 'UNKNOWN'	     
	     GROUP BY v2.title, type
	     ORDER BY max_exit ASC
    )
    SELECT cte1.type, AVG(cte2.max_exit - cte1.min_entry) AS diff
    FROM cte1, cte2
    WHERE cte2.max_exit BETWEEN cte1.min_entry AND cte1.min_entry + INTERVAL '30 minutes'
    GROUP BY cte1.type
    ORDER BY cte1.type    
} {    
    lappend avg_types "\"$type\": \{\"today\": \"$diff\", \"week\": \"$diff\", \"month\": \"$diff\"\},"    
}

set avg_types [string trimright $avg_types ","]

append result "\{\"total_entries\": $total_entries, \"total_exits\": $total_exits, \"avg_types\": \[$avg_types\]\}"



ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
