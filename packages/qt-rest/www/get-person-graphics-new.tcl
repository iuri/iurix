# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
    {age_range_p:boolean,optional}
    {heatmap_p:boolean,optional}
}

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


# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
append result "\{\"hours\":\["
set hourly_data [db_list_of_lists select_grouped_per_hour "
    SELECT EXTRACT('hour' FROM o.creation_date) AS hour,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY 1 ORDER BY hour ASC    
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


# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly "
    SELECT EXTRACT('dow' FROM o.creation_date) AS dow,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id    
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY 1 ORDER BY dow;
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




















# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_month_per_day "
    SELECT EXTRACT('day' FROM o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    $where_clauses
    GROUP BY 1 ORDER BY day;
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



if {[info exists heatmap_p] && $heatmap_p eq true} {
    set max 0
    append result "\"heatmap\":\["
    # Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
    db_foreach select_week_grouped_hourly {
	select date_trunc('hour', o.creation_date) AS hour,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
	FROM cr_items ci, acs_objects o, cr_revisions cr
	WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	AND o.creation_date BETWEEN :creation_date::date - INTERVAL '6 day' AND :creation_date::date + INTERVAL '1 day'
	GROUP BY 1 ORDER BY hour ASC    
    } {	
	set hour [clock scan [lindex [split $hour "+"] 0]]
	set h [clock format $hour -format %H]
	set d [clock format $hour -format "%d/%m"]

	if {$max < $total} {
	    set max $total
	}
	append result "\{\"date\": \"$d\", \"time\": \"${h}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
    }
    set result [string trimright $result ","]
    append result "\],"
    
    set r [expr $max / 6]
    append result "\"heatmap_range\":\["
    append result "\{\"range\": \"1-$r\", \"color\": \"#5bcdfa\"\},"
    append result "\{\"range\": \"[expr $r + 1]-[expr $r * 3]\", \"color\": \"#5eaffe\"\},"
    append result "\{\"range\": \"[expr 3 * $r + 1]-[expr $r * 4]\", \"color\": \"#4782f5\"\},"
    append result "\{\"range\": \"[expr 4 * $r + 1]-[expr $r * 5]\", \"color\": \"#3450ef\"\},"
    append result "\{\"range\": \"[expr 5 * $r + 1]-$max\", \"color\": \"#0502d3\"\}"
    append result "\],"    
}


if {[info exists age_range_p] && $age_range_p eq true} {
    append result "\"ageRanges\":\["
    set l_age_ranges [db_list_of_lists select_ranges "
	SELECT
	CASE WHEN SPLIT_PART(cr.description, ' ', 4) <> 'undefined' THEN ROUND(SPLIT_PART(cr.description, ' ', 4)::numeric) END AS range,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS total_female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS total_male
	FROM cr_items ci, acs_objects o, cr_revisions cr
	WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = 'qt_face'
	GROUP BY range;
	
    "]
   
    if {[llength $l_age_ranges] > 0} {
	set male18 0
	set female18 0
	set male60 0
	set female60 0
	foreach range $l_age_ranges {
	    if {[lindex $range 0] <= 18} {
		set female18 [expr int([lindex $range 2]) + $female18]			    
		set male18 [expr int([lindex $range 3]) + $male18]
		set idx [lsearch $l_age_ranges $range]
		set l_age_ranges [lreplace $l_age_ranges $idx $idx]
	    } elseif {[lindex $range 0] >= 60} {
		set female60 [expr int([lindex $range 2]) + $female60]			    
		set male60 [expr int([lindex $range 3]) + $male60]
		set idx [lsearch $l_age_ranges $range]
		set l_age_ranges [lreplace $l_age_ranges $idx $idx]
	    }
	}
	set l_age_ranges [linsert $l_age_ranges 0 [list 18 [expr $female18 + $male18] $female18 $male18]]
	set l_age_ranges [linsert $l_age_ranges [llength $l_age_ranges] [list 60 [expr $female60 + $male60] $female60 $male60]]

	set default_ranges [list 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60]
	foreach range $default_ranges {	   	    
	    if {[lsearch -index 0 $l_age_ranges $range] eq -1} {
		set l_age_ranges [linsert $l_age_ranges end [list $range 0 0 0]]
	    }
	}
	set l_age_ranges [lsort -integer -index 0 $l_age_ranges]
	
	set aux [list 0 0 0 0]
	foreach elem $l_age_ranges {
	    if {[expr [lindex $elem 0] % 2] > 0 } {
		set aux $elem
	    } else {
		set female [expr [lindex $elem 2] + [lindex $aux 2]]
		set male [expr [lindex $elem 3] + [lindex $aux 3]]
		set total [expr $female + $male]
		switch [lindex $elem 0] {
		    "18" { set range "-18" }
		    "60" { set range "+60" }
		    default { set range [lindex $elem 0] }
		}
		append result "\{
		    \"range\": \"$range\",
		    \"female\": \"$female\",
		    \"male\": \"$male\",
		    \"total\": \"$total\"	    
		\},"	   
	    }
	}		
   	set result [string trimright $result ","]
	append result "\],"	
    }    
}














# Instant data: hour, today, yesterday, day, week and month total

set instant_data [db_list_of_lists select_instant_data {
    SELECT date_trunc('hour', o.creation_date) AS hour,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND date_trunc('month', o.creation_date::date) = date_trunc('month', :creation_date::date)
    GROUP BY 1 ORDER BY hour;
}]

ns_log Notice "INSTANT DATA $instant_data"
#INSTANT DATA {{2020-09-01 06:00:00+00} 14 0 14} {{2020-09-01 07:00:00+00} 6 0 6} {{2020-09-01 08:00:00+00} 13 1 12} {{2020-09-01 09:00:00+00} 31 7 24} {{2020-09-01 10:00:00+00} 10 4 6} {{2020-09-01 11:00:00+00} 17 4 13} {{2020-09-01 12:00:00+00} 17 3 14} {{2020-09-01 13:00:00+00} 27 6 21} {{2020-09-01 14:00:00+00} 21 3 18} {{2020-09-01 15:00:00+00} 42 2 40} {{2020-09-01 16:00:00+00} 28 5 23} {{2020-09-01 17:00:00+00} 41 14 27} {{2020-09-01 18:00:00+00} 1 0 1} {{2020-09-02 06:00:00+00} 2 1 1} {{2020-09-02 07:00:00+00} 11 2 9} {{2020-09-02 08:00:00+00} 7 0 7} {{2020-09-02 09:00:00+00} 33 3 30} {{2020-09-02 10:00:00+00} 30 1 29} {{2020-09-02 11:00:00+00} 30 2 28} {{2020-09-02 12:00:00+00} 3 0 3} {{2020-09-02 13:00:00+00} 19 2 17} {{2020-09-02 14:00:00+00} 14 1 13} {{2020-09-02 15:00:00+00} 17 1 16} {{2020-09-02 16:00:00+00} 9 3 6} {{2020-09-02 17:00:00+00} 23 6 17} {{2020-09-03 02:00:00+00} 1 1 0} {{2020-09-03 05:00:00+00} 1 0 1} {{2020-09-03 06:00:00+00} 16 4 12} {{2020-09-03 07:00:00+00} 6 2 4} {{2020-09-03 08:00:00+00} 7 1 6} {{2020-09-03 09:00:00+00} 12 2 10} {{2020-09-03 10:00:00+00} 5 1 4} {{2020-09-03 11:00:00+00} 5 2 3} {{2020-09-03 12:00:00+00} 12 6 6} {{2020-09-03 13:00:00+00} 9 5 4} {{2020-09-03 14:00:00+00} 30 4 26} {{2020-09-03 15:00:00+00} 27 8 19} {{2020-09-03 16:00:00+00} 21 4 17} {{2020-09-03 17:00:00+00} 29 4 25} {{2020-09-03 18:00:00+00} 1 0 1} {{2020-09-04 06:00:00+00} 2 1 1} {{2020-09-04 07:00:00+00} 1 0 1} {{2020-09-04 08:00:00+00} 5 2 3} {{2020-09-04 09:00:00+00} 6 1 5} {{2020-09-04 10:00:00+00} 7 2 5} {{2020-09-04 11:00:00+00} 10 7 3} {{2020-09-04 12:00:00+00} 45 20 25} {{2020-09-04 13:00:00+00} 36 17 19} {{2020-09-04 14:00:00+00} 6 0 6}


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


set week_female 0
set week_male 0
set week_total 0

# To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
# set current_day [lindex [lindex $monthly_data [expr [llength $monthly_data] -1] ] 0]
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
		  











append result "\"today_total\": $today_total,
    \"today_female\": $today_female,
    \"today_male\": $today_male,
    \"today_percent\": $today_percent,
    \"today_percent_female\": $today_percent_female,
    \"today_percent_male\": $today_percent_male,
    \"yesterday_total\": $yesterday_total,
    \"yesterday_female\": $yesterday_female,
    \"yesterday_male\": $yesterday_male,
    \"max_hour\": \{\"hour\": \"[lindex $max_hour 0]\", \"total\": [lindex $max_hour 1]\},
    \"max_hour_female\": \{\"hour\": \"[lindex $max_hour_female 0]\", \"total\": [lindex $max_hour_female 1]\},
    \"max_hour_male\": \{\"hour\": \"[lindex $max_hour_male 0]\", \"total\": [lindex $max_hour_male 1]\},
    \"max_week_day\": \{\"day\": [lindex $max_week_day 0], \"total\": [lindex $max_week_day 1]\},
    \"max_week_day_female\": \{\"day\": \"[lindex $max_week_day_female 0]\", \"total\": [lindex $max_week_day_female 1]\},
    \"max_week_day_male\": \{\"day\": \"[lindex $max_week_day_male 0]\", \"total\": [lindex $max_week_day_male 1]\},
    \"max_month_day\": \{\"day\": \"[lindex $max_month_day 0]\", \"total\": [lindex $max_month_day 1]\},
    \"max_month_day_female\": \{\"day\": \"[lindex $max_month_day_female 0]\", \"total\": [lindex $max_month_day_female 1]\},
    \"max_month_day_male\": \{\"day\": \"[lindex $max_month_day_male 0]\", \"total\": [lindex $max_month_day_male 1]\},
    \"week_total\": $week_total,
    \"week_female\": $week_female,
    \"week_male\": $week_male,
    \"week_percent\": $week_percent,
    \"month_total\": $month_total,
    \"month_female\": $month_female,
    \"month_male\": $month_male\}"


ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
