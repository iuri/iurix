ad_library {

    Layout Manager Procs

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date 2008-07-05
    @version $Id: layout-procs.tcl,v 1.3 2008/11/26 11:16:15 donb Exp $

}

namespace eval layout {}
       
ad_proc layout::package_id {} {
    Returns the package id of our instance (the closest ancestor which is a
    layout-manager instance or a package which extends it, i.e. layout-managed-subsite)
} {
    return [site_node::closest_ancestor_package \
               -include_self \
               -node_id [ad_conn node_id] \
               -package_key [concat layout-manager [apm_package_descendents layout-manager]]]
}


ad_proc layout::package_options {} {
    Return packages installed in the system
} {
    return [db_list_of_lists select_packages {
	select instance_name, package_id from apm_packages
	where package_key IN ('acs-subsite','layout-managed-subsite')
    }]
    
 
}


###
# Drag-drop APIs
###


ad_proc layout::customize_p {
      -pageset_id
} {
    return [db_string customize_p {select customize from layout_pagesets where pageset_id = :pageset_id and owner_id = 0}]
}


ad_proc layout::customize_turn {
    -pageset_id
    -customize_state
} {
    
    switch $customize_state {
        f {set turn_customize t}
        t {set turn_customize f}
    }

    db_dml turn_customize_p {update layout_pagesets set customize = :turn_customize where pageset_id = :pageset_id}

}


ad_proc layout::element_pageset_id {
      -element_id
} {
    return [db_string pageset {select pageset_id from layout_elements le, layout_pages lp where le.page_id = lp.page_id and le.element_id = :element_id}]
}



ad_proc -private layout::hidden_elements_list {
    {-pageset_id:required}
} {
    Returns a list of "hidden" element avaliable to a subsite. Use a 1 second cache here
    to fake a per-connection cache.
} {
    return [util_memoize "layout::hidden_elements_list_not_cached -pageset_id $layout_id" 1]
}

ad_proc -private layout::hidden_elements_list_not_cached {
    {-pageset_id:required}
} {
    Memoizing helper
} {
    
    #return [db_list_of_lists select_hidden_elements {}]
    return [db_list_of_lists select_hidden_elements {
	select element_id,
	le.title
	from layout_elements le,
	layout_pages lp
	where lp.pageset_id = :pageset_id
	and lp.page_id = le.page_id
	and le.state = 'hidden'
	order by le.name 
    }]
}


ad_proc -public layout::layouts {
} {
} {
    return [db_list_of_lists select_layout {select columns, name from layout_page_templates}]
}


ad_proc layout::object_map {
     -portal_id
-object_id
} {
    return [db_string map_object {select portal_object__map (:portal_id,:object_id)}]
}

ad_proc layout::object_unmap {
   -object_id
} {
    return [db_string unmap_object {select portal_object__unmap (:object_id)}]
}

ad_proc layout::get_mapped_portal {
   -object_id
} {
    return [db_string map_object {select portal_id from portal_object_map where object_id = :object_id} -default ""]
}




###
# Themes
###


ad_proc -public layout::get_theme_options {
} {
    
    Reutrns a list of themes available
    @author iuri sampaio (iuri.sampaio@gmail.com)
    
} {

    set theme_options {
	{{Plain Master} {/packages/openacs-default-theme/lib/plain-master}}
	{{MDA} {/packages/theme-mda/lib/mda-master}}
    }
    
    return $theme_options
}

ad_proc -public layout::get_subsite_options {
} {

    Reutrns a list of subsite available
    @author iuri sampaio (iuri.sampaio@gmail.com)

} {

    set subsites [db_list_of_lists select_subsites {
	select instance_name, package_id
	from apm_packages ap
	where package_key = 'acs-subsite'
	or package_key = 'layout-managed-subsite'
	order by lower(instance_name)
    }]

    set subsites [concat [list [list Selecione 0]] $subsites]

    return $subsites
}


