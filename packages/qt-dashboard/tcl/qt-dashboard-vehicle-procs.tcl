# /packages/qt-dashboard/tcl/qt-dashboard-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard::vehicle {}




ad_proc qt::dashboard::vehicle::import {} {
    Gets full JSON, converts JSON's response to TCL array, then converts the array into a TCL list, suing rl_json library, isolates page into @data and gets @item_id directly, accessing data with list poperties
    
    JSON's format
    
    # {"1":{"id":"41784","plate_number":"UNKNOWN","country_name":"Unknown","country_symbol":"??","first_seen":"2020-07-23
    #11:08:53","last_seen":"2020-07-23
    #11:08:54","probability":"0.4","location_name":"Test","camera_name":"LPR1","direction":"UNKNOWN","plate_image":"http:\/\/178.62.211.78\/plate_image_fa.php?id=41784","car_image":"http:\/\/178.62.211.78\/car_image_fa.php?id=41784"}}
    
    
} {

    package require json
    package require rl_json
    namespace path {::rl_json}
    
    
    set url "http://178.62.211.78/io/lpr/trigger_with_response.php?camera_id=4&timeout=3&fast_answer=1&output_type=JSON"
    
    
    # Gets full JSON
    set result [util::http::get -url $url]
    # Converts JSON to TCL array
    array set arr $result
        
    if {[array exists arr] && $arr(status) == 200} {
	if {$arr(page) ne "Warning: empty answer!"} {
	    # Isolates page data
	    set data [json get $arr(page)]
	    array set arr2 [lindex $data 1]  	    
	    set item_id [db_nextval "acs_object_id_seq"]	    
	    set creation_user 726
	    set content_type qt_vehicle
	    set storage_type "text"
	    set package_id [apm_package_id_from_key qt-dashboard]
	    set creation_ip "178.62.211.78"
	    set creation_date $arr2(first_seen)
	    set name $arr2(id)
	    set description [lindex $data 1]
	    set plate [lindex $description 3]
	    
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
				     -mime_type "text/plain"
				]
		}	    	    
	
		ns_log Notice "New Vehicle Inserted $name"
	    } else {
		db_1row item_exists {
		    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :package_id
		}
	    }	    
	    return $item_id	    
	}
    }
    return 
}
