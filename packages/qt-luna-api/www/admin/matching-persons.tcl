ad_page_contract {}

ns_log Notice "Running TCL script mathcing-persons"
# Notice: JSON result {faces {{attributes {age 45.5743560791 eyeglasses 0 gender 1 emotions {estimations {anger 7.9e-9 disgust 3.116e-7 fear 4e-9 happiness 0.0607639067 neutral 0.9390019774 sadness 0.0002264857 surprise 0.0000072517} predominant_emotion neutral}} id 72d0c011-4102-4e40-a51f-5ea9ef8bca1e score 0.7995510101}}} timestamp 1611014921.584385 source descriptors event_type extract authorization {token_id b935a0e0-44ad-4b4d-ad9d-f66b3653cf34 token_data CCPN002}

set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
set req_headers [ns_set create]
ns_set put $req_headers "X-Auth-Token" "$token"
ns_set put $req_headers "Content-Type" "application/json"
    
#   set url "http://luna.qonteo.com:5000/4/storage/lists"
set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]


set list_id "36349d2c-36ba-484f-a282-62b0334881ac"
		     

db_foreach select_faces {
    SELECT object_id,
    qt_face_id,
    creation_date,
    SPLIT_PART(description, ' ', 28) AS descriptor_id
    FROM qt_face_tx
    WHERE creation_date::date > '2020-12-15'
    --LIMIT 100
} {

    #ns_log Notice "DESCRIPTION $descriptor_id"

    set url "${proto}://${domain}:${port}/4/matching/match?descriptor_id=$descriptor_id&list_id=$list_id"
    #ns_log Notice "URL $url"
    
    #    var matchrequestURL = 'https://192.199.241.130:9000/4/matching/identify?descriptor_id=' + jsonstring.result.faces[0].id + '&list_id=c7669b64-2174-45d5-88c9-c5dba0914623&limit=1';
    
    
    set res [ns_http run -method POST -headers $req_headers -body "" $url]
    #ns_log Notice "RES $res"
    set data [dict get $res body]
    #ns_log Notice "DATA $data"

    package req json
    set l [json::json2dict $data]
    #ns_log Notice "LUIS $l"
    
    foreach elem [lindex $l 1] {
	#ns_log Notice "ELEM $elem"
	
	#ns_log Notice "SIMILARITY [lindex $elem 3]"
	if {[lindex $l 3] > 0.70} {
	    ns_log Notice "MATCHED DESCRIPTOR $descriptor_id | PERSOn $id" 
	    
	} 
	
	
	
    }
}
    
