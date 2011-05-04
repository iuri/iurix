# /packages/photo-album/www/photo-add-2.tcl

ad_page_contract {
    adds a photo to an album

    @author davis@xarg.net
    @author bags@arsdigita.com
    @creation-date 12/10/2000
    @cvs-id $Id: photo-add-2.tcl,v 1.7 2006/08/08 21:27:09 donb Exp $
} {
    upload_file:notnull,trim
    upload_file.tmpfile:tmpfile
    album_id:integer,notnull
    photo_id:integer,notnull
    {description [db_null]}
    {caption [db_null]}
    {story [db_null]}
    return_url:optional
} -validate {
    valid_album -requires {album_id:integer} {
	if [string equal [pa_is_album_p $album_id] "f"] {
	    ad_complain "The specified album is not valid."
	}
    }
    valid_mime_type {
 
        if { ![parameter::get -parameter ConverttoJpgorPng -package_id [ad_conn package_id] -default 1] } {
    
	    if { [catch {set photo_info [pa_file_info ${upload_file.tmpfile}]}  errMsg] } { 
            ns_log Warning "Error parsing file data Error: $errMsg" 
            ad_complain "error" 
	    } 
         
	    foreach {base_bytes base_width base_height base_type base_mime base_colors base_quantum base_sha256} $photo_info { break } 
 
	    if [empty_string_p $base_mime] { 
		set base_mime invalid 
	    }   
 
	    if ![regexp  $base_mime [parameter::get -parameter AcceptableUploadMIMETypes -package_id [ad_conn package_id]]] { 
		ad_complain "[_ photo-album._The_5]" 
		ad_complain "[_ photo-album._The_6]" 
	    } 
	} 
    }
    valid_photo_id -requires {photo_id:integer} {
	# supplied photo_id must not already exist	
        if {[db_string check_photo_id {}]} {
	    ad_complain "The photo already exists.  Check if it is already in the <a href=\"album?album_id=$album_id\">album</a>."
	}
    }
}

ns_log Debug "photo-add-2: Done uploading user file, $upload_file"

set user_id [ad_conn user_id]

#check permission
ad_require_permission $album_id "pa_create_photo"

set new_photo_ids [pa_load_images \
                       -remove 1 \
                       -client_name $upload_file \
                       -description $description \
                       -story $story \
                       -caption $caption \
                       ${upload_file.tmpfile} $album_id $user_id]

pa_flush_photo_in_album_cache $album_id

# page used as part of redirect so user returns to the album page containing the newly uploaded photo
set page [pa_page_of_photo_in_album [lindex $new_photo_ids 0] $album_id]


# HAM : added return_url
if { ![exists_and_not_null return_url] } {
    ad_returnredirect "album?album_id=$album_id&page=$page"
} else {
    ad_returnredirect $return_url
}


