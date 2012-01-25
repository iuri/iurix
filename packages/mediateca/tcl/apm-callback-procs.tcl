# /packages/mediateca/tcl/apm-callback-procs.tcl
ad_library {
    Installation procs to support mediateca package
}

namespace eval mediateca {}

ad_proc -private mediateca::after_instantiate {
    {-package_id}
} {
    Mount and Instantiate required appls
} {

    
    set mediateca_node_id [db_string select_mediateca_instance {
	SELECT sn.node_id FROM apm_packages ap, site_nodes sn WHERE ap.package_id = :package_id AND ap.package_key= 'mediateca' AND ap.package_id = sn.object_id and sn.name = 'mediateca'
    } -default 0]


    #Audios
    set audios_p [apm_package_installed_p "audios"]
    
    if {[info exists audios_p]} {

	site_node::instantiate_and_mount -parent_node_id $mediateca_node_id \
	    -node_name "audios" -package_key "audios" \
	    -package_name "Audios"        
    }
    
    # Videos
    
    set videos_p [apm_package_installed_p "videos"]
    
    if {[info exists videos_p]} {

	site_node::instantiate_and_mount -parent_node_id $mediateca_node_id \
	    -node_name "videos" -package_key "videos" \
	    -package_name "Videos"        
    
    # Documents
    # Photos
    
}
