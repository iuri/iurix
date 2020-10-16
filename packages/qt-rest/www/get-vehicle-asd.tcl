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



set total_asd "00:00"
set count_asd 0

db_multirow entries select_entries {
    SELECT revision_id, title, creation_date
    FROM qt_vehicle_ti
    WHERE creation_date::date > '2020-09-30'
    AND  SPLIT_PART(description, ' ', 21) = 'Cam14'
    ORDER BY creation_date ASC
} {
    

    set min_entry [db_string select_min_entry {
	SELECT MIN(creation_date)
	FROM qt_vehicle_ti
	WHERE title = :title
	AND SPLIT_PART(description, ' ', 21) = 'Cam14'
	AND creation_date::timestamp BETWEEN :creation_date::timestamp AND :creation_date::timestamp + INTERVAL '1 hour' ;
    } -default ""]
    
    set max_exit [db_string select_max_exit {
	SELECT MAX(creation_date)
	FROM qt_vehicle_ti
	WHERE title = :title
	AND SPLIT_PART(description, ' ', 21) = 'Cam11'
	AND creation_date::timestamp BETWEEN :creation_date::timestamp AND :creation_date::timestamp + INTERVAL '1 hour' ;
    } -default ""]
    
    set asd [db_string diff_timestamp { SELECT :max_exit::timestamp - :min_entry::timestamp FROM dual } -default ""]
    # ns_log Notice "REVISIONID $revision_id \n PAIRED EXIT: $max_exit" 
    
    
    if {$asd ne ""} {
	incr count_asd
	append detailed_entries "\{\"plate\": \"$title\", \"entry_datetime\": \"$creation_date\", \"exit_datetime\": \"$max_exit\", \"duration\": \"$asd\"\},"
    } else {
	# append detailed_entries "\{\"plate\": \"$title\", \"entry_datetime\": \"$creation_date\"\},"
    }
    
}

set detailed_entries [string trimright $detailed_entries ","]
set total_entries [set entries:rowcount]

ns_log Notice "TOTAL $total_asd | $count_asd"

#db_multirow exits select_exits {
#--     SELECT title, creation_date FROM qt_vehicle_ti WHERE SPLIT_PART(description, ' ', 21) = 'Cam11'
#} {
#    append detailed_exits "\{\"plate\": \"$title\", \"datetime\": \"$creation_date\"\},"
#}
#set detailed_exits [string trimright $detailed_exits ","]
#set total_exits [set exits:rowcount]
set total_exits [db_string select_count_exits {
     SELECT COUNT(revision_id) FROM qt_vehicle_ti WHERE SPLIT_PART(description, ' ', 21) = 'Cam11'
} -default 0]



#append result "\{\"total_entries\": $total_entries, \"total_exits\": $total_exits, \"entries\": \[$detailed_entries\], \"exits\": \[$detailed_exits\]\}"
append result "\{\"total_entries\": $total_entries, \"total_exits\": $total_exits, \"entries\": \[$detailed_entries\]\}"




ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
