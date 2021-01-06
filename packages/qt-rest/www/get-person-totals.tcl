# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {group_id:integer 0}
    {date_from:optional}
    {date_to:optional}
    {age_range_p:boolean,optional}
    {heatmap_p:boolean,optional}
}
ns_log Notice "Running TCL script get-person-graphics.tcl"

# Validate and Authenticate JWT
qt::rest::jwt::validation_p
ns_log Notice "GROUPID $group_id "
# group::get -group_id $group_id -array group
# ns_log Notice "[parray group]"




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




# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly "
    SELECT date_trunc('day', o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS male
    FROM qt_face_tx f, acs_objects o WHERE f.item_id = o.object_id
    AND o.creation_date::date > :creation_date::date - INTERVAL '7 days'
    AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}'
    GROUP BY 1 ORDER BY day"]


ns_log Notice "Weekly data $weekly_data"

set today_totals1 [lindex $weekly_data end]
ns_log Notice "TODAY $today_totals1"

set yesterday_totals1 [lindex $weekly_data [expr [llength $weekly_data] -2]]
ns_log Notice "YESTERDAY $yesterday_totals1"

set week_totals1 [list 0 0 0]
foreach elem $weekly_data {
    ns_log Notice "ELEM $elem"
    set week_totals1 [list \
			 [expr [lindex $week_totals1 0] + [lindex $elem 1]] \
			 [expr [lindex $week_totals1 1] + [lindex $elem 2]] \
			 [expr [lindex $week_totals1 2] + [lindex $elem 3]] ]
}

db_0or1row select_totals_totem1 "
    SELECT
    COUNT(1) AS total1,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS total_female1,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS total_male1
    FROM qt_face_tx f, acs_objects o WHERE f.item_id = o.object_id
    AND SPLIT_PART(f.description, ' ', 37) = 'CCPN001\}'"



# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly "
    SELECT date_trunc('day', o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS male
    FROM qt_face_tx f, acs_objects o WHERE f.item_id = o.object_id
    AND o.creation_date::date > :creation_date::date - INTERVAL '7 days'
    AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}'
    GROUP BY 1 ORDER BY day"]


ns_log Notice "Weekly data $weekly_data"

set today_totals2 [lindex $weekly_data end]
ns_log Notice "TODAY $today_totals2"

set yesterday_totals2 [lindex $weekly_data [expr [llength $weekly_data] -2]]
ns_log Notice "YESTERDAY $yesterday_totals2"

set week_totals2 [list 0 0 0]
foreach elem $weekly_data {
    ns_log Notice "ELEM $elem"
    set week_totals2 [list \
			 [expr [lindex $week_totals2 0] + [lindex $elem 1]] \
			 [expr [lindex $week_totals2 1] + [lindex $elem 2]] \
			 [expr [lindex $week_totals2 2] + [lindex $elem 3]] ]
}

db_0or1row select_totals_totem1 "
    SELECT
    COUNT(1) AS total2,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS total_female2,
    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS total_male2
    FROM qt_face_tx f, acs_objects o WHERE f.item_id = o.object_id
    AND SPLIT_PART(f.description, ' ', 37) = 'CCPN002\}'"





append result "\{
    \"totemone\": \{	
	\"today\": \{
	    \"count\": [lindex $today_totals1 1],
	    \"female\": [lindex $today_totals1 2],
	    \"male\": [lindex $today_totals1 3]
	\},
	\"yesterday\": \{
	    \"total\": [lindex $yesterday_totals1 1],
	    \"female\": [lindex $yesterday_totals1 2],
	    \"male\": [lindex $yesterday_totals1 3]
	\},
	\"week\": \{
	    \"total\": [lindex $week_totals1 0],
	    \"female\": [lindex $week_totals1 1],
	    \"male\": [lindex $week_totals1 2]
	\},
	\"total\": \{
	    \"count\": $total1,
	    \"female\": $total_female1,
	    \"male\": $total_male1
	\}
    \},
    \"totemtwo\": \{	
	\"today\": \{
	    \"count\": [lindex $today_totals2 1],
	    \"female\": [lindex $today_totals2 2],
	    \"male\": [lindex $today_totals2 3]
	\},
	\"yesterday\": \{
	    \"total\": [lindex $yesterday_totals2 1],
	    \"female\": [lindex $yesterday_totals2 2],
	    \"male\": [lindex $yesterday_totals2 3]
	\},
	\"week\": \{
	    \"total\": [lindex $week_totals2 0],
	    \"female\": [lindex $week_totals2 1],
	    \"male\": [lindex $week_totals2 2]
	\},
	\"total\": \{
	    \"count\": $total2,
	    \"female\": $total_female2,
	    \"male\": $total_male2
	\}
    \},
    \"totemtotal\": \{
	\"today\": \{
	    \"count\": [expr  [lindex $today_totals1 1] +  [lindex $today_totals2 1]],
	    \"female\": [expr  [lindex $today_totals1 2] +  [lindex $today_totals2 2]],
	    \"male\": [expr  [lindex $today_totals1 3] +  [lindex $today_totals2 3]]
	\},
	\"yesterday\": \{
	    \"total\": [expr [lindex $yesterday_totals1 1] +  [lindex $yesterday_totals2 1]],
	    \"female\": [expr [lindex $yesterday_totals1 2] +  [lindex $yesterday_totals2 2]],
	    \"male\": [expr [lindex $yesterday_totals1 3] +  [lindex $yesterday_totals2 3]]
	\},
	\"week\": \{
	    \"total\": [expr [lindex $week_totals1 0] +  [lindex $week_totals2 0]],
	    \"female\": [expr [lindex $week_totals1 1] +  [lindex $week_totals2 1]],
	    \"male\": [expr [lindex $week_totals1 2] +  [lindex $week_totals2 2]]
	\},
	\"total\": \{
	    \"count\": [expr $total1 + $total2],
	    \"female\": [expr $total_female1 + $total_female2],
	    \"male\": [expr $total_male1 + $total_male2]
	\}
    \}
\}"


ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
