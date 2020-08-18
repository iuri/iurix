# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
    {age_range_p:boolean,optional}
    {heatmap_p:boolean,optional}
}

if {[qt_rest::jwt::validation_p] eq 0} {
    ad_return_complaint 1 "Bad HTTP Request: Invalid Token!"
    ns_respond -status 400 -type "text/html" -string "Bad Request Error HTML 400. The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing."
    ad_script_abort
}
set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set content_type qt_face
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {set t [clock scan $date_from]} errmsg]} {
	set creation_date $date_from
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
append result "\{\"day_hours\":\["
db_foreach select_grouped_per_hour "
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
" {
    append result "\{\"time\": \"${hour}:00h\", \"hour\": \"${hour}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
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
    append result "\{\"dow\": \"$dow\", \"total\": [lindex $elem 1], \"female\": [lindex $elem 2], \"male\": [lindex $elem 3]\},"    
}

set result [string trimright $result ","]
append result "\],"



















# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_month_per_day {
    SELECT EXTRACT('day' FROM o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND date_trunc('month', o.creation_date::date) = date_trunc('month', :creation_date::date)
    GROUP BY 1 ORDER BY day;
}]

# ns_log Notice "MONTH DATA $monthly_data"

set today_female [lindex [lindex $monthly_data [expr [llength $monthly_data] -1] ] 2]
set today_male [lindex [lindex $monthly_data [expr [llength $monthly_data] -1] ] 3]
set today_total [expr $today_female + $today_male]

set yesterday_female [lindex [lindex $monthly_data [expr [llength $monthly_data] -2] ] 2]
set yesterday_male [lindex [lindex $monthly_data [expr [llength $monthly_data] -2] ] 3]
set yesterday_total [expr $yesterday_female + $yesterday_male]

set today_percent_female [expr [expr [expr $today_female * 100] / $yesterday_female] - 100]
set today_percent_male [expr [expr [expr $today_male * 100] / $yesterday_male] - 100]
set today_percent [expr $today_percent_female + $today_percent_male]

set week_female 0
set week_male 0
set last_week_total 0

# To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
# set current_day [lindex [lindex $monthly_data [expr [llength $monthly_data] -1] ] 0]
set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :creation_date) } -default 6]
set i $dow
while {$i>-1} {
    set elem [lindex $monthly_data [expr [llength $monthly_data] - $i -1]]
    set week_female [expr $week_female + [lindex $elem 2]]
    set week_male [expr $week_male + [lindex $elem 3]]
    set i [expr $i - 1] 
}

set i [expr $dow + 7]
while {$i>$dow} {
    set elem [lindex $monthly_data [expr [llength $monthly_data] - $i -1]]
    set last_week_total [expr $last_week_total + [lindex $elem 1]]
    set i [expr $i - 1]
}
ns_log Notice "$last_week_total"
set week_total [expr $week_female + $week_male]
set week_percent [expr [expr [expr $week_total * 100] / $last_week_total] - 100]
		  
		  


set month_female 0
set month_male 0
foreach elem $monthly_data {
    set month_female [expr $month_female + [lindex $elem 2]]
    set month_male [expr $month_male + [lindex $elem 3]]
}
set month_total [expr $month_female + $month_male]

set aux [lindex [lindex $monthly_data [expr [llength $monthly_data] - 1 ] 0] 0]
for {set i [expr $aux +1]} {$i <= 31} {incr i} {
#    set aux [clock format [clock scan {+1 day} -base [clock scan $aux]] -format "%Y-%m-%d %T" ]
    lappend monthly_data [list $i 0]
}


append result "\"month\":\["
foreach elem $monthly_data {
    #  set day [lc_time_fmt [lindex $elem 0] "%d/%b"]
    append result "\{\"day\": \"[lindex $elem 0]\", \"total\": [lindex $elem 1]\},"
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
    set l_age_ranges [db_list_of_lists select_ranges {
	SELECT ROUND(SPLIT_PART(cr.description, ' ', 4)::numeric) AS range,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS total_female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS total_male
	FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id AND ci.content_type = :content_type
	AND EXTRACT(MONTH FROM o.creation_date) = EXTRACT(MONTH FROM :creation_date::date)
	GROUP BY range;	
    }]
   
   
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
		    \"total_female\": \"$female\",
		    \"total_male\": \"$male\",
		    \"total\": \"$total\"	    
		\},"	   
	    }
	}
	
	
   	set result [string trimright $result ","]
	append result "\],"
	
    }
    
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
    \"week_total\": $week_total,
    \"week_female\": $week_female,
    \"week_male\": $week_male,
    \"week_percent\": $week_percent,
    \"month_total\": $month_total,
    \"month_female\": $month_female,
    \"month_male\": $month_male\}"


ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
