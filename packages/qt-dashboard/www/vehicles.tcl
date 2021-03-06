ad_page_contract {}


ns_log Notice "Running TCL script index.tcl"

# Retrieves Yesterday's vehicles
db_0or1row select_vehicles_total {
    SELECT COUNT(ci.item_id) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
    AND o.creation_date BETWEEN now() - INTERVAL '48 hours' AND now() - INTERVAL '24 hours'    
} -column_array yesterday

# Retrieves weekly's vehicles
db_0or1row select_vehicles_total {
    SELECT COUNT(ci.item_id) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
    AND o.creation_date BETWEEN now() - INTERVAL '1 week' AND now()
} -column_array week

# Retrieves monthly vehicles 
db_0or1row select_vehicles_total {
    SELECT COUNT(ci.item_id) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
    AND o.creation_date BETWEEN now() - INTERVAL '1 month' AND now()
} -column_array month



set total [db_string select_vehicles_total {
    SELECT COUNT(ci.item_id)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
    AND o.creation_date BETWEEN now() - INTERVAL '24 hours' AND now()
} -default 0]

array set today [list \
		     total $total \
		     date [clock format [clock seconds] -format "%Y %h - %d"] \
		     diff [expr 100 - \
			       [expr [expr $total * 100] / $yesterday(total)]] \
		]





# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set daily_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('hour', o.creation_date) AS hour, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
  --  AND o.creation_date > now()::date
    AND o.creation_date BETWEEN now() - INTERVAL '22 hours' AND now()
    GROUP BY 1 ORDER BY hour;
    
}]


foreach elem $daily_data {
    set hour [lindex $elem 0]
    set total [lindex $elem 1]
    
    set hour [clock scan [lindex [split $hour "+"] 0]]
    # Extract the hour only. Colombia timezone GMT-5
    set hour [clock format $hour -format %H]
    switch $hour {
	"00" {
	    set hour 24
	}
	"08" {
	    set hour 8
	}
	"09" {
	    set hour 9
	}
    }
    set hour [expr abs([expr $hour - 5])]
    
    append daily_data_html "\[\'${hour}h\', $total, \'#05c105\'\],"
}










# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set weekly_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('day', o.creation_date) AS day, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
    AND o.creation_date BETWEEN now() - INTERVAL '1 week' AND now()
    GROUP BY 1 ORDER BY day;
}]


foreach elem $weekly_data {
    
    ns_log Notice "ELEM $elem"

    set day [lindex $elem 0]
    set total [lindex $elem 1]


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
    ns_log Notice "DAY $day"


    append weekly_data_html "\[\'$day\', $total, \'#292D95\'\],"
    
}







# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set monthly_data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('day', o.creation_date) AS day, COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = 'qt_vehicle'
    AND o.creation_date BETWEEN now() - INTERVAL '1 week' AND now()
    GROUP BY 1 ORDER BY day;
}]


foreach elem $monthly_data {
    
    ns_log Notice "ELEM $elem"

    set day [lc_time_fmt [lindex $elem 0] "%d/%b"] 
    
    set total [lindex $elem 1]

    append monthly_data_html "\[\'$day\', $total, \'#292D95\'\],"
    
}




template::head::add_javascript -src "https://www.gstatic.com/charts/loader.js" -order 1



template::head::add_css -href "/resources/qt-dashboard/styles/dashboard.css"
# <!-- Latest compiled and minified CSS -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"

# <!-- Optional theme -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"

# <!-- Latest compiled and minified JavaScript -->
template::head::add_javascript -src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
