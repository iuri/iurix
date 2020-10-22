# /packages/qt-rest/www/get-vehicle-graphics.tcl
ad_page_contract {
    API REST method to return cr_items qt_vehicle
} {
    {date_from ""}
    {date_to ""}
}
ns_log Notice "Running TCL script get-vehicle-graphics.tcl"


# Validate and Authenticate JWT
qt::rest::jwt::validation_p

set current_date  [db_string select_now { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
set creation_date [db_string select_creation_date { SELECT (MIN(creation_date) - INTERVAL '5 hour')::date FROM qt_vehicle_ti}]
set content_type "qt_vehicle"

set datasource [qt::dashboard::get_types_total_per_day -date_from $date_from -date_to $date_to]
# ns_log Notice "$datasource"

set today_data [db_list_of_lists  select_types_count "
    SELECT v.creation_date::date AS date, split_part(v.description, ' ', 25) AS type, COUNT(1) AS count FROM qt_vehicle_ti v WHERE v.creation_date::date = :current_date::date GROUP BY date, type, 1 ORDER BY date;"]

lappend datasource [lindex $today_data 0]






set ds_asd_today [db_list_of_lists select_avg_interval_per_type {
    WITH
    cte1 AS (
	     SELECT v1.title,
	     SPLIT_PART(v1.description, ' ', 25) AS type,
	     MIN(v1.creation_date::timestamp) AS min_entry
	     FROM qt_vehicle_ti v1
	     WHERE v1.creation_date::date = :current_date::date
	     AND v1.title != 'UNKNOWN'
	     AND SPLIT_PART(v1.description, ' ', 21) = 'Cam14'
	     GROUP BY v1.title, type
	     ORDER BY min_entry ASC
    ),
    cte2 AS (
	     SELECT v2.title,
	     SPLIT_PART(v2.description, ' ', 25) AS type,
	     MAX(v2.creation_date::timestamp) AS max_exit
	     FROM qt_vehicle_ti v2
	     WHERE v2.creation_date::date = :current_date
	     AND SPLIT_PART(v2.description, ' ', 21) = 'Cam11'
	     AND v2.title != 'UNKNOWN'	     
	     GROUP BY v2.title, type
	     ORDER BY max_exit ASC
    )
    SELECT cte1.type, AVG(cte2.max_exit - cte1.min_entry) AS diff
    FROM cte1, cte2
    WHERE cte2.max_exit BETWEEN cte1.min_entry AND cte1.min_entry + INTERVAL '30 minutes'
    GROUP BY cte1.type
    ORDER BY cte1.type    
} ]



set ds_asd_week [db_list_of_lists select_avg_interval_per_type {
    WITH
    cte1 AS (
	     SELECT v1.title,
	     SPLIT_PART(v1.description, ' ', 25) AS type,
	     MIN(v1.creation_date::timestamp) AS min_entry
	     FROM qt_vehicle_ti v1
	     WHERE EXTRACT('week' FROM v1.creation_date::date) = EXTRACT('week' FROM :current_date::date)
	     AND v1.title != 'UNKNOWN'
	     AND SPLIT_PART(v1.description, ' ', 21) = 'Cam14'
	     GROUP BY v1.title, type
	     ORDER BY min_entry ASC
    ),
    cte2 AS (
	     SELECT v2.title,
	     SPLIT_PART(v2.description, ' ', 25) AS type,
	     MAX(v2.creation_date::timestamp) AS max_exit
	     FROM qt_vehicle_ti v2
	     WHERE EXTRACT('week' FROM v2.creation_date::date) = EXTRACT('week' FROM :current_date::date)
	     AND SPLIT_PART(v2.description, ' ', 21) = 'Cam11'
	     AND v2.title != 'UNKNOWN'	     
	     GROUP BY v2.title, type
	     ORDER BY max_exit ASC
    )
    SELECT cte1.type, AVG(cte2.max_exit - cte1.min_entry) AS diff
    FROM cte1, cte2
    WHERE cte2.max_exit BETWEEN cte1.min_entry AND cte1.min_entry + INTERVAL '30 minutes'
    GROUP BY cte1.type
    ORDER BY cte1.type    
} ]




set ds_asd_month [db_list_of_lists select_avg_interval_per_type {
    WITH
    cte1 AS (
	     SELECT v1.title,
	     SPLIT_PART(v1.description, ' ', 25) AS type,
	     MIN(v1.creation_date::timestamp) AS min_entry
	     FROM qt_vehicle_ti v1
	     WHERE EXTRACT('month' FROM v1.creation_date::date) = EXTRACT('month' FROM :current_date::date)
	     AND v1.title != 'UNKNOWN'
	     AND SPLIT_PART(v1.description, ' ', 21) = 'Cam14'
	     GROUP BY v1.title, type
	     ORDER BY min_entry ASC
    ),
    cte2 AS (
	     SELECT v2.title,
	     SPLIT_PART(v2.description, ' ', 25) AS type,
	     MAX(v2.creation_date::timestamp) AS max_exit
	     FROM qt_vehicle_ti v2
	     WHERE EXTRACT('month' FROM v2.creation_date::date) = EXTRACT('month' FROM :current_date::date)
	     AND SPLIT_PART(v2.description, ' ', 21) = 'Cam11'
	     AND v2.title != 'UNKNOWN'	     
	     GROUP BY v2.title, type
	     ORDER BY max_exit ASC
    )
    SELECT cte1.type, AVG(cte2.max_exit - cte1.min_entry) AS diff
    FROM cte1, cte2
    WHERE cte2.max_exit BETWEEN cte1.min_entry AND cte1.min_entry + INTERVAL '30 minutes'
    GROUP BY cte1.type
    ORDER BY cte1.type    
} ]




ns_log Notice "MONTH $ds_asd_month"

#lists  total today week month today-ASD week-ASD month-ASD
set bus [list 0 0 0 0 00:00:00 00:00:00 00:00:00]
set car [list 0 0 0 0 00:00:00 00:00:00 00:00:00]
set bike [list 0 0 0 0 00:00:00 00:00:00 00:00:00]
set suv [list 0 0 0 0 00:00:00 00:00:00 00:00:00]
set truck [list 0 0 0 0 00:00:00 00:00:00 00:00:00]
set other [list 0 0 0 0 00:00:00 00:00:00 00:00:00]
set van [list 0 0 0 0 00:00:00 00:00:00 00:00:00]

foreach elem $datasource {
    lassign $elem date type count
    switch -exact $type {
	"Bus" {
	    lset bus 0 [expr [lindex $bus 0] + $count]
	
	    if {$date eq $current_date} {
		lset bus 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset bus 2 [expr [lindex $bus 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset bus 3 [expr [lindex $bus 3] + $count]
	    }

	    lset bus 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"
	    lset bus 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"
	    lset bus 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"
	}
	"Car" {
	    lset car 0 [expr [lindex $car 0] + $count]
	
	    if {$date eq $current_date} {
		lset car 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset car 2 [expr [lindex $car 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset car 3 [expr [lindex $car 3] + $count]
	    }	    

	    lset car 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"
	    lset car 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"
	    lset car 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"
	}
	"Motorbike" {
	    lset bike 0 [expr [lindex $bike 0] + $count]
	
	    if {$date eq $current_date} {
		lset bike 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset bike 2 [expr [lindex $bike 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset bike 3 [expr [lindex $bike 3] + $count]
	    }    

	    lset bike 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"
	    lset bike 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"
	    lset bike 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"

	}
	"SUV/Pickup" {
	    lset suv 0 [expr [lindex $suv 0] + $count]
	
	    if {$date eq $current_date} {
		lset suv 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset suv 2 [expr [lindex $suv 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset suv 3 [expr [lindex $suv 3] + $count]
	    }

	    lset suv 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"

	    lset suv 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"

	    lset suv 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"

	}
	"Truck" {
	    lset truck 0 [expr [lindex $truck 0] + $count]
	
	    if {$date eq $current_date} {
		lset truck 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset truck 2 [expr [lindex $truck 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset truck 3 [expr [lindex $truck 3] + $count]
	    }

	    lset truck 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"
	    lset truck 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"
	    lset truck 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"
	}
	"Unknown" {
	    lset other 0 [expr [lindex $other 0] + $count]
	
	    if {$date eq $current_date} {
		lset other 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset other 2 [expr [lindex $other 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset other 3 [expr [lindex $other 3] + $count]
	    }

	    lset other 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"
	    lset other 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"
	    lset other 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"
	}
	"Van" {
	    lset van 0 [expr [lindex $van 0] + $count]
	
	    if {$date eq $current_date} {
		lset van 1 $count
	    }
	    if { [db_string select_week { select extract('week' from :date::date) as week; }] eq
		 [db_string select_week { select extract('week' from :current_date::date) as week; }] } {
		lset van 2 [expr [lindex $van 2] + $count]
	    }
	    if {[lc_time_fmt $date -format %m] eq [lc_time_fmt $date -format %m]} {
		lset van 3 [expr [lindex $van 3] + $count]
	    }

	    lset van 4 "[lindex [split [lindex [lindex $ds_asd_today [lsearch -index 0 $ds_asd_today $type]] 1] "."] 0] MIN"
	    lset van 5 "[lindex [split [lindex [lindex $ds_asd_week [lsearch -index 0 $ds_asd_week $type]] 1] "."] 0] MIN"
	    lset van 6 "[lindex [split [lindex [lindex $ds_asd_month [lsearch -index 0 $ds_asd_month $type]] 1] "."] 0] MIN"
	}      
    }
}


append result "\{\"types\": \[ 
    \{\"bus\": \{\"total\": [lindex $bus 0], \"today\": [lindex $bus 1], \"week\": [lindex $bus 2], \"month\": [lindex $bus 3], \"asd_today\": \"[lindex $bus 4]\", \"asd_week\": \"[lindex $bus 5]\", \"asd_month\": \"[lindex $bus 6]\"\}\},
    \{\"car\": \{\"total\": [lindex $car 0], \"today\": [lindex $car 1], \"week\": [lindex $car 2], \"month\": [lindex $car 3], \"asd_today\": \"[lindex $car 4]\", \"asd_week\": \"[lindex $car 5]\", \"asd_month\": \"[lindex $car 6]\"\}\},
    \{\"bike\": \{\"total\": [lindex $bike 0], \"today\": [lindex $bike 1], \"week\": [lindex $bike 2], \"month\": [lindex $bike 3], \"asd_today\": \"[lindex $bike 4]\", \"asd_week\": \"[lindex $bike 5]\", \"asd_month\": \"[lindex $bike 6]\"\}\},
    \{\"suv\": \{\"total\": [lindex $suv 0], \"today\": [lindex $suv 1], \"week\": [lindex $suv 2], \"month\": [lindex $suv 3], \"asd_today\": \"[lindex $suv 4]\", \"asd_week\": \"[lindex $suv 5]\", \"asd_month\": \"[lindex $suv 6]\"\}\},
    \{\"truck\": \{\"total\": [lindex $truck 0], \"today\": [lindex $truck 1], \"week\": [lindex $truck 2], \"month\": [lindex $truck 3], \"asd_today\": \"[lindex $truck 4]\", \"asd_week\": \"[lindex $truck 5]\", \"asd_month\": \"[lindex $truck 6]\"\}\},
    \{\"other\": \{\"total\": [lindex $other 0], \"today\": [lindex $other 1], \"week\": [lindex $other 2], \"month\": [lindex $other 3], \"asd_today\": \"[lindex $other 4]\", \"asd_week\": \"[lindex $other 5]\", \"asd_month\": \"[lindex $other 6]\"\}\},
    \{\"van\": \{\"total\": [lindex $van 0], \"today\": [lindex $van 1], \"week\": [lindex $van 2], \"month\": [lindex $van 3], \"asd_today\": \"[lindex $van 4]\", \"asd_week\": \"[lindex $van 5]\", \"asd_month\": \"[lindex $van 6]\"\}\}\],"




# Instant Data
set instant_data [db_list_of_lists select_instant_data {
    SELECT
    date_trunc('hour', v.creation_date - INTERVAL '5 hour') AS hour,
    COUNT(1) AS total
    FROM qt_vehicle_ti v
    WHERE date_trunc('month', v.creation_date::date) = date_trunc('month', :current_date::date)
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
	FROM qt_vehicle_ti v
	WHERE v.creation_date::date = :current_date::date - INTERVAL '1 day'
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
    SELECT COUNT(DISTINCT(item_id)) FROM qt_vehicle_ti;
} -default 0] 


append result "\"today_total\": $today_total,
    \"today_percent\": $today_percent,
    \"yesterday_total\": $yesterday_total,
    \"week_total\": $week_total,
    \"week_percent\": $week_percent,
    \"total\": $total,
    \"creation_date\": \"[lc_time_fmt $creation_date %Y-%m-%d]\",
    \"current_date\": \"[lc_time_fmt $current_date %Y-%m-%d]\"\}"












# ns_log Notice "INSTANTDATA $datasource "

ns_respond -status 200 -type "application/json" -string $result
ad_script_abort
