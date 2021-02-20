# /packages/qt-dashboard/tcl/qt-dashboard-persons-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::dashboard::person {}


# Schedule procs
## BEGIN
ad_proc -public qt::dashboard::person::update_totals {} {

    Updates qt_face_range_totals and qt_face_totals tables from qt_faces
} {

    qt::dashboard::person::update_count_totals
    qt::dashboard::person::update_range_totals
}


    
ad_proc -public qt::dashboard::person::update_range_totals {} {
    Updates qt_face_range_totals table from qt_faces
} {
    ns_log Notice "Running TCL script ad_proc schedule dashboard::person::update_range_totals.tcl"
     
    set creation_date [db_string select_now { SELECT date_trunc('hour', now()::timestamp - INTERVAL '5 hour') FROM dual}]
    #    set creation_date "2018-01-15 00:00:00"
    ns_log Notice "CREATION DATE $creation_date"
    
    set hostnames [list PMXCO001 CCPN001 CCPN002]
    foreach hostname $hostnames {
	
	if {$hostname eq "PMXCO001"} {
	    set where_clauses " AND SPLIT_PART(f.description, ' ', 37) != 'CCPN001\}' AND SPLIT_PART(f.description, ' ', 37) != 'CCPN002\}'"
	} else {
	    set where_clauses " AND SPLIT_PART(f.description, ' ', 37) = '${hostname}\}'"
	}
	
	db_foreach select_grouped_per_range "
	    SELECT
	    DATE_TRUNC('hour', o.creation_date::timestamp) AS hour,
	    CASE WHEN SPLIT_PART(f.description, ' ', 4) <> 'undefined' THEN ROUND(SPLIT_PART(f.description, ' ',4)::numeric) END AS range,
	    COUNT(1) AS total,
	    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS total_female,
	    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS total_male
	    FROM qt_face_tx f, acs_objects o
	    WHERE f.item_id = o.object_id
	    $where_clauses
	    AND o.creation_date::date >= :creation_date::date 
	    GROUP BY hour, range
	    ORDER BY hour;
	" {
	    set percentage ""
	    # set hostname "PMXCO001"
	    # set hostname "CCPN001"
	    # set hostname "CCPN002"
	    
	    ns_log Notice "$hour | $range | $total | $total_female | $total_male | $hostname "
	    
	    db_0or1row exists_total_p {
		SELECT range_id, total AS old_total,
		total_female,
		total_male,
		creation_date AS old_date,
		hostname AS old_host
		FROM qt_face_range_totals
		WHERE hostname = :hostname
		AND range = :range
		AND creation_date = DATE_TRUNC('hour', :hour::timestamp) 
	    }
	    
	    if {[info exists range_id]} {
		if {$old_total ne $total} {
		    ns_log Notice "UPDATE TOTALS $range_id | $range | $total | $total_female | $total_male | $old_date | $old_host"
		    db_transaction {
			db_exec_plsql update_totals {
			    SELECT qt_face_range_totals__edit(
							      :range_id,
							      :range,
							      :total,
							      :total_female,
							      :total_male,
							      :percentage)
			}   
		    }
		}		
	    } else {
		ns_log Notice "ADDING NEW TOTAL "
		#		ns_log Notice "$hour $total $female $male $hostname"
		
		db_transaction {
		    db_exec_plsql insert_totals {
			SELECT qt_face_range_totals__new(
							 null,
							 :range,
							 :hour,
							 :total,
							 :total_female,
							 :total_male,
							 :percentage,
							 :hostname,
							 'qt_face')		    
		    }
		}
	    }	    	    
	}   
    }
    
    return 
}



ad_proc -public qt::dashboard::person::update_count_totals {} {
    Updates qt_face_totals tables from qt_faces
} {
    ns_log Notice "Running TCL script ad_proc schedule dashboard::person::update_count_totals.tcl"
     
    set creation_date [db_string select_now { SELECT date_trunc('hour', now()::timestamp - INTERVAL '5 hour') FROM dual}]
    # set creation_date "2021-01-15 00:00:00"
#    ns_log Notice "CREATION DATE $creation_date"
    
    set hostnames [list CCPN001 CCPN002]
    foreach hostname $hostnames {
	#ns_log Notice "Hostname $hostname"
	
	db_foreach select_grouped_per_hour "
	    SELECT DATE_TRUNC('hour', o.creation_date::timestamp) AS hour,
	    COUNT(1) AS total,
	    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '0' THEN f.item_id END) AS total_female,
	    COUNT(CASE WHEN SPLIT_PART(f.description, ' ', 8) = '1' THEN f.item_id END) AS total_male
	    FROM qt_face_tx f, acs_objects o
	    WHERE f.item_id = o.object_id
	    AND o.creation_date::date >= :creation_date::date 
	    AND SPLIT_PART(f.description, ' ', 37) = '${hostname}\}'
	    GROUP BY 1
	    ORDER BY hour ASC   
	" {
	    
	    set percentage ""
	    # set hostname "PMXCO001"
	    # set hostname "CCPN001"
	    # set hostname "CCPN002"
	    
	    ns_log Notice "$total | $female | $male | $hostname | [db_string select_hour { SELECT DATE_TRUNC('hour', :hour::timestamp) FROM dual} ]"
	    
	    db_0or1row exists_total_p {
		SELECT total_id AS total_id, total, total_female, total_male, creation_date AS old_date, hostname AS old_host
		FROM qt_totals
		WHERE hostname = :hostname
		AND creation_date = DATE_TRUNC('hour', :hour::timestamp) 
	    }
	    
	    if {[info exists total_id]} {
		if {$total1 ne $total} {
		    ns_log Notice "UPDATE TOTALS $total_id | $total1 | $total2 | $total3 | $old_date | $old_host"
		    db_transaction {
			db_exec_plsql update_totals {
			    SELECT qt_face_totals__edit(
					       :total_id,
					       :total,
					       :total_female,
					       :total_male,
					       :percentage)
			}   
		    }
		}
		unset total_id
		unset total1
		unset total2
		unset total3
		unset old_date
		unset old_host
		
	    } else {
		ns_log Notice "ADDING NEW TOTAL "
#		ns_log Notice "$hour $total $female $male $hostname"
		
		db_transaction {
		    db_exec_plsql insert_totals {
			SELECT qt_face_totals__new(null,
						   :hour,
						   :total,
						   :total_female,
						   :total_male,
						   :percentage,
						   :hostname,
						   'qt_face')		    
		    }
		}
	    }
	}   
    }
    return 
}




## END




ad_proc -public qt::dashboard::person::export_heatmap_csv {
    {-interval}
    {-date_from ""}
    {-date_to ""}
} {

    Export data from list::template  to CSV file

} {
    ns_log Notice "Running HEATMAP"
    set content_type qt_face
    set creation_date [db_string select_now { SELECT (now() - INTERVAL '5 hour')::date FROM dual}]
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

    
    set elements {
	textinfo {label "TOTAL SEMANA ACUMULADO PERSONAS POR HORA DEL DIA"}
	hour {label "HORA"}
    } 
       
#    qt::list::write_csv -name persons
    return


}


ad_proc -public qt::dashboard::person::export_csv {
    {-interval}
    {-date_from ""}
    {-date_to ""}
    {-gender ""}
} {

    Export data from list::template  to CSV file

} {
    set content_type qt_face
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
	    set textlabel "[_ qt-dashboard.Persons_total_hourly_per_day]"
	    set textlabel_datetime "[_ qt-dashboard.Hour]"
	    set sql "SELECT EXTRACT('hour' FROM o.creation_date) AS datetime,
		COUNT(1) AS total,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
		FROM cr_items ci, acs_objects o, cr_revisions cr
		WHERE ci.item_id = o.object_id
		AND ci.item_id = cr.item_id
		AND ci.latest_revision = cr.revision_id
		AND ci.content_type = :content_type
		$where_clauses
		GROUP BY 1 ORDER BY datetime ASC"

	    	    
	}
	"week" {
	    set textlabel "[_ qt-dashboard.Persons_total_daily_per_week]"
	    set textlabel_datetime "[_ qt-dashboard.Day]"

	    set sql "SELECT EXTRACT('dow' FROM o.creation_date) AS datetime,
		COUNT(1) AS total,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
		FROM cr_items ci, acs_objects o, cr_revisions cr
		WHERE ci.item_id = o.object_id
		AND ci.item_id = cr.item_id
		AND ci.latest_revision = cr.revision_id    
		AND ci.content_type = :content_type
		$where_clauses
		GROUP BY 1 ORDER BY datetime;"	    
	    
	}
	"month" {
	    set textlabel "[_ qt-dashboard.Persons_total_daily_per_month]"
	    set textlabel_datetime "[_ qt-dashboard.Day]"
	    set sql "SELECT EXTRACT('day' FROM o.creation_date) AS datetime,
		COUNT(1) AS total,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
		FROM cr_items ci, acs_objects o, cr_revisions cr
		WHERE ci.item_id = o.object_id
		AND ci.item_id = cr.item_id
		AND ci.latest_revision = cr.revision_id
		AND ci.content_type = :content_type
		$where_clauses
		GROUP BY 1 ORDER BY datetime;"
	}
    }


    set elements [list \
		      textinfo [list label $textlabel] \
		      datetime [list label $textlabel_datetime]]
    switch $gender {
	"w" {	    
	    lappend elements female [list label "Mujeres"]
	}
	"m" {
	    lappend elements male [list label "Hombres"]
	    
	}
	default {
	    lappend elements total [list label "Total"] \
		female [list label "Mujeres"] \
		male [list label "Hombres"]
	}
    }

    set datasource [db_list_of_lists select_grouped_hour $sql]
    set max [list]
    foreach elem $datasource {
	if {[lindex $max 1]<[lindex $elem 1]} {
	    set max $elem
	}
	if {[lindex $max 2]<[lindex $elem 2]} {
	    set max $elem
	}
	if {[lindex $max 3]<[lindex $elem 3]} {
	    set max $elem
	}	
    }
    




    
    template::list::create \
	-name persons \
	-multirow persons \
	-key item_id \
	-elements $elements
    
    set i 0
    db_multirow -extend { textinfo } persons select_persons $sql {	
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
			set datetime "${datetime}"
			set textinfo  "[_ qt-dashboard.Busiest_hour] [lindex $max 0] [_ qt-dashboard.with] [lindex $max 1] [_ qt-dashboard.persons], [lindex $max 2] [_ qt-dashboard.Women] y [lindex $max 3] [_ qt-dashboard.Men]"
		    }
		    "week" {
			set textinfo  "[_ qt-dashboard.Busiest_day] $datetime [_ qt-dashboard.with] [lindex $max 1] [_ qt-dashboard.persons], [lindex $max 2] [_ qt-dashboard.Women] y [lindex $max 3] [_ qt-dashboard.Men]"
		    }
		    "month" {
			set textinfo  "[_ qt-dashboard.Busiest_day] $datetime [_ qt-dashboard.with] [lindex $max 1] [_ qt-dashboard.persons], [lindex $max 2] [_ qt-dashboard.Women] y [lindex $max 3] [_ qt-dashboard.Men]"
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
		if {[info exists date_to] } {
		    set textinfo $date_to
		}
	    }
	}
	incr i
    }
    
    qt::list::write_csv -name persons
    
    
    return
}



ad_proc -public qt::dashboard::person::import {
    -json_text
} {
    Gets full JSON, converts JSON's response to TCL array, then converts the array into a TCL list, suing rl_json library, isolates page into @data and gets @item_id directly, accessing data with list poperties

    Format Reference:
    "result":{"faces":[{"attributes":{"age":40.4277687073,"eyeglasses":0,"gender":1},"id":"71f91150-e8dc-41d1-b94e-52f037b83624","rect":{"height":164,"width":129,"x":55,"y":60},"score":0.9653117061,"rectISO":{"height":315,"width":236,"x":9,"y":-24}}]},"timestamp":1594603141.1834712029,"source":"descriptors","event_type":"extract","authorization":"basic"


    
} {

    
#    ns_log Notice "JSON \n $json_text"
    if {[llength $json_text] > 0} {
	array set arr $json_text
	
	if {[array exists arr]} {
#	    ns_log Notice "ARRAY \n [parray arr]"	    
	
	    set item_id [db_nextval "acs_object_id_seq"]
	    
	    # Inserting Face
	    set creation_user 726
	    set creation_ip "192.199.241.130"
	    set epoch $arr(timestamp)
	    set creation_date [db_string select_timestamp {
		SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :epoch * INTERVAL '1 second' - INTERVAL '5 hour';
	    }]
	    set creation_date [lindex [split $creation_date  "."] 0] 	    
	    # set creation_date [clock format $arr(timestamp)]
	    set package_id [apm_package_id_from_key qt-dashboard]
	    set parent_id $package_id
	    set attributes [lindex $arr(result) 1]
#	    ns_log Notice "ATTRIBS $attributes"
	    
	    set name [lindex [lindex $attributes 0] 3]
	    set description "$arr(result) timestamp $arr(timestamp) authorization {$arr(authorization)}"
	    
	    if {![db_0or1row item_exists {
		SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
	    }]} {	    
		db_transaction {
		    set item_id [content::item::new \
				     -item_id $item_id \
				     -parent_id $package_id \
				     -creation_user $creation_user \
				     -creation_ip $creation_ip \
				     -creation_date $creation_date \
				     -package_id $package_id \
				     -name $name \
				     -title $name \
				     -description $description \
				     -storage_type text \
				     -content_type qt_face \
				     -mime_type "text/plain"
				]
		}	    	    
	    } else {
		db_1row item_exists {
		    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
		}
	    }	    	  	    	    
	}
    }
}
    
    



ad_proc qt::dashboard::person::get {
    {-url}
    {-body}
} {
    It retrieves quantity of persons in the requested period of time

    RESPONSE Example 
    # status 200 time 0:2511 headers d5 body {[{"genero":"Femenino","COUNT(*)":10},{"genero":"Masculino","COUNT(*)":308}]} https {sslversion TLSv1.2 cipher ECDHE-RSA-CHACHA20-POLY1305}

    
} {
    

    
    
    
    ns_log Notice "BODY $body"
    
    #######################
    # submit POST request
    #######################
    set requestHeaders [ns_set create]
    set replyHeaders [ns_set create]
    ns_set update $requestHeaders "Content-type" "application/json"
    
    set h [ns_http queue -method POST \
	       -headers $requestHeaders \
	       -timeout 60.0 \
	       -body $body \
	       $url]
    set result [ns_http wait $h]
    
    #######################
    # output results
    #######################
    # ns_log notice "status [dict get $result status]"
    
    ns_log Notice "RESLUT $result"
    
    ns_log Notice "STATUS [dict get $result status]"

    ns_log Notice "BODY [dict get $result body]"

    return $result
    
}


