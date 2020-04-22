ad_library {

    Procedures to support the Project Manager Projects Portlet

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    @creation_date 2005-11-11
}

namespace eval project_manager_projects_portlet {

    ad_proc -private my_package_key {
    } {
        return "project-manager-portlet"
    }

    ad_proc -private get_my_name {
    } {
        return "project_manager_projects_portlet"
    }

    ad_proc -public get_pretty_name {
    } {
        return "#project-manager-portlet.Project_Manager_Projects_Portlet#"
    }

    ad_proc -public link {
    } {
	return ""
    }

    ad_proc -public add_self_to_page {
	{-portal_id:required}
	{-package_id:required}
	{-project_manager_id:required}
        {-page_name ""}
        {-pretty_name ""}
        {-force_region ""}
	{-scoped_p ""}
	{-param_action "overwrite"}

    } {
	Adds the Project Manager Projects Portlet to the given page.

	@param portal_id The page to add self to
	@return element_id The new element's id
    } {
        
        # allow overrides of pretty_name and force_region
        if {[empty_string_p $pretty_name]} {
            set pretty_name [get_pretty_name]
        }

        if {[empty_string_p $force_region]} {
            set force_region [parameter::get_from_package_key \
                                  -package_key [my_package_key] \
                                  -parameter "force_region"
            ]
        }

        set extra_params ""

        if {![empty_string_p $scoped_p]} {
            set extra_params [list scoped_p $scoped_p]
        }
        
        return [portal::add_element_parameters \
                    -portal_id $portal_id \
                    -page_name $page_name \
                    -portlet_name [get_my_name] \
                    -pretty_name $pretty_name \
                    -force_region $force_region \
                    -value $package_id \
		    -key $project_manager_id \
		    -param_action $param_action \
                    -extra_params $extra_params
        ]
    }

    ad_proc -public remove_self_from_page {
	{-portal_id:required}
	{-package_id "0"}
    } {
        Removes the Project Manager Projects Portlet from the given page.

	  @param portal_id The page to remove self from

    } {
        portal::remove_element_parameters \
            -portal_id $portal_id \
            -portlet_name [get_my_name] \
            -key package_id \
            -value $package_id
    }

    ad_proc -public show {
	 cf
    } {
    } {

        portal::show_proc_helper \
            -package_key [my_package_key] \
            -config_list $cf \
            -template_src "project-manager-projects-portlet"		
    }

    ad_proc -public add_to_all_portals { } {
	
	Add the Project Manager Projects Portlet to all	portals that have a template_id ( This means that they are
	a user, club, class or subcommunity portals). Here we use a package_id equal to 0 since we don't
	care about the pm_instance_id since the portlet doesn't make use of it.

	@author Miguel Marin (miguelmarin@viaro.net)
	@author Viaro Networks www.viaro.net
	@creation-date 2005-11-16

    } {
	
	# We get all portals
	set all_portals [db_list get_all_portals {
	    select
	            portal_id
	    from
	            portals
	    where
	            template_id is not null
	}]

	foreach portal_id $all_portals {
	    project_manager_projects_portlet::add_self_to_page \
		-portal_id $portal_id \
		-project_manager_id 0 \
		-package_id 0
	}
    } 
}
