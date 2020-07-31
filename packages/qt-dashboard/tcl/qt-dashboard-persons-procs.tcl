# /packages/qt-dashboard/tcl/qt-dashboard-persons-procs.tcl

ad_library {

    Utility functions for Qonteo Dashboard package

    @author Iuri de Araujo (iuri@iurix.com)
    @creation-date Jul 12th 2020

}


namespace eval qt {}
namespace eval qt::dashboard {}
namespace eval qt::dashboard::person {}


ad_proc qt::dashboard::person::import {
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


