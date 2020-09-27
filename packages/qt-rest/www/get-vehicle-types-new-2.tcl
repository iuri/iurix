# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from:optional}
    {date_to:optional}
}
ns_log Notice "Running TCL script get-vehicle-types.tcl"


# Validate and Authenticate JWT
qt::rest::jwt::validation_p

set current_date  [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set creation_date [db_string select_now { SELECT (MIN(o.creation_date) - INTERVAL '5 hour')::date FROM cr_items ci, acs_objects o WHERE ci.item_id = o.object_id and ci.content_type = 'qt_vehicle'}]
set content_type "qt_vehicle"
set where_clauses ""

if {[info exists date_from]} {
    if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	append where_clauses " AND o.creation_date::date >= :date_from::date "	
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}


if {[info exists date_to]} {   
    if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	append where_clauses " AND o.creation_date::date <= :date_to::date"
    } else {
	ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	ad_script_abort    
    }
}



set datasource [db_list_of_lists  select_types_count "
    SELECT date_trunc('hour', o.creation_date) AS datetime, split_part(cr.description, ' ', 25) AS type, COUNT(1) AS count FROM cr_items ci, acs_objects o, cr_revisions cr WHERE ci.item_id = o.object_id AND ci.item_id = cr.item_id AND ci.latest_revision = cr.revision_id AND ci.content_type = 'qt_vehicle' $where_clauses GROUP BY datetime, type, 1 ORDER BY type;
"]

# ns_log Notice "DATASOURCE $datasource"

#lists  total today week month today_hour week_day total_avg
set bus [list 0 0 0 0 0 "" 0]
set car [list 0 0 0 0 0 "" 0]
set bike [list 0 0 0 0 0 "" 0]
set suv [list 0 0 0 0 0 "" 0]
set truck [list 0 0 0 0 0 "" 0]
set other [list 0 0 0 0 0 "" 0]
set van [list 0 0 0 0 0 "" 0]]

# aux storage to day of the week and quantity. USed to get the day of the week, which had the max quantity
set bus_dows [list]
set car_dows [list]
set bike_dows [list]
set suv_dows [list]
set truck_dows [list]
set other_dows [list]
set van_dows [list]

foreach elem $datasource {
    lassign $elem datetime type count
    set datetime [lindex [split $datetime "+"] 0]
    switch -exact $type {
	"Bus" {
	    # Calculate total
	    lset bus 0 [expr [lindex $bus 0] + $count]

	    # Filter current_date's quantity
	    if {[lc_time_fmt $datetime "%Y-%m-%d"] eq $current_date} {
		# calculate total quantity of current date
		lset bus 1 [expr [lindex $bus 1] + $count]				

		# Get hour of the day with max quantity
	    	if {$count > [lindex $bus 1]} {
		    lset bus 4 [lc_time_fmt $datetime %H:%M]
		}
	    }
	    # Filter quantities of the current week
	    if { [db_string select_week { select extract('week' from :datetime::date) }] eq
		 [db_string select_week { select extract('week' from :current_date::date) }] } {

		# get day of the week
		set dow [db_string select_dow { select extract('dow' from :datetime::date) }]

		# store day of the week and respective quantity in a auxiliary list
		if {[lsearch -index 0 $dows $dow] eq -1} {
		    lappend bus_dows [list $dow $count] 
		} else {
		    set idx [lsearch -index 0 $dows $dow]
		    lset bus_dows $idx [list $dow [expr $count + [lindex [lindex $dows $idx] 1]]]
		}

		# Calculate total quantity of the week
		lset bus 2 [expr [lindex $bus 2] + $count]
	    }	    
	    # Filter total quantity of the current month
	    if {[lc_time_fmt $datetime %m] eq [lc_time_fmt $current_date %m]} {
		lset bus 3 [expr [lindex $bus 3] + $count]
	    }	    
	    

	    
	}
	"Car" {
	    # Calculate total
	    lset car 0 [expr [lindex $car 0] + $count]

	    # Filter current_date's quantity
	    if {[lc_time_fmt $datetime "%Y-%m-%d"] eq $current_date} {
		# calculate total quantity of current date
		lset car 1 [expr [lindex $car 1] + $count]				

		# Get hour of the day with max quantity
	    	if {$count > [lindex $car 1]} {
		    lset car 4 [lc_time_fmt $datetime %H:%M]
		}
	    }
	    # Filter quantities of the current week
	    if { [db_string select_week { select extract('week' from :datetime::date) }] eq
		 [db_string select_week { select extract('week' from :current_date::date) }] } {

		# get day of the week
		set dow [db_string select_dow { select extract('dow' from :datetime::date) }]

		# store day of the week and respective quantity in a auxiliary list
		if {[lsearch -index 0 $dows $dow] eq -1} {
		    lappend car_dows [list $dow $count] 
		} else {
		    set idx [lsearch -index 0 $dows $dow]
		    lset car_dows $idx [list $dow [expr $count + [lindex [lindex $dows $idx] 1]]]
		}

		# Calculate total quantity of the week
		lset car 2 [expr [lindex $car 2] + $count]
	    }	    
	    # Filter total quantity of the current month
	    if {[lc_time_fmt $datetime %m] eq [lc_time_fmt $current_date %m]} {
		lset car 3 [expr [lindex $car 3] + $count]
	    }	    
	    
	}
	"Motorbike" {
	}
	"SUV/Pickup" {
	}
	"Truck" {
	}
	"Unknown" {
	}
	"Van" {
	}      
    }
}

ns_log Notice "DOWS $bus_dows"

append result "\{\"types\": \[ 
    \{\"bus\": \{\"total\": [lindex $bus 0], \"today\": [lindex $bus 1], \"week\": [lindex $bus 2], \"month\": [lindex $bus 3], \"today_hour\": \"[lindex $bus 4]\"\}\},
    \{\"car\": \{\"total\": [lindex $car 0], \"today\": [lindex $car 1], \"week\": [lindex $car 2], \"month\": [lindex $car 3]\}\},
    \{\"bike\": \{\"total\": [lindex $bike 0], \"today\": [lindex $bike 1], \"week\": [lindex $bike 2], \"month\": [lindex $bike 3]\}\},
    \{\"suv\": \{\"total\": [lindex $suv 0], \"today\": [lindex $suv 1], \"week\": [lindex $suv 2], \"month\": [lindex $suv 3]\}\},
    \{\"truck\": \{\"total\": [lindex $truck 0], \"today\": [lindex $truck 1], \"week\": [lindex $truck 2], \"month\": [lindex $truck 3]\}\},
    \{\"other\": \{\"total\": [lindex $other 0], \"today\": [lindex $other 1], \"week\": [lindex $other 2], \"month\": [lindex $other 3]\}\},
    \{\"van\": \{\"total\": [lindex $van 0], \"today\": [lindex $van 1], \"week\": [lindex $van 2], \"month\": [lindex $van 3]\}\}\],"




# Instant Data
set instant_data [db_list_of_lists select_instant_data {
    SELECT
    date_trunc('hour', o.creation_date) AS hour,
    COUNT(1) AS total
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
    AND date_trunc('month', o.creation_date::date) = date_trunc('month',:current_date::date)
    GROUP BY 1 ORDER BY hour;
}]

set today_total 0
set yesterday_total 0

set today $current_date
set yesterday [db_string select_yesterday { SELECT (:current_date::timestamp - INTERVAL '1 day')::date FROM dual}]
set i [expr [llength $instant_data] - 1]
while {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today || [lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
    if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $today} {
	set today_total [expr $today_total + [lindex [lindex $instant_data $i] 1]]							     
    }
    if {[lindex [split [lindex [lindex $instant_data $i] 0] " "] 0] eq $yesterday} {
	set yesterday_total [expr $yesterday_total + [lindex [lindex $instant_data $i] 1]]
    }
    set i [expr $i - 1]
}

if {$yesterday_total eq "" || $yesterday_total eq 0} {
    set yesterday_total [db_string select_yesterday {
	SELECT COUNT(1) AS total
	FROM cr_items ci, acs_objects o
	WHERE ci.item_id = o.object_id
	AND ci.content_type = :content_type
	AND o.creation_date::date = :current_date::date - INTERVAL '1 day'
    } -default 1]
}

set today_percent 0
if {$today_total ne 0 && $yesterday_total ne 0} {
    set today_percent [expr [expr [expr $today_total * 100] / $yesterday_total] - 100]
}




# To get the week total, we must get the last day stored (i.e. today's date), find out which day of the week it is, then to drecrease days untill 0 (i.e. last sunday where the week starts)
set week_total 0
set dow [db_string select_dow { SELECT EXTRACT(dow FROM date :current_date) } -default 6]
set i $dow
set j 0
while {$i>-1} {
    set elem [lindex $instant_data [expr [llength $instant_data] - $j -1]]
    set aux $elem
    while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	set week_total [expr $week_total + [lindex $aux 1]]	
	incr j
	set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]      
    }
    set i [expr $i - 1]    
}

set last_week_total 0
set i [expr $dow + 7]
set j 0
while {$i>$dow} {
    set elem [lindex $instant_data [expr [llength $instant_data] - $j-1]]
    set aux $elem
    while {[lindex [lindex $aux 0] 0] eq [lindex [lindex $elem 0] 0] && $aux ne ""} {
	set last_week_total [expr $last_week_total + [lindex $aux 1]]
	incr j
	set aux [lindex $instant_data [expr [llength $instant_data] - $j -1]]      
    }
    set i [expr $i - 1]
}


set week_percent 0
if {$week_total ne 0 && $last_week_total ne 0} {
    set week_percent [expr [expr [expr $week_total * 100] / $last_week_total] - 100]
}
		  

set total [db_string select_count_total {
    SELECT COUNT(1)
    FROM cr_items ci, acs_objects o
    WHERE ci.item_id = o.object_id
    AND ci.content_type = :content_type
} -default 0] 


append result "\"today_total\": $today_total,
    \"today_percent\": $today_percent,
    \"yesterday_total\": $yesterday_total,
    \"week_total\": $week_total,
    \"week_percent\": $week_percent,
    \"total\": $total,
    \"creation_date\": \"[lc_time_fmt $creation_date %Y-%m-%d]\",
    \"current_date\": \"[lc_time_fmt $current_date %Y-%m-%d]\"
\}"







# ns_log Notice "INSTANTDATA $datasource "

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
