ad_page_contract {} {
    {user_id ""}
}

ns_log Notice "Running TCL script listPhotos $user_id"

if {[ns_conn method] eq "GET"} {
    
    set album_id [qt::rest::album::get_id -user_id $user_id]

    set url [ad_url]
    # Gets user's Album
    ns_log Notice "ALBUM $album_id"
    
    
    # Gets Albums's photos
    set photos [pa_all_photos_in_album $album_id]

    set json "\["
    foreach photo_id $photos {
	photo_album::photo::get -photo_id $photo_id -array photo
	set package_url [photo_album::photo::package_url -photo_id $photo_id]
	ns_log Notice "PHOTO URL $package_url"
	ns_log Notice "PHOTO \n [parray photo]"
	append json "\{\"id\": \"$photo_id\", \"name\": \"$photo(caption)\", \"url\": \"${url}${package_url}images/$photo(thumb_live_revision)\"\},"
    }

    set json [string trimright $json ","]
    append json "\]"
    
    ns_log Notice "JSON $json"
    # format JSON output
    set result "\{\"count\":[llength $photos],\"next\":\"https://dashboard.qonteo.com/REST/listPhotos?offset=20&limit=20\",\"previous\": null,\"results\":$json\}"
	  
    
    ns_respond -status 200 -type "application/json" -string $result  
    ad_script_abort
    
    

} else {
    ad_return_complaint 1 "unsupported HTTP method: [ns_conn method]"
    ns_respond -status 405 -type "text/html" -string "Method Not Allowed"
    ad_script_abort
}
