ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {type ""}    
} -validate {
    type_validation {
	if {$type ne "persons" && $type ne "vehicles"} {
	    # ad_return_complaint 1 "BAD HTTP REQUEST: Invalid type!" 
	    ns_respond -status 422 -type "text/plain charset=utf-8" -string "BAD HTTP REQUEST: Invalid type!"
	    ad_script_abort
	}
    }
}

switch $type {
    "vehicles" {
	set content_type "qt_vehicle"
    }
    "persons" {
	set content_type "qt_face"
    }
}

ns_log Notice "Running TCL script get-graphics.tcl"

set result "\{\"$type\": \["



# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set daily_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('hour', o.creation_date) AS hour, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND o.creation_date > now()::date
      --  AND o.creation_date BETWEEN now() - INTERVAL '28 hours' AND now()
    GROUP BY 1 ORDER BY hour ASC;
    
}]

append result "\{\"today\":\["
foreach elem $daily_data {
    set hour [lindex $elem 0]   
    set hour [clock scan [lindex [split $hour "+"] 0]]
    set hour [clock format $hour -format %H]

    set total [lindex $elem 1]

    append result "\{\"${hour}h\", $total, \"#05c105\"\},"
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
    AND o.creation_date BETWEEN now() - INTERVAL '6 day' AND now()
    GROUP BY 1 ORDER BY day;
}]

append result "\{\"week\":\["
foreach elem $weekly_data {
    set day [lindex $elem 0]
    set day [db_string select_dow {
	SELECT EXTRACT(dow from date :day); 
    } -default ""]
    switch $day {
	"0" {
	    set day "DOM"
	}
	"1" {
	    set day "LUN"
	}
	"2" {
	    set day "MAR"
	}
	"3" {
	    set day "MIE"
	}
	"4" {
	    set day "JUE"
	}
	"5" {
	    set day "VIE"
	}
	"6" {
	    set day "SAB"
	}
    }
    set total [lindex $elem 1]

    append result "\{\"$day\", $total, \"#292D95\"\},"
    
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
    AND o.creation_date BETWEEN now() - INTERVAL '1 month' AND now()
    GROUP BY 1 ORDER BY day;
}]

append result "\{\"month\":\["
foreach elem $monthly_data {
    set day [lc_time_fmt [lindex $elem 0] "%d/%b"]     
    set total [lindex $elem 1]

    append result "\{\"$day\", $total, \"#292D95\"\},"
}
set result [string trimright $result ","]
append result "\]\}"





append result "\]\}"





ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
