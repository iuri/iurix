# /packages/qt-luna-api/tcl/qt-luna-api-procs.tcl
#
# Copyright (C) 2021 IURIX
#
# All rights reserved. Please check
# https:/iurix.com for details

ad_library {
    REST Webservice API
    Utility functions - Library to support IURIX WS API

    @author Iuri de Araujo [iuri@iurix.com]
    @creation-date Sat May 23 17:16:42 2020 
}


namespace eval qt::lunaapi {}
namespace eval qt::lunaapi::descriptor {}
namespace eval qt::lunaapi::person {}
namespace eval qt::lunaapi::group {}

ad_proc -public qt::lunaapi::matching::descriptor {
    {-json}
} {
    It matches face's descriptor with person within a list
    @returns user_id
} {


    set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
    set req_headers [ns_set create]
    ns_set put $req_headers "X-Auth-Token" "$token"
    ns_set put $req_headers "Content-Type" "application/json"
    
    #   set url "http://luna.qonteo.com:5000/4/storage/lists"
    set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
    set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
    set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
    
    set list_id "36349d2c-36ba-484f-a282-62b0334881ac"

    ns_log Notice "JSON $json"
    
    set timestamp [lindex $json 3]    
    ns_log Notice "TIMESTAMP $timestamp"
    set creation_date [db_string convert_timestamp {
	SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :timestamp * INTERVAL '1 second' - INTERVAL '5 hours';
    }]

    ns_log Notice "CREATION DATE $creation_date"


    set descriptor_id [lindex [lindex [lindex [lindex $json 1] 1] 0] 3]
        
    set url "${proto}://${domain}:${port}/4/matching/identify?descriptor_id=$descriptor_id&list_id=$list_id"

    set res [ns_http run -method POST -headers $req_headers -body "" $url]
    ns_log Notice "RES2 $res"

    set data [dict get $res body]
    # ns_log Notice "DATA $data"

    package req json
    set l [json::json2dict $data]
    #ns_log Notice "LUIS $l"
    
    foreach elem [lindex $l 1] {
#	ns_log Notice "ELEM $elem"
	
#	ns_log Notice "SIMILARITY [lindex $elem 3]"
	if {[lindex $l 3] > 0.10} {
#	    ns_log Notice "MATCHED DESCRIPTOR $descriptor_id | PERSOn $id" 

	    
#	    % de similitud (con 2 decimales)

#	    La siguiente persona:
#	    1. Nombres
#	    2. Apellidos
#	    3. Tótem
#	    4. Fecha
	    #	    5. Hora


#	    qt::lunaapi::matching::new \
#		-descriptor_id $descriptor_id \
#		-person_id $person_id \
#		-creation_date $creation_date \
#		-station $station
	      
	} 		
    }

}



ad_proc -public qt::lunaapi::person::new  {
    {-user_id}
} {
    Creates a person_id at Luna SFW 
} {
    ns_log Notice "Running ad_proc qt::lunapai::person::new"
    
    
    # Integration with Luna Faces Luna
    # Creates person id
    set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
    set req_headers [ns_set create]
    ns_set put $req_headers "X-Auth-Token" "$token"
    
    #   set url "http://luna.qonteo.com:5000/4/storage/lists"
    set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
    set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
    set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
    set path [parameter::get_global_value -package_key qt-luna-api -parameter StorageResourcePath -default ""]
    
    # Add person
    set url "${proto}://${domain}:${port}${path}persons"
    ns_log Notice "URL $url"

    acs_user::get -user_id $user_id -array user
    set person_name $user(name)
    
		     
    set body "\{\"user_data\": \"${person_name}\"\}"

    
    set res [util::http::post \
                 -headers $req_headers \
                 -url $url \
                 -timeout 60 \
                 -body $body]
    
    ns_log Notice "RES $res"
    package req json
    set person_id [lindex [json::json2dict [dict get $res page]] 1]
    
    ns_log Notice "DATA $person_id"
    
    return $person_id 
}




ad_proc -public qt::lunaapi::descriptor::new  {
    {-file}
} {
    Creates a descriptor at Luna SFW
} {
    ns_log Notice "Running ad_proc qt::lunapai::descriptor::new"
    
    ns_log Notice "FILE $file"
    
    # Integration with Luna Faces Luna
    # Creates person id
    set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
    set req_headers [ns_set create]
    ns_set put $req_headers "X-Auth-Token" "$token"
    
    
    #   set url "http://luna.qonteo.com:5000/4/storage/lists"
    set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
    set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
    set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
    set path [parameter::get_global_value -package_key qt-luna-api -parameter StorageResourcePath -default ""]
    
    
    # Add Descriptor (portrait)
    ns_set put $req_headers "Content-Type" "image/jpeg"
    ns_log Notice "HEADERS $req_headers"
    ns_log Notice "TOKEN $token"
    set url "${proto}://${domain}:${port}${path}descriptors"
    ns_log Notice "URL $url"
    
    #    set url "https://dashboard.qonteo.com/REST/debug-upload"
    
    set res [ns_http run -method POST -headers $req_headers -body_file $file $url]
    ns_log Notice "RES $res"

    set descriptor_id [dict get $res body]
    ns_log Notice "DESCRIPTOR ID $descriptor_id"
    package req json
    set faces [lindex [json::json2dict [dict get $res body]] 1]
    ns_log Notice "FACES $faces"
    set id [lindex [lindex $faces 0] 1]
    ns_log Notice "ID $id"
    #S status 201 time 0:681508 headers d26 body {{"faces":[{"id":"bff4e5a5-7472-4c53-bbc6-269fca2ca081","rect":{"height":199,"width":144,"x":51,"y":32},"score":0.9471633434,"rectISO":{"height":341,"width":256,"x":-6,"y":-46}}]}}
    


    return $id
}






ad_proc -public qt::lunaapi::descriptor::attach_to_person  {
    {-person_id}
    {-descriptor_id}
} {
    Attaches a descriptor to a person at Luna SFW 
} {
    ns_log Notice "Running ad_proc qt::lunapai::descriptor::attach_to_person"
    
    
    # Integration with Luna Faces Luna
    # Creates person id
    set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
    set req_headers [ns_set create]
    ns_set put $req_headers "X-Auth-Token" "$token"
    
    #   set url "http://luna.qonteo.com:5000/4/storage/lists"
    set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
    set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
    set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
    set path [parameter::get_global_value -package_key qt-luna-api -parameter StorageResourcePath -default ""]
    
    # Add person
    set url "${proto}://${domain}:${port}${path}persons/${person_id}/linked_descriptors?descriptor_id=${descriptor_id}&do=attach"
    ns_log Notice "URL $url"
    
    
    set res [ns_http run -method PATCH -headers $req_headers $url]   
    ns_log Notice "RES $res"
    
}




##
# Group ad_procs API
##
ad_proc -public qt::lunaapi::group::new {
    {-group_name ""}
} {
    It creates a list at Luna SFW, returns list_id
} {

    set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
    set req_headers [ns_set create]
    ns_set put $req_headers "X-Auth-Token" "$token"
    
    
    #   set url "http://luna.qonteo.com:5000/4/storage/lists"
    set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]

    set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
    set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
    
    set path [parameter::get_global_value -package_key qt-luna-api -parameter StorageResourcePath -default ""]

    set url "${proto}://${domain}:${port}${path}lists"

    set body "\{\"list_data\": \"${group_name}\", \"type\": \"persons\"\}"
    set res [util::http::post \
		 -headers $req_headers \
		 -url $url \
		 -timeout 60 \
		 -body $body]

    
    package req json
    set group_id [lindex [json::json2dict [dict get $res page]] 1]
    
    ns_log Notice "DATA $group_id"

    return $group_id
	     

}


ad_proc -public qt::lunaapi::group::add_person  {
    {-user_id}
    {-group_id}
} {
    Attaches a person to a list/group at Luna SFW

    curl -k -v -X PATCH -H "X-Auth-Token: 41fb3071-4947-48a-bf2a-e59e3062c2ff" "http://ip:5000/4/storage/persons/e5630cda-84c3-4bfe-9871-e2a5078c94fc/linked_lists?list_id=770bf902-fe2a-4c39-a292-93e9d2b1dd18&do=attach"
} {
    ns_log Notice "Running ad_proc qt::lunapai::group::add_person"

    # Retrieves person_id
    set portrait_id [acs_user::get_portrait_id -user_id $user_id]
    
    ns_log Notice "PORTRAIT ID $portrait_id"
    
    if {$portrait_id ne 0} {
	# Integration with Luna Faces
	set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
	set req_headers [ns_set create]
	ns_set put $req_headers "X-Auth-Token" "$token"
	
	#   set url "http://luna.qonteo.com:5000/4/storage/lists"
	set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
	set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
	set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
	set path [parameter::get_global_value -package_key qt-luna-api -parameter StorageResourcePath -default ""]
	
	content::item::get -item_id $portrait_id -array_name item
	set person_id [lindex $item(description) 1]
	
	
	# Retrieves list_id
	group::get -group_id $group_id -array group
	
	ns_log Notice "[parray group]"
	# Add person
	set url "${proto}://${domain}:${port}${path}persons/${person_id}/linked_lists?list_id=$group(group_name)&do=attach"
	ns_log Notice "URL $url"
	
	
	set res [ns_http run -method PATCH -headers $req_headers $url]   
	ns_log Notice "RES $res"
	
    }
    
    
}
