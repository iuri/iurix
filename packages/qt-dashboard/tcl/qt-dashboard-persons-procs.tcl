# /packages/qt-dashboard/tcl/qt-dashboard-persons-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::dashboard::person {}

ad_proc -public qt::dashboard::person::export_csv {
    {-interval}
    {-date_from ""}
    {-date_to ""}
} {

    Export data from list::template  to CSV file

} {
    set content_type qt_face
    set creation_date [db_string select_now { SELECT now() - INTERVAL '5 hour' FROM dual}]
    set where_clauses ""

    if {$date_from ne ""} {
	if {![catch {set t [clock scan $date_from]} errmsg]} {
	    set creation_date $date_from
	    append where_clauses " AND o.creation_date::timestamp >= :date_from::timestamp "	
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    if {$date_to ne ""} {
	if {![catch {set t [clock scan $date_to]} errmsg]} {
	    append where_clauses " AND o.creation_date::timestamp <= :date_to::timestamp "
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }    
    switch $interval {
	"hour" {
	    set textlabel [_ qt-dashboard.Persons_total_hourly_per_day]
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
	    set textlabel [_ qt-dashboard.Persons_total_daily_per_week]
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
	    set textlabel [_ qt-dashboard.Persons_total_daily_per_month]
	    set sql "SELECT date_trunc('day', o.creation_date)::date AS datetime,
		COUNT(1) AS total,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '0' THEN ci.item_id END) AS female,
		COUNT(CASE WHEN SPLIT_PART(cr.description, ' ', 8) = '1' THEN ci.item_id END) AS male
		FROM cr_items ci, acs_objects o, cr_revisions cr
		WHERE ci.item_id = o.object_id
		AND ci.item_id = cr.item_id
		AND ci.latest_revision = cr.revision_id
		AND ci.content_type = :content_type
		AND date_trunc('month', o.creation_date::date) = date_trunc('month', :creation_date::date)
		GROUP BY 1 ORDER BY datetime;"
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
	-elements {
	    textinfo { label "$textlabel" }
	    datetime { label "Tiempo" }
	    total { label "Total" }	
	}
    
    
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
	    3 {
		switch $interval {
		    "hour" {
			set datetime "${datetime}:00h"
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
	    5 {
		if {$date_from ne ""} {
		    set textinfo [_ qt-dashboard.Date_Range]
		}
	    }
	    6 {
		if {$date_from ne ""} {
		    set textinfo $date_from
		}
	    }
	    7 {
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

    
    ns_log Notice "JSON \n $json_text"
    if {[llength $json_text] > 0} {
	array set arr $json_text
	
	if {[array exists arr]} {
	    ns_log Notice "ARRAY \n [parray arr]"	    
	
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
	    set content_type qt_face
	    set storage_type "text"
	    set parent_id $package_id	    	    
	    set attributes [lindex $arr(result) 1]
	    ns_log Notice "ATTRIBS $attributes"
	    
	    set name [lindex [lindex $attributes 0] 3]
	    set description "$arr(result) timestamp $arr(timestamp) authorization {$arr(authorization)}"
	    
	    ns_log Notice "NAME $name"
	    if {![db_0or1row item_exists {
		SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
	    }]} {	    
		ns_log Notice "-item_id $item_id \
				     -parent_id $parent_id \
				     -creation_user $creation_user \
				     -creation_ip $creation_ip \
                                     -cration_date $creation_date \
				     -package_id $package_id \
				     -name $name \
				     -title $name \
				     -description $description \
				     -storage_type $storage_type \
				     -content_type $content_type \
				     -mime_type text/plain"	       
		db_transaction {
		    set item_id [content::item::new \
				     -item_id $item_id \
				     -parent_id $parent_id \
				     -creation_user $creation_user \
				     -creation_ip $creation_ip \
				     -creation_date $creation_date \
				     -package_id $package_id \
				     -name $name \
				     -title $name \
				     -description $description \
				     -storage_type "$storage_type" \
				     -content_type $content_type \
				     -mime_type "text/plain"
				]
		}	    	    
	    } else {
		ns_log Notice "Face EXISTS"
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


