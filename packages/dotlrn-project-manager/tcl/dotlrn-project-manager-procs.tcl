#  Copyright (C) 2001, 2002 MIT
#  This file is part of dotLRN.
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.

ad_library {
    
    the dotlrn applet for calendar
    
    @author ben@openforce.net,arjun@openforce.net
    @version $Id: dotlrn-project-manager-procs.tcl,v 1.13 2018/03/27 14:22:30 hectorr Exp $
}

namespace eval dotlrn_project_manager {}

ad_proc -public dotlrn_project_manager::package_key {
} {
    What package does this applet deal with?
} {
    return "project-manager"
}

ad_proc -public dotlrn_project_manager::my_package_key {
} {
    What's my package key?
} {
    return "dotlrn-project-manager"
}

ad_proc -public dotlrn_project_manager::applet_key {
} {
    What's my applet key?
} {
    return "dotlrn_project_manager"
}

ad_proc -public dotlrn_project_manager::get_pretty_name {
} {
} {
    return "Project Manager"
}

ad_proc -public dotlrn_project_manager::add_applet {
} {
    Called for one time init - must be repeatable!
    @return new pkg_id or 0 on failure
} {
    
    # FIXME: won't work with multiple dotlrn instances Use the package_key
    # for the -url param - "/" are not allowed!
    
    set package_id 0
    
    if {![dotlrn::is_package_mounted \
	      -package_key [package_key]]} {
	set package_id [dotlrn::mount_package \
			    -package_key [package_key] \
			    -url [package_key] \
			    -directory_p "t"]
    }
    
    dotlrn_applet::add_applet_to_dotlrn -applet_key [applet_key] -package_key [my_package_key]
    
}

ad_proc -public dotlrn_project_manager::remove_applet {
} {
    One-time destroy for when the entire applet is removed from dotlrn.
} {
    ad_return_complaint 1 "[applet_key] remove_applet not implemented!"
}

ad_proc -public dotlrn_project_manager::project_manager_create_helper {
    {-community_id:required}
    {-package_id:required}
} {
    A helper proc to create a calendar for a comm, returns the new calendar_id
} {
    return "00"
}

ad_proc -public dotlrn_project_manager::add_applet_to_community {
    community_id
} {
    Add the calendar applet to a specific dotlrn community
} {
    set results [add_applet_to_community_helper \
		     -community_id $community_id
		]
    
    return [lindex $results 0]
}

ad_proc -public dotlrn_project_manager::add_applet_to_community_helper {
    {-community_id:required}
} {
    Add the calendar applet to a specific dotlrn community
    
    @params community_id
} {
    
    # Create and Mount the Project Manager Package

    set package_id [dotlrn::instantiate_and_mount \
			-mount_point "project-manager" \
			$community_id \
			[package_key] \
		       ]
    
    # Set up the project manager portlet for this portal/community
    
    set portal_id [dotlrn_community::get_portal_id \
		       -community_id $community_id \
		      ]
    
    # Add all portlets to the Portal.
    
    project_manager_portlet::add_self_to_page \
	-portal_id $portal_id \
	-package_id $package_id \
	-project_manager_id $package_id

    project_manager_task_portlet::add_self_to_page \
	-portal_id $portal_id \
	-package_id $package_id \
	-project_manager_id $package_id

    project_manager_calendar_portlet::add_self_to_page \
	-portal_id $portal_id \
	-package_id $package_id \
	-project_manager_id $package_id
    
    project_manager_project_calendar_portlet::add_self_to_page \
	-portal_id $portal_id \
	-package_id $package_id \
	-project_manager_id $package_id
    
    project_manager_projects_portlet::add_self_to_page \
	-portal_id $portal_id \
	-package_id $package_id \
	-project_manager_id $package_id
    

    # instantiate and mount the logger package for this pm
    callback dotlrn_project_manager::new_community -community_id $community_id -package_id $package_id
    
    
    
    # and now to the existing fs, conntacts, forums package
    # of this community
    
    
    
    foreach target_key [list "[dotlrn_community::get_community_url $community_id]forums" "[dotlrn_community::get_community_url $community_id]file-storage" "/contacts/"] {
	
	set site_node_inf [site_node::get_from_url -url $target_key]
	
	set target_package_id [lindex $site_node_inf 19]
	set is_package_id [lindex $site_node_inf 18]
	
	if {![empty_string_p $target_package_id] && $is_package_id == "package_id"} {
	    
	    application_link::new -this_package_id $package_id -target_package_id $target_package_id
	    
	}
	
    } 
    
    
    # this should return the package_id
    return $package_id
}

ad_proc -public dotlrn_project_manager::remove_applet_from_community {
    community_id
} {
    remove the applet from the community
} {
    ad_return_complaint 1 "[applet_key] remove_applet_from_community not implemented!"
}

ad_proc -public dotlrn_project_manager::add_user {
    user_id
} {
    Called once when a user is added as a dotlrn user.
    Create a private, personal, global Project Manager for the User if they don't have one and add it to the user's portal
} {
}

ad_proc -public dotlrn_project_manager::remove_user {
    user_id
} {
    Remove a user from dotlrn
} {
    
    # Not yet implemented.
}

ad_proc -public dotlrn_project_manager::add_user_to_community {
    community_id
    user_id
} {
    Add a user to a community
} {
    
    set package_id [dotlrn_community::get_applet_package_id -community_id $community_id -applet_key [applet_key]]
    set portal_id [dotlrn::get_portal_id -user_id $user_id]
    
    # use "append" here since we want to aggregate
    set param_action append
    
    # Add both portlets
    project_manager_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
	-project_manager_id $package_id \
        -param_action $param_action
    
    project_manager_task_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
	-project_manager_id $package_id \
        -param_action $param_action
    
    project_manager_calendar_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
	-project_manager_id $package_id \
        -param_action $param_action
    
    project_manager_project_calendar_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
	-project_manager_id $package_id \
        -param_action $param_action
    
    project_manager_projects_portlet::add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
	-project_manager_id $package_id \
        -param_action $param_action

}

ad_proc -public dotlrn_project_manager::remove_user_from_community {
    community_id
    user_id
} {
    Remove a user from a community
} {
}

ad_proc -public dotlrn_project_manager::add_portlet {
    portal_id
} {
    Set up default params for templates about to call add_portlet_helper
    
    @param portal_id
} {

    project_manager_portlet::add_self_to_page \
	-portal_id $portal_id \
	-project_manager_id 0 \
	-package_id 0

    project_manager_task_portlet::add_self_to_page \
	-portal_id $portal_id \
	-project_manager_id 0 \
	-package_id 0

    project_manager_calendar_portlet::add_self_to_page \
	-portal_id $portal_id \
	-project_manager_id 0 \
	-package_id 0

    project_manager_project_calendar_portlet::add_self_to_page \
	-portal_id $portal_id \
	-project_manager_id 0 \
	-package_id 0

    project_manager_projects_portlet::add_self_to_page \
	-portal_id $portal_id \
	-project_manager_id 0 \
	-package_id 0
    
    #    add_portlet_helper $portal_id $args
}

#ad_proc -private dotlrn_project_manager::add_portlet_helper {
#aportal_id # args #} {# Does the call to add the portlet to the
#aportal.  # Params for the portlet are sent to this proc by the
#acaller.  #} {# calendar_portlet::add_self_to_page \
    -portal_id $portal_id \
    -pretty_name [ns_set get $args "pretty_name"] \
    -calendar_id [ns_set get $args "calendar_id"]  \
    -scoped_p [ns_set get $args "scoped_p"] \
    -param_action [ns_set get $args "param_action"]

#    calendar_full_portlet::add_self_to_page \
    -portal_id $portal_id \
    -page_name [ns_set get $args "full_portlet_page_name"] \
    -calendar_id [ns_set get $args "calendar_id"]  \
    -scoped_p [ns_set get $args "scoped_p"] \
    -param_action [ns_set get $args "param_action"]

#}

ad_proc -public dotlrn_project_manager::remove_portlet {
    portal_id
    args
} {
    A helper proc to remove the underlying portlet from the given portal.
    This is a lot simpler than add_portlet.
    
    @param portal_id
    @param args An ns_set with the project_manager_id.
} {
    project_manager_portlet::remove_self_from_page \
	-portal_id $portal_id \
	-project_manager_id [ns_set get $args "project_manager_id"]

    project_manager_portlet::remove_self_from_page \
	-portal_id $portal_id \
	-project_manager_id [ns_set get $args "project_manager_id"]

    project_manager_projects_portlet::remove_self_from_page \
	-portal_id $portal_id \
	-project_manager_id [ns_set get $args "project_manager_id"]
    
    #    calendar_full_portlet::remove_self_from_page \
	-portal_id $portal_id \
	-calendar_id [ns_set get $args "calendar_id"]
}

ad_proc -public dotlrn_project_manager::clone {
    old_community_id
    new_community_id
} {
    Clone this applet's content from the old community to the new one
} {
}

ad_proc -public dotlrn_project_manager::change_event_handler {
    community_id
    event
    old_value
    new_value
} {
    listens for the following events: rename
} {
    switch $event {
	rename {
	    
	    #	    handle_rename -community_id $community_id -old_value
	    #	$old_value -new_value $new_value
	}
    }
}

ad_proc -private dotlrn_project_manager::handle_rename {
    {-community_id:required}
    {-old_value:required}
    {-new_value:required}
} {
    what to do in calendar when a dotlrn community is renamed
} {
    
    #    calendar::rename -calendar_id [get_group_calendar_id
    # -community_id $community_id] -calendar_name $new_value
}

# Some dotlrn_project_manager specific procs

ad_proc -private dotlrn_project_manager::upgrade {
    {-from_version_name:required }
    {-to_version_name:required }
} {
    Procedures to upgrade dotlrn-project-manager
    
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec {
	    0.1d 0.1d1 {
		# We are going to add all the portlets of project-manager to the 
		# templates
		
		db_foreach get_portal_templates { } {
		    project_manager_portlet::add_self_to_page \
			-portal_id $portal_id \
			-project_manager_id 0 \
			-package_id 0

		    project_manager_task_portlet::add_self_to_page \
			-portal_id $portal_id \
			-project_manager_id 0 \
			-package_id 0
		    
		    project_manager_calendar_portlet::add_self_to_page \
			-portal_id $portal_id \
			-project_manager_id 0 \
			-package_id 0
		    
		    project_manager_project_calendar_portlet::add_self_to_page \
			-portal_id $portal_id \
			-project_manager_id 0 \
			-package_id 0
		}
	    }
	    
	    0.1d1 0.1d2 {
		db_foreach get_all_portal_templates { } {

		    project_manager_projects_portlet::add_self_to_page \
			-portal_id $portal_id \
			-project_manager_id 0 \
			-package_id 0

		}
	    }
	}
}
