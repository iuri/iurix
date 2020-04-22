# packages/project-manager/lib/project-list.tcl
# List of all projects
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-23
# @arch-tag: 2f586eec-4768-42ef-a09a-4950ac00ddaf
# @cvs-id $Id: projects.tcl,v 1.13 2018/05/09 15:33:33 hectorr Exp $

set required_param_list [list package_id]
set optional_param_list [list status_id searchterm bulk_p action_p filter_p base_url end_date_f is_observer_p]
set optional_unset_list [list assignee_id date_range]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

set package_ids [join $package_id ","]
foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

if {![info exists format]} {
    set format "normal"
}

set community_id [dotlrn_community::get_community_id]

#ad_return_complaint 1 $package_ids

if { [empty_string_p $community_id] } {
    set user_space_p 1
    set extra_role_tables "pm_project_assignment pa,pm_roles pr,"
    set extra_role_where_clause "
	and pa.project_id = p.item_id
	and pa.role_id = pr.role_id
        and 1 = ( select 1 from dual where pa.party_id = :user_id or :user_id in ( select object_id_two from acs_rels where object_id_one = pa.party_id
                 and rel_type = 'membership_rel'))
        "
} else {
    set user_space_p 0
    set extra_role_tables ""
    set extra_role_where_clause "and p.object_package_id in ($package_ids)"
}

# --------------------------------------------------------------- #

set c_row 0

set exporting_vars { status_id category_id assignee_id format }
set hidden_vars [export_vars -form $exporting_vars]


# set up context bar
set context [list]

# the unique identifier for this package
set user_id    [ad_maybe_redirect_for_registration]

# Filter for observers

if { ![empty_string_p $is_observer_p] } {
    set extra_query "and pr.is_observer_p = '$is_observer_p'"
} else {
    set extra_query ""
}

# Projects, using list-builder ---------------------------------

# Set status
if {![exists_and_not_null status_id] } {
    set default_closed [pm::project::default_status_closed]
    set status_where_clause {proj.status_id <> :default_closed}
    set status_id ""
} else {
    set status_where_clause "proj.status_id in ([join $status_id ,])"
}

# We want to set up a filter for each category tree.

set export_vars [export_vars -form {status_id }]

if {[exists_and_not_null category_id]} {
    set temp_category_id $category_id
    set pass_cat $category_id
} else {
    set temp_category_id ""
    if {[info exists category_id]} {
	unset category_id
    }
}


set assignees_filter [pm::project::assignee_filter_select -status_id $status_id]

if {![empty_string_p $searchterm]} {

    if {[regexp {([0-9]+)} $searchterm match query_digits]} {
        set search_term_where " (upper(p.title) like upper('%$searchterm%')
 or p.item_id = :query_digits) "
    } else {
        set search_term_where " upper(p.title) like upper('%$searchterm%')"
    }
} else {
    set search_term_where ""
}

##############################################
# Filter for planned_end_date
if {[exists_and_not_null date_range] } {
    set start_range_f [lindex [split $date_range "/"] 0]
    set end_range_f [lindex [split $date_range "/"] 1]
    if {![empty_string_p $start_range_f] && ![empty_string_p $end_range_f]} {
	set p_range_where "to_char(p.planned_end_date,'YYYY-MM-DD') >= :start_range_f and
                       to_char(p.planned_end_date,'YYYY-MM-DD') <= :end_range_f"
    } else {
	if {![empty_string_p $start_range_f] } {
	    set p_range_where "to_char(p.planned_end_date,'YYYY-MM-DD') >= :start_range_f"
	} elseif { ![empty_string_p $end_range_f] } {
	    set p_range_where "to_char(p.planned_end_date,'YYYY-MM-DD') <= :end_range_f"
	} else {
	    set p_range_where ""
	}
    }
} else {
    set p_range_where ""
}

##############################################

# Get url of the contacts package if it has been mounted for the links on the index page.
# set contacts_url [util_memoize [list site_node::get_package_url -package_key contacts]]
set contacts_url "/contacts/"
if {[empty_string_p $contacts_url]} {
    set contact_column "@projects.customer_name@"
} else {
    set contact_column "<a href=\"${contacts_url}@projects.customer_id@\">@projects.customer_name@</a>"
}

# Store project names and all other project individuel data
set contact_coloum "fff" 

incr c_row

# Get the rows to display

if {$bulk_p == 1} {
    set row_list "checkbox {}\nproject_name {}\n" 
    set bulk_actions [list "[_ project-manager.Close]" "@{base_url}/bulk-close" "[_ project-manager.Close_project]" ] 
} else {
    set row_list "project_name {}\n"     
    set bulk_actions [list]
}

foreach element $elements {
    append row_list "$element {}\n"
}

if {$actions_p == 1} {

    if {[info exists portal_info_name]} {
	
	set actions [list "$portal_info_name" "$portal_info_url" "$portal_info_name" "[_ project-manager.Add_project]" "[export_vars -base "[lindex $base_url 0]add-edit" -url {customer_id}]" "[_ project-manager.Add_project]" "[_ project-manager.Customers]" "[site_node::get_package_url -package_key contacts]" "[_ project-manager.View_customers]" ] 
    
    } else {

	set actions [list  "[_ project-manager.Add_project]" "[export_vars -base "[lindex $base_url 0]add-edit" -url {customer_id}]" "[_ project-manager.Add_project]" "[_ project-manager.Customers]" "[site_node::get_package_url -package_key contacts]" "[_ project-manager.View_customers]" ] 
    
    }
    
} else {
    set actions [list]
}

template::list::create \
    -name "projects" \
    -multirow projects \
    -selected_format $format \
    -key project_item_id \
    -elements {
        project_name {
            label "[_ project-manager.Project_name]"
            link_url_col item_url
            link_html { title "[_ project-manager.lt_View_this_project_ver]" }
        }
        customer_name {
            label "[_ project-manager.Customer]"
            display_template "
<if @projects.customer_id@ not nil>$contact_column</if><else>@projects.customer_name@</else>
"
        }
        earliest_finish_date {
            label "[_ project-manager.Earliest_finish]"
            display_template "<if @projects.days_to_earliest_finish@ gt 1>@projects.earliest_finish_date@</if><else><font color=\"green\">@projects.earliest_finish_date@</font></else>"
        }
        latest_finish_date {
            label "[_ project-manager.Latest_Finish]"
            display_template "<if @projects.days_to_latest_finish@ gt 1>@projects.latest_finish_date@</if><else><font color=\"red\">@projects.latest_finish_date@</font></else>"
        }
        actual_hours_completed {
            label "[_ project-manager.Hours_completed]"
            display_template "@projects.actual_hours_completed@/@projects.estimated_hours_total@"
        }
        category_id {
            display_template "<group column=\"project_item_id\"></group>"
        }
	status_id {
	    label "[_ project-manager.Status_1]"
	    display_template "<if @projects.status_id@ eq 2>#project-manager.Closed#</if><else>#project-manager.Open#</else>"
	}
	planned_end_date {
	    label "[_ project-manager.Planned_end_date]"
            display_template "@projects.planned_end_date_lc@"
	}
    } \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -sub_class {
        narrow
    } \
    -filters {
        searchterm {
            label "[_ project-manager.Search_1]"
            where_clause {$search_term_where}
        }
	date_range {
	    label "[_ project-manager.Planned_end_date]"
	    where_clause {$p_range_where}
	}
        status_id {
            label "[_ project-manager.Status_1]" 
            values {[pm::status::project_status_select]}
            where_clause {$status_where_clause}
        }
        assignee_id {
            label "[_ project-manager.Assignee]"
            values {$assignees_filter}
            where_clause {pa.party_id = :assignee_id}
        }
        category_id {
            label Categories
            where_clause {c.category_id = [join [value_if_exists category_id] ","]}
        }
    } \
    -formats {
        normal {
            label "[_ project-manager.Table]"
            layout table
            row $row_list
        } 
        csv {
            label "[_ project-manager.CSV]"
            output csv
            page_size 0
            row $row_list
        } 
    } \
    -html {
        width 100%
    }

if {[lsearch -exact $row_list project_status] == -1} {
    set project_status_p 0
} else {
    set project_status_p 1
}

set count 0
set more_p 0
set fmt "[lc_get d_fmt] %X"

db_multirow -extend { item_url customer_name planned_end_date_lc project_status } "projects" project_folders {
} {
    incr count
    if {[string equal $count 26] } {
	set more_p 1
	# break
    }
    set _base_url [site_node::get_url_from_object_id -object_id $package_id]
    
    if {![empty_string_p $_base_url]} {
        set base_url $_base_url
    }

    set planned_end_date_lc [lc_time_fmt $planned_end_date $fmt]

    set item_url [export_vars -base "${base_url}one" {project_item_id}]
    # root CR folder
    #set root_folder [pm::util::get_root_folder -package_id $package_id]
    set community_id [dotlrn_community::get_community_id_from_url \
                          -url $base_url \
                         ]

    if {![empty_string_p $community_id]} {
        
        set community_name [dotlrn_community::get_community_name  $community_id]
        
        set portal_info_name "Project: $community_name" 
        set portal_info_url  [lindex $base_url 0] 
        
    }
    set customer_name [contact::name -party_id $customer_id]
    set project_status [pm::project::get_status_description -project_item_id $project_item_id]

    if {!$project_status_p} {
	set project_name "[string index [lang::util::localize $project_status] 0]-$project_name"
    }
}



ad_return_template
# ------------------------- END OF FILE ------------------------- #
