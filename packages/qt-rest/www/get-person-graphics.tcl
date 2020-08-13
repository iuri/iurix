# /packages/qt-rest/www/get-person-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {content_type "qt_face"}
    {date:optional}
    {age_range_p:boolean,optional}
    {heatmap_p:boolean,optional}
}
ns_log Notice "Running TCL script get-person-graphics.tcl"

set creation_date [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
if {[info exists date]} {
    if {![catch {set t [clock scan $date]} errmsg]} {
	set creation_date $date
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}

set result "\{\"persons\": \["
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set week_hourly_datasource [db_list_of_lists select_person_of_month_grouped_hourly {
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
}]

set i [expr [llength $week_hourly_datasource] - 1]
set elem [lindex $week_hourly_datasource $i]

set today_datasource [list]
while {[lindex [split [lindex $elem 0] " "] 0] eq $creation_date && $i > -1} {
    lappend today_datasource $elem
    set i [expr $i - 1]
    set elem [lindex $week_hourly_datasource $i]
    
}

append result "\{\"$creation_date\":\["

foreach elem $today_datasource {
    set datetime [lindex [split [lindex $elem 0] "+"] 0]
    set hour [clock format  [clock scan $datetime] -format %H]
    set total [lindex $elem 1]
    set female [lindex $elem 2]
    set male [lindex $elem 3]
    
    append result "\{\"time\": \"${hour}:00h\", \"hora\": \"${hour}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
}

# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set month_data [db_list_of_lists select_persons_of_month_grouped_daily {
    select date_trunc('day', o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND EXTRACT('MONTH' FROM o.creation_date::date) = EXTRACT('MONTH' FROM :creation_date::date)
    GROUP BY 1 ORDER BY day;
}]


# number of week to collect data
set i 1
# day of the omnth
set j [expr [llength $month_data] - 1]
# list to accumulate data
set total_weeks [list]
set week_data [list]
while {$i < 3} {
    set elem [lindex $month_data $j]
    lappend week_data $elem
    set day [lindex $elem 0]
    if {$day ne ""} {
	set dow [db_string select_dow {
	    SELECT EXTRACT(dow from date :day); 
	} -default ""]
	
	set total_week 0
	set k 1
	while {$k <= [expr $dow + 1]} {
	    set total_week [expr [lindex $elem 1] + $total_week]	
	    set elem [lindex $month_data [expr $j - $k]]
	    lappend week_data $elem
	    incr k 
	}
	set j [expr $j - $dow - 1]
	lappend total_weeks $total_week
    } else {
	break
    }
    incr i    
}

set percent_today 0
if {[llength $week_data] > 2} {
    set today [lindex $week_data 0]
    set yesterday [lindex $week_data 1]
    ns_log Notice "TODAY $today YESTERDAY $yesterday"
    set percent_today [expr [expr [expr [lindex $today 1] * 100] / [lindex $yesterday 1]] - 100]
}

set result [string trimright $result ","]
append result "\], \"percent_today\": $percent_today\},"



append result "\{\"week\":\["
foreach elem $week_data {
    set day [lindex $elem 0]
    set total [lindex $elem 1]
    set female [lindex $elem 2]
    set male [lindex $elem 3]
    if {$day ne ""} {

	set dow [db_string select_dow {
	    SELECT EXTRACT(dow from date :day); 
	} -default ""]
	set day [lc_time_fmt $day "%d/%b"]
    
	switch $dow {
	    "0" { set dow "DOM" }
	    "1" { set dow "LUN" }
	    "2" { set dow "MAR" }
	    "3" { set dow "MIE" }
	    "4" { set dow "JUE" }
	    "5" { set dow "VIE" }
	    "6" { set dow "SAB" }
	}
	append result "\{\"day\": \"$day\", \"dow\": \"$dow\", \"total\": $total\, \"female\": $female, \"male\": $male\},"
    }
}

set percent_week 0
if {[llength $total_weeks] > 2} {
    set percent_week [expr [expr [expr [lindex $total_weeks 0] * 100] / [lindex $total_weeks 1]] - 100]
}
set result [string trimright $result ","]
append result "\],\"percent_week\": $percent_week\},"



# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
append result "\{\"month\":\["
foreach elem $month_data {
    set day [lindex $elem 0]
    set total [lindex $elem 1]
    set female [lindex $elem 2]
    set male [lindex $elem 3]
    
    set day [lc_time_fmt $day "%d/%b"]     
    append result "\{\"day\": \"$day\", \"total\": $total\, \"female\": $female, \"male\": $male\},"
}
set result [string trimright $result ","]
append result "\],\"percent_month\": 10\},"



if {[info exists heatmap_p] && $heatmap_p eq true} {
    append result "\{\"heatmap\":\["
    
    foreach elem $week_hourly_datasource {
	set hour [clock scan [lindex [split [lindex $elem 0] "+"] 0]]
	set h [clock format $hour -format %H]
	set d [clock format $hour -format "%d/%m"]
	set total [lindex $elem 1]
	set female [lindex $elem 2]
	set male [lindex $elem 3]
	append result "\{\"date\": \"$d\", \"time\": \"${h}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
    }
    set result [string trimright $result ","]
    append result "\]\},"    
}


if {[info exists age_range_p] && $age_range_p eq true} {
    append result "\{\"ageRanges\":\["
    set l_age_ranges [db_list_of_lists seelct_ranges {
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
		switch {[lindex $elem 0]} {
		    "18" { set range "-18" }
		    "60" { set range "60+" }
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
	append result "\]\},"
	
    }
    
}
set result [string trimright $result ","]
append result "\]\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
