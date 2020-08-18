# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
    {content_type "qt_vehicle"}
}
ns_log Notice "Running TCL script get-vehicle-graphics.tcl"

if {[qt_rest::jwt::validation_p] eq 0} {
    ad_return_complaint 1 "Bad HTTP Request: Invalid Token!"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."
    ad_script_abort
}

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
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
}




# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set daily_data [db_list_of_lists select_grouped_hour "
    SELECT EXTRACT('hour' FROM o.creation_date) AS hour, COUNT(1) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY hour ORDER BY hour ASC
"]

# ns_log Notice "DAYly DATA $daily_data"

append result "\{\"day_hours\":\["
foreach elem $daily_data {
    append result "\{\"time\": \"[lindex $elem 0]:00h\", \"hour\": \"[lindex $elem 0]h\", \"total\":  [lindex $elem 1]\},"
}
set result [string trimright $result ","]
append result "\],"




# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly "
    select EXTRACT('dow' FROM o.creation_date) AS dow, COUNT(1) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY dow ORDER BY dow;
"]
set weekly_data [lreplace [lappend weekly_data [lindex $weekly_data 0]] 0 0]

append result "\"week\":\["
foreach elem $weekly_data {
    set dow [lindex $elem 0]    
    switch $dow {
	0 { set dow "DOM" }
	1 { set dow "LUN" }
	2 { set dow "MAR" }
	3 { set dow "MIE" }
	4 { set dow "JUE" }
	5 { set dow "VIE" }
	6 { set dow "SAB" }
    }
    append result "\{\"dow\": \"$dow\", \"total\": [lindex $elem 1]\},"
}
set result [string trimright $result ","]
append result "\],"


# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_vehicles_grouped_hourly "
    SELECT date_trunc('day', o.creation_date) AS day, COUNT(1) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND date_trunc('month', o.creation_date::date) = date_trunc('month', :creation_date::date)
    GROUP BY 1 ORDER BY day;
"]

set today_total [lindex [lindex $monthly_data [expr [llength $monthly_data] -1]] 1]
set yesterday_total [lindex [lindex $monthly_data [expr [llength $monthly_data] -2]] 1]
set today_percent [expr [expr [expr $today_total * 100] / $yesterday_total] - 100]

set aux [lindex [lindex $monthly_data [expr [llength $monthly_data] - 1 ] 0] 0]
ns_log Notice "AUX $aux"



set last_week_total 0
set week_total 0

# To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
# set current_day [lindex [lindex $monthly_data [expr [llength $monthly_data] -1] ] 0]
set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
set i $dow
while {$i>-1} {
    set elem [lindex $monthly_data [expr [llength $monthly_data] - $i -1]]
    set week_total [expr $week_total + [lindex $elem 1]]
    set i [expr $i - 1] 
}

set i [expr $dow + 7]
while {$i>$dow} {
    set elem [lindex $monthly_data [expr [llength $monthly_data] - $i -1]]
    set last_week_total [expr $last_week_total + [lindex $elem 1]]
    set i [expr $i - 1]
}
ns_log Notice "$last_week_total"
set week_percent [expr [expr [expr $week_total * 100] / $last_week_total] - 100]
		  








for {set i [expr [lindex [split $aux "-"] 2] +1]} {$i <= 31} {incr i} {
    set aux [clock format [clock scan {+1 day} -base [clock scan $aux]] -format "%Y-%m-%d %T" ]
    lappend monthly_data [list $aux 0]
}

append result "\"month\":\["
set month_total 0
foreach elem $monthly_data {       
    set month_total [expr [lindex $elem 1] + $month_total]
    append result "\{\"day\": \"[lc_time_fmt [lindex $elem 0] "%d/%b"]\", \"total\": [lindex $elem 1]\},"
}

set result [string trimright $result ","]
append result "\],"


# ns_log Notice "MONTH DATA $monthly_data"

append result "\"today_total\": $today_total, \"today_percent\": $today_percent, \"yesterday_total\": $yesterday_total, \"week_total\": $week_total, \"week_percent\": 24, \"month_total\": $month_total\}"

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
