# /packages/qt-rest/www/get-person-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {content_type "qt_face"}
    {date:optional}
    {age:boolean,optional}
    {heatmap:boolean,optional}
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
ns_log Notice "
    select date_trunc('hour', o.creation_date) AS hour,
    COUNT(1) AS total,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
    COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
    FROM cr_items ci, acs_objects o, cr_revisions cr
    WHERE ci.item_id = o.object_id
    AND ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = $content_type
    AND o.creation_date = $creation_date
    GROUP BY 1 ORDER BY hour ASC    "


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
	"0" { set dow "DOM $day" }
	"1" { set dow "LUN $day" }
	"2" { set dow "MAR $day" }
	"3" { set dow "MIE $day" }
	"4" { set dow "JUE $day" }
	"5" { set dow "VIE $day" }
	"6" { set dow "SAB $day" }
    }
    append result "\{\"day\": \"$day\", \"total\": $total\, \"female\": $female, \"male\": $male\},"
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



if {[info exists heatmap] && $heatmap eq true} {
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


if {[info exists age] && $age eq true} {
    append result "\{\"ageRanges\":\["
    db_foreach select_person_grouped_ageRange_daily {
	SELECT
	-- totalPersons
	date_trunc('day', o.creation_date) AS day, COUNT(1) AS total,
	-- persons < ageRange 18
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) < '18' THEN ci.item_id END) AS age18minus,
	-- Females ageRange < 18 
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) < '18' AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female18minus,
	-- Males ageRange < 18
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) < '18' AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male18minus,
	-- persons 18 <= ageRange < 25
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '18' AND SPLIT_PART(cr.description, ' ', 4) < '25' ) THEN ci.item_id END) AS age1825,
	-- Females 18 <= ageRange < 25
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '18' AND SPLIT_PART(cr.description, ' ', 4) < '25' ) AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female1825,
	-- Males 18 <= ageRange < 25
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '18' AND SPLIT_PART(cr.description, ' ', 4) < '25' ) AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male1825,
	-- persons 25 <= ageRange < 35    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '25' AND SPLIT_PART(cr.description, ' ', 4) <= '35' ) THEN ci.item_id END) AS age2535,
	-- females 25 <= ageRange < 25    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '25' AND SPLIT_PART(cr.description, ' ', 4) <= '35' ) AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female2535,
	-- males 25 <= ageRange < 25
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '25' AND SPLIT_PART(cr.description, ' ', 4) <= '35' ) AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male2535,
	-- persons 35 <= ageRange < 45    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '35' AND SPLIT_PART(cr.description, ' ', 4) <= '45' ) THEN ci.item_id END) AS age3545,
	-- females 35 <= ageRange < 45    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '35' AND SPLIT_PART(cr.description, ' ', 4) <= '45' ) AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female3545,
	-- males 35 <= ageRange < 45    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '35' AND SPLIT_PART(cr.description, ' ', 4) <= '45' ) AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male3545,
	-- persons 45 <= ageRange < 55    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '45' AND SPLIT_PART(cr.description, ' ', 4) <= '55' ) THEN ci.item_id END) AS age4555,
	-- females 45 <= ageRange < 55    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '45' AND SPLIT_PART(cr.description, ' ', 4) <= '55' ) AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female4555,
	-- males 45 <= ageRange < 55    
	COUNT(CASE WHEN ( SPLIT_PART(cr.description, ' ', 4) >= '45' AND SPLIT_PART(cr.description, ' ', 4) <= '55' ) AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male4555,
	-- persons ageRange <= 55    
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) >= '55' THEN ci.item_id END) AS age55plus,
	-- females ageRange <= 55    
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) >= '55' AND SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female55plus,
	-- males ageRange <= 55    
	COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 4) >= '55' AND SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male55plus
	FROM cr_items ci, acs_objects o, cr_revisions cr
	WHERE ci.item_id = o.object_id
	AND ci.item_id = cr.item_id
	AND ci.latest_revision = cr.revision_id
	AND ci.content_type = :content_type
	-- AND o.creation_date BETWEEN :creation_date::date - INTERVAL '6 day' AND :creation_date::date + INTERVAL '1 day'
	AND o.creation_date BETWEEN :creation_date::date - INTERVAL '1 month' AND :creation_date::date + INTERVAL '1 day'
	GROUP BY 1
	ORDER BY day ASC;
	
    } {
	set day [clock scan [lindex [split $day "+"] 0]]
	set day [clock format $day -format "%d/%m"]
	
	append result "\{\"day\": \"$day\", \"ranges\": \["
	append result "\{\"rangoEdad\": \"-18\", \"mujeres\": \"$female18minus\", \"hombres\": \"$male18minus\"\},"
	append result "\{\"rangoEdad\": \"18-25\", \"mujeres\": \"$female1825\", \"hombres\": \"$male1825\"\},"
	append result "\{\"rangoEdad\": \"25-35\", \"mujeres\": \"$female2535\", \"hombres\": \"$male2535\"\},"
	append result "\{\"rangoEdad\": \"35-45\", \"mujeres\": \"$female3545\", \"hombres\": \"$male3545\"\},"
	append result "\{\"rangoEdad\": \"45-55\", \"mujeres\": \"$female4555\", \"hombres\": \"$male4555\"\},"
	append result "\{\"rangoEdad\": \"+55\", \"mujeres\": \"$female55plus\", \"hombres\": \"$male55plus\"\}"
	append result "\]\},"
    }

    set result [string trimright $result ","]
    append result "\]\}"
    

}






set result [string trimright $result ","]
append result "\]\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
