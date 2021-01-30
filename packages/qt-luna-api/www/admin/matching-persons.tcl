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
    SPLIT_PART(description, ' ', 28) AS descriptor_id,
    description
    FROM qt_face_tx
    WHERE creation_date::date > '2020-12-15'
    ORDER BY creation_date DESC
    LIMIT 100
} {

    
    # ns_log Notice "DESCRIPTION $description"

    #faces {{attributes {age 49.9930801392 eyeglasses 0 gender 1 emotions {estimations {anger 0.0000010351 disgust 0.0000071471 fear 1.264e-7 happiness 0.9954314232 neutral 0.0045503597 sadness 0.0000081951 surprise 0.0000018175} predominant_emotion happiness}} id d0f1864e-0e8c-44d1-940a-90d28d3ffed0 score 0.5314277411}} timestamp 1611083014.5894287 authorization {token_id b935a0e0-44ad-4b4d-ad9d-f66b3653cf34 token_data CCPN002}
    
    qt::lunaapi::matching::descriptor -json $description
    
}
    
