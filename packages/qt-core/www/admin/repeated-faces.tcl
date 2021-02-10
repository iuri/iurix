ad_page_contract {}

set token [parameter::get_global_value -package_key qt-luna-api -parameter AccessToken -default ""]  
set req_headers [ns_set create]
ns_set put $req_headers "X-Auth-Token" "$token"
ns_set put $req_headers "Content-Type" "application/json"

#   set url "http://luna.qonteo.com:5000/4/storage/lists"
set proto [parameter::get_global_value -package_key qt-luna-api -parameter ProtoURL -default "http"]
set domain [parameter::get_global_value -package_key qt-luna-api -parameter DomainURL -default ""]
set port [parameter::get_global_value -package_key qt-luna-api -parameter PortURL -default ""]
    
#set list_id "68391cca-e654-400c-b9a8-43d8401f60a4"
set list_id "18103946-6f17-4b82-894c-958fe57ea69d"


db_foreach select_faces {
    SELECT object_id,
    qt_face_id,
    creation_date,
    SPLIT_PART(description, ' ', 28) AS descriptor_id,
    description
    FROM qt_face_tx
    WHERE creation_date::date > '2020-12-15'
    ORDER BY creation_date DESC
    LIMIT 10000
} {

    
#    ns_log Notice "DESCRIPTION $description"
#    ns_log Notice "DESCRIPTOR_ID $descriptor_id "


    # Get DescriptorInfo
    set url "${proto}://${domain}:${port}/4/storage/descriptors/$descriptor_id"    
    set res [ns_http run -method GET -headers $req_headers -body "" $url]
 #   ns_log Notice "RES1 $res"



    set url "${proto}://${domain}:${port}/4/matching/match?descriptor_id=$descriptor_id&list_id=$list_id"    
    set res [ns_http run -method POST -headers $req_headers -body "" $url]
  #  ns_log Notice "RES2 $res"

    set data [dict get $res body]
   # ns_log Notice "DATA $data"

    package req json
    set l [json::json2dict $data]
    #ns_log Notice "List $l"
    if {[llength [lindex $l 1]] > 0} {
	foreach elem [lindex $l 1] {
	    if { [expr [lindex $elem 3] > 0.90] } {
		ns_log Notice "MATCH \n DESCID $descriptor_id \n $elem"
#		ns_log Notice "Similarity [lindex $elem 3]"
	    }
	}
	
    } else {
	ns_log Notice "NO MATCH"
	
	# Add Descriptor to List
	set url "${proto}://${domain}:${port}/4/storage/descriptors/$descriptor_id/linked_lists?list_id=$list_id&do=attach"
	set res [ns_http run -method PATCH -headers $req_headers -body "" $url]
#	ns_log Notice "RES3 $res"
	
    }
    
    
}
