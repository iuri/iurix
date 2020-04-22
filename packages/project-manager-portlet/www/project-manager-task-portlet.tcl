ad_page_contract {
} {
    {tasks_orderby "end_date,asc"}
    {watcher_p 0}
    {page_num 0}
    {is_observer_filter "m"}
    {filter_party_id ""}
    {filter_group_id ""}
} 
# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]
set user_id [ad_conn user_id]
#------------------------
# Check if the project will be handled on daily basis or will show hours and minutes
#------------------------

set fmt "%x %r"
if { $daily_p } {
    set fmt "%x"
} 

array set config $cf

set community_id [dotlrn_community::get_community_id_from_url]

##############
# should be callback here
##############
set group_id [group::get_id -group_name Freelancer]

set tasks_portlet [parameter::get_from_package_key -package_key project-manager-portlet -parameter TasksPortlet]

if {![empty_string_p $community_id]} {

    # We are in a community, so we can (savely?) assume that project-manager is mounted under project-manager
    set base_url "project-manager/"
    set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $community_id]
    set party_id ""
    set elements "project_item_id task_item_id title role end_date"
} else {
    
    # We assume that project-manager is always mounted under /dotlrn/project-manager if we deal with .LRN
    set elements "project_item_id task_item_id title priority end_date estimated_hours_work_max last_name"
    set party_id [ad_conn user_id]
    set base_url "/dotlrn/project-manager/"
    set pm_package_id ""
}
