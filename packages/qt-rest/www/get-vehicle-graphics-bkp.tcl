# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
    {content_type "qt_vehicle"}
}
ns_log Notice "Running TCL script get-vehicle-graphics.tcl"


# Validate and Authenticate JWT
qt::rest::jwt::validation_p

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	append where_clauses " AND o.creation_date::date >= :date_from::date "
	set creation_date $date_from
	
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {   
    if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	append where_clauses " AND o.creation_date::date <= :date_to::date"
	set creation_date $date_to
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}




# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
append result "\{\"hours\":\["
set max_hour [list]

set hourly_data [db_list_of_lists select_grouped_hour "
    SELECT EXTRACT('hour' FROM o.creation_date) AS hour, 
    COUNT(1) AS total
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND cr.title <> 'UNKNOWN'
    $where_clauses
    GROUP BY hour ORDER BY hour ASC
"]

for {set i 0} {$i<24} {incr i} {
    if {[lsearch -index 0 $hourly_data $i] eq -1} {
	set hourly_data [linsert $hourly_data $i [list $i 0]]				    
    }
}

foreach elem $hourly_data {
    if {[lindex $max_hour 1]<[lindex $elem 1]} {
	set max_hour [list "\"[lindex $elem 0]h\"" [lindex $elem 1]]
    }
    append result "\{\"time\": \"[lindex $elem 0]:00h\", \"hour\": \"[lindex $elem 0]h\", \"total\": [lindex $elem 1]\},"
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

append result "\"week\":\["
set max_week_day [list]
for {set i 0} {$i<7} {incr i} {
    if {[lsearch -index 0 $weekly_data $i] eq -1} {
	lappend weekly_data [list $i 0]
    }
}
set weekly_data [lsort -index 0 $weekly_data]
 set weekly_data [lreplace [lappend weekly_data [lindex $weekly_data 0]] 0 0]


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
    if {[lindex $max_week_day 1]<[lindex $elem 1]} {
	set max_week_day [list "\"$dow\"" [lindex $elem 1]]
    }

    append result "\{\"dow\": \"$dow\", \"total\": [lindex $elem 1]\},"
}
set result [string trimright $result ","]
append result "\],"


# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_vehicles_grouped_daily "
    SELECT
    EXTRACT('day' FROM o.creation_date) AS day,
    COUNT(1) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = '$content_type'
    $where_clauses
    GROUP BY 1 ORDER BY day;
"]


ns_log Notice "MONTHLY DATA $monthly_data"

set today_total [lindex [lindex $monthly_data [expr [llength $monthly_data] -1]] 1]
ns_log Notice "Today Total $today_total"

set yesterday_total [lindex [lindex $monthly_data [expr [llength $monthly_data] -2]] 1]
ns_log Notice "Today Total $yesterday_total"


if {$yesterday_total eq ""} {
    set yesterday_total [db_string select_yesterday {
	SELECT COUNT(1) AS total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = :content_type
	AND o.creation_date::date = :creation_date::date - INTERVAL '1 day'

    } -default 1]
}

set today_percent 0
if {$today_total ne 0 && $yesterday_total ne 0} {
    set today_percent [expr [expr [expr $today_total * 100] / $yesterday_total] - 100]
}




# To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
# set current_day [lindex [lindex $monthly_data [expr [llength $monthly_data] -1] ] 0]
set week_total 1
set last_week_total 1
set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
set i $dow
while {$i>-1} {
    set elem [lindex $monthly_data [expr [llength $monthly_data] - $i -1]]
    if {[lindex $elem 1] ne ""} {
	set week_total [expr $week_total +  [lindex $elem 1]]
    }
    set i [expr $i - 1] 
}

set i [expr $dow + 7]
while {$i>$dow} {
    set elem [lindex $monthly_data [expr [llength $monthly_data] - $i -1]]
    if { [llength $elem] > 0} {
	set last_week_total [expr $last_week_total + [lindex $elem 1]]
    }
    set i [expr $i - 1]
}



if {$last_week_total eq ""} {
    set last_week_total 1
}
    
set week_percent [expr [expr [expr $week_total * 100] / $last_week_total] - 100]

set aux [lindex [lindex [lindex $monthly_data 0] 0] 0]
for {set i [expr [lindex [split $aux "-"] 2] - 1]} {$i>0} {set i [expr $i - 1]} {
    set aux [clock format [clock scan {-1 day} -base [clock scan $aux]] -format "%Y-%m-%d %T" ]
    lappend monthly_data [list $aux 0] 
}
set monthly_data [lsort -index 0 $monthly_data]


set aux [lindex [lindex [lindex $monthly_data [expr [llength $monthly_data] - 1 ]] 0] 0]
for {set i [expr [lindex [split $aux "-"] 2] +1]} {$i <= 31} {incr i} {
    set aux [clock format [clock scan {+1 day} -base [clock scan $aux]] -format "%Y-%m-%d %T" ]
    lappend monthly_data [list $aux 0]
}

append result "\"month\":\["
set month_total 0
set max_month_day [list]
foreach elem $monthly_data {       
    set month_total [expr [lindex $elem 1] + $month_total]
    if {[lindex $max_month_day 1]<[lindex $elem 1]} {
	set max_month_day [list "[lc_time_fmt [lindex $elem 0] %d/%b es_ES]" [lindex $elem 1]]
    }
    append result "\{\"day\": \"[lc_time_fmt [lindex $elem 0] "%d/%b" "es_ES"]\", \"total\": [lindex $elem 1]\},"
}

set result [string trimright $result ","]
append result "\],"


# ns_log Notice "MONTH DATA $monthly_data"

append result "\"today_total\": $today_total,
    \"today_percent\": $today_percent,
    \"yesterday_total\": $yesterday_total,
    \"week_total\": $week_total,
    \"week_percent\": $week_percent,
    \"month_total\": $month_total,
    \"max_hour\": \{\"hour\": [lindex $max_hour 0], \"total\": [lindex $max_hour 1]\},
    \"max_week_day\": \{\"day\": [lindex $max_week_day 0], \"total\": [lindex $max_week_day 1]\},
    \"max_month_day\": \{\"day\": \"[lindex $max_month_day 0]\", \"total\": [lindex $max_month_day 1]\}
\}"

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
