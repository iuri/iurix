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
set daily_data [db_list_of_lists select_vehicles_grouped_hourly "
    SELECT date_trunc('hour', o.creation_date) AS hour, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY hour ORDER BY hour ASC
"]

#ns_log Notice "DAYly DATA $daily_data"

set total00 0
set total01 0
set total02 0
set total03 0
set total04 0
set total05 0
set total06 0
set total07 0
set total08 0
set total09 0
set total10 0
set total11 0
set total12 0
set total13 0
set total14 0
set total15 0
set total16 0
set total17 0
set total18 0
set total19 0
set total20 0
set total21 0
set total22 0
set total23 0
set total24 0

foreach elem $daily_data {
#    ns_log Notice "ELEM $elem"
    set hour [lindex $elem 0]
    set hour [clock scan [lindex [split $hour "+"] 0]]
    set hour [clock format $hour -format %H]
    #   ns_log Notice "HOUR $hour"
    # ns_log Notice "$hour | [lindex $elem 1]"
    switch $hour {
	"00" { set total00 [expr $total00 + [lindex $elem 1]] }
	"01" { set total01 [expr $total01 + [lindex $elem 1]] }
	"02" { set total02 [expr $total02 + [lindex $elem 1]] }
	"03" { set total03 [expr $total03 + [lindex $elem 1]]}
	"04" { set total04 [expr $total04 + [lindex $elem 1]]}
	"05" { set total05 [expr $total05 + [lindex $elem 1]]}
	"06" { set total06 [expr $total06 + [lindex $elem 1]]}
	"07" { set total07 [expr $total07 + [lindex $elem 1]]}
	"08" { set total08 [expr $total08 + [lindex $elem 1]]}
	"09" { set total09 [expr $total09 + [lindex $elem 1]]}
	"10" { set total10 [expr $total10 + [lindex $elem 1]]}
	"11" { set total11 [expr $total11 + [lindex $elem 1]]}
	"12" { set total12 [expr $total12 + [lindex $elem 1]]}
	"13" { set total13 [expr $total13 + [lindex $elem 1]]}
	"14" { set total14 [expr $total14 + [lindex $elem 1]]}
	"15" { set total15 [expr $total15 + [lindex $elem 1]]}
	"16" { set total16 [expr $total16 + [lindex $elem 1]]}
	"17" { set total17 [expr $total17 + [lindex $elem 1]]}
	"18" { set total18 [expr $total18 + [lindex $elem 1]]}
	"19" { set total19 [expr $total19 + [lindex $elem 1]]}
	"20" { set total20 [expr $total20 + [lindex $elem 1]]}
	"21" { set total21 [expr $total21 + [lindex $elem 1]]}
	"22" { set total22 [expr $total22 + [lindex $elem 1]]}
	"23" { set total23 [expr $total23 + [lindex $elem 1]]}
    }
}


set daily_data [list \
		    [list 00 $total00] \
		    [list 01 $total01] \
		    [list 02 $total02] \
		    [list 03 $total03] \
		    [list 04 $total04] \
		    [list 05 $total05] \
		    [list 06 $total06] \
		    [list 07 $total07] \
		    [list 08 $total08] \
		    [list 09 $total09] \
		    [list 10 $total10] \
		    [list 11 $total11] \
		    [list 12 $total12] \
		    [list 13 $total13] \
		    [list 14 $total14] \
		    [list 15 $total15] \
		    [list 16 $total16] \
		    [list 17 $total17] \
		    [list 18 $total18] \
		    [list 19 $total19] \
		    [list 20 $total20] \
    		    [list 21 $total21] \
		    [list 22 $total22] \
		    [list 23 $total23] \
		   ]

# ns_log Notice "DAILY DATA $daily_data"


# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_vehicles_grouped_hourly "
    select date_trunc('day', o.creation_date) AS day, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND date_trunc('month', o.creation_date::date) = date_trunc('month', :creation_date::date)
    GROUP BY 1 ORDER BY day;
"]

#ns_log Notice "MONTH DATA $monthly_data"

set today [lindex [lindex $monthly_data [expr [llength $monthly_data] -1]] 1]
set yesterday [lindex [lindex $monthly_data [expr [llength $monthly_data] -2]] 1]
#ns_log Notice "TODAY $today YESTERDAY $yesterday"






append result "\{\"today_total\": $today, \"today_percent\": 11, \"yesterday_total\": $yesterday, \"week_total\": 23056, \"week_percent\": 24, \"month_total\": 210556,"
append result "\"day_hours\":\["

foreach elem $daily_data {
#    ns_log Notice "ELEM $elem"
    set hour [lindex $elem 0]   
    #set hour [clock scan [lindex [split $hour "+"] 0]]
    #set hour [clock format $hour -format %H]
    set total [lindex $elem 1]

    append result "\{\"time\": \"${hour}:00h\", \"hour\": \"${hour}h\", \"total\": $total\},"
}
set result [string trimright $result ","]
append result "\],"








# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly "
    select date_trunc('day', o.creation_date) AS day, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY 1 ORDER BY day;
"]







#ns_log Notice "WEEKLY DATA $weekly_data"
set total0 0
set total1 0
set total2 0
set total3 0
set total4 0
set total5 0
set total6 0

append result "\"week\":\["
foreach elem $weekly_data {
    set day [lindex $elem 0]
    set dow [db_string select_dow {
	SELECT EXTRACT(dow from date :day); 
    } -default ""]
    set day [lc_time_fmt $day %d/%b]

    switch $dow {
	"0" {
	    set dow "DOM"
	    set total0 [expr $total0 + [lindex $elem 1]]
	}
	"1" { set dow "LUN"
	    set total1 [expr $total1 + [lindex $elem 1]]
	}
	"2" { set dow "MAR"
	    set total2 [expr $total2 + [lindex $elem 1]]
	}
	"3" { set dow "MIE"
	    set total3 [expr $total3 + [lindex $elem 1]]
	}
	"4" { set dow "JUE"
	    set total4 [expr $total4 + [lindex $elem 1]]
	}
	"5" { set dow "VIE"
	    set total5 [expr $total5 + [lindex $elem 1]]
	}
	"6" { set dow "SAB"
	    set total6 [expr $total6 + [lindex $elem 1]]
	}
    }
    set total [lindex $elem 1]
    # append result "\{\"day\": \"$day\", \"dow\": \"$dow\", \"total\": [lindex $elem 1]\},"
}




set weekly_data [list \
		     [list "LUN" $total1] \
		     [list "MAR" $total2] \
		     [list "MIE" $total3] \
		     [list "JUE" $total4] \
		     [list "VIE" $total5] \
		     [list "SAB" $total6] \
		     [list "DOM" $total0] \
		     ]
foreach elem $weekly_data {

    append result "\{\"dow\": \"[lindex $elem 0]\", \"total\": [lindex $elem 1]\},"
    
}

set result [string trimright $result ","]
append result "\],"

#ns_log Notice "MONTHLY DATA $monthly_data"

set aux [lindex [lindex $monthly_data [expr [llength $monthly_data] - 1 ] 0] 0]
for {set i [expr [lindex [split $aux "-"] 2] +1]} {$i <= 31} {incr i} {
    set aux [clock format [clock scan {+1 day} -base [clock scan $aux]] -format "%Y-%m-%d %T" ]
    lappend monthly_data [list $aux 0]
}


append result "\"month\":\["
foreach elem $monthly_data {
    set day [lc_time_fmt [lindex $elem 0] "%d/%b"]     
    set total [lindex $elem 1]

    append result "\{\"day\": \"$day\", \"total\": $total\},"
}

set result [string trimright $result ","]
append result "\]"
append result "\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
