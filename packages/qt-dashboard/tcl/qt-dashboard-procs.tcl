# /packages/qt-dashboard/tcl/qt-dashboard-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::websocket {}



ad_proc qt::dashboard::get_past_totals_per_hour_not_cached {
    {-date_from ""}
    {-date_to ""}
} {
    It returns a list of lists within totals of vehicles per hour starting from yesterday's results untill the very begining
} {

    set where_clauses ""
    set current_date [db_string select_timestamp { SELECT date(now() - INTERVAL '5 hour') FROM dual}]
    
    if {$date_from ne ""} {
	if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date >= :date_from::date "	
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    
    if {$date_to ne ""} {   
	if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date <= :date_to::date"
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    return [db_list_of_lists select_past_totals_per_hour ""]
}


ad_proc qt::dashboard::get_past_totals_per_hour {
    {-date_from ""}
    {-date_to ""}
} {
    It returns a list of lists within totals of vehicles per hour starting from yesterday's results untill the very begining
} {

    
    set where_clauses ""
    
    if {$date_from ne ""} {
	if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date >= :date_from::date "	
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    
    if {$date_to ne ""} {   
	if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date <= :date_to::date"
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    
    set result [util_memoize [list qt::dashboard::get_past_totals_per_hour_not_cached -date_from $date_from -date_to $date_to]]
    
    if {[llength $result] eq 0} {
	util_memoize_flush [list qt::dashboard::get_past_totals_per_hour_not_cached -date_from $date_from -date_to $date_to]
    }
    
    return $result
}







ad_proc qt::dashboard::get_types_total_per_day_not_cached {
    {-date_from ""}
    {-date_to ""}
} {
    It returns a list of lists within types and totals grouped per day

    date    |    type    | count
    ------------+------------+-------
    2020-07-11 | Bus        |    71
    2020-07-11 | Car        |  5919
    2020-07-11 | SUV/Pickup |    68
    2020-07-11 | Truck      |   644
    2020-07-11 | Unknown    |   334
    2020-07-11 | Van        |   274
...
} {

    set where_clauses ""

    if {$date_from ne ""} {
	if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date >= :date_from::date "	
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    
    if {$date_to ne ""} {   
	if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date <= :date_to::date"
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    return [db_list_of_lists select_types_count ""]
}







ad_proc qt::dashboard::get_types_total_per_day {
    {-date_from ""}
    {-date_to ""}
} {
    It returns a list of lists within types and totals grouped per day

    date    |    type    | count
    ------------+------------+-------
    2020-07-11 | Bus        |    71
    2020-07-11 | Car        |  5919
    2020-07-11 | SUV/Pickup |    68
    2020-07-11 | Truck      |   644
    2020-07-11 | Unknown    |   334
    2020-07-11 | Van        |   274
...
} {

    set where_clauses ""

    if {$date_from ne ""} {
	if {![catch {db_1row validate_date { SELECT :date_from::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date >= :date_from::date "	
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }
    
    
    if {$date_to ne ""} {   
	if {![catch { db_1row validate_date { select :date_to::date FROM dual } } errmsg]} {
	    append where_clauses " AND date::date <= :date_to::date"
	} else {
	    ns_respond -status 422 -type "text/plain" -string "Unprocessable Entity! $errmsg"
	    ad_script_abort    
	}
    }

    set result [util_memoize [list qt::dashboard::get_types_total_per_day_not_cached -date_from $date_from -date_to $date_to]]
    
    if {[llength $result] eq 0} {
	util_memoize_flush [list qt::dashboard::get_types_total_per_day_not_cached -date_from $date_from -date_to $date_to]
    }
    
    return $result
    
}



















ad_proc qt::websocket::listen {} {
    It listens to Luna Stats & Events Service to get data faces in the json format
} {
    
    package require json
    package require rl_json
    namespace path {::rl_json}
    
    
    set WebSocketUri [parameter::get_global_value -parameter "WebSocketUri" -package_key "qt-dashboard" -default ""]
    
    # set url "ws://192.199.241.130:5008/api/subscribe?auth_token=9fb6e731-b342-4952-b0c1-aa1d0b52757b&event_type=extract"
    #set url "wss://javascript.info/article/websocket/demo/hello"
    
    if {$WebSocketUri ne ""} {
	set channel [ws::client::open $WebSocketUri]
	
	while {1} {
	    set status_p [parameter::get_global_value -parameter "WebSocketListenStatusP" -package_key "qt-dashboard" -default 0]	    
	    if {$status_p eq 0} {
		ws::client::close $channel   
		break
	    }
	    
	    set result [ws::client::receive $channel]
	    set l_json [json get [lindex $result 0]]
	    array set arr $l_json
	    
	    if { [lindex $arr(result) 0] eq "faces"} {
		qt::dashboard::import_json -l_json $l_json
	    }	    	    	    
	}
    }
}


ad_proc qt::dashboard::import_json {
    -l_json
} {
    Gets full JSON, converts JSON's response to TCL array, then converts the array into a TCL list, suing rl_json library, isolates page into @data and gets @item_id directly, accessing data with list poperties
} {

    
    ns_log Notice "JSON \n $l_json"
    if {[llength $l_json] > 0} {
	array set arr $l_json
	
	if {[array exists arr]} {
	    ns_log Notice "ARRAY \n [parray arr]"	    
	
	    set item_id [db_nextval "acs_object_id_seq"]
	    
	    # Inserting Face
	    set creation_user [ad_conn user_id]
	    set creation_ip [ad_conn peeraddr]
	    set package_id [ad_conn package_id]
	    set content_type qt_face
	    set storage_type "text"
	    set parent_id $package_id
	    
	    
	    set attributes [lindex $arr(result) 1]
	    ns_log Notice "ATTRIBS $attributes"
	    
	    set name [lindex [lindex $attributes 0] 3]
	    ns_log Notice "NAME $name"

	    
	    if {![db_0or1row item_exists {
		SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
	    }]} {	    


		ns_log Notice "-item_id $item_id \
				     -parent_id $parent_id \
				     -creation_user $creation_user \
				     -creation_ip $creation_ip \
				     -package_id $package_id \
				     -name $name \
				     -title $name \
				     -description $l_json \
				     -storage_type $storage_type \
				     -content_type $content_type \
				     -mime_type text/plain"

		
		db_transaction {
		    set item_id [content::item::new \
				     -item_id $item_id \
				     -parent_id $parent_id \
				     -creation_user $creation_user \
				     -creation_ip $creation_ip \
				     -package_id $package_id \
				     -name $name \
				     -title $name \
				     -description $l_json \
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
    
    
