ad_page_contract {}

set package_id [ad_conn package_id]

set audios_p [apm_package_installed_p "audios"]
if {[info exists audios_p]} {
    
    db_1row select_audio_package_id {
	SELECT 
    #set audios_url [export_vars -base "" {}]
    set audios_url [site_node::get_url_from_object_id -object_id $audio_package_id]
    ns_log Notice "URL $audios_url"
}

set videos_url ""




set photos_p [apm_package_installed_p "photo-album"]

if {[info exists photos_p]} {
    
    #set audios_url [export_vars -base "" {}]
    set photos_url [apm_package_url_from_key "photo-album"]
}
set documents_url ""