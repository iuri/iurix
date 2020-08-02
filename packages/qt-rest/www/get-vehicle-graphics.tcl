# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date:optional}
    {content_type "qt_vehicle"}
}
ns_log Notice "Running TCL script get-vehicle-graphics.tcl"


# set creation_date [clock format [clock scan [db_string select_now { SELECT now() - INTERVAL '5 hour' FROM dual}]] -format %Y-%m-%d]
set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
if {[info exists date]} {
    if {![catch {set t [clock scan $date]} errmsg]} {
	set creation_date $date
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}

set result "\{\"vehicles\": \["
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set daily_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('hour', o.creation_date) AS hour, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND o.creation_date::date = :creation_date::date
    GROUP BY 1 ORDER BY hour ASC
}]

append result "\{\"$creation_date\":\["
foreach elem $daily_data {
    set hour [lindex $elem 0]   
    set hour [clock scan [lindex [split $hour "+"] 0]]
    set hour [clock format $hour -format %H]

    set total [lindex $elem 1]

    append result "\{\"hour\": \"${hour}h\", \"total\": $total\},"
}
set result [string trimright $result ","]
append result "\]\},"


# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('day', o.creation_date) AS day, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND o.creation_date BETWEEN :creation_date::date - INTERVAL '6 day' AND :creation_date::date + INTERVAL '1 day'
    GROUP BY 1 ORDER BY day;
}]

append result "\{\"week\":\["
foreach elem $weekly_data {
    set day [lindex $elem 0]
    set dow [db_string select_dow {
	SELECT EXTRACT(dow from date :day); 
    } -default ""]
    set day [lc_time_fmt $day %d/%b]

    switch $dow {
	"0" { set dow "DOM $day" }
	"1" { set dow "LUN $day" }
	"2" { set dow "MAR $day" }
	"3" { set dow "MIE $day" }
	"4" { set dow "JUE $day" }
	"5" { set dow "VIE $day" }
	"6" { set dow "SAB $day" }
    }
    set total [lindex $elem 1]

    append result "\{\"day\": \"$day\", \"total\": $total\},"
    
}
set result [string trimright $result ","]
append result "\]\},"



# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('day', o.creation_date) AS day, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND o.creation_date BETWEEN :creation_date::date - INTERVAL '1 month' AND :creation_date::date + INTERVAL '1 day'
    GROUP BY 1 ORDER BY day;
}]

append result "\{\"month\":\["
foreach elem $monthly_data {
    set day [lc_time_fmt [lindex $elem 0] "%d/%b"]     
    set total [lindex $elem 1]

    append result "\{\"day\": \"$day\", \"total\": $total\},"
}
set result [string trimright $result ","]
append result "\]\}"

append result "\]\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
