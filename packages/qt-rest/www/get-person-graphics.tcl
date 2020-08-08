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
    append result "\{\"time\": \"${hour}:00h\", \"hora\": \"${hour}h\", \"total\": $total, \"female\": $female, \"male\": $male\},"
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
    LIMIT 1
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
    set l_age_ranges [db_list_of_lists select_age_ranges {
	SELECT
	ROUND(SPLIT_PART(cr.description, ' ', 4)::numeric) AS range,
	COUNT(1) AS total,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS total_female,
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS total_male
	FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id AND ci.content_type = :content_type
	AND EXTRACT(MONTH FROM o.creation_date) = EXTRACT(MONTH FROM :creation_date::date) GROUP BY range;	
    }]

    set male10 0
    set female10 0
    set male60 0
    set female60 0
    

#    set l_age_range [list {6 15 5 10} {11 22 7 15} {15 1 0 1} {16 11 2 9} {17 1 1 0} {19 1 0 1} {20 6 0 6} {21 10 1 9} {22 12 4 8} {23 25 7 18} {24 57 16 41} {25 91 17 74} {26 138 21 117} {27 202 22 180} {28 251 28 223} {29 370 34 336} {30 408 49 359} {31 456 42 414} {32 437 47 390} {33 495 45 450} {34 425 47 378} {35 432 55 377} {36 385 38 347} {37 362 52 310} {38 300 40 260} {39 265 28 237} {40 251 34 217} {41 199 28 171} {42 198 43 155} {43 160 30 130} {44 146 26 120} {45 127 31 96} {46 94 20 74} {47 85 21 64} {48 90 18 72} {49 56 13 43} {50 59 13 46} {51 45 8 37} {52 33 6 27} {53 28 3 25} {54 21 0 21} {55 18 4 14} {56 7 1 6} {57 15 4 11} {58 4 0 4} {59 9 1 8} {60 5 1 4} {61 7 0 7} {62 1 0 1} {63 6 0 6} {65 1 0 1} {66 1 0 1} {67 1 0 1}]

    foreach range $l_age_ranges {
	if {[lindex $range 0] <= 10} {
	    set female10 [expr [lindex $range 2] + $female10]			    
	    set male10 [expr [lindex $range 3] + $male10]
	    set total10 [expr $female10 + $male10]
	} elseif {[lindex $range 0] >= 60} {
	    set female60 [expr [lindex $range 2] + $female60]			    
	    set male60 [expr [lindex $range 3] + $male60]
	    set total60 [expr $female60 + $male60]
	} else {
	    lappend range_f $range
	}
    }

    if {[exists_and_not_null total10]} {	
	append result "\{
	    \"range\": \"-10\",
	    \"total_female\": \"$female10\",
	    \"total_male\": \"$male10\",
	    \"total\": \"$total10\"	    
	\},"
    }

    foreach range $range_f {
	if {[expr [lindex $range 0] % 2] > 0 } {
	    set aux $range
	} else {
	    set female [expr [lindex $range 2] + [lindex $aux 2]]
	    set male [expr [lindex $range 3] + [lindex $aux 3]]
	    set total [expr [lindex $range 1] + [lindex $aux 1]]
    	    append result "\{
		\"range\": \"[lindex $range 0]\",
		\"total_female\": \"$female\",
		\"total_male\": \"$male\",
		\"total\": \"$total\"	    
	    \},"	   
	    set aux "0 0 0 0"
	}	


	
    }
    
    if {[exists_and_not_null total60]} {
	append result "\{
	    \"range\": \"60+\",
	    \"total_female\": \"$female60\",
	    \"total_male\": \"$male60\",
	    \"total\": \"$total60\"	    
	\},"
    } 
     

    set result [string trimright $result ","]
    append result "\]\},"
    
}
    
    
set result [string trimright $result ","]
append result "\]\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
