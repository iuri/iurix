# Possible
# party_id
# role_id

set required_param_list [list]
set optional_param_list [list searchterm status_id page bulk_p actions_p base_url is_observer_p]
set optional_unset_list [list party_id role_id project_item_id instance_id]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

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

if ![info exists page_size] {
    set page_size 25
}

if ![info exists display_mode] {
    set display_mode "all"
}

if ![info exists format] {
    set format "normal"
}

if ![info exists package_id] {
    set package_id [ad_conn package_id]
}

if { $is_observer_p == "f" } {
    set extra_query "and pr.is_observer_p = :is_observer_p"
} else {
    set extra_query ""
}

# ---------------------------------------------------------------

# Hide finished tasks. This should be added as a filter, but I did not
# have time to look it up in the howto. <openacs@sussdorff.de>

set hide_done_tasks_p [parameter::get \
			   -parameter "HideDoneTaskP" -default "1"]

if {$hide_done_tasks_p} {
    set done_clause "and tr.percent_complete < 100"
} else {
    set done_clause ""
}

# Deal with the fact that we might work with days instead of hours

if {[parameter::get \
	 -parameter "UseDayInsteadOfHour" -default "t"] == "t"} {
    set days_string "days"
} else {
    set days_string "hours"
}

set exporting_vars {status_id party_id }
set hidden_vars [export_vars \
		     -form $exporting_vars]

# how to get back here

set return_url [ad_return_url \
		    -qualified]
set logger_url [pm::util::logger_url]

set contacts_url [util_memoize [list site_node::get_package_url \
				    -package_key contacts]]


# set up context bar

set context [list "[_ project-manager.Tasks]"]

# Get the currently available Status

set status_list [db_list_of_lists get_status_values "select description, status_id from pm_task_status order by status_type desc, description"]

# the unique identifier for this package

set package_id [ad_conn package_id]
set user_id [ad_maybe_redirect_for_registration]

# status defaults to open

if {![exists_and_not_null status_id]} {
    set status_where_clause ""
} else {
    set status_where_clause {ts.status = :status_id}
}

# permissions

permission::require_permission -party_id $user_id -object_id $package_id -privilege read

# Tasks, using list-builder ---------------------------------

if {![empty_string_p $searchterm]} {

    # if we're searching, we disregard who we were searching for.

    if {[info exists party_id]} {
        unset party_id
    } 

    if {[regexp {([0-9]+)} $searchterm match query_digits]} {
        set search_term_where " (upper(t.title) like upper('%$searchterm%')
 or t.item_id = :query_digits) "
    } else {
        set search_term_where " upper(t.title) like upper('%$searchterm%')"
    }
} else {
    set search_term_where ""
}

# Get the rows to display

if {![exists_and_not_null elements]} {
    set elements [list task_item_id title slack_time role latest_start latest_finish planned_end_date status_type remaining worked project_item_id percent_complete edit_url]
}

set filters [list \
		 searchterm [list \
				 label "[_ project-manager.Search_1]" \
				 where_clause {$search_term_where}
			    ] \
		 status_id [list \
				label "[_ project-manager.Status_1]" \
				values {$status_list} \
				where_clause "$status_where_clause"
			   ] \
		 project_item_id [list \
				      label "[_ project-manager.Project_1]" \
				      values {[pm::project::get_list_of_open]} \
				      where_clause "t.parent_id = :project_item_id"
				 ] \
		 instance_id [list \
				  where_clause "o.package_id = :instance_id"
			     ] \
		]




foreach element $elements {

    # Special treatement for days / hours

    if {$element == "remaining"} {
	set element "${days_string}_remaining"
    }
    if {$element == "worked"} {
	set element "actual_${days_string}_worked"
    }


##### maltes: Why on earth do we need this query?
    # We need to filter by the user if a party_id is given
#    if {[exists_and_not_null party_id]} {
#	set party_where_clause "and 1 = ( select 1 from dual where t.party_id = :user_id or :user_id in ( 
#                                        select object_id_two from acs_rels where object_id_one = t.party_id and rel_type = 'membership_rel'))"
#    } else {
	set party_where_clause ""
#    }


    # If we display the items of a single user, show the role. Otherwise
    # show all players.

    if {$element == "role"} {
	if {[exists_and_not_null party_id]
	    && $user_id == $party_id} {
	    set element "role"
	    lappend filters [list role_id [list \
					       label "[_ project-manager.Roles]" \
					       values {[pm::role::select_list_filter]} \
					       where_clause "ta.role_id = :role_id"
					  ]
			    ]
	} else {
	    set element "party_id"
	    lappend filters [list party_id [list \
						label "[_ project-manager.People]" \
						values "[pm::task::assignee_filter_select \
-status_id $status_id]" \
						where_clause ""
					   ]
			    ]
	}
    }
    append row_list "$element {}\n"
}

if {$bulk_p == 1} {
    set bulk_actions [list "[_ project-manager.Edit_tasks]" "${base_url}task-add-edit" "[_ project-manager.Edit_multiple_tasks]"]
    set bulk_action_export_vars [list [list return_url]]
} else {
    set bulk_actions [list]
    set bulk_action_export_vars [list]
}

if {$actions_p == 1} {
    set actions [list "[_ project-manager.Add_task]" [export_vars \
							  -base "${base_url}task-select-project" {return_url}] "[_ project-manager.Add_a_task]"]
} else {
    set actions [list]
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -key task_item_id \
    -selected_format $format \
    -elements {
	task_item_id {
	    label "[_ project-manager.number]"
	    link_url_col item_url
	    link_html {title "[_ project-manager.lt_View_this_project_ver]" }
	    display_template {<a href="@tasks.base_url@@tasks.item_url@">@tasks.task_item_id@</a>}
	}
        status_type {
            label "[_ project-manager.Done_1]"
            display_template {<a href="@tasks.task_close_url@"><if @tasks.status_type@ eq c><img border="0" src="/resources/checkboxchecked.gif" /></if><else><img border="0" src="/resources/checkbox.gif" /></else></a>
            }
        }
	title {
	    label "[_ project-manager.Subject_1]"
	    display_template {<if @tasks.is_observer_p@ eq "f"><font color="green">@tasks.title@</font></if><else>@tasks.title@</else>}
	}
        parent_task_id {
            label "[_ project-manager.Dep]"
            display_template {<a href="@tasks.base_url@task-one?task_id=@tasks.parent_task_id@">@tasks.parent_task_id@</a>
            }
        }
        priority {
            label "[_ project-manager.Priority_1]"
            display_template {
		@tasks.priority@
            }
        }
	slack_time {
	    label "[_ project-manager.Slack_1]"
	    display_template "<if @tasks.slack_time@ gt 1>@tasks.slack_time@</if><else><font color=\"red\">@tasks.slack_time@</font></else>"
	}
        party_id {
            label "[_ project-manager.Who]"
            display_template {<group column="task_item_id"> <if @tasks.party_id@ eq @tasks.my_user_id@> <span class="selected"> </if> <if @tasks.is_lead_p@><i></if> <a href="@tasks.base_url@@tasks.user_url@">@tasks.name@</a> <if @tasks.is_lead_p@></i></if> <if @tasks.party_id@ eq @tasks.my_user_id@> </span> </if> <br> </group>
            }
	}
	role {
	    label "[_ project-manager.Role]"
	}
        earliest_start {
            label "[_ project-manager.Earliest_Start]"
            display_template "<if @tasks.days_to_earliest_start@ gt 1 or @tasks.status_type@ ne o>@tasks.earliest_start_pretty@</if><else><font color=\"00ff00\">@tasks.earliest_start_pretty@</font></else>"
        }
        earliest_finish {
            label "[_ project-manager.Earliest_Finish]"
            display_template "<if @tasks.days_to_earliest_finish@ gt 1 or @tasks.status_type@ ne o>@tasks.earliest_finish_pretty@</if><else><font color=\"00ff00\">@tasks.earliest_finish_pretty@</font></else>"
        }
        latest_start {
            label "[_ project-manager.Latest_Start]"
            display_template "<if @tasks.days_to_latest_start@ gt 1 or @tasks.status_type@ ne o>@tasks.latest_start_pretty@</if><else><font color=\"red\">@tasks.latest_start_pretty@</font></else>"
        }
        latest_finish {
            label "[_ project-manager.Latest_Finish]"
            display_template "<if @tasks.days_to_latest_finish@ gt 1 or @tasks.status_type@ ne o>@tasks.latest_finish_pretty@</if><else><font color=\"red\">@tasks.latest_finish_pretty@</font></else>"
        }
	end_date {
	    label "[_ project-manager.Deadline]"
            display_template "<if @tasks.days_to_end_date@ gt 1 or @tasks.status_type@ ne o>@tasks.end_date_pretty@</if><else><font color=\"red\">@tasks.end_date_pretty@</font></else>"
	}
	status {
	    label "[_ project-manager.Status_1]"
	}
	days_remaining {
	    label "[_ project-manager.Days_work]"
	    html {
		align right
	    }
	}
	hours_remaining {
	    label "[_ project-manager.Hours_remaining]"
	    html {
		align right
	    }
	}
	actual_days_worked {
	    label "[_ project-manager.Days_worked]"
	    html {
		align right
	    }
	}
	actual_hours_worked {
	    label "[_ project-manager.Hours_worked]"
	    html {
		align right
	    }
	}
	project_item_id {
	    label "[_ project-manager.Project_1]"
	    display_template {<a href="@tasks.project_url@">@tasks.project_name@</a>}
	    hide_p {[ad_decode [exists_and_not_null project_item_id] 1 1 0]}
	}
	edit_url {
	    display_template {<a href="@tasks.base_url@@tasks.edit_url@">E</a>}
	}
	percent_complete {
	    label "[_ project-manager.Percent_complete]"
	}
        last_name {
            label "[_ project-manager.Who]"
            display_template {<group column="task_item_id"> <if @tasks.party_id@ eq @tasks.my_user_id@> <span class="selected"> </if> <if @tasks.is_lead_p@><i></if>
		@tasks.name@ <if @tasks.is_lead_p@></i></if> <if @tasks.party_id@ eq @tasks.my_user_id@> </span> </if> <br> </group>
            }
	}
    } \
    -sub_class {
	narrow
    } \
    -filters $filters \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars $bulk_action_export_vars \
    -html {
	width 100%
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
    }


set count 0
set more_p 0

# We ge the package_id of the pm instance to get the value of the parameter

set pm_package_id [dotlrn_community::get_package_id_from_package_key \
		       -package_key "project-manager" \
		       -community_id [dotlrn_community::get_community_id]]

set assign_group_p [parameter::get -parameter "AssignGroupP" -default 0 -package_id $pm_package_id]
set user_instead_full_p [parameter::get -parameter "UsernameInsteadofFullnameP" -default "f" -package_id $pm_package_id]


db_multirow -extend {item_url earliest_start_pretty earliest_finish_pretty end_date_pretty latest_start_pretty latest_finish_pretty slack_time edit_url hours_remaining days_remaining actual_days_worked my_user_id user_url base_url task_close_url project_url name} tasks tasks {} {
    
    if { $assign_group_p } {
        # We are going to show all asignees including groups
	if { $user_instead_full_p } {
            set name [db_string get_assignee_name { } -default ""]
            if { [empty_string_p $name] } {
                set name [group::title -group_id $party_id]
            }
        } else {
	    if { [catch {set name [person::name -person_id $party_id] } err] } {
		# person::name give us an error so its probably a group so we get
		# the title
		set name [group::title -group_id $party_id]
	    }
	}
    } else {
	if { $user_instead_full_p } {
            set name [db_string get_assignee_name {  } -default ""]
            if { [empty_string_p $name] } {
                continue
            }
        } else {
	    if { [catch {set name [person::name -person_id $party_id] } err] } {
		# person::name give us an error so its probably a group, here we don't want
		# to show any group so we just continue the multirow
		continue
	    }
	}
    }


    incr count
    if { [string equal $count 26] } {
	set more_p 1
	break
    }

    set item_url [export_vars \
		      -base "task-one" {{task_id $task_item_id}}]

    set edit_url [export_vars \
		      -base "task-add-edit" {{task_id $task_item_id} project_item_id return_url}]

    if {[parameter::get -parameter "UseDayInsteadOfHour"] == "f"} {
	set fmt "%x %X"
    } else {
	set fmt "%x"
    }

    set earliest_start_pretty [lc_time_fmt $earliest_start $fmt]
    set earliest_finish_pretty [lc_time_fmt $earliest_finish $fmt]
    set latest_start_pretty [lc_time_fmt $latest_start $fmt]
    set latest_finish_pretty [lc_time_fmt $latest_finish $fmt]
    set end_date_pretty [lc_time_fmt $end_date $fmt]

    if {[exists_and_not_null earliest_start_j]} {
	set slack_time [pm::task::slack_time \
			    -earliest_start_j $earliest_start_j \
			    -today_j $today_j \
			    -latest_start_j $latest_start_j]
    } else {
	set slack_time "[_ project-manager.na]"
    }

    if {![exists_and_not_null percent_complete]} {
	set percent_complete 0
    }

    set hours_remaining \
	[pm::task::hours_remaining \
	     -estimated_hours_work $estimated_hours_work \
	     -estimated_hours_work_min $estimated_hours_work_min \
	     -estimated_hours_work_max $estimated_hours_work_max \
	     -percent_complete $percent_complete]

    set days_remaining \
	[pm::task::days_remaining \
	     -estimated_hours_work $estimated_hours_work \
	     -estimated_hours_work_min $estimated_hours_work_min \
	     -estimated_hours_work_max $estimated_hours_work_max \
	     -percent_complete $percent_complete]

    if {[exists_and_not_null actual_hours_worked]} {
	set actual_days_worked [expr $actual_hours_worked / 24]
    } else {
	set actual_days_worked ""
    }
    set my_user_id $user_id
    set user_url [export_vars \
		      -base "${contacts_url}contact" {{party_id $party_id}}]

    acs_object::get -object_id $task_item_id -array task_array
    set base_url [lindex [site_node::get_url_from_object_id -object_id $task_array(package_id)] 0]
    set task_close_url [export_vars -base "${base_url}task-close" -url {task_item_id return_url}]
    set project_url [export_vars -base "${base_url}one" {project_item_id $tasks(project_item_id)}]
}

# ------------------------- END OF FILE -------------------------
