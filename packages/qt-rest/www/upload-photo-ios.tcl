ad_page_contract {} {}

ns_log Notice "Running REST upload-photo"

if {[ns_conn method] eq "POST"} {
    set content [ns_getcontent -as_file false]
    #ns_log Notice "HCONTENT $content"
    
    set myform [ns_getform]
    if {[string equal "" $myform]} {
	ns_log Notice "No Form was submited"
    } else {
	ns_log Notice "FORM"
	ns_set print $myform
	for {set i 0} {$i < [ns_set size $myform]} {incr i} {
	    set varname [ns_set key $myform $i]
	    set varvalue [ns_set value $myform $i]
	    ns_log Notice " $varname - $varvalue"

	    set $varname $varvalue
	    


	    
	}
    }
    
    package req json
    set dict [json::json2dict $data]
    array set arr $dict

    ns_log Notice "[parray arr]"

    set album_id [qt::rest::album::get_id -user_id $arr(user_id)]
    ns_log Notice "ALBUM $album_id"
    permission::require_permission -party_id $arr(user_id) -object_id $album_id -privilege "pa_create_photo"
    set photo_id [pa_load_images \
		      -remove 1 \
		      -client_name $arr(person_name) \
		      -description $dict \
		      -story "" \
		      -package_id [apm_package_id_from_key "photo-album"] \
		      -caption $arr(person_name) \
		      ${file.tmpfile} $album_id $arr(user_id)]
    
    
    
    pa_flush_photo_in_album_cache $album_id
    permission::grant -party_id -1 -object_id $photo_id -privilege read
    
    photo_album::photo::get -photo_id $photo_id -array photo
    ns_log Notice "[parray photo]"
    
    
    

    ns_respond -status 200 -type "application/json" -string "ok"
    
} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort
