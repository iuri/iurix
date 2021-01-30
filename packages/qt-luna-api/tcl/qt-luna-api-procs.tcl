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
    set creation_date [db_string convert_timestamp {
	SELECT TIMESTAMP WITH TIME ZONE 'epoch' + :timestamp * INTERVAL '1 second' - INTERVAL '5 hours';
    }]

    set location [lindex [lindex $json 9] 3]
    #ns_log Notice "LOCATION $location"
    set descriptor_id [lindex [lindex [lindex $json 1] 0] 3] 
    #set descriptor_id [lindex [lindex [lindex [lindex $json 1] 1] 0] 3]
    ns_log Notice "DESC $descriptor_id "
        
    set url "${proto}://${domain}:${port}/4/matching/identify?descriptor_id=$descriptor_id&list_id=$list_id"

    set res [ns_http run -method POST -headers $req_headers -body "" $url]
    ns_log Notice "RES2 $res"

    set data [dict get $res body]
    # ns_log Notice "DATA $data"

    package req json
    set l [json::json2dict $data]
    #ns_log Notice "LUIS $l"
    
    foreach elem [lindex $l 1] {
	ns_log Notice "ELEM $elem"
	set description  "$elem location $location"
	# ns_log Notice "DESC $description"
	
	# ns_log Notice "SIMILARITY [lindex $elem 3]"
	# ns_log Notice "CREATION DATE $creation_date"
#	ns_log Notice "SIM PARAM [parameter::get_global_value -package_key qt-luna-api -parameter MatchingSimilarityPercentage -default 90]"
#	ns_log Notice "*** [lindex $elem 1] > [expr [parameter::get_global_value -package_key qt-luna-api -parameter MatchingSimilarityPercentage -default 90] / 100.00000000]"
	if {[expr [lindex $elem 1] >= [expr [parameter::get_global_value -package_key qt-luna-api -parameter MatchingSimilarityPercentage -default 90] / 100.0000000000]]} {

	    set person_id [lindex $elem 3]
	    db_0or1row select_user_id {
		SELECT user_id FROM user_ext_info WHERE luna_person_id = :person_id
	    } 
	    
	    ns_log Notice "MATCHED DESCRIPTOR $descriptor_id | PERSOn $user_id" 
	    
	    set item_id [db_nextval "acs_object_id_seq"]
	    set creation_ip "192.199.241.130"
	    set package_id [apm_package_id_from_key qt-luna-api]
	    set similarity [lindex $elem 1]
	    set title [lindex $elem 7]

	    db_transaction {
		set item_id [content::item::new \
				 -item_id $item_id \
				 -parent_id $user_id \
				 -creation_user $user_id \
				 -creation_ip $creation_ip \
				 -creation_date $creation_date \
				 -package_id $package_id \
				 -name "${item_id}-${person_id}-${descriptor_id}" \
				 -title "$title $similarity"  \
				 -description $description \
				 -storage_type text \
				 -content_type qt_matching \
				 -mime_type "text/plain"
			    ]
	    }	    	    

	    qt::do_notifications \
		-item_id $item_id \
		-package_id $package_id \
		-action "new_item" \
		-name "${person_id}-${descriptor_id}" \
		-title "$title $similarity" \
		-description $description
	} 		
    }
}





ad_proc -public qt::do_notifications {
    {-item_id:required}
    {-name:required}
    {-title ""}
    {-description ""}
    {-package_id ""}
    {-action:required}
} {
    Send notifications for Luna API integration &  operations.

    Note that not all possible operations are implemented, e.g. move, copy etc. See documentation.

    @param action The kind of operation. One of: new_matching/new_item
    Others  such as new_version, new_url, delete_file, delete_url delete_folder must be implemented
    
} {
    ns_log Notice "Running ad_proc qt::do_notification"
    
    switch $action {
        "new_item" {
            set action_type "[_ qt-luna-api.New_Matching_Added]"
        }
        "new_url" {
            set action_type "[_ file-storage.New_URL_Uploaded]"
        }
        "new_version" {
            set action_type "[_ file-storage.lt_New_version_of_file_u]"
        }
        "delete_file" {
            set action_type "[_ file-storage.File_deleted]"
        }
        "delete_url" {
            set action_type "[_ file-storage.URL_deleted]"
        }
        "delete_folder" {
            set action_type "[_ file-storage.Folder_deleted]"
        }
        default {
            error "Unknown file-storage notification action: $action"
        }
    }

    set new_content ""
    set creation_user [acs_object::get_element \
                           -object_id $item_id \
                           -element creation_user]
    set owner [person::name -person_id $creation_user]


    # Set email message body - "text only" for now
    set text_version ""
    append text_version "[_ qt-luna-api.lt_Notification_for_Face_Matching]\n"

    if {[info exists description]} {
	# append text_version "[_ file-storage.lt_Version_Notes_descrip]\n"
	 append text_version "$title\n$description"
    }

    set html_version [ad_html_text_convert -from text/plain -to text/html -- $text_version]
    append html_version "<br><br>"
    # Do the notification for the file-storage

    notification::new \
        -type_id [notification::type::get_type_id \
                      -short_name qt_face_matching_notif] \
        -object_id $item_id \
        -notif_subject "[_ qt_luna-api-.lt_Face_Matching_Notif]" \
        -notif_text $text_version \
        -notif_html $html_version

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
    {-user_id}
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

    
    
    db_transaction {
	set userinfo_id [db_nextval "user_info_id_seq"]
	db_exec_plsql insert_userinfo {
	    
	    SELECT userinfo__new(:userinfo_id,
				 :person_id,
				 :descriptor_id,
				 null,
				 null,
				 :user_id);
	}
    }
    
    
    return 
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
