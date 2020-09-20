# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
}


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




# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
append result "\{\"hours\":\["
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

set max_hour [list]
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
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY 1 ORDER BY day;
"]

for {set i 1} {$i<32} {incr i} {    
    if {[lsearch -index 0 $monthly_data $i] eq -1} {
	set monthly_data [linsert $monthly_data [expr $i - 1] [list $i 0]]
    }
}
append result "\"month\":\["
set month_total 0
set max_month_day [list]
foreach elem $monthly_data {       
    set month_total [expr [lindex $elem 1] + $month_total]
    if {[lindex $max_month_day 1]<[lindex $elem 1]} {
	set max_month_day [list [lindex $elem 0] [lindex $elem 1]]
    }
    append result "\{\"day\": \"[lindex $elem 0]\", \"total\": [lindex $elem 1]\},"
}

set result [string trimright $result ","]
append result "\],"








# Instant Data
set instant_data [db_list_of_lists select_instant_data {
    SELECT
    date_trunc('hour', o.creation_date) AS hour,
    COUNT(1) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND date_trunc('month', o.creation_date::date) = date_trunc('month',:creation_date::date)
    GROUP BY 1 ORDER BY hour;
}]
set today_total 0
set yesterday_total 0

set today $creation_date
set yesterday [db_string select_yesterday { SELECT (:creation_date::timestamp - INTERVAL '1 day')::date FROM dual}]
set i [expr [llength $instant_data] - 1]
while {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today || [lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
    if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today} {
	set today_total [expr $today_total + [lindex [lindex $instant_data $i] 1]]							     
    }
    if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	set yesterday_total [expr $yesterday_total + [lindex [lindex $instant_data $i] 1]]
    }
    set i [expr $i - 1]
}

if {$yesterday_total eq "" || $yesterday_total eq 0} {
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
set week_total 0
set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
set i $dow
set j 0
while {$i>-1} {
    set elem [lindex $instant_data [expr [llength $instant_data] - $j -1]]
    set aux $elem
    while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	set week_total [expr $week_total + [lindex $aux 1]]	
	incr j
	set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]      
    }
    set i [expr $i - 1]    
}

set last_week_total 0
set i [expr $dow + 7]
set j 0
while {$i>$dow} {
    set elem [lindex $instant_data [expr [llength $instant_data] - $j-1]]
    set aux $elem
    while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	set last_week_total [expr $last_week_total + [lindex $aux 1]]
	incr j
	set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]      
    }
    set i [expr $i - 1]
}


set week_percent 0
if {$week_total ne 0 && $last_week_total ne 0} {
    set week_percent [expr [expr [expr $week_total * 100] / $last_week_total] - 100]
}
		  



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
