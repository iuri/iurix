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


ad_proc -public qt::lunaapi::person::new  {} {
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

    
    set res [util::http::post \
                 -headers $req_headers \
                 -url $url \
                 -timeout 60 \
                 -body ""]
    
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



