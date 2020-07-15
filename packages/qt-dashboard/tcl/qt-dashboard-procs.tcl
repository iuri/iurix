# /packages/qt-dashboard/tcl/qt-dashboard-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::websocket {}


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
		set revision_id [content::revision::new \
				     -item_id $item_id \
				     -title $name \
				     -description $l_json]	   	    
	    } else {
		ns_log Notice "Face EXISTS"
		db_1row item_exists {
		    SELECT item_id FROM cr_items WHERE name = :name AND parent_id = :parent_id
		}
	    }	    	  	    	    
	}
    }
}
    
    
