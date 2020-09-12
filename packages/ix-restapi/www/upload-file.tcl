ad_page_contract {} {}

ns_log Notice "Running REST TCL script upload-file.tcl"

set header [ns_conn header]
ns_log Notice "HEADER \n $header"
set h [ns_set size $header]
ns_log Notice "HEADERS $h"
set req [ns_set array $header]
ns_log Notice "$req"


set tmpfile [ns_getcontent -as_file true]

set content [ns_getcontent -as_file false]
ns_log Notice "CONTENT \n $content"
#set fcontent [dict get $content upload_file]
#set filename [dict get $content filename]
#ns_log Notice "FILNANEM $filename"


set fp [open $tmpfile r]

ns_log Notice "FP \n $fp"
set upload_file [dict get $fp upload_file]

set filename [dict get $fp filename]

#
# Do something with the dict
#
ns_log Notice "DICT $filename"

ns_log Notice "DICT $upload_file"



#ns_log Notice "FILE \n $file"

ns_log Notice "FILE \n $file"
if {[ns_conn method] eq "POST"} {

   # 1. get photo
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
	}
    }
    
    



    # 1. Get album_id
    set album_id 184392
    set user_id 704


    
    # 2. Insert foto

    if { ![parameter::get -parameter ConverttoJpgorPng -package_id [apm_package_id_from_key photo-album] -default 1] } {	
	if { [catch {set photo_info [pa_file_info ${upload_file}]}  errMsg] } { 
            ns_log Warning "Error parsing file data Error: $errMsg" 
            ad_complain "error" 
	} 
	
	lassign $photo_info base_bytes base_width base_height base_type base_mime base_colors base_quantum base_sha256 
	
	if {$base_mime eq ""} { 
	    set base_mime invalid 
	}   
	
	if ![regexp  $base_mime [parameter::get -parameter AcceptableUploadMIMETypes -package_id [apm_package_id_from_key package_id]]] { 
            ad_complain "[_ photo-album._The_5]" 
            ad_complain "[_ photo-album._The_6]" 
	} 
    } 
    
    ns_log Notice "FLAG1"
    
    
    
    
    #check permission
    permission::require_permission -party_id $user_id -object_id $album_id -privilege "pa_create_photo"
    set description ""
    set story ""
    set caption ""
    set fp [open $tmp_file r]
    
    ns_log notice "uploadfile \n $upload_file"
    
    set new_photo_ids [pa_load_images \
			   -remove 1 \
			   -client_name $tmp_file \
			   -description $description \
			   -story $story \
			   -caption $caption \
			   ${upload_file} $album_id $user_id]
    
    pa_flush_photo_in_album_cache $album_id
    
    


    
















    
    
    
    
    # 3. Return response
    set result "ok"
    set status 200
    # doc_return 200 "application/json" $result    
    # ns_return -binary $status "application/json;" -header $headers result
    ns_respond -status $status -type "application/json" -string $result  
    
}

ad_script_abort
