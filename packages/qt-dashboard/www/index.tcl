ad_page_contract {}


ns_log Notice "Running TCL script index.tcl"

# Retrieves Yesterday's vehicles
db_0or1row select_vehicles_total {
    SELECT COUNT(ci.item_id) AS total
    FROM cr_items ci, cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND content_type = 'qt_vehicle'
    AND creation_date BETWEEN now() - INTERVAL '48 hours' AND now() - INTERVAL '24 hours'    
} -column_array yesterday

# Retrieves weekly's vehicles
db_0or1row select_vehicles_total {
    SELECT COUNT(ci.item_id) AS total
    FROM cr_items ci, cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND content_type = 'qt_vehicle'
    AND creation_date BETWEEN now() - INTERVAL '1 week' AND now()
} -column_array week

# Retrieves monthly vehicles 
db_0or1row select_vehicles_total {
    SELECT COUNT(ci.item_id) AS total
    FROM cr_items ci, cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND content_type = 'qt_vehicle'
    AND creation_date BETWEEN now() - INTERVAL '1 month' AND now()
    
} -column_array month



set total [db_string select_vehicles_total {
    SELECT COUNT(*)
    FROM cr_items ci, cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND content_type = 'qt_vehicle'
    AND creation_date BETWEEN now() - INTERVAL '24 hours' AND now()
    
} -default 0]

array set today [list \
		     total $total \
		     date [clock format [clock seconds] -format "%Y %h - %d"] \
		     diff [expr 100 - \
			       [expr [expr $total * 100] / $yesterday(total)]] \
		]





# Retrieves vehicles grouped by hour
# Reference: https://popsql.com/learn-sql/postgresql/how-to-group-by-time-in-postgresql
set data [db_list_of_lists select_vehicles_grouped_hourly {
    select date_trunc('hour', cr.creation_date) AS hour, COUNT(1)
    FROM cr_items ci, cr_revisionsx cr
    WHERE ci.item_id = cr.item_id
    AND ci.latest_revision = cr.revision_id
    AND ci.content_type = 'qt_vehicle'
    AND cr.creation_date BETWEEN now() - INTERVAL '22 hours' AND now()
    GROUP BY 1 ORDER BY hour;
}]


foreach elem $data {
    ns_log Notice "ELEM $elem"
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
    
    append data_html "\[\'${hour}h\', $total, \'#292D95\'\],"
}


ns_log Notice "DTA HTML $data_html" 

template::head::add_javascript -src "https://www.gstatic.com/charts/loader.js" -order 1
template::head::add_javascript -script {
    
} -order 2



template::head::add_css -href "/resources/qt-dashboard/styles/dashboard.css"
# <!-- Latest compiled and minified CSS -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"

# <!-- Optional theme -->
template::head::add_css -href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"

# <!-- Latest compiled and minified JavaScript -->
template::head::add_javascript -src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
