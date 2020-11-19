ad_page_contract {} {}

ns_log Notice "Running REST upload-photo-ios"


set header [ns_conn header]
#ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
#ns_log Notice "HEADERS $h"
set req [ns_set array $header]
#ns_log Notice "$req"

#ns_log Notice "[ns_getcontent -as_file false]"
 
if {[ns_conn method] eq "POST"} {
    set content [ns_getcontent -as_file false]
#    ns_log Notice "HCONTENT $content"
    
    set myform [ns_getform]
    if {[string equal "" $myform]} {
	ns_log Notice "No Form was submited"
    } else {
#	ns_log Notice "FORM"
	ns_set print $myform
	for {set i 0} {$i < [ns_set size $myform]} {incr i} {
     	    set varname [ns_set key $myform $i]
	    set varvalue [ns_set value $myform $i]
#	    ns_log Notice " $varname - $varvalue"

	    set $varname $varvalue
	    


	    
	}
    }
    
    package req json
    set dict [json::json2dict $data]
    array set arr $dict

 #   ns_log Notice "[parray arr]"

    set album_id [qt::rest::album::get_id -user_id $arr(user_id)]
  #  ns_log Notice "ALBUM $album_id"
    permission::require_permission -party_id $arr(user_id) -object_id $album_id -privilege "pa_create_photo"
    set photo_id [pa_load_images \
		      -remove 1 \
		      -description $arr(description) \
		      -story $dict \
		      -package_id [apm_package_id_from_key "photo-album"] \
		      -caption $arr(title) \
		      ${file.tmpfile} $album_id $arr(user_id)]
    
    
    
    pa_flush_photo_in_album_cache $album_id
    permission::grant -party_id -1 -object_id $photo_id -privilege read
    
    photo_album::photo::get -photo_id $photo_id -array photo
    # ns_log Notice "[parray photo]"


    # Retrieve Face feature from AWS Rekognition
    ns_log Notice "Request face features"
    set url "http://ec2-54-86-23-8.compute-1.amazonaws.com/file/upload"
    
    set req_headers [ns_set create]
    ns_set put $req_headers User-Agent "[ns_info name]-Tcl/[ns_info version]"
    ns_set put $req_headers Content-type "multipart/form-data"
    ns_set put $req_headers Connection keep-alive
    ns_set put $req_headers Content-length [string length $content]

    # POST request
    #callback qt::rest::get_photo_features
    #set h [util::http::post -url $url -headers $req_headers -timeout 600 -body $content]
    set h [ns_httpopen POST $url $req_headers 600 $content]
    #set h [ns_http run -method POST -headers $req_headers -timeout 600 -body $content $url]
    ns_log Notice "HTTP $h"
    ns_respond -status 200 -type "application/json" -string "ok"
    
} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method not allowed/supported."
}


ad_script_abort
