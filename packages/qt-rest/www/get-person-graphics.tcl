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

set result "\{\"persons\": \["
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql

append result "\{\"$creation_date\":\["
db_foreach select_person_grouped_hourly {
    select date_trunc('hour', o.creation_date) AS hour,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND o.creation_date::date = :creation_date::date
    GROUP BY 1 ORDER BY hour ASC    
} {
    set hour [clock scan [lindex [split $hour "+"] 0]]
    set hour [clock format $hour -format %H]   
    append result "\{\"hora\": \"${hour}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
}



db_0or1row select_total {
    select date_trunc('hour', o.creation_date) AS hour,
    COUNT(1) AS total
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND o.creation_date::date = :creation_date::date
    GROUP BY 1 ORDER BY hour ASC
}

if {![exists_and_not_null total]} {
    for {set i 0} {$i < 24} {incr i} {
	set total [ expr 3 * $i]
	       append result "\{\"hour\": \"${i}h\", \"time\": \"${i}:00\", \"total\": \"$total\", \"female\": \"[expr int($total * 0.3)]\", \"male\": \"[expr int($total * 0.7)]\"\},"
	
    }
}





set result [string trimright $result ","]
append result "\]\},"


# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql

append result "\{\"week\":\["
db_foreach select_persons_of_week_grouped_daily {
    select date_trunc('day', o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND o.creation_date BETWEEN :creation_date::date - INTERVAL '6 day' AND :creation_date::date + INTERVAL '1 day'
    GROUP BY 1 ORDER BY day;
} {
    
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
set result [string trimright $result ","]
append result "\]\},"



# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
append result "\{\"month\":\["
db_foreach select_persons_of_month_grouped_daily {
    select date_trunc('day', o.creation_date) AS day,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = :content_type
    AND o.creation_date BETWEEN :creation_date::date - INTERVAL '1 month' AND :creation_date::date + INTERVAL '1 day'
    GROUP BY 1 ORDER BY day;
} {
    set day [lc_time_fmt $day "%d/%b"]     
    append result "\{\"day\": \"$day\", \"total\": $total\, \"female\": $female, \"male\": $male\},"
}
set result [string trimright $result ","]
append result "\]\},"



if {[info exists heatmap_p] && $heatmap_p eq true} {
    append result "\{\"heatmap\":\["
    db_foreach select_person_of_month_grouped_hourly {
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
	-- AND o.creation_date BETWEEN :creation_date::date - INTERVAL '1 month' AND :creation_date::date + INTERVAL '1 day'
	GROUP BY 1 ORDER BY hour ASC    
    } {
	set hour [clock scan [lindex [split $hour "+"] 0]]
	set h [clock format $hour -format %H]
	set d [clock format $hour -format "%d/%m"]
	
	append result "\{\"date\": \"$d\", \"time\": \"${h}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
    }
    set result [string trimright $result ","]
    append result "\]\},"    
}


if {[info exists age_range_p] && $age_range_p eq true} {
    append result "\{\"ageRanges\":\["
    set total_female10 0
    set total_male10 0
    set total10 0
    set total_female60 0
    set total_male60 0
    set total60 0
    db_foreach select_age_ranges {
	SELECT
	ROUND(SPLIT_PART(cr.description, ' ', 4)::numeric) AS range,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS total_female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS total_male
	FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id AND ci.content_type = :content_type
	AND EXTRACT(MONTH FROM o.creation_date) = EXTRACT(MONTH FROM :creation_date::date) GROUP BY range;

	
    } {
	
	if {[expr $range % 2] eq 0} {

	    append result "\{
		\"range\": \"$range\",
		\"total_female\": \"$total_female\",
		\"total_male\": \"$total_male\",
		\"total\": \"$total\"	    
	    \},"
	    
	}
	
	
	
	
	
	
	
    }

    set result [string trimright $result ","]
    append result "\]\},"
    
}
    
    
set result [string trimright $result ","]
append result "\]\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
