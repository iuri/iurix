ad_library {
    Photo Album install callbacks

    @creation-date 2004-05-20

    @author Jeff Davis davis@xarg.net
    @cvs-id $Id: photo-album-install-procs.tcl,v 1.1 2004/06/01 19:13:05 jeffd Exp $
}

namespace eval photo_album::install {}

ad_proc -private photo_album::install::package_install {} { 
    package install callback
} {
    photo_album::search::album::register_fts_impl
    photo_album::search::photo::register_fts_impl
}

ad_proc -private photo_album::install::package_uninstall {} { 
    package uninstall callback
} {
    photo_album::search::unregister_implementations
}


ad_proc -private photo_album::install::add_categories {
    {-package_id ""}
} {
    a callback install that adds standard tree, categories ans sub-categories related to photo
} {

    #create category tree
    set tree_id [category_tree::add -name photos]
    
    set parent_id [category::add -tree_id $tree_id -parent_id [db_null] -name "Tipo" -description "Tipo de Foto"]
    category::add -tree_id $tree_id -parent_id $parent_id -name "Livre" -description "Livre desc" -locale "pt_BR"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Eventos" -description "Eventos desc" -locale "pt_BR"
    category::add -tree_id $tree_id -parent_id $parent_id -name "Logo" -description "Logo" -locale "pt_BR"
    
    set object_id [db_list select_object_id "
	select object_id 
	from acs_objects 
	where object_type = 'apm_package' 
	and package_id = $package_id
    "]

    category_tree::map -tree_id $tree_id -object_id $object_id
}

ad_proc -private photo_album::install::add_acs_rel_types {} {
    a callback install that adds a relation type named as pa_photo
} {

    rel_types::new "photo_subsite" "Photo Subsite" "Photo Subsite" "pa_photo" 0 1 "apm_package" 0 1

    if {[apm_package_installed_p dotlrn]} {
	rel_types::new "photo_community" "Photo Community" "Photo Community" "pa_photo" 0 1 "dotlrn_community" 0 1
    }
}




ad_proc -private photo_album::install::package_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    Package before-upgrade callback
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
            5.2.2d1 5.2.2d2 {
                # just need to install the search callback
                photo_album::search::album::register_fts_impl
                photo_album::search::photo::register_fts_impl
            }
	    5.2.0d2 5.2.0d3 {
		
	    }
	   

        }
}
