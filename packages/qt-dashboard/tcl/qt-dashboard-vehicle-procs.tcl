# /packages/qt-dashboard/tcl/qt-dashboard-procs.tcl
ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard::vehicle {}



ad_proc -public qt::dashboard::vehicle::export_csv {
    {-interval}
    {-date_from ""}
    {-date_to ""}
} {

    Export data to CSV file

} {
    set content_type qt_vehicle
    set creation_date [db_string select_now { SELECT now() - INTERVAL '5 hour' FROM dual}]
    set where_clauses ""

    if {$date_from ne ""} {
	if {![catch {set t [clock scan $date_from]} errmsg]} {
	    set creation_date $date_from
	    append where_clauses " AND o.creation_date::date >= :date_from::date "	
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    if {$date_to ne ""} {
	if {![catch {set t [clock scan $date_to]} errmsg]} {
	    append where_clauses " AND o.creation_date::date <= :date_to::date "
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    switch $interval {
	"hour" {
	    set textlabel "[_ qt-dashboard.Vehicles_total_hourly_per_day]"
	    set textlabel_datetime "[_ qt-dashboard.Hour]"
	    set sql "SELECT EXTRACT('hour' FROM o.creation_date) AS datetime, 
		COUNT(1) AS total
		FROM cr_items ci, acs_objects o, cr_revisions cr
		WHERE ci.item_id = o.object_id
		AND ci.item_id = cr.item_id
		AND ci.latest_revision = cr.revision_id
		AND ci.content_type = :content_type
		AND cr.title <> 'UNKNOWN'
		$where_clauses
		GROUP BY datetime ORDER BY datetime ASC"
	}
	"week" {
	    set textlabel "[_ qt-dashboard.Vehicles_total_daily_per_week]"
	    set textlabel_datetime "[_ qt-dashboard.Day]"
	    set sql "SELECT EXTRACT('dow' FROM o.creation_date) AS datetime, COUNT(1) AS total
		FROM cr_items ci, acs_objects o
		WHERE ci.item_id = o.object_id
		AND ci.content_type = :content_type
		$where_clauses
		GROUP BY datetime ORDER BY datetime;"
	}
	"month" {
	    set textlabel "[_ qt-dashboard.Vehicles_total_daily_per_month]"
	    set textlabel_datetime "[_ qt-dashboard.Day]"
	    set sql "SELECT date_trunc('day', o.creation_date)::date AS datetime, COUNT(1) AS total
		FROM cr_items ci, acs_objects o
		WHERE ci.item_id = o.object_id
		AND ci.content_type = :content_type
                $where_clauses
		GROUP BY 1 ORDER BY datetime;"
	}
    }
    
    
    set datasource [db_list_of_lists select_grouped_hour $sql]
    set max [list]
    foreach elem $datasource {
	if {[lindex $max 1]<[lindex $elem 1]} {
	    set dow [lindex $elem 0]
	    switch $dow   {
		0 { set dow "DOM" }
		1 { set dow "LUN" }
		2 { set dow "MAR" }
		3 { set dow "MIE" }
		4 { set dow "JUE" }
		5 { set dow "VIE" }
		6 { set dow "SAB" }
	    }
	    set max [list $dow [lindex $elem 1]]
	    
	}
    }
  
    template::list::create \
	-name vehicles \
	-multirow vehicles \
	-key item_id \
	-elements {
	    textinfo { label $textlabel }
	    datetime { label $textlabel_datetime }
	    total { label "[_ qt-dashboard.Total_Vehicles]" }	
	}
    
    
    set i 0
    db_multirow -extend { textinfo } vehicles select_vehicles $sql {
	set textinfo ""
	switch $interval {
	    "hour" {
		set datetime "${datetime}:00h"
	    }
	    "week" {
		switch $datetime {
		    0 { set datetime "DOM" }
		    1 { set datetime "LUN" }
		    2 { set datetime "MAR" }
		    3 { set datetime "MIE" }
		    4 { set datetime "JUE" }
		    5 { set datetime "VIE" }
		    6 { set datetime "SAB" }
		}
	    
	    }
	}
	
	switch $i {
	    1 {
		set creation_date [db_string select_now { SELECT now() - INTERVAL '5 hour' FROM dual}]
		set textinfo  "[_ qt-dashboard.Report_created_at] [lindex [split $creation_date "."] 0]"	    
	    }
	    2 {
		switch $interval {
		    "hour" {
			set textinfo  "[_ qt-dashboard.Busiest_hour] [lindex $max 0]h [_ qt-dashboard.with] [lindex $max 1] [_ qt-dashboard.vehicles]"
		    }
		    "week" {
			set textinfo  "[_ qt-dashboard.Busiest_day] [lindex $max 0] [_ qt-dashboard.with] [lindex $max 1] [_ qt-dashboard.vehicles]"
		    }
		    "month" {
			set textinfo  "[_ qt-dashboard.Busiest_day] [lindex $max 0] [_ qt-dashboard.with] [lindex $max 1] [_ qt-dashboard.vehicles]"
		    }
		}
	    }
	    4 {
		if {$date_from ne ""} {
		    set textinfo [_ qt-dashboard.Date_Range]
		}
	    }
	    5 {
		if {$date_from ne ""} {
		    set textinfo $date_from
		}
	    }
	    6 {
		if {$date_to ne ""} {
		    set textinfo $date_to
		}
	    }
	}
	incr i
    }
    
    qt::list::write_csv -name vehicles
    
    
    return
}





ad_proc qt::dashboard::vehicle::import_from_digital_ocean {} {
    Gets full JSON, converts JSON's response to TCL array, then converts the array into a TCL list, suing rl_json library, isolates page into @data and gets @item_id directly, accessing data with list poperties
    
    JSON's format
    
    # {"1":{"id":"41784","plate_number":"UNKNOWN","country_name":"Unknown","country_symbol":"??","first_seen":"2020-07-23
    #11:08:53","last_seen":"2020-07-23
    #11:08:54","probability":"0.4","location_name":"Test","camera_name":"LPR1","direction":"UNKNOWN","plate_image":"http:\/\/178.62.211.78\/plate_image_fa.php?id=41784","car_image":"http:\/\/178.62.211.78\/car_image_fa.php?id=41784"}}
    
    
} {
    ns_log Notice "Running ad_proc import vehicles"
    package require json
    package require rl_json
    namespace path {::rl_json}
    
    set last_req [util_text_to_url [lindex [split [db_string select_last_record { select MAX(creation_date) FROM cr_items ci, acs_objects o WHERE ci.item_id = o.object_id AND ci.content_type = 'qt_vehicle';} -default [clock scan seconds] ] "+"] 0] ]
    set url "http://178.62.211.78/io/lpr/trigger_with_response_qonteo.php?camera_id=16&last_req=$last_req&timeout=3&fast_answer=1&output_type=JSON"
    
    
    # Gets full JSON
    set result [util::http::get -url $url]
    # Converts JSON to TCL array
    array set arr $result
        
    if {[array exists arr] && $arr(status) == 200} {
	if {$arr(page) ne "Warning: empty answer!"} {
	    # Isolates page data
	    set data [json get $arr(page)]
	    #ns_log Notice "DATA $data"

	    
	    foreach {i elem} $data {
		set insert_p true
		array set arr2 $elem
		
		set item_id [db_nextval "acs_object_id_seq"]	    
		set creation_user 726
		set content_type qt_vehicle
		set storage_type "text"
		set package_id [apm_package_id_from_key qt-dashboard]
		set creation_ip "178.62.211.78"
		set creation_date $arr2(first_seen)
		set name $arr2(id)
		set description $elem
		set plate [lindex $description 3]
		
		if { [regexp {^([0-9]+)$} $plate] } {
		    ns_log Notice "IMPORTING VEHICLE ERROR: PLATE HAS ONLY NUMBERS NOT INSERTED"
		    set insert_p false 
		}

		#if {[lindex $elem 3] ne "UNKNOWN" && [db_string repeated_p {
		#    SELECT COUNT(ci.item_id)
		#    FROM cr_items ci, acs_objects o, cr_revisions cr
		#    WHERE ci.item_id = o.object_id
		#    AND ci.item_id = cr.item_id
		#    AND content_type = :content_type
		#    AND cr.title = :plate
		#    AND o.creation_date::timestamp >= :creation_date::timestamp - INTERVAL '9 minutes'
		#} -default 0] > 0 } {
		#    ns_log Notice "ERROR IMPORTING: VEHICLE $plate HAS BEEN SCANNED IN THE LAST 9 MINUTES, $creation_date \n $elem"
		    # set insert_p false
		#}
    
		if {$insert_p eq true} {
		    if {![db_0or1row item_exists {
			SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
		    }]} {	    		
			db_transaction {
			    set item_id [content::item::new \
					     -item_id $item_id \
					     -parent_id $package_id \
					     -creation_user $creation_user \
					     -package_id $package_id \
					     -creation_ip $creation_ip \
					     -creation_date $creation_date \
					     -name $name \
					     -title $plate \
					     -description $description \
					     -storage_type "$storage_type" \
					     -content_type $content_type \
					     -text $description \
					     -data $description \
					     -is_live "t" \
					     -mime_type "text/plain"
					]
			}	    	    
			
			ns_log Notice "New ITEM Vehicle Inserted $plate"
		    } else {
			
			db_1row item_exists {
			    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
			}
			
			set revision_id [content::revision::new \
					     -item_id $item_id \
					     -creation_user $creation_user \
					     -package_id $package_id \
					     -creation_ip $creation_ip \
					     -creation_date $creation_date \
					     -title $plate \
					     -description $description \
					     -content $description \
					     -mime_type "text/plain" \
					     -publish_date $creation_date \
					     -is_live "t" \
					     -storage_type "$storage_type" \
					     -content_type $content_type]
			
			ns_log Notice "New REVISION Vehicle Inserted $plate"
			
		    }
		}
	    }
	}
    }
    
    return 
}





ad_proc qt::dashboard::vehicle::import_new {
    {-json_text}
} {
    Gets full JSON, converts JSON's response to TCL array, then converts the array into a TCL list, suing rl_json library, isolates page into @data and gets @item_id directly, accessing data with list poperties
    
    JSON's format
    
    # {"1":{"id":"41784","plate_number":"UNKNOWN","country_name":"Unknown","country_symbol":"??","first_seen":"2020-07-23
    #11:08:53","last_seen":"2020-07-23
    #11:08:54","probability":"0.4","location_name":"Test","camera_name":"LPR1","direction":"UNKNOWN","plate_image":"http:\/\/178.62.211.78\/plate_image_fa.php?id=41784","car_image":"http:\/\/178.62.211.78\/car_image_fa.php?id=41784"}}
    
    
} {
 #   ns_log Notice "Running ad_proc import vehicles new"
    package require json
    set dict [json::json2dict [ns_getcontent -as_file false]]
#     ns_log Notice "DICT $dict"

    
    foreach {i elem} $dict {
	ns_log Notice "ELEM $elem"
	set insert_p true
	array set arr2 $elem
	
	set item_id [db_nextval "acs_object_id_seq"]	    
	set creation_user 726
	set content_type qt_vehicle
	set storage_type "text"
	set package_id [apm_package_id_from_key qt-dashboard]
	set creation_ip "178.62.211.78"
	set creation_date $arr2(first_seen)
	set description $elem
	set plate [lindex $elem 3]

	set name [util_text_to_url $plate]
	if {$plate eq "UNKNOWN"} {
	    set name "$name-$item_id"
	}
	
	if { [regexp {^([0-9]+)$} $plate] } {
	    ns_log Notice "IMPORTING VEHICLE ERROR: PLATE HAS ONLY NUMBERS NOT INSERTED"
	    set insert_p false 
	}


	
	#if {[lindex $elem 3] ne "UNKNOWN" && [db_string repeated_p {
	 #   SELECT COUNT(ci.item_id)
	  #  FROM cr_items ci, acs_objects o, cr_revisions cr
	   # WHERE ci.item_id = o.object_id
	    #AND ci.item_id = cr.item_id
	    #AND content_type = :content_type
	    #AND cr.title = :plate
	    #AND o.creation_date::timestamp >= :creation_date::timestamp - INTERVAL '9 minutes'
	#} -default 0] > 0 } {
	#    ns_log Notice "ERROR IMPORTING: VEHICLE $plate HAS BEEN SCANNED IN THE LAST 9 MINUTES, $creation_date \n $elem"
	    # set insert_p false
	#}
	
	if {$insert_p eq "true"} {
	    if {![db_0or1row item_exists {
		SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
	    }]} {	    		
		db_transaction {
		    set item_id [content::item::new \
				     -item_id $item_id \
				     -parent_id $package_id \
				     -creation_user $creation_user \
				     -package_id $package_id \
				     -creation_ip $creation_ip \
				     -creation_date $creation_date \
				     -name $name \
				     -title $plate \
				     -description $description \
				     -storage_type "$storage_type" \
				     -content_type $content_type \
				     -text $description \
				     -data $description \
				     -is_live "t" \
				     -mime_type "text/plain"
				]
		}	    	    
		
		ns_log Notice "New ITEM Vehicle Inserted $plate"
	    } else {
		
		db_1row item_exists {
		    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
		}
		
		set revision_id [content::revision::new \
				     -item_id $item_id \
				     -creation_user $creation_user \
				     -package_id $package_id \
				     -creation_ip $creation_ip \
				     -creation_date $creation_date \
				     -title $plate \
				     -description $description \
				     -content $description \
				     -mime_type "text/plain" \
				     -publish_date $creation_date \
				     -is_live "t" \
				     -storage_type "$storage_type" \
				     -content_type $content_type]
		
		ns_log Notice "New REVISION Vehicle Inserted $plate"
		
	    }
	}
    }
    
    
    return 
}
