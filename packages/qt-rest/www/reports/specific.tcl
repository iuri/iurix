# /packages/qt-rest/www/reports/specific.tcl
ad_page_contract {
    API REST method to return cr_items qt_face
} {
    {report_type "c"}
    {resource ""}
    {contact_type ""}
    {gender ""}
    {age_from ""}
    {age_to ""}
    {time_from ""}
    {time_to ""}
}
ns_log Notice "Running TCL script reports/specific.tcl"

# Validate and Authenticate JWT
#qt::rest::jwt::validation_p

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set where_clauses ""


switch $resource {
   "1"  {
	append where_clauses " AND t.hostname = 'CCPN001'"
    }
    "2" {
	append where_clauses " AND t.hostname = 'CCPN002'"
    }
    default {
	append where_clauses " AND (t.hostname = 'CCPN002' OR t.hostname = 'CCPN001')"
	
    }
}




set result "\{"




##
# If report_type ius Comercial
##
if {$report_type eq "c"} {



# Instant data: hour, today, yesterday, day, week and month total

set instant_data [db_list_of_lists select_instant_data {
    SELECT date_trunc('hour', t.creation_date) AS hour,
    COALESCE(SUM(t.total),0) AS total,
    COALESCE(SUM(t.total_female),0) AS female,
    COALESCE(SUM(t.total_male),0) AS male
    FROM qt_face_totals t
    WHERE date_trunc('month', t.creation_date::date) = date_trunc('month', :creation_date::date)
    GROUP BY hour
    ORDER BY hour;
}]



set today_total 0
set today_female 0
set today_male 0
set yesterday_total 0
set yesterday_female 0
set yesterday_male 0

set today $creation_date
set yesterday [db_string select_yesterday { SELECT (:creation_date::timestamp - INTERVAL '1 day')::date FROM dual}]
set i [expr [llength $instant_data] - 1]
while {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today || [lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
    if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today} {
	set today_total [expr $today_total + [lindex [lindex $instant_data $i] 1]]							     
	set today_female [expr $today_female + [lindex [lindex $instant_data $i] 2]]
	set today_male [expr $today_male + [lindex [lindex $instant_data $i] 3]]
    }
    if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	set yesterday_total [expr $yesterday_total + [lindex [lindex $instant_data $i] 1]]
	set yesterday_female [expr $yesterday_female + [lindex [lindex $instant_data $i] 2]]
	set yesterday_male [expr $yesterday_male + [lindex [lindex $instant_data $i] 3]]
    }
    set i [expr $i - 1]
}


set today_percent_female 0
if {$today_female ne 0 && $yesterday_female ne 0} {
    set today_percent_female [expr [expr [expr $today_female * 100] / $yesterday_female] - 100]
}
set today_percent_male 0
if {$today_male ne 0 && $yesterday_male ne 0} {
    set today_percent_male [expr [expr [expr $today_male * 100] / $yesterday_male] - 100]
}
set today_percent 0
if {$today_female ne 0 && $today_male ne 0} {
    set today_percent [expr $today_percent_female + $today_percent_male]
}



# To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
set week_female 0
set week_male 0
set week_total 0
set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
set i $dow
set j 0
while {$i>-1} {
    set elem [lindex $instant_data [expr [llength $instant_data] - $j -1]]
    set aux $elem
    while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	set week_total [expr $week_total + [lindex $aux 1]]
	set week_female [expr $week_female + [lindex $aux 2]]
	set week_male [expr $week_male + [lindex $aux 3]]
	
	incr j
	set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]
      
    }
    set i [expr $i - 1]    
}
set last_week_total 0
set last_week_female 0
set last_week_male 0
set i [expr $dow + 7]
set j 0
while {$i>$dow} {
    set elem [lindex $instant_data [expr [llength $instant_data] - $j-1]]
    set aux $elem
    while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	set last_week_total [expr $last_week_total + [lindex $aux 1]]
	set last_week_female [expr $last_week_female + [lindex $aux 2]]
	set last_week_male [expr $last_week_male + [lindex $aux 3]]	
	incr j
	set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]
      
    }
    set i [expr $i - 1]
}


set week_percent 0
if {$week_total ne 0 && $last_week_total ne 0} {
    set week_percent [expr [expr [expr $week_total * 100] / $last_week_total] - 100]
}
		  


# Totals
db_0or1row select_totals {
    SELECT
    COALESCE(SUM(t.total),0) AS total,
    COALESCE(SUM(t.total_female),0) AS total_female,
    COALESCE(SUM(t.total_male),0) AS total_male
    FROM qt_face_totals t
}


    
  append result "
    \"boxes\": \{
	\"today\": \{
	    \"count\": $today_total,
	    \"percent\": $today_percent,
	    \"female\": $today_female,
	    \"male\": $today_male
	\},
	\"yesterday\": \{
	    \"total\": $yesterday_total,
	    \"female\": $yesterday_female,
	    \"male\": $yesterday_male
	\},
	\"week\": \{
	    \"total\": $week_total,
	    \"percent\": $week_percent,
	    \"female\": $week_female,
	    \"male\": $week_male
	\},
	\"total\": \{
	    \"count\": $total,
	    \"female\": $total_female,
	    \"male\": $total_male
	\}
    \},
    \"progress\": \[
		 \{
		     \"name\": \"total\",
		     \"bars\": \[
			      \{
				  \"percent\": 18,
				  \"bg\": \"yellow\",
				  \"minutes\": 45,
				  \"name\": \"today\"
			      \},
			      \{
				  \"percent\": 30,
				  \"bg\": \"blue\",
				  \"minutes\": 45,
				  \"name\": \"week\"
			      \},
			      \{
				  \"percent\": 30,
				  \"minutes\": 45,
				  \"bg\": \"ligthBlue\",
				  \"name\": \"month\"
			      \}
			     \]
		 \},
		 \{
		     \"name\": \"male\",
		     \"bars\": \[
			      \{
				  \"percent\": 60,
				  \"bg\": \"yellow\",
				  \"minutes\": 17,
				  \"name\": \"today\"
			      \},
			      \{
				  \"percent\": 45,
				  \"bg\": \"blue\",
				  \"minutes\": 20,
				  \"name\": \"week\"
			      \},
			      \{
				  \"percent\": 27,
				  \"bg\": \"ligthBlue\",
				  \"minutes\": 46,
				  \"name\": \"month\"
			      \}
			     \]
		 \},
		 \{
		     \"name\": \"female\",
		     \"bars\": \[
			      \{
				  \"percent\": 78,
				  \"bg\": \"yellow\",
				  \"minutes\": 16,
				  \"name\": \"today\"
			      \},
			      \{
				  \"percent\": 55,
				  \"bg\": \"blue\",
				  \"minutes\": 28,
				  \"name\": \"week\"
			      \},
			      \{
				  \"percent\": 64,
				  \"bg\": \"ligthBlue\",
				  \"minutes\": 28,
				  \"name\": \"month\"
			     \}
			     \]
		 \}
		 \],"


}










##
# Further results to Comercial and Executive reports
##
append result "\"hours\": \["
set hourly_data [db_list_of_lists select_grouped_per_hour "
    SELECT EXTRACT('hour' FROM t.creation_date) AS hour,
    COALESCE(SUM(t.total),0) AS total,
    COALESCE(SUM(t.total_female),0) AS female,
    COALESCE(SUM(t.total_male),0) AS male
    FROM qt_face_totals t
    WHERE 1 = 1 
    $where_clauses
    GROUP BY hour
    ORDER BY hour ASC    
"]

for {set i 0} {$i<24} {incr i} {
    if {[lsearch -index 0 $hourly_data $i] eq -1} {
	set hourly_data [linsert $hourly_data $i [list $i 0 0 0]]				     
    }
}

set max_hour [list]
set max_hour_female [list]
set max_hour_male [list]
foreach elem $hourly_data {    
    if {[lindex $max_hour 1]<[lindex $elem 1]} {
	set max_hour [list "[lindex $elem 0]h" [lindex $elem 1]]
    }
    if {[lindex $max_hour_female 1]<[lindex $elem 2]} {
	set max_hour_female [list "[lindex $elem 0]h" [lindex $elem 2]]
	
    }
    if {[lindex $max_hour_male 1]<[lindex $elem 3]} {
	set max_hour_male [list "[lindex $elem 0]h" [lindex $elem 3]]
	
    }		
    append result "\{\"time\": \"[lindex $elem 0]:00h\", \"hour\": \"[lindex $elem 0]h\", \"total\": [lindex $elem 1]\, \"female\": [lindex $elem 2], \"male\": [lindex $elem 3]\},"
}


set result [string trimright $result ","]
append result "\],"





set weekly_data [db_list_of_lists select_vehicles_grouped_hourly "
    SELECT EXTRACT('dow' FROM t.creation_date) AS dow,
    COALESCE(SUM(t.total),0) AS total,
    COALESCE(SUM(t.total_female),0) AS female,
    COALESCE(SUM(t.total_male),0) AS male
    FROM qt_face_totals t
    WHERE 1 = 1 
    $where_clauses
    GROUP BY dow
    ORDER BY dow;
"]


append result "\"week\":\["
set max_week_day [list]
set max_week_day_female [list]
set max_week_day_male [list]

for {set i 0} {$i<7} {incr i} {
    if {[lsearch -index 0 $weekly_data $i] eq -1} {
	#lappend weekly_data [list $i 0 0 0]
	set weekly_data [linsert $weekly_data $i [list $i 0 0 0]]
    }
}
#set weekly_data [lsort -index 0 $weekly_data]
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
    if {[lindex $max_week_day_female 1]<[lindex $elem 2]} {
	set max_week_day_female [list "$dow" [lindex $elem 1]]
    }
    if {[lindex $max_week_day_male 1]<[lindex $elem 3]} {
	set max_week_day_male [list "$dow" [lindex $elem 1]]
    }
    
    append result "\{\"dow\": \"$dow\", \"total\": [lindex $elem 1], \"female\": [lindex $elem 2], \"male\": [lindex $elem 3]\},"    
}
set result [string trimright $result ","]
append result "\],"


set monthly_data [db_list_of_lists select_month_per_day "
    SELECT EXTRACT('day' FROM t.creation_date) AS day,
    COALESCE(SUM(t.total),0) AS total,
    COALESCE(SUM(t.total_female),0) AS female,
    COALESCE(SUM(t.total_male),0) AS male
    FROM qt_face_totals t
    WHERE date_trunc('month', t.creation_date::date) = date_trunc('month', :creation_date::date)
    GROUP BY day
    ORDER BY day;
"]
for {set i 1} {$i<32} {incr i} {    
    if {[lsearch -index 0 $monthly_data $i] eq -1} {
	set monthly_data [linsert $monthly_data [expr $i - 1] [list $i 0 0 0]]
    }
}
    

set max_month_day [list]
set max_month_day_female [list]
set max_month_day_male [list]

set month_female 0
set month_male 0
set month_total 0

append result "\"month\":\["
foreach elem $monthly_data {
    set month_total [expr $month_total + [lindex $elem 1]]
    set month_female [expr $month_female + [lindex $elem 2]]
    set month_male [expr $month_male + [lindex $elem 3]]
    #set day [lc_time_fmt [lindex $elem 0] "%d/%b"]
    if {[lindex $max_month_day 1]<[lindex $elem 1]} {
	set max_month_day [list [lindex $elem 0] [lindex $elem 1]]
    }
    if {[lindex $max_month_day_female 1]<[lindex $elem 2]} {
	set max_month_day_female [list [lindex $elem 0] [lindex $elem 1]]
    }
    if {[lindex $max_month_day_male 1]<[lindex $elem 3]} {
	set max_month_day_male [list [lindex $elem 0] [lindex $elem 1]]
    }
        
    append result "\{\"day\": [lindex $elem 0], \"total\": [lindex $elem 1], \"female\": [lindex $elem 2], \"male\": [lindex $elem 3]\},"
}

set result [string trimright $result ","]
append result "\],"





append result "\"max_hour\": \{\"hour\": \"[lindex $max_hour 0]\", \"total\": [lindex $max_hour 1]\},
    \"max_hour_female\": \{\"hour\": \"[lindex $max_hour_female 0]\", \"total\": [lindex $max_hour_female 1]\},
    \"max_hour_male\": \{\"hour\": \"[lindex $max_hour_male 0]\", \"total\": [lindex $max_hour_male 1]\},
    \"max_week_day\": \{\"day\": [lindex $max_week_day 0], \"total\": [lindex $max_week_day 1]\},
    \"max_week_day_female\": \{\"day\": \"[lindex $max_week_day_female 0]\", \"total\": [lindex $max_week_day_female 1]\},
    \"max_week_day_male\": \{\"day\": \"[lindex $max_week_day_male 0]\", \"total\": [lindex $max_week_day_male 1]\},
    \"max_month_day\": \{\"day\": \"[lindex $max_month_day 0]\", \"total\": [lindex $max_month_day 1]\},
    \"max_month_day_female\": \{\"day\": \"[lindex $max_month_day_female 0]\", \"total\": [lindex $max_month_day_female 1]\},
    \"max_month_day_male\": \{\"day\": \"[lindex $max_month_day_male 0]\", \"total\": [lindex $max_month_day_male 1]\}
\}"


ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
